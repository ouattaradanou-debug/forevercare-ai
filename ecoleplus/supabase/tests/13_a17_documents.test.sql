-- A17 : journal des documents délivrés, droits.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set sec  '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
begin;
select plan(8);

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select is((public.sync_push($$[{"change_id": 1, "table": "issued_documents", "row": {
  "id": "9a100000-0000-4000-8000-000000000001", "school_id": "10000000-0000-4000-8000-000000000001",
  "doc_code": "certificat_scolarite", "student_id": "d0000000-0000-4000-8000-000000000003",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'directeur : certificat de scolarité journalisé');
select is((select generated_by::text from public.issued_documents
            where id = '9a100000-0000-4000-8000-000000000001'),
  'a0000000-0000-4000-8000-000000000001', 'auteur = la personne connectée');
select is((public.sync_push($$[{"change_id": 2, "table": "issued_documents", "row": {
  "id": "9a100000-0000-4000-8000-000000000002", "school_id": "10000000-0000-4000-8000-000000000001",
  "doc_code": "prise_service", "teacher_id": "b0000000-0000-4000-8000-000000000001",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'ok',
  'directeur : attestation de prise de service journalisée');
select is((select count(*)::int from public.audit_log where table_name = 'issued_documents'), 2,
  'les documents délivrés apparaissent dans le journal d''activité');
select is((public.sync_push(jsonb_build_array(jsonb_build_object('change_id', 3, 'table', 'schools',
  'row', jsonb_build_object('id', '10000000-0000-4000-8000-000000000001',
  'director_civility', 'madame', 'director_grade', 'Professeur Certifié des Écoles',
  'updated_at', now() + interval '1 minute'))))) -> 0 ->> 'status', 'ok',
  'directeur : civilité et grade enregistrés');

select set_config('request.jwt.claims', :'ens1', true);
select is((public.sync_push($$[{"change_id": 4, "table": "issued_documents", "row": {
  "id": "9a100000-0000-4000-8000-000000000003", "school_id": "10000000-0000-4000-8000-000000000001",
  "doc_code": "attestation_niveau", "student_id": "d0000000-0000-4000-8000-000000000003",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'enseignant : ne délivre aucun document');
select is((select count(*)::int from public.issued_documents), 0,
  'enseignant : ne voit pas le journal des documents');

select set_config('request.jwt.claims', :'sec', true);
select is((public.sync_push($$[{"change_id": 5, "table": "issued_documents", "row": {
  "id": "9a100000-0000-4000-8000-000000000004", "school_id": "10000000-0000-4000-8000-000000000001",
  "doc_code": "non_redevance", "student_id": "d0000000-0000-4000-8000-000000000003",
  "updated_at": "2026-10-01T08:00:00Z"}}]$$::jsonb)) -> 0 ->> 'status', 'rejete',
  'délégué sans droit « registres » : refus');

select * from finish();
rollback;
