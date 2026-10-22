-- Phase 2 : registres réservés, numéro d'ordre du registre matricule.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set sec  '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
begin;
select plan(23);

-- ----------------------- Registres réservés --------------------------
set local role authenticated;
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.students), 4, 'enseignant : voit les 4 élèves de sa classe');
select is((select count(*)::int from public.student_registry), 0,
  'enseignant : aucun accès au registre matricule ni à la fiche de scolarité');
select is((select count(*)::int from public.teacher_diplomas
            where teacher_id = 'b0000000-0000-4000-8000-000000000002'), 0,
  'enseignant : ne voit pas les diplômes d''un collègue');
select is((select count(*)::int from public.teacher_diplomas
            where teacher_id = 'b0000000-0000-4000-8000-000000000001'), 2,
  'enseignant : voit ses propres diplômes');
select is((public.sync_push($$[{"change_id": 1, "table": "student_registry", "row": {
  "id": "d0000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "registry_observations": "x", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status',
  'rejete', 'enseignant : écriture dans le registre refusée');
select is((public.sync_push($$[{"change_id": 2, "table": "teachers", "row": {
  "id": "b0000000-0000-4000-8000-000000000009", "school_id": "10000000-0000-4000-8000-000000000001",
  "last_name": "X", "first_names": "Y", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status',
  'rejete', 'enseignant : création d''une fiche enseignant refusée');

select set_config('request.jwt.claims', :'sec', true);
select is((select count(*)::int from public.student_registry), 0,
  'délégué sans droit « registres » : aucun accès au registre');
select is((select count(*)::int from public.teachers), 0,
  'délégué sans droit « registres » : aucune fiche du personnel');

select set_config('request.jwt.claims', :'dir1', true);
select is((select origin_school from public.student_registry
            where id = 'd0000000-0000-4000-8000-000000000008'), 'École Ancienne Test',
  'directeur : lit le registre (venant de)');
select is((select count(*)::int from public.teacher_postings), 2, 'directeur : communes successives (B3 col. 8)');

-- ---------------------- Numéro d'ordre (B2) --------------------------
select is((select max(registry_number) from public.students
            where school_id = '10000000-0000-4000-8000-000000000001'), 12,
  'École Test : 12 élèves numérotés de 1 à 12');
-- Deux téléphones hors ligne créent chacun un élève, puis synchronisent.
select is((public.sync_push($$[{"change_id": 10, "table": "students", "row": {
  "id": "d0000000-0000-4000-8000-0000000000a1", "school_id": "10000000-0000-4000-8000-000000000001",
  "last_name": "NOUVEAU", "first_names": "Téléphone A", "registry_provisional": "P-A-0001",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok', 'téléphone A : élève envoyé');
select is((public.sync_push($$[{"change_id": 11, "table": "students", "row": {
  "id": "d0000000-0000-4000-8000-0000000000b1", "school_id": "10000000-0000-4000-8000-000000000001",
  "last_name": "NOUVEAU", "first_names": "Téléphone B", "registry_provisional": "P-B-0001",
  "updated_at": "2026-10-01T08:01:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok', 'téléphone B : élève envoyé');
select is((select array_agg(registry_number order by registry_number) from public.students
            where id in ('d0000000-0000-4000-8000-0000000000a1', 'd0000000-0000-4000-8000-0000000000b1')),
  array[13, 14], 'numéros 13 et 14 : uniques et à la suite');
-- Le téléphone A renvoie la fiche modifiée sans avoir encore reçu son numéro.
select is((public.sync_push($$[{"change_id": 12, "table": "students", "row": {
  "id": "d0000000-0000-4000-8000-0000000000a1", "school_id": "10000000-0000-4000-8000-000000000001",
  "last_name": "NOUVEAU", "first_names": "Téléphone A (corrigé)", "registry_number": null,
  "updated_at": "2026-10-01T09:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok', 'modification sans numéro acceptée');
select is((select registry_number from public.students where id = 'd0000000-0000-4000-8000-0000000000a1'), 13,
  'le numéro reçu n''est pas effacé');
select is((public.sync_push($$[{"change_id": 13, "table": "students", "row": {
  "id": "d0000000-0000-4000-8000-0000000000a1", "school_id": "10000000-0000-4000-8000-000000000001",
  "last_name": "NOUVEAU", "first_names": "Téléphone A", "registry_number": 99,
  "updated_at": "2026-10-01T10:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'un numéro attribué ne peut pas être changé');
-- Archivage (suppression logique) : le numéro n'est jamais réutilisé.
update public.students set archived_at = now(), deleted_at = now()
 where id = 'd0000000-0000-4000-8000-0000000000b1';
insert into public.students (id, school_id, last_name, first_names)
values ('d0000000-0000-4000-8000-0000000000c1', '10000000-0000-4000-8000-000000000001', 'APRÈS', 'Archivage');
select is((select registry_number from public.students where id = 'd0000000-0000-4000-8000-0000000000c1'), 15,
  'après archivage, le numéro suivant est 15 (le 14 n''est pas réutilisé)');
-- Reprise d'un registre papier : un numéro saisi fait avancer le compteur.
insert into public.students (id, school_id, last_name, first_names, registry_number)
values ('d0000000-0000-4000-8000-0000000000d1', '10000000-0000-4000-8000-000000000001', 'PAPIER', 'Ancien', 40);
insert into public.students (id, school_id, last_name, first_names)
values ('d0000000-0000-4000-8000-0000000000d2', '10000000-0000-4000-8000-000000000001', 'APRÈS', 'Papier');
select is((select registry_number from public.students where id = 'd0000000-0000-4000-8000-0000000000d2'), 41,
  'reprise du registre papier : le compteur repart après le plus grand numéro');
select throws_ok($$select app.next_counter('10000000-0000-4000-8000-000000000001', 'registre_matricule')$$,
  '42501', null, 'le compteur ne peut pas être avancé directement');

-- ---------------------- Formulaires officiels -------------------------
select set_config('request.jwt.claims', :'dir1', true);
select is((public.sync_push($$[{"change_id": 20, "table": "official_forms", "row": {
  "id": "f1000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "school_year_id": "20000000-0000-4000-8000-000000002025", "form_code": "B1",
  "reference_date": "2025-12-31", "signed_place": "Ville Test",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'directeur : paramètres de la fiche B1 enregistrés');
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.official_forms), 0, 'enseignant : aucun accès aux formulaires');
select is((public.sync_push($$[{"change_id": 21, "table": "official_forms", "row": {
  "id": "f1000000-0000-4000-8000-000000000002", "school_id": "10000000-0000-4000-8000-000000000001",
  "school_year_id": "20000000-0000-4000-8000-000000002025", "form_code": "B3",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'enseignant : création d''un formulaire refusée');

select * from finish();
rollback;
