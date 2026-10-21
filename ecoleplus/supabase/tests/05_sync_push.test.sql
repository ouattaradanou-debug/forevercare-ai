-- Phase 1 : synchronisation (envoi) — règles de conflit, idempotence, droits.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
begin;
select plan(19);
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);

-- Création hors ligne d'une année, envoyée deux fois (renvoi après coupure) : pas de doublon.
create temp table r1 as select public.sync_push($$[
  {"change_id": 1, "table": "school_years", "row": {"id": "2a000000-0000-4000-8000-000000002026",
   "school_id": "10000000-0000-4000-8000-000000000001", "label": "2026-2027",
   "updated_at": "2026-09-01T10:00:00Z", "created_at": "2026-09-01T10:00:00Z"}}]$$::jsonb) as r;
select is((select r -> 0 ->> 'status' from r1), 'ok', 'création : acceptée');
select is((select public.sync_push($$[
  {"change_id": 1, "table": "school_years", "row": {"id": "2a000000-0000-4000-8000-000000002026",
   "school_id": "10000000-0000-4000-8000-000000000001", "label": "2026-2027",
   "updated_at": "2026-09-01T10:00:00Z", "created_at": "2026-09-01T10:00:00Z"}}]$$::jsonb) -> 0 ->> 'status'),
  'ok', 'renvoi identique : accepté sans erreur');
select is((select count(*)::int from public.school_years where label = '2026-2027'), 1, 'aucun doublon après renvoi');
select is((select created_by::text from public.school_years where label = '2026-2027'),
  'a0000000-0000-4000-8000-000000000001', 'auteur fixé par le serveur');

-- Dernière modification gagne
select is((select public.sync_push($$[
  {"change_id": 2, "table": "admin_headers", "row": {"id": null, "school_id": "x", "updated_at": "2026-09-01T10:00:00Z"}}]$$::jsonb) -> 0 ->> 'status'),
  'rejete', 'changement mal formé : rejeté proprement');
create temp table h as select id from public.admin_headers where school_year_id = '20000000-0000-4000-8000-000000002025';
select is((select public.sync_push(jsonb_build_array(jsonb_build_object('change_id', 3, 'table', 'admin_headers',
  'row', jsonb_build_object('id', (select id from h), 'ceb', 'CEB modifiée (récente)',
                            'updated_at', (now() + interval '1 minute')::text)))) -> 0 ->> 'status'),
  'ok', 'modification plus récente : appliquée');
select is((select public.sync_push(jsonb_build_array(jsonb_build_object('change_id', 4, 'table', 'admin_headers',
  'row', jsonb_build_object('id', (select id from h), 'ceb', 'CEB modifiée (ancienne)',
                            'updated_at', (now() - interval '1 hour')::text)))) -> 0 ->> 'status'),
  'ignore_plus_ancien', 'modification plus ancienne (autre téléphone resté hors ligne) : ignorée');
select is((select ceb from public.admin_headers where id = (select id from h)), 'CEB modifiée (récente)',
  'la valeur la plus récente est conservée');
select is((select ministry from public.admin_headers where id = (select id from h)), 'MINISTÈRE TEST',
  'les colonnes non envoyées ne sont pas effacées');
select is((select count(*)::int from public.sync_conflicts
            where table_name = 'admin_headers' and loser ->> 'ceb' = 'CEB modifiée (ancienne)'), 1,
  'la version perdante est tracée');

-- Clé composée (options) et lot mixte : une erreur ne bloque pas les autres changements.
create temp table r2 as select public.sync_push(jsonb_build_array(
  jsonb_build_object('change_id', 5, 'table', 'payments', 'row',
    jsonb_build_object('id', '70000000-0000-4000-8000-00000000000f', 'updated_at', now()::text)),
  jsonb_build_object('change_id', 6, 'table', 'school_modules', 'row',
    jsonb_build_object('school_id', '10000000-0000-4000-8000-000000000001', 'module_key', 'cantine',
                       'enabled', true, 'updated_at', (now() + interval '1 minute')::text)))) as r;
select is((select r -> 0 ->> 'status' from r2), 'rejete', 'table non synchronisable : rejetée');
select is((select r -> 1 ->> 'status' from r2), 'ok', 'le changement suivant du lot est quand même appliqué');
select is((select enabled from public.school_modules where module_key = 'cantine'
            and school_id = '10000000-0000-4000-8000-000000000001'), true, 'option activée par synchronisation');

-- Horloge du téléphone très en avance : refus explicite.
select is((select public.sync_push(jsonb_build_array(jsonb_build_object('change_id', 7, 'table', 'schools',
  'row', jsonb_build_object('id', '10000000-0000-4000-8000-000000000001', 'phone', '0',
                            'updated_at', (now() + interval '1 day')::text)))) -> 0 ->> 'code'),
  'P0002', 'date du téléphone dans le futur : refusée');

-- La fiche école elle-même (pas de colonne school_id) : modification tracée.
select is((select public.sync_push(jsonb_build_array(jsonb_build_object('change_id', 9, 'table', 'schools',
  'row', jsonb_build_object('id', '10000000-0000-4000-8000-000000000001', 'commune', 'Commune synchronisée',
                            'updated_at', (now() + interval '1 minute')::text)))) -> 0 ->> 'status'),
  'ok', 'modification de la fiche école par synchronisation : acceptée');
select is((select count(*)::int from public.sync_conflicts where table_name = 'schools'), 1,
  'l''ancienne version de la fiche école est tracée');

-- Un enseignant ne peut rien imposer par la synchronisation.
select set_config('request.jwt.claims', :'ens1', true);
create temp table r3 as select public.sync_push(jsonb_build_array(jsonb_build_object('change_id', 8, 'table', 'schools',
  'row', jsonb_build_object('id', '10000000-0000-4000-8000-000000000001', 'name', 'Piratée',
                            'updated_at', (now() + interval '2 minutes')::text)))) as r;
select is((select r -> 0 ->> 'status' from r3), 'rejete', 'enseignant : modification de l''école rejetée');
select is((select r -> 0 ->> 'code' from r3), '42501', 'motif : droits insuffisants');
reset role;
select is((select name from public.schools where id = '10000000-0000-4000-8000-000000000001'), 'École Test',
  'le nom de l''école est inchangé');

select * from finish();
rollback;
