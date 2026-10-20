-- Phase 1 : stockage privé des images de l'école.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(6);

select is((select public from storage.buckets where id = 'ecole-medias'), false, 'compartiment privé (aucun lien public)');

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$insert into storage.objects (bucket_id, name, owner_id)
  values ('ecole-medias', '10000000-0000-4000-8000-000000000001/entetes/test.png', 'a0000000-0000-4000-8000-000000000001')$$,
  'directeur : dépose l''image d''en-tête de son école');
select throws_ok($$insert into storage.objects (bucket_id, name)
  values ('ecole-medias', '10000000-0000-4000-8000-000000000002/entetes/intrus.png')$$,
  '42501', null, 'directeur : ne peut rien déposer dans une autre école');

select set_config('request.jwt.claims', :'ens1', true);
select throws_ok($$insert into storage.objects (bucket_id, name)
  values ('ecole-medias', '10000000-0000-4000-8000-000000000001/entetes/x.png')$$,
  '42501', null, 'enseignant : ne peut pas changer l''image d''en-tête');
select is((select count(*)::int from storage.objects where bucket_id = 'ecole-medias'), 1,
  'enseignant : peut voir l''image d''en-tête de son école');

select set_config('request.jwt.claims', :'dir2', true);
select is((select count(*)::int from storage.objects where bucket_id = 'ecole-medias'), 0,
  'autre école : ne voit pas l''image');

select * from finish();
rollback;
