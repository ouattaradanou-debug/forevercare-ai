-- Phase 8 : photos des élèves (stockage privé) et cartes scolaires.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set sec  '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(16);

select is((select public from storage.buckets where id = 'ecole-medias'), false,
  'photos : compartiment privé, aucun lien public');

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
-- Aïcha : CM1 A (classe d'Enseignant Un).
select lives_ok($$insert into storage.objects (bucket_id, name) values ('ecole-medias',
  '10000000-0000-4000-8000-000000000001/eleves/d0000000-0000-4000-8000-000000000001-1.jpg')$$,
  'directeur : photo d''un élève de son école');
select lives_ok($$insert into storage.objects (bucket_id, name) values ('ecole-medias',
  '10000000-0000-4000-8000-000000000001/entetes/entete.png')$$, 'directeur : image d''en-tête');
select throws_ok($$insert into storage.objects (bucket_id, name) values ('ecole-medias',
  '10000000-0000-4000-8000-000000000001/eleves/d0000000-0000-4000-8000-000000000099-1.jpg')$$,
  '42501', null, 'photo d''un élève d''une autre école rangée chez soi : refusée');
select lives_ok($$insert into storage.objects (bucket_id, name) values ('ecole-medias',
  '10000000-0000-4000-8000-000000000001/logo/logo-1.png')$$, 'directeur : logo de l''école');
select lives_ok($$insert into public.student_cards (id, school_id, student_id, school_year_id, qr_token) values
  ('76000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'd0000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'a1b2c3d4e5f60718293a4b5c6d7e8f90')$$,
  'directeur : carte (identifiant opaque du QR code)');

-- Enseignante de la classe d'Aïcha : voit sa photo.
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from storage.objects where name like '%/eleves/%'), 1,
  'enseignante : voit la photo d''un élève de sa classe');
select throws_ok($$insert into storage.objects (bucket_id, name) values ('ecole-medias',
  '10000000-0000-4000-8000-000000000001/eleves/d0000000-0000-4000-8000-000000000002-1.jpg')$$,
  '42501', null, 'enseignante : ne dépose pas de photo');
select is((select count(*)::int from public.student_cards), 0, 'enseignante : ne voit pas les cartes');
select is((select count(*)::int from storage.objects where name like '%/logo/%'), 1,
  'enseignante : voit le logo de l''école');

-- Enseignant d'une autre classe : aucune photo.
select set_config('request.jwt.claims', :'ens2', true);
select is((select count(*)::int from storage.objects where name like '%/eleves/%'), 0,
  'enseignant d''une autre classe : ne lit pas la photo');

-- Délégué « cartes » : lit les photos, n'en dépose pas.
reset role;
insert into public.delegate_permissions (school_id, membership_id, permission_key) values
  ('10000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000004', 'cartes');
set local role authenticated;
select set_config('request.jwt.claims', :'sec', true);
select is((select count(*)::int from storage.objects where name like '%/eleves/%'), 1,
  'délégué « cartes » : lit les photos');
select is((select count(*)::int from public.student_cards), 1, 'délégué « cartes » : voit les cartes');
select throws_ok($$insert into storage.objects (bucket_id, name) values ('ecole-medias',
  '10000000-0000-4000-8000-000000000001/eleves/d0000000-0000-4000-8000-000000000003-1.jpg')$$,
  '42501', null, 'délégué « cartes » : ne dépose pas de photo');

-- Autre école, et visiteur non connecté : rien.
select set_config('request.jwt.claims', :'dir2', true);
select is((select count(*)::int from storage.objects where bucket_id = 'ecole-medias'), 0,
  'autre école : aucune image');
reset role;
set local role anon;
select is((select count(*)::int from storage.objects), 0, 'visiteur non connecté : aucune image');

select * from finish();
rollback;
