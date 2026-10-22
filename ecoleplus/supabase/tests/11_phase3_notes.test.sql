-- Phase 3 : droits sur les notes, barème, coefficients, résultats annuels.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set sec  '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
\set dir9 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(14);

set local role authenticated;
-- Enseignant Un (CM1)
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.subjects), 5, 'enseignant : lit les matières de l''école');
select is((select count(*)::int from public.class_subjects), 5, 'enseignant : lit les coefficients de SA classe');
select is((public.sync_push($$[{"change_id": 1, "table": "grades", "row": {
  "id": "9a000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "assessment_id": "f0000000-0000-4000-8000-000000000001", "student_id": "d0000000-0000-4000-8000-000000000003",
  "subject_id": "e0000000-0000-4000-8000-000000000005", "score": 8.5, "status": "note",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'enseignant : note saisie pour un élève de sa classe');
select is((public.sync_push($$[{"change_id": 2, "table": "grades", "row": {
  "id": "9a000000-0000-4000-8000-000000000002", "school_id": "10000000-0000-4000-8000-000000000001",
  "assessment_id": "f0000000-0000-4000-8000-000000000001", "student_id": "d0000000-0000-4000-8000-000000000003",
  "subject_id": "e0000000-0000-4000-8000-000000000004", "score": 11, "status": "note",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'message', 'Note hors barème : 11 sur 10.',
  'note hors barème refusée avec un message clair');
select is((public.sync_push($$[{"change_id": 3, "table": "grades", "row": {
  "id": "9a000000-0000-4000-8000-000000000003", "school_id": "10000000-0000-4000-8000-000000000001",
  "assessment_id": "f0000000-0000-4000-8000-000000000002", "student_id": "d0000000-0000-4000-8000-000000000005",
  "subject_id": "e0000000-0000-4000-8000-000000000001", "score": 3, "status": "note",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'enseignant : refus de noter un élève d''une autre classe');
select is((public.sync_push(jsonb_build_array(jsonb_build_object('change_id', 4, 'table', 'class_subjects',
  'row', jsonb_build_object('id', (select id from public.class_subjects limit 1), 'coefficient', 5,
  'updated_at', now() + interval '1 minute'))))) -> 0 ->> 'status', 'rejete',
  'enseignant : ne peut pas changer un coefficient');
select is((public.sync_push($$[{"change_id": 5, "table": "assessments", "row": {
  "id": "9b000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "class_id": "c0000000-0000-4000-8000-000000000002", "school_year_id": "20000000-0000-4000-8000-000000002025",
  "label": "Composition 2", "sequence": 2, "max_score": 10, "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb))
  -> 0 ->> 'status', 'ok', 'enseignant : crée une composition pour sa classe');
select is((select count(*)::int from public.annual_results), 0,
  'enseignant : ne voit pas le résultat annuel d''une élève qui n''est plus dans sa classe');

-- Enseignant Deux (CM2) : ne voit pas les notes du CM1.
select set_config('request.jwt.claims', :'ens2', true);
select is((select count(*)::int from public.grades
            where assessment_id = 'f0000000-0000-4000-8000-000000000001'), 0,
  'autre enseignant : aucune note du CM1');
select is((select count(*)::int from public.grades), 8, 'autre enseignant : les notes de sa classe (CM2)');

-- Secrétaire (droit « finances » seulement) : aucune note.
select set_config('request.jwt.claims', :'sec', true);
select is((select count(*)::int from public.grades), 0, 'délégué sans droit : aucune note');

-- Autre école : rien.
select set_config('request.jwt.claims', :'dir9', true);
select is((select count(*)::int from public.grades), 0, 'autre école : aucune note');

-- Directeur : tout, et enregistre les résultats annuels.
select set_config('request.jwt.claims', :'dir1', true);
select is((select count(*)::int from public.grades), 23, 'directeur : toutes les notes de l''école');
select is((public.sync_push($$[{"change_id": 6, "table": "annual_results", "row": {
  "id": "9c000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "student_id": "d0000000-0000-4000-8000-000000000001", "school_year_id": "20000000-0000-4000-8000-000000002025",
  "class_id": "c0000000-0000-4000-8000-000000000002", "level_code": "CM1", "general_average": 7,
  "rank": 1, "rank_ex_aequo": false, "class_size": 4, "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb))
  -> 0 ->> 'status', 'ok', 'directeur : moyenne annuelle, rang et effectif enregistrés');

select * from finish();
rollback;
