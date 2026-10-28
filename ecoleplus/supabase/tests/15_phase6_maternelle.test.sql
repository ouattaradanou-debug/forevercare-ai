-- Phase 6 : maternelle (module optionnel), évaluations qualitatives,
-- livrets, présences ; droits.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set ecole '\'10000000-0000-4000-8000-000000000001\''
begin;
select plan(20);

set local role authenticated;
select set_config('request.jwt.claims', :'dir1', true);

-- Module désactivé (par défaut) : rien de la maternelle.
select throws_ok($$insert into public.learning_domains (id, school_id, name)
  values ('70000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Langage')$$,
  '42501', null, 'module désactivé : aucun domaine d''apprentissage');
select throws_ok($$insert into public.classes (id, school_id, school_year_id, level_code, name)
  values ('c1000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
          '20000000-0000-4000-8000-000000002025', 'GS', 'GS A')$$,
  '42501', null, 'module désactivé : aucune classe de maternelle');

-- Activation.
update public.school_modules set enabled = true where module_key = 'maternelle' and school_id = :ecole;
select is((select enabled from public.school_modules where module_key = 'maternelle' and school_id = :ecole),
  true, 'directeur : maternelle activée');
select lives_ok($$insert into public.classes (id, school_id, school_year_id, level_code, name, main_teacher_id)
  values ('c1000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
          '20000000-0000-4000-8000-000000002025', 'GS', 'GS A', 'b0000000-0000-4000-8000-000000000002')$$,
  'module actif : classe de grande section créée');
select lives_ok($$insert into public.learning_domains (id, school_id, name, sort_order) values
  ('70000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Langage', 1)$$,
  'directeur : domaine d''apprentissage');
select lives_ok($$insert into public.qualitative_levels (id, school_id, code, label, color_hex, icon_key, sort_order) values
  ('71000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'acquis', 'Acquis', '#2E7D32', 'check', 1)$$,
  'directeur : niveau qualitatif (couleur et pictogramme)');
select throws_ok($$insert into public.qualitative_levels (school_id, code, label, color_hex, icon_key) values
  ('10000000-0000-4000-8000-000000000001', 'x', 'X', 'vert', 'check')$$,
  '23514', null, 'couleur obligatoirement au format #RRGGBB');
select lives_ok($$update public.schools set preschool_ranking = true where id = '10000000-0000-4000-8000-000000000001'$$,
  'directeur : option de classement');

-- Enseignante de la grande section.
select set_config('request.jwt.claims', :'ens2', true);
select is((select count(*)::int from public.learning_domains), 1, 'enseignant : voit les domaines');
select lives_ok($$insert into public.preschool_periods (id, school_id, class_id, school_year_id, label, sequence) values
  ('72000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'c1000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', '1er trimestre', 1)$$,
  'enseignant de la classe : trimestre');
select lives_ok($$insert into public.preschool_evaluations (id, school_id, period_id, student_id, domain_id, level_id) values
  ('73000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '72000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000012',
   '70000000-0000-4000-8000-000000000001', '71000000-0000-4000-8000-000000000001')$$,
  'enseignant de la classe : évaluation qualitative');
insert into public.preschool_booklets (id, school_id, period_id, student_id, teacher_appreciation, observation) values
  ('74000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   '72000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000012', 'Bon début', 'tentative');
select lives_ok($$insert into public.attendance (id, school_id, class_id, student_id, day, status) values
  ('75000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'c1000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000012', '2025-11-03', 'absent')$$,
  'enseignant de la classe : présences');

-- Autre enseignante : rien.
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.preschool_evaluations), 0, 'autre enseignant : ne voit pas les évaluations');
select throws_ok($$insert into public.preschool_evaluations (school_id, period_id, student_id, domain_id, level_id) values
  ('10000000-0000-4000-8000-000000000001', '72000000-0000-4000-8000-000000000001',
   'd0000000-0000-4000-8000-000000000011', '70000000-0000-4000-8000-000000000001',
   '71000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'autre enseignant : n''évalue pas cette classe');
select throws_ok($$insert into public.attendance (school_id, class_id, student_id, day, status) values
  ('10000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001',
   'd0000000-0000-4000-8000-000000000011', '2025-11-03', 'present')$$,
  '42501', null, 'autre enseignant : ne fait pas l''appel de cette classe');

-- Directeur : observation du livret.
select set_config('request.jwt.claims', :'dir1', true);
select is((select observation from public.preschool_booklets where id = '74000000-0000-4000-8000-000000000001'),
  null, 'l''observation envoyée par l''enseignant est ignorée');
update public.preschool_booklets set observation = 'Enfant épanoui' where id = '74000000-0000-4000-8000-000000000001';
select is((select (teacher_appreciation, observation)::text from public.preschool_booklets
            where id = '74000000-0000-4000-8000-000000000001'),
  '("Bon début","Enfant épanoui")', 'directeur : observation du livret');
select is((select count(*)::int from public.audit_log where table_name = 'preschool_booklets'), 2,
  'livrets dans le journal d''activité');

-- Désactivation : tout disparaît, rien n'est effacé.
update public.school_modules set enabled = false where module_key = 'maternelle' and school_id = :ecole;
select is((select count(*)::int from public.preschool_evaluations) + (select count(*)::int from public.learning_domains)
          + (select count(*)::int from public.classes where level_code = 'GS'), 0,
  'module désactivé : domaines, évaluations et classe de maternelle invisibles');
reset role;
select is((select count(*)::int from public.preschool_evaluations), 1, 'les données restent conservées');

select * from finish();
rollback;
