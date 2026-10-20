-- Phase 1 : droits par profil et isolement des écoles (refus prouvés au niveau des données).
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set secr '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(34);
set local role authenticated;

-- ---------- Enseignant Un (CM1 A) ----------
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.classes), 1, 'ens. CM1 : voit une seule classe');
select is((select name from public.classes), 'CM1 A', 'ens. CM1 : c''est sa classe de l''année en cours');
select is((select count(*)::int from public.classes where name = 'CM2 A'), 0, 'ens. CM1 : ne voit pas le CM2');
select is((select count(*)::int from public.students), 4, 'ens. CM1 : voit les 4 élèves de sa classe');
select is((select count(*)::int from public.students where first_names = 'Fatou'), 0,
  'ens. CM1 : ne voit pas une élève du CM2');
select is((select count(*)::int from public.guardians), 4, 'ens. CM1 : parents de sa classe seulement');
select is((select count(*)::int from public.memberships), 1, 'ens. CM1 : ne voit que son propre compte');
select is((select count(*)::int from public.teachers), 1, 'ens. CM1 : ne voit que sa propre fiche enseignant');
update public.schools set name = 'Piratée';
update public.admin_headers set ministry = 'Piraté';
update public.school_modules set enabled = true;
select throws_ok($$insert into public.school_years (school_id, label) values
  ('10000000-0000-4000-8000-000000000001', '2030-2031')$$, '42501', null, 'ens. : création d''année refusée');
select throws_ok($$insert into public.students (school_id, last_name, first_names) values
  ('10000000-0000-4000-8000-000000000001', 'X', 'Y')$$, '42501', null, 'ens. : ajout d''élève refusé (phase 1)');

-- ---------- Enseignant Deux (CM2 A) ----------
select set_config('request.jwt.claims', :'ens2', true);
select is((select array_agg(name) from public.classes), array['CM2 A'], 'ens. CM2 : voit seulement le CM2');
select is((select count(*)::int from public.students where first_names in ('Aïcha', 'Boukary')), 0,
  'ens. CM2 : ne voit pas les élèves du CM1');

-- ---------- Secrétaire (droit « finances » seulement) ----------
select set_config('request.jwt.claims', :'secr', true);
select is((select count(*)::int from public.students), 12, 'secrétaire finances : voit les élèves de l''école');
select is((select count(*)::int from public.teachers), 0, 'secrétaire finances : ne voit pas le personnel');
select throws_ok($$insert into public.students (school_id, last_name, first_names) values
  ('10000000-0000-4000-8000-000000000001', 'X', 'Y')$$, '42501', null,
  'secrétaire finances : ne peut pas créer d''élève');
update public.admin_headers set ministry = 'Piraté';

-- ---------- Directeur de l'École Test ----------
select set_config('request.jwt.claims', :'dir1', true);
select is((select name from public.schools), 'École Test', 'les tentatives des autres profils n''ont rien modifié (nom)');
select is((select count(*)::int from public.admin_headers where ministry = 'Piraté'), 0,
  'les tentatives des autres profils n''ont rien modifié (en-têtes)');
select is((select count(*)::int from public.school_modules where enabled), 0,
  'les tentatives des autres profils n''ont rien modifié (options)');
select is((select count(*)::int from public.schools), 1, 'directeur : voit uniquement son école');
select is((select count(*)::int from public.students), 12, 'directeur : voit les 12 élèves de son école');
select is((select count(*)::int from public.students where school_id = '10000000-0000-4000-8000-000000000002'), 0,
  'directeur : ne voit aucun élève de l''autre école');
select is((select count(*)::int from public.classes), 4, 'directeur : voit toutes ses classes, archives comprises');
select is((select count(*)::int from public.memberships), 4, 'directeur : voit les comptes de son école');
select is((select count(*)::int from public.teachers), 2, 'directeur : voit le personnel');
update public.schools set phone = '+226 11 11 11 11';
select is((select phone from public.schools), '+226 11 11 11 11', 'directeur : peut modifier son école');
select throws_ok($$insert into public.school_years (school_id, label) values
  ('10000000-0000-4000-8000-000000000002', '2030-2031')$$, '42501', null,
  'directeur : ne peut rien créer dans une autre école');

-- ---------- Directeur de l'École Témoin ----------
select set_config('request.jwt.claims', :'dir2', true);
select is((select array_agg(name) from public.schools), array['École Témoin'], 'école 2 : ne voit que son école');
select is((select count(*)::int from public.students), 1, 'école 2 : ne voit que son élève');
select is((select count(*)::int from public.admin_headers), 0, 'école 2 : aucun en-tête de l''école 1');
update public.schools set name = 'Piratée' where id = '10000000-0000-4000-8000-000000000001';

-- ---------- Compte désactivé ----------
reset role;
update public.memberships set active = false where id = 'a1000000-0000-4000-8000-000000000002';
set local role authenticated;
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.classes), 0, 'compte désactivé : plus aucune classe');
select is((select count(*)::int from public.students), 0, 'compte désactivé : plus aucun élève');
select is((select count(*)::int from public.schools), 0, 'compte désactivé : plus d''accès à l''école');

reset role;
select is((select name from public.schools where id = '10000000-0000-4000-8000-000000000001'), 'École Test',
  'l''autre directeur n''a pas pu renommer l''École Test');
select throws_ok($$update public.memberships set active = false where id = 'a1000000-0000-4000-8000-000000000001'$$,
  'P0001', null, 'impossible de désactiver le dernier directeur actif');

select * from finish();
rollback;
