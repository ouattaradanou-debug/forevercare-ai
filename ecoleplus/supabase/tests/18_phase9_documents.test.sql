-- Phase 9 : bibliothèque et archives — droits sur les fiches, les fichiers
-- et l'index ; validation des ajouts d'enseignants ; doublons ; quota.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(22);

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
-- 77…1 commun ; 77…2 réservé au CM1 A ; 77…3 réservé au CM2 A ; 77…4 archives.
select lives_ok($$insert into public.documents (id, school_id, space, title, is_common, size_bytes, sha256) values
  ('77000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'bibliotheque',
   'Programme officiel', true, 1000, repeat('a', 64))$$, 'directeur : document commun');
select lives_ok($$insert into public.documents (id, school_id, space, title, class_ids, size_bytes, sha256) values
  ('77000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'bibliotheque',
   'Fiches CM1', '{c0000000-0000-4000-8000-000000000002}', 1000, repeat('b', 64))$$, 'directeur : document du CM1');
select lives_ok($$insert into public.documents (id, school_id, space, title, class_ids, size_bytes, sha256) values
  ('77000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001', 'bibliotheque',
   'Sujets CM2', '{c0000000-0000-4000-8000-000000000003}', 1000, repeat('c', 64))$$, 'directeur : document du CM2');
select lives_ok($$insert into public.documents (id, school_id, space, title, ai_allowed, size_bytes, sha256) values
  ('77000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000001', 'archives',
   'PV du conseil', false, 1000, repeat('d', 64))$$, 'directeur : archive');
select throws_ok($$insert into public.documents (school_id, space, title, ai_allowed) values
  ('10000000-0000-4000-8000-000000000001', 'archives', 'Archive pour l''IA', true)$$,
  '23514', null, 'archives : jamais autorisées pour l''IA');
select throws_ok($$insert into public.documents (school_id, space, title, size_bytes, sha256) values
  ('10000000-0000-4000-8000-000000000001', 'bibliotheque', 'Doublon', 1000, repeat('a', 64))$$,
  '23505', null, 'doublon (même empreinte) : refusé');
select lives_ok($$insert into storage.objects (bucket_id, name) values
  ('documents', '10000000-0000-4000-8000-000000000001/77000000-0000-4000-8000-000000000003/sujets.pdf'),
  ('documents', '10000000-0000-4000-8000-000000000001/77000000-0000-4000-8000-000000000002/fiches.pdf'),
  ('documents', '10000000-0000-4000-8000-000000000001/77000000-0000-4000-8000-000000000004/pv.pdf')$$,
  'directeur : fichiers déposés');

-- Index (écrit par le travailleur d'indexation).
reset role;
insert into public.document_chunks (school_id, document_id, page, chunk_index, content) values
  ('10000000-0000-4000-8000-000000000001', '77000000-0000-4000-8000-000000000003', 1, 0,
   'Sujet de mathématiques : les fractions décimales et la multiplication.'),
  ('10000000-0000-4000-8000-000000000001', '77000000-0000-4000-8000-000000000004', 1, 0,
   'Procès-verbal du conseil des maîtres : budget de la coopérative.');
set local role authenticated;

-- Enseignante du CM1.
select set_config('request.jwt.claims', :'ens1', true);
select is((select array_agg(title order by title)::text from public.documents),
  '{"Fiches CM1","Programme officiel"}', 'enseignante du CM1 : fonds commun et sa classe seulement');
select is((select count(*)::int from storage.objects where bucket_id = 'documents'), 1,
  'enseignante du CM1 : seul le fichier de sa classe');
select is((select count(*)::int from public.document_chunks), 0,
  'enseignante du CM1 : aucun passage du CM2 ni des archives');
select is((select count(*)::int from public.documents_search('10000000-0000-4000-8000-000000000001', 'fractions')), 0,
  'recherche : rien du CM2 pour l''enseignante du CM1');
select throws_ok($$insert into public.documents (school_id, space, title, ai_allowed) values
  ('10000000-0000-4000-8000-000000000001', 'archives', 'Archive', false)$$,
  '42501', null, 'enseignante : n''ajoute pas d''archive');
select lives_ok($$insert into public.documents (id, school_id, space, title, class_ids, is_common, approved) values
  ('77000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000001', 'bibliotheque',
   'Ma fiche de lecture', '{c0000000-0000-4000-8000-000000000002}', true, true)$$,
  'enseignante : ajoute dans la bibliothèque de sa classe');
select is((select (approved, is_common, uploaded_by::text)::text from public.documents
            where id = '77000000-0000-4000-8000-000000000005'),
  '(f,f,a0000000-0000-4000-8000-000000000002)', 'ajout d''enseignante : en attente de validation, auteur imposé');

select set_config('request.jwt.claims', :'ens2', true);
select is((select count(*)::int from public.documents where id = '77000000-0000-4000-8000-000000000005'), 0,
  'document non validé : invisible pour les autres');

select set_config('request.jwt.claims', :'dir1', true);
select is((select count(*)::int from public.documents_search('10000000-0000-4000-8000-000000000001', 'fraction')), 1,
  'recherche (racines françaises) : « fraction » trouve « fractions »');
select is((select count(*)::int from public.documents_search('10000000-0000-4000-8000-000000000001', 'coopérative')), 1,
  'directeur : recherche aussi dans les archives');
update public.documents set approved = true where id = '77000000-0000-4000-8000-000000000005';
update public.documents set index_status = 'indexe' where id = '77000000-0000-4000-8000-000000000001';
select is((select index_status from public.documents where id = '77000000-0000-4000-8000-000000000001'),
  'en_attente', 'statut d''indexation : tenu par le serveur seul');
select is((select used_bytes::int from public.documents_usage('10000000-0000-4000-8000-000000000001')), 4000,
  'espace utilisé');

-- Quota.
reset role;
update public.schools set storage_quota_bytes = 10000 where id = '10000000-0000-4000-8000-000000000001';
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select throws_like($$insert into public.documents (school_id, space, title, size_bytes) values
  ('10000000-0000-4000-8000-000000000001', 'bibliotheque', 'Gros scan', 9000)$$,
  'Espace plein%', 'quota atteint : message clair');

-- Ajout fermé aux enseignants.
update public.schools set library_teacher_mode = 'interdit' where id = '10000000-0000-4000-8000-000000000001';
select set_config('request.jwt.claims', :'ens1', true);
select throws_ok($$insert into public.documents (school_id, space, title) values
  ('10000000-0000-4000-8000-000000000001', 'bibliotheque', 'Fiche')$$,
  '42501', null, 'ajout fermé par le directeur : refusé');

select set_config('request.jwt.claims', :'dir2', true);
select is((select count(*)::int from public.documents), 0, 'autre école : aucun document');

select * from finish();
rollback;
