-- Phase 5 : programme d'activités (B6), bilan (B7), versions verrouillées.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set sec  '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
begin;
select plan(18);

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select is((public.sync_push($$[{"change_id": 1, "table": "activity_objectives", "row": {
  "id": "61000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "school_year_id": "20000000-0000-4000-8000-000000002025", "order_no": 1,
  "label": "Gérer le courrier", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'directeur : objectif ajouté (même N° d''ordre qu''un autre : simple tri)');
select is((public.sync_push($$[{"change_id": 2, "table": "activity_lines", "row": {
  "id": "62000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "objective_id": "61000000-0000-4000-8000-000000000001", "sort_order": 1,
  "planned_activity": "Enregistrer le courrier", "deadline_text": "Toute l'année",
  "expected_result": "Courrier enregistré", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'directeur : activité ajoutée');
select is((select count(*)::int from public.audit_log where table_name in ('activity_objectives', 'activity_lines')
                                         and actor_id = 'a0000000-0000-4000-8000-000000000001'), 2,
  'programme : apparaît dans le journal d''activité');

-- Version finale du programme (B6) : instantané puis verrou.
select is((public.sync_push($$[{"change_id": 3, "table": "official_forms", "row": {
  "id": "63000000-0000-4000-8000-000000000006", "school_id": "10000000-0000-4000-8000-000000000001",
  "school_year_id": "20000000-0000-4000-8000-000000002025", "form_code": "B6",
  "status": "complet", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'formulaire B6 créé');
select is((public.sync_push($$[{"change_id": 4, "table": "form_versions", "row": {
  "id": "64000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "form_id": "63000000-0000-4000-8000-000000000006", "version_no": 1, "is_final": true,
  "snapshot": {"objectifs": []}, "updated_at": "2026-10-01T08:01:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'version finale 1 enregistrée');
select is((select created_by::text from public.form_versions where id = '64000000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-000000000001', 'version : auteur = la personne connectée');
select is((public.sync_push($$[{"change_id": 5, "table": "official_forms", "row": {
  "id": "63000000-0000-4000-8000-000000000006", "locked_version": 1,
  "updated_at": "2026-10-01T08:02:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'programme verrouillé (version 1)');

select is((public.sync_push($$[{"change_id": 6, "table": "activity_lines", "row": {
  "id": "62000000-0000-4000-8000-000000000001", "expected_result": "Autre chose",
  "updated_at": "2026-10-01T08:03:00Z"}}]$$::jsonb)) -> 0 ->> 'message',
  'Programme verrouillé (version finale) : touchez « Modifier » pour créer une nouvelle version.',
  'B6 verrouillé : résultats attendus inchangeables');
select is((public.sync_push($$[{"change_id": 7, "table": "activity_objectives", "row": {
  "id": "61000000-0000-4000-8000-000000000002", "school_id": "10000000-0000-4000-8000-000000000001",
  "school_year_id": "20000000-0000-4000-8000-000000002025", "order_no": 2,
  "label": "Rédiger les rapports", "updated_at": "2026-10-01T08:03:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'B6 verrouillé : aucun nouvel objectif');
select is((public.sync_push($$[{"change_id": 8, "table": "activity_lines", "row": {
  "id": "62000000-0000-4000-8000-000000000001", "achieved_result": "Courrier à jour", "success_rate": 90,
  "updated_at": "2026-10-01T08:04:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'B6 verrouillé : le bilan (résultats atteints, taux) reste modifiable');

-- Version finale du bilan (B7).
select is((public.sync_push($$[{"change_id": 9, "table": "official_forms", "row": {
  "id": "63000000-0000-4000-8000-000000000007", "school_id": "10000000-0000-4000-8000-000000000001",
  "school_year_id": "20000000-0000-4000-8000-000000002025", "form_code": "B7",
  "locked_version": 1, "updated_at": "2026-10-01T08:05:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'bilan verrouillé');
select is((public.sync_push($$[{"change_id": 10, "table": "activity_lines", "row": {
  "id": "62000000-0000-4000-8000-000000000001", "success_rate": 50,
  "updated_at": "2026-10-01T08:06:00Z"}}]$$::jsonb)) -> 0 ->> 'message',
  'Bilan verrouillé (version finale) : touchez « Modifier » pour créer une nouvelle version.',
  'B7 verrouillé : taux inchangeable');

-- « Modifier » : verrou levé, l'ancienne version reste.
select is((public.sync_push($$[{"change_id": 11, "table": "official_forms", "row": {
  "id": "63000000-0000-4000-8000-000000000006", "locked_version": null,
  "updated_at": "2026-10-01T08:07:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  '« Modifier » lève le verrou du programme');
select is((public.sync_push($$[{"change_id": 12, "table": "activity_lines", "row": {
  "id": "62000000-0000-4000-8000-000000000001", "expected_result": "Tout le courrier enregistré",
  "updated_at": "2026-10-01T08:08:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'programme de nouveau modifiable');
update public.form_versions set snapshot = '{}' where id = '64000000-0000-4000-8000-000000000001';
select is((select snapshot from public.form_versions where id = '64000000-0000-4000-8000-000000000001'),
  '{"objectifs": []}'::jsonb, 'version finale : jamais modifiée (l''ancienne version reste)');

select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.activity_lines), 0, 'enseignant : ne voit pas le programme');
select is((public.sync_push($$[{"change_id": 13, "table": "activity_objectives", "row": {
  "id": "61000000-0000-4000-8000-000000000003", "school_id": "10000000-0000-4000-8000-000000000001",
  "school_year_id": "20000000-0000-4000-8000-000000002025", "order_no": 3,
  "label": "Évaluer les enseignants", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'enseignant : ne modifie pas le programme');

-- Délégué « formulaires » : autorisé.
reset role;
insert into public.delegate_permissions (school_id, membership_id, permission_key) values
  ('10000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000004', 'formulaires');
set local role authenticated;
select set_config('request.jwt.claims', :'sec', true);
select is((public.sync_push($$[{"change_id": 14, "table": "activity_lines", "row": {
  "id": "62000000-0000-4000-8000-000000000002", "school_id": "10000000-0000-4000-8000-000000000001",
  "objective_id": "61000000-0000-4000-8000-000000000001", "sort_order": 2,
  "planned_activity": "Classer le courrier", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'délégué « formulaires » : ajoute une activité');

select * from finish();
rollback;
