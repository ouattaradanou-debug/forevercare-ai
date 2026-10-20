-- R4 : RLS activée sur toutes les tables ; en phase 0, aucune donnée d'école
-- n'est lisible ni modifiable par les rôles de l'application.
begin;
select plan(11);

select is(
  (select count(*)::int from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where c.relkind = 'r' and n.nspname in ('public', 'medical') and not c.relrowsecurity),
  0, 'RLS activée sur toutes les tables (public et medical)');

select cmp_ok(
  (select count(*)::int from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where c.relkind = 'r' and n.nspname in ('public', 'medical')),
  '>=', 50, 'le schéma couvre tous les modules (au moins 50 tables)');

-- Enseignant connecté
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is((select count(*)::int from public.students), 0, 'enseignant : aucun élève lisible sans politique');
select is((select count(*)::int from public.schools), 0, 'enseignant : aucune école lisible sans politique');
select is((select count(*)::int from public.payments), 0, 'enseignant : aucune donnée financière lisible');
select is((select count(*)::int from public.levels), 9, 'le référentiel des niveaux reste lisible');
select throws_ok(
  $$insert into public.schools (name) values ('École pirate')$$,
  '42501', null, 'enseignant : création d''école refusée');
select throws_ok(
  $$select * from medical.records$$,
  '42501', null, 'enseignant : schéma médical inaccessible');

-- Visiteur non connecté
reset role;
set local role anon;
select is((select count(*)::int from public.students), 0, 'anonyme : aucun élève lisible');
select is((select count(*)::int from public.grades), 0, 'anonyme : aucune note lisible');
select throws_ok($$select * from medical.fitness$$, '42501', null, 'anonyme : schéma médical inaccessible');

select * from finish();
rollback;
