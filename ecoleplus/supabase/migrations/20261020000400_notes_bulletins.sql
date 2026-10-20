-- =====================================================================
-- Matières, compositions, notes, mentions, bulletins, emploi du temps
-- (modules 5, 6, 7). Les calculs (moyennes, total des points, rang) sont
-- faits par l'application à partir de ces tables : aucune valeur calculée
-- n'est stockée ici, sauf le résultat annuel figé (annual_results).
-- =====================================================================

create table public.subjects (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  name text not null,
  cycle text not null default 'primaire' check (cycle in ('maternelle', 'primaire')),
  sort_order smallint not null default 0,
  default_coefficient numeric(4, 2) not null default 1 check (default_coefficient >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, cycle, name)
);

-- Coefficient par matière et par classe (1 par défaut ; 0 autorisé).
create table public.class_subjects (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  class_id uuid not null references public.classes (id),
  subject_id uuid not null references public.subjects (id),
  coefficient numeric(4, 2) not null default 1 check (coefficient >= 0),
  teacher_id uuid references public.teachers (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (class_id, subject_id)
);

-- Composition 1, 2, 3 ou autre évaluation paramétrable.
create table public.assessments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  class_id uuid not null references public.classes (id),
  school_year_id uuid not null references public.school_years (id),
  label text not null,
  kind text not null default 'composition' check (kind in ('composition', 'evaluation')),
  sequence smallint not null default 1,
  held_on date,
  max_score numeric(5, 2) not null default 10 check (max_score > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (class_id, label)
);

create table public.grades (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  assessment_id uuid not null references public.assessments (id),
  student_id uuid not null references public.students (id),
  subject_id uuid not null references public.subjects (id),
  score numeric(5, 2) check (score >= 0),
  -- 'note' : note saisie ; 'absent' : absent à l'épreuve ; 'dispense'.
  status text not null default 'note' check (status in ('note', 'absent', 'dispense')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (assessment_id, student_id, subject_id),
  check ((status = 'note') = (score is not null))
);

-- Une note hors barème est refusée au niveau des données.
create or replace function app.check_grade_scale() returns trigger
language plpgsql as $$
declare
  v_max numeric;
begin
  if new.score is null then
    return new;
  end if;
  select max_score into v_max from public.assessments where id = new.assessment_id;
  if new.score > v_max then
    raise exception 'Note hors barème : % sur %.', new.score, v_max using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger grades_check_scale
  before insert or update of score, assessment_id on public.grades
  for each row execute function app.check_grade_scale();

-- Mentions / appréciations automatiques par tranche de moyenne (paramétrable).
create table public.mention_scales (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  min_average numeric(5, 2) not null,
  max_average numeric(5, 2) not null,
  label text not null,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  check (min_average <= max_average)
);

create table public.report_templates (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  name text not null,
  settings jsonb not null default '{}'::jsonb,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- Bulletin d'un élève pour une composition (assessment_id) ou annuel (null).
create table public.report_cards (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  class_id uuid not null references public.classes (id),
  assessment_id uuid references public.assessments (id),
  template_id uuid references public.report_templates (id),
  teacher_appreciation text,
  director_observation text,
  decision text,
  status text not null default 'brouillon'
    check (status in ('brouillon', 'genere', 'imprime', 'signe_archive')),
  generated_at timestamptz,
  pdf_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique nulls not distinct (student_id, class_id, assessment_id)
);

create table public.timetable_slots (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  class_id uuid not null references public.classes (id),
  weekday smallint not null check (weekday between 1 and 7),
  starts_at time not null,
  ends_at time not null,
  subject_id uuid references public.subjects (id),
  activity_label text,
  teacher_id uuid references public.teachers (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  check (starts_at < ends_at),
  check (subject_id is not null or activity_label is not null)
);
