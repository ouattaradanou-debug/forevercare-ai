-- Phase 13 : emploi du temps (lu par l'école, écrit par le directeur et
-- l'enseignant pour SA classe) ; appel du jour (l'enseignant de la classe,
-- le directeur corrige ; jamais une autre classe).
\set dir1 '{"sub":"a0000000-0000-4000-8000-000000000001","role":"authenticated"}'
\set ens1 '{"sub":"a0000000-0000-4000-8000-000000000002","role":"authenticated"}'
\set ens2 '{"sub":"a0000000-0000-4000-8000-000000000003","role":"authenticated"}'
\set dir2 '{"sub":"a0000000-0000-4000-8000-000000000009","role":"authenticated"}'
\set ecole '''10000000-0000-4000-8000-000000000001'''
\set cm1 '''c0000000-0000-4000-8000-000000000002'''
\set cm2 '''c0000000-0000-4000-8000-000000000003'''
begin;
select plan(11);

select ok((select table_name from app.sync_tables where table_name = 'timetable_slots') is not null,
  'emploi du temps synchronisé');

set local role authenticated;

-- Enseignante du CM1 : sa classe oui, le CM2 non.
select set_config('request.jwt.claims', :'ens1', true);
select lives_ok($$insert into public.timetable_slots (id, school_id, class_id, weekday, starts_at, ends_at, subject_id)
  values ('f1300000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
          'c0000000-0000-4000-8000-000000000002', 1, '07:30', '08:30', 'e0000000-0000-4000-8000-000000000001')$$,
  'enseignante : créneau de SA classe');
select throws_ok($$insert into public.timetable_slots (school_id, class_id, weekday, starts_at, ends_at, activity_label)
  values ('10000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000003', 1, '07:30', '08:30', 'Sport')$$,
  '42501', null, 'enseignante : jamais l''emploi du temps d''une autre classe');
select throws_ok($$insert into public.timetable_slots (school_id, class_id, weekday, starts_at, ends_at, activity_label)
  values ('10000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000002', 1, '09:00', '08:00', 'Récréation')$$,
  '23514', null, 'début avant la fin');

-- Enseignant du CM2 : lit l'emploi du temps de l'école, ne le modifie pas.
select set_config('request.jwt.claims', :'ens2', true);
select is((select count(*)::int from public.timetable_slots where class_id = :cm1), 1, 'lu par toute l''école');
update public.timetable_slots set activity_label = 'Piraté' where id = 'f1300000-0000-4000-8000-000000000001';
select is((select activity_label from public.timetable_slots where id = 'f1300000-0000-4000-8000-000000000001'),
  null, 'enseignant d''une autre classe : modification sans effet');

-- Directeur : copie vers le CM2.
select set_config('request.jwt.claims', :'dir1', true);
select lives_ok($$insert into public.timetable_slots (school_id, class_id, weekday, starts_at, ends_at, subject_id)
  select school_id, 'c0000000-0000-4000-8000-000000000003', weekday, starts_at, ends_at, subject_id
    from public.timetable_slots where class_id = 'c0000000-0000-4000-8000-000000000002'$$,
  'directeur : copie vers une autre classe');

-- Autre école : rien lu, rien écrit.
select set_config('request.jwt.claims', :'dir2', true);
select is((select count(*)::int from public.timetable_slots where school_id = :ecole), 0, 'autre école : rien');
select throws_ok($$insert into public.timetable_slots (school_id, class_id, weekday, starts_at, ends_at, activity_label)
  values ('10000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000002', 1, '07:30', '08:30', 'X')$$,
  '42501', null, 'classe d''une autre école refusée');

-- Appel : l'enseignante du CM1 ne note pas un élève du CM2.
select set_config('request.jwt.claims', :'ens1', true);
select lives_ok($$insert into public.attendance (school_id, class_id, student_id, day, status)
  values ('10000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000002',
          'd0000000-0000-4000-8000-000000000001', '2026-11-05', 'absent')$$, 'appel de sa classe');
select throws_ok($$insert into public.attendance (school_id, class_id, student_id, day, status)
  values ('10000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000003',
          'd0000000-0000-4000-8000-000000000005', '2026-11-05', 'absent')$$,
  '42501', null, 'jamais l''appel d''une autre classe');

select * from finish();
rollback;
