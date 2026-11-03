-- A22 : rubriques de frais propres à l'école.
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set sec1 '{"sub":"a0000000-0000-4000-8000-000000000004","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
begin;
select plan(10);
set local role authenticated;

select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$insert into public.fee_rubrics (id, school_id, code, label) values
  ('fa000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'carte_scolaire', 'Carte scolaire'),
  ('fa000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'frais_d_examen', 'Frais d''examen')$$,
  'directeur : rubriques ajoutées');
select lives_ok($$insert into public.fee_items (school_id, school_year_id, rubric, label, amount) values
  ('10000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000002025', 'frais_d_examen', 'Examen', 2000)$$,
  'frais dans une rubrique créée par l''école');
select throws_ok($$insert into public.fee_rubrics (school_id, code, label) values
  ('10000000-0000-4000-8000-000000000001', 'autre', 'Autre')$$, '23514', null,
  '« Autre » est réservée');
select throws_ok($$update public.fee_rubrics set deleted_at = now()
  where id = 'fa000000-0000-4000-8000-000000000002'$$, 'P0001', null,
  'rubrique utilisée : retrait refusé');
select lives_ok($$update public.fee_rubrics set deleted_at = now()
  where id = 'fa000000-0000-4000-8000-000000000001'$$, 'rubrique inutilisée : retirée');
update public.fee_rubrics set code = 'autre_code', label = 'Examens'
 where id = 'fa000000-0000-4000-8000-000000000002';
select is((select (code, label)::text from public.fee_rubrics where id = 'fa000000-0000-4000-8000-000000000002'),
  '(frais_d_examen,Examens)', 'renommée ; le code ne change jamais');

select set_config('request.jwt.claims', :'sec1', true);
select is((select count(*)::int from public.fee_rubrics), 2, 'économe : voit les rubriques');
select set_config('request.jwt.claims', :'ens1', true);
select is((select count(*)::int from public.fee_rubrics), 0, 'enseignant : rien');
select throws_ok($$insert into public.fee_rubrics (school_id, code, label) values
  ('10000000-0000-4000-8000-000000000001', 'xx', 'X')$$, '42501', null, 'enseignant : ajout refusé');
select set_config('request.jwt.claims', :'dir2', true);
select is((select count(*)::int from public.fee_rubrics), 0, 'autre école : rien');

select * from finish();
rollback;
