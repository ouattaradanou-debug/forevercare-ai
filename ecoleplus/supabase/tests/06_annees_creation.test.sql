-- Phase 1 : années scolaires (bascule, archives, en-têtes par année), création d'école,
-- inscription des appareils.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
\set neuf '{"sub":"a0000000-0000-4000-8000-0000000000aa","role":"authenticated"}'
begin;
select plan(17);

insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
values ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-4000-8000-0000000000aa', 'authenticated',
        'authenticated', 'nouveau@ecole-neuve.local', '', now(), now(), now());

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);

-- Préparer l'année suivante (en-têtes différents), puis basculer.
insert into public.school_years (id, school_id, label) values
  ('2b000000-0000-4000-8000-000000002026', '10000000-0000-4000-8000-000000000001', '2026-2027');
insert into public.admin_headers (school_id, school_year_id, ministry, region, ceb, school_label) values
  ('10000000-0000-4000-8000-000000000001', '2b000000-0000-4000-8000-000000002026', 'MINISTÈRE TEST',
   'Région Test C', 'CEB Test 3', 'École Test');
update public.schools set current_school_year_id = '2b000000-0000-4000-8000-000000002026';
update public.school_years set archived_at = now() where id = '20000000-0000-4000-8000-000000002025';

select is((select count(*)::int from public.school_years), 3, 'les trois années restent consultables');
select is((select array_agg(region order by region) from public.admin_headers),
  array['Région Test A', 'Région Test B', 'Région Test C'], 'chaque année garde ses propres en-têtes');
select is((select count(*)::int from public.enrollments
            where school_year_id = '20000000-0000-4000-8000-000000002025'), 12,
  'les inscriptions de l''année archivée sont intactes');
reset role;
select is((select count(*)::int from public.annual_results), 1, 'les résultats des années passées sont intacts');
set local role authenticated;

select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.classes), 0,
  'après la bascule, l''enseignant ne voit plus les classes de l''année archivée');

-- Création d'une école par un nouveau directeur
select set_config('request.jwt.claims', :'neuf', true);
select throws_ok($$select public.create_school('{"school_id":"1c000000-0000-4000-8000-000000000001",
  "school_year_id":"2c000000-0000-4000-8000-000000000001","membership_id":"ac000000-0000-4000-8000-000000000001",
  "name":"École Neuve","year_label":"2026-2027","manages_primary":false,"manages_preschool":false}'::jsonb)$$,
  'P0001', null, 'création refusée sans aucun niveau');
select is((public.create_school('{"school_id":"1c000000-0000-4000-8000-000000000001",
  "school_year_id":"2c000000-0000-4000-8000-000000000001","membership_id":"ac000000-0000-4000-8000-000000000001",
  "name":"École Neuve","year_label":"2026-2027","region":"Région Neuve","ceb":"CEB Neuve",
  "director_name":"Directrice Neuve"}'::jsonb)) ->> 'already_created', 'false', 'école créée');
select is((public.create_school('{"school_id":"1c000000-0000-4000-8000-000000000001",
  "school_year_id":"2c000000-0000-4000-8000-000000000001","membership_id":"ac000000-0000-4000-8000-000000000001",
  "name":"École Neuve","year_label":"2026-2027"}'::jsonb)) ->> 'already_created', 'true',
  'renvoi après coupure : pas de seconde école');
select is((select count(*)::int from public.schools), 1, 'le nouveau directeur voit son école');
select is((select current_school_year_id::text from public.schools), '2c000000-0000-4000-8000-000000000001',
  'année en cours fixée');
select is((select count(*)::int from public.school_modules where not enabled), 3,
  'tous les modules optionnels désactivés par défaut');
select is((select ceb from public.admin_headers), 'CEB Neuve', 'en-têtes de la première année enregistrés');
select is((select count(*)::int from public.students), 0, 'aucune donnée d''une autre école');

-- Appareils : série attribuée une fois pour toutes
select set_config('request.jwt.claims', :'dir1', true);
select is((public.register_device('9c000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001', 'Téléphone test')) ->> 'series_code', 'C',
  'nouvel appareil : série suivante (C)');
select is((public.register_device('9c000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001', 'Téléphone test')) ->> 'series_code', 'C',
  'appareil déjà inscrit : même série');
select set_config('request.jwt.claims', :'dir2', true);
select throws_ok($$select public.register_device('9c000000-0000-4000-8000-000000000002',
  '10000000-0000-4000-8000-000000000001', 'Intrus')$$, '42501', null,
  'impossible d''inscrire un appareil dans une autre école');
select set_config('request.jwt.claims', :'neuf', true);
select throws_ok($$select public.create_school('{"school_id":"10000000-0000-4000-8000-000000000001",
  "school_year_id":"2c000000-0000-4000-8000-000000000009","membership_id":"ac000000-0000-4000-8000-000000000009",
  "name":"Vol","year_label":"2026-2027"}'::jsonb)$$, '42501', null,
  'impossible de s''approprier une école existante');

select * from finish();
rollback;
