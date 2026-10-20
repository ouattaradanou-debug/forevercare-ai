-- Preuve que le schéma suffit à calculer moyenne, total des points, rang
-- (avec ex-aequo) et effectif. La logique de référence sera écrite en Dart
-- (phase 3, utilisable hors ligne) et testée contre ces mêmes résultats.
-- Hypothèses (à valider) : une épreuve « absent » et une matière sans note
-- sont exclues du calcul ; un coefficient nul n'influence pas la moyenne.
begin;
select plan(4);

create temp view classement_cm1_compo1 as
with subj as (
  select g.student_id, g.subject_id, avg(g.score) as moyenne
    from public.grades g
   where g.assessment_id = 'f0000000-0000-4000-8000-000000000001' and g.status = 'note'
   group by 1, 2
), gen as (
  select e.student_id,
         sum(s.moyenne * cs.coefficient) as total,
         sum(cs.coefficient) filter (where s.moyenne is not null) as coefs
    from public.enrollments e
    left join subj s on s.student_id = e.student_id
    left join public.class_subjects cs on cs.class_id = e.class_id and cs.subject_id = s.subject_id
   where e.class_id = 'c0000000-0000-4000-8000-000000000002'
   group by 1
), moy as (
  select student_id, round(total, 2) as total, round(total / nullif(coefs, 0), 2) as moyenne from gen
)
select st.first_names, m.total, m.moyenne,
       rank() over (order by m.moyenne desc) as rang
  from moy m join public.students st on st.id = m.student_id
 where m.moyenne is not null;

select results_eq(
  'select first_names, total, moyenne, rang::int from classement_cm1_compo1 order by rang, first_names',
  $$values ('Aïcha', 21.00::numeric, 7.00::numeric, 1),
           ('Boukary', 18.00, 6.00, 2),
           ('Clarisse', 18.00, 6.00, 2),
           ('Daouda', 11.00, 5.50, 4)$$,
  'CM1 / Composition 1 : 2e ex-aequo puis 4e, coefficient nul et matière sans note ignorés');

select is(
  (select count(*)::int from public.enrollments where class_id = 'c0000000-0000-4000-8000-000000000002'),
  4, 'effectif de la classe (CM1 A)');

select is(
  (select array[max(moyenne), min(moyenne), round(avg(moyenne), 2)] from classement_cm1_compo1),
  array[7.00, 5.50, 6.13]::numeric[], 'meilleure moyenne, moyenne minimale, moyenne de la classe');

select is(
  (select rank || 'e/' || class_size from public.annual_results
    where student_id = 'd0000000-0000-4000-8000-000000000005'),
  '7e/39', 'résultat annuel conservé au format « 7e/39 » pour la fiche de scolarité');

select * from finish();
rollback;
