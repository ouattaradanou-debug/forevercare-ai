-- A21 : « Effacer définitivement » un document de la corbeille.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(9);

-- Un document commun (avec un passage lu) et une archive.
insert into public.documents (id, school_id, space, title, is_common, size_bytes, sha256) values
  ('78000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'bibliotheque',
   'Rapport à effacer', true, 1000, repeat('1', 64));
insert into public.documents (id, school_id, space, title, ai_allowed, size_bytes, sha256) values
  ('78000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'archives',
   'PV à garder', false, 500, repeat('2', 64));
insert into public.document_chunks (school_id, document_id, page, chunk_index, content) values
  ('10000000-0000-4000-8000-000000000001', '78000000-0000-4000-8000-000000000001', 1, 0, 'rapport de mission');

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select throws_ok($$select public.document_effacer('78000000-0000-4000-8000-000000000001')$$,
  'P0001', 'Mettez d''abord le document à la corbeille.', 'hors corbeille : refusé');
update public.documents set trashed_at = now() where id = '78000000-0000-4000-8000-000000000001';

select set_config('request.jwt.claims', :'ens1', true);
select throws_ok($$select public.document_effacer('78000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'enseignant : refusé');
select set_config('request.jwt.claims', :'dir2', true);
select throws_ok($$select public.document_effacer('78000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'directeur d''une autre école : refusé');
set local role anon;
select throws_ok($$select public.document_effacer('78000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'visiteur non connecté : refusé');

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$select public.document_effacer('78000000-0000-4000-8000-000000000001')$$,
  'directeur : document de la corbeille effacé');
select is((select count(*)::int from public.documents where id = '78000000-0000-4000-8000-000000000001'), 0,
  'il n''est plus visible');
select throws_ok($$select public.document_effacer('78000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'deuxième effacement : refusé');

reset role;
select is((select deleted_at is not null from public.documents where id = '78000000-0000-4000-8000-000000000001'),
  true, 'fiche gardée, marquée effacée (trace)');
select is((select count(*)::int from public.document_chunks where document_id = '78000000-0000-4000-8000-000000000001'),
  0, 'texte lu effacé');

select * from finish();
rollback;
