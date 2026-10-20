-- Phase 1 : mécanisme générique des modules optionnels (R11) sur un module factice,
-- puis gardes réelles (niveaux gérés, maternelle, dossier médico-scolaire).
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
begin;
select plan(23);

-- Préparation : un module « factice » et sa table, protégés par le mécanisme générique.
insert into public.modules_catalog (key, label, description) values ('factice', 'Factice', 'Module de test');
insert into public.modules_catalog (key, label, description, depends_on)
values ('factice_dependant', 'Dépendant', 'Module de test dépendant', 'factice');
insert into public.school_modules (school_id, module_key, enabled) values
  ('10000000-0000-4000-8000-000000000001', 'factice', false),
  ('10000000-0000-4000-8000-000000000001', 'factice_dependant', true);
create table public.module_factice_items (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  label text not null
);
alter table public.module_factice_items enable row level security;
create policy f_read on public.module_factice_items for select to authenticated using (app.is_member(school_id));
create policy f_write on public.module_factice_items for insert to authenticated with check (app.is_director(school_id));
create policy f_update on public.module_factice_items for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));
select app.guard_module('public.module_factice_items', 'factice');
insert into public.module_factice_items (school_id, label) values
  ('10000000-0000-4000-8000-000000000001', 'donnée 1'), ('10000000-0000-4000-8000-000000000001', 'donnée 2');

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
create temp table totaux_avant as
  select (select count(*) from public.students) as eleves, (select count(*) from public.classes) as classes;

-- OFF
select is((select count(*)::int from public.module_factice_items), 0, 'OFF : lecture vide');
select throws_ok($$insert into public.module_factice_items (school_id, label)
  values ('10000000-0000-4000-8000-000000000001', 'x')$$, '42501', null, 'OFF : écriture refusée');
select is(app.module_enabled('10000000-0000-4000-8000-000000000001', 'factice_dependant'), false,
  'OFF : un module qui en dépend est considéré inactif');

-- ON (activé par le directeur)
update public.school_modules set enabled = true where module_key = 'factice';
select is((select count(*)::int from public.module_factice_items), 2, 'ON : données visibles');
select lives_ok($$insert into public.module_factice_items (school_id, label)
  values ('10000000-0000-4000-8000-000000000001', 'donnée 3')$$, 'ON : écriture acceptée');
select is(app.module_enabled('10000000-0000-4000-8000-000000000001', 'factice_dependant'), true,
  'ON : le module dépendant redevient actif');

-- OFF de nouveau
update public.school_modules set enabled = false where module_key = 'factice';
select is((select count(*)::int from public.module_factice_items), 0, 'OFF → ON → OFF : lecture vide');
select throws_ok($$insert into public.module_factice_items (school_id, label)
  values ('10000000-0000-4000-8000-000000000001', 'y')$$, '42501', null, 'OFF → ON → OFF : écriture refusée');
update public.module_factice_items set label = 'modifiée';

-- Totaux des autres modules inchangés
select is((select count(*) from public.students), (select eleves from totaux_avant), 'élèves : total inchangé');
select is((select count(*) from public.classes), (select classes from totaux_avant), 'classes : total inchangé');

-- Un enseignant ne peut pas activer un module
select set_config('request.jwt.claims', :'ens1', true);
update public.school_modules set enabled = true where module_key = 'factice';

reset role;
select is((select count(*)::int from public.module_factice_items), 3, 'données conservées pendant la désactivation');
select is((select count(*)::int from public.module_factice_items where label = 'modifiée'), 0,
  'aucune modification possible pendant la désactivation');
select is((select enabled from public.school_modules where module_key = 'factice'
            and school_id = '10000000-0000-4000-8000-000000000001'), false, 'l''enseignant n''a pas pu activer le module');
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
update public.school_modules set enabled = true where module_key = 'factice';
select is((select count(*)::int from public.module_factice_items), 3, 'réactivation : les 3 données réapparaissent');

-- Niveaux gérés : maternelle = module Maternelle
reset role;
insert into public.classes (id, school_id, school_year_id, level_code, name)
values ('c0000000-0000-4000-8000-000000000060', '10000000-0000-4000-8000-000000000001',
        '20000000-0000-4000-8000-000000002025', 'MS', 'MS A');
insert into public.learning_domains (school_id, name) values ('10000000-0000-4000-8000-000000000001', 'Langage');
set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);
select is((select count(*)::int from public.classes where level_code = 'MS'), 0,
  'maternelle désactivée : classe de maternelle invisible');
select is((select count(*)::int from public.learning_domains), 0, 'maternelle désactivée : domaines invisibles');
select throws_ok($$insert into public.classes (school_id, school_year_id, level_code, name) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'GS', 'GS B')$$,
  '42501', null, 'maternelle désactivée : création de classe de maternelle refusée');
update public.school_modules set enabled = true where module_key = 'maternelle';
select is((select count(*)::int from public.classes where level_code = 'MS'), 1,
  'maternelle activée : la classe réapparaît');
update public.schools set manages_primary = false;
select is((select count(*)::int from public.classes where level_code like 'C%'), 0,
  'école « maternelle seule » : aucune classe du primaire visible');
select throws_ok($$update public.school_modules set enabled = false where module_key = 'maternelle'$$,
  'P0001', null, 'au moins un niveau doit rester actif');
update public.schools set manages_primary = true;
update public.school_modules set enabled = false where module_key = 'maternelle';
select is((select count(*)::int from public.classes where level_code like 'C%'), 4, 'primaire réactivé : classes intactes');

-- Dossier médico-scolaire : inaccessible directement, même pour le directeur
select throws_ok($$select * from medical.records$$, '42501', null, 'medical : aucun accès direct');
reset role;
select is((select count(*)::int from pg_policies where policyname like 'module_%' and permissive = 'RESTRICTIVE'), 17,
  'gardes posées sur les 17 tables des modules optionnels (5 maternelle, 7 cantine, 4 médical + 1 factice)');

select * from finish();
rollback;
