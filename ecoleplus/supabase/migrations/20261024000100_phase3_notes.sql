-- =====================================================================
-- Phase 3 — notes, moyennes et classement (primaire) : droits d'accès et
-- synchronisation. Les calculs sont faits sur le téléphone (hors ligne),
-- par le moteur Dart testé contre le contrôle SQL de la phase 0.
-- =====================================================================

-- Classe d'une composition (pour les droits sur les notes).
create or replace function app.assessment_class(p_assessment uuid) returns uuid
language sql stable security definer set search_path = '' as $$
  select class_id from public.assessments where id = p_assessment;
$$;

-- L'enseignant note seulement les élèves inscrits dans SA classe (année en
-- cours) ; le directeur note partout.
create or replace function app.can_grade(p_school uuid, p_assessment uuid, p_student uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select app.is_director(p_school) or exists (
    select 1 from public.enrollments e
     where e.student_id = p_student and e.deleted_at is null
       and e.class_id = app.assessment_class(p_assessment)
       and e.class_id in (select app.my_class_ids()));
$$;

-- Matières de l'école et mentions : lues par tous les membres, écrites par
-- le directeur.
create policy subjects_read on public.subjects for select to authenticated
  using (app.is_member(school_id));
create policy subjects_insert on public.subjects for insert to authenticated
  with check (app.is_director(school_id));
create policy subjects_update on public.subjects for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

create policy mention_scales_read on public.mention_scales for select to authenticated
  using (app.is_member(school_id));
create policy mention_scales_insert on public.mention_scales for insert to authenticated
  with check (app.is_director(school_id));
create policy mention_scales_update on public.mention_scales for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

-- Coefficients par classe : le directeur les fixe ; l'enseignant les lit.
create policy class_subjects_read on public.class_subjects for select to authenticated
  using (app.has_any_perm(school_id, array['registres', 'formulaires'])
         or class_id in (select app.my_class_ids()));
create policy class_subjects_insert on public.class_subjects for insert to authenticated
  with check (app.is_director(school_id));
create policy class_subjects_update on public.class_subjects for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

-- Compositions : le directeur et l'enseignant de la classe.
create policy assessments_read on public.assessments for select to authenticated
  using (app.has_any_perm(school_id, array['registres', 'formulaires'])
         or class_id in (select app.my_class_ids()));
create policy assessments_insert on public.assessments for insert to authenticated
  with check (app.is_director(school_id) or class_id in (select app.my_class_ids()));
create policy assessments_update on public.assessments for update to authenticated
  using (app.is_director(school_id) or class_id in (select app.my_class_ids()))
  with check (app.is_director(school_id) or class_id in (select app.my_class_ids()));

-- Notes : le directeur et l'enseignant de la classe, pour les élèves de la
-- classe seulement.
create policy grades_read on public.grades for select to authenticated
  using (app.has_any_perm(school_id, array['registres', 'formulaires'])
         or app.assessment_class(assessment_id) in (select app.my_class_ids()));
create policy grades_insert on public.grades for insert to authenticated
  with check (app.can_grade(school_id, assessment_id, student_id));
create policy grades_update on public.grades for update to authenticated
  using (app.can_grade(school_id, assessment_id, student_id))
  with check (app.can_grade(school_id, assessment_id, student_id));

-- Résultats annuels (fiche de scolarité, « 7e/39 ») : enregistrés par le
-- directeur à la clôture ; l'enseignant les lit pour ses élèves.
create policy annual_results_read on public.annual_results for select to authenticated
  using (app.has_any_perm(school_id, array['registres', 'formulaires'])
         or app.teacher_sees_student(student_id));
create policy annual_results_insert on public.annual_results for insert to authenticated
  with check (app.is_director(school_id));
create policy annual_results_update on public.annual_results for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

-- Barème : la vérification lit la composition avec les droits du
-- propriétaire (le trigger ne doit pas dépendre de ce que voit l'appelant),
-- et le message est lisible (« 11 sur 10 », virgule française).
create or replace function app.check_grade_scale() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_max numeric;
begin
  if new.score is null then
    return new;
  end if;
  select max_score into v_max from public.assessments where id = new.assessment_id;
  if new.score > v_max then
    raise exception 'Note hors barème : % sur %.',
      replace(trim_scale(new.score)::text, '.', ','), replace(trim_scale(v_max)::text, '.', ',')
      using errcode = 'P0001';
  end if;
  return new;
end $$;

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('subjects', 'lww', '{id}'),
  ('mention_scales', 'lww', '{id}'),
  ('class_subjects', 'lww', '{id}'),
  ('assessments', 'lww', '{id}'),
  ('grades', 'lww', '{id}'),
  ('annual_results', 'lww', '{id}');

do $$
declare
  t text;
begin
  foreach t in array array['subjects', 'class_subjects', 'assessments', 'annual_results'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;
