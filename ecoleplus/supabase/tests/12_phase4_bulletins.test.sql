-- Phase 4 : bulletins (appréciations, observation, décision), modèle,
-- journal des fiches de scolarité.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set sec  '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
begin;
select plan(15);

set local role authenticated;
-- Enseignant Un (CM1) : appréciation pour un élève de sa classe ; la
-- décision qu'il envoie est ignorée.
select set_config('request.jwt.claims', :'ens1', true);
select is((public.sync_push($$[{"change_id": 1, "table": "report_cards", "row": {
  "id": "9d000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "student_id": "d0000000-0000-4000-8000-000000000003", "class_id": "c0000000-0000-4000-8000-000000000002",
  "assessment_id": "f0000000-0000-4000-8000-000000000001", "teacher_appreciation": "Bon trimestre",
  "decision": "Admise", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'enseignant : appréciation enregistrée pour sa classe');
select is((select decision from public.report_cards where id = '9d000000-0000-4000-8000-000000000001'),
  null, 'enseignant : la décision envoyée est ignorée');
select is((public.sync_push($$[{"change_id": 2, "table": "report_cards", "row": {
  "id": "9d000000-0000-4000-8000-000000000002", "school_id": "10000000-0000-4000-8000-000000000001",
  "student_id": "d0000000-0000-4000-8000-000000000005", "class_id": "c0000000-0000-4000-8000-000000000003",
  "teacher_appreciation": "x", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'enseignant : refus pour un élève d''une autre classe');
select is((public.sync_push($$[{"change_id": 3, "table": "report_templates", "row": {
  "id": "9e000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "name": "Mon modèle", "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'enseignant : ne peut pas changer le modèle de bulletin');
select is((public.sync_push($$[{"change_id": 4, "table": "scolarity_copy_log", "row": {
  "id": "9f000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "student_id": "d0000000-0000-4000-8000-000000000003", "is_certified_copy": true,
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'enseignant : aucune fiche de scolarité');

-- Directeur : observation et décision ; modèle ; copie conforme.
select set_config('request.jwt.claims', :'dir1', true);
select is((public.sync_push(jsonb_build_array(jsonb_build_object('change_id', 5, 'table', 'report_cards',
  'row', jsonb_build_object('id', '9d000000-0000-4000-8000-000000000001',
  'director_observation', 'Travail sérieux', 'decision', 'Passe en CM2',
  'updated_at', now() + interval '1 minute'))))) -> 0 ->> 'status', 'ok',
  'directeur : observation et décision');
select is((select (teacher_appreciation, decision)::text from public.report_cards
            where id = '9d000000-0000-4000-8000-000000000001'),
  '("Bon trimestre","Passe en CM2")', 'l''appréciation de l''enseignant est conservée');
select is((public.sync_push($$[{"change_id": 6, "table": "report_templates", "row": {
  "id": "9e000000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "name": "Mon modèle", "settings": {"titre": "BULLETIN DE NOTES"}, "is_default": true,
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'directeur : modèle de bulletin');
select is((public.sync_push($$[{"change_id": 7, "table": "scolarity_copy_log", "row": {
  "id": "9f000000-0000-4000-8000-000000000002", "school_id": "10000000-0000-4000-8000-000000000001",
  "student_id": "d0000000-0000-4000-8000-000000000003", "is_certified_copy": true,
  "generated_by": "a0000000-0000-4000-8000-000000000004",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'directeur : copie conforme enregistrée');
select is((select generated_by::text from public.scolarity_copy_log
            where id = '9f000000-0000-4000-8000-000000000002'),
  'a0000000-0000-4000-8000-000000000001', 'l''auteur de la copie est celui qui est connecté');
select is((public.sync_push($$[{"change_id": 8, "table": "scolarity_copy_log", "row": {
  "id": "9f000000-0000-4000-8000-000000000002", "school_id": "10000000-0000-4000-8000-000000000001",
  "student_id": "d0000000-0000-4000-8000-000000000003", "is_certified_copy": false,
  "updated_at": "2026-10-02T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'deja_recu',
  'journal des copies : renvoi sans doublon ni modification');
select is((select count(*)::int from public.audit_log
            where table_name = 'scolarity_copy_log' and row_id = '9f000000-0000-4000-8000-000000000002'),
  1, 'la copie conforme apparaît dans le journal d''activité');

-- Enseignant Deux (CM2) : ne voit pas les bulletins du CM1.
select set_config('request.jwt.claims', :'ens2', true);
select is((select count(*)::int from public.report_cards), 0, 'autre enseignant : aucun bulletin du CM1');
select is((select count(*)::int from public.scolarity_copy_log), 0, 'enseignant : journal des copies invisible');

-- Secrétaire (droit « finances » seulement) : pas de fiche de scolarité.
select set_config('request.jwt.claims', :'sec', true);
select is((public.sync_push($$[{"change_id": 9, "table": "scolarity_copy_log", "row": {
  "id": "9f000000-0000-4000-8000-000000000003", "school_id": "10000000-0000-4000-8000-000000000001",
  "student_id": "d0000000-0000-4000-8000-000000000003", "is_certified_copy": false,
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'délégué sans droit « registres » : pas de fiche de scolarité');

select * from finish();
rollback;
