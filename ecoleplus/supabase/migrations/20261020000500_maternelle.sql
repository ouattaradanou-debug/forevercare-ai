-- =====================================================================
-- Maternelle (module 8, OPTIONNEL) : domaines, niveaux qualitatifs,
-- périodes, évaluations, livrets. Pas de note chiffrée.
-- Le blocage « module désactivé » (écritures refusées) arrive en phase 1.
-- =====================================================================

create table public.learning_domains (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  name text not null,
  sort_order smallint not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, name)
);

-- Niveaux qualitatifs (ex. acquis / en cours / non acquis) : couleur ET pictogramme.
create table public.qualitative_levels (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  code text not null,
  label text not null,
  color_hex text not null check (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
  icon_key text not null,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, code)
);

create table public.preschool_periods (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  class_id uuid not null references public.classes (id),
  school_year_id uuid not null references public.school_years (id),
  label text not null,
  sequence smallint not null default 1,
  ends_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (class_id, label)
);

create table public.preschool_evaluations (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  period_id uuid not null references public.preschool_periods (id),
  student_id uuid not null references public.students (id),
  domain_id uuid not null references public.learning_domains (id),
  level_id uuid not null references public.qualitative_levels (id),
  comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (period_id, student_id, domain_id)
);

create table public.preschool_booklets (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  period_id uuid not null references public.preschool_periods (id),
  student_id uuid not null references public.students (id),
  teacher_appreciation text,
  observation text,
  status text not null default 'brouillon'
    check (status in ('brouillon', 'genere', 'imprime', 'signe_archive')),
  pdf_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (period_id, student_id)
);
