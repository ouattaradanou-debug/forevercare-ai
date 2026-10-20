-- =====================================================================
-- Personnel enseignant (module 2 ; formulaires B1 et B3).
-- Visible du directeur (et du délégué autorisé) uniquement : RLS en phase 1-2.
-- Aucune donnée de santé (rappel affiché sur les champs libres).
-- =====================================================================

create table public.teachers (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  last_name text not null,
  first_names text not null,
  sex text check (sex in ('F', 'M')),
  matricule text,
  phone text,
  birth_date date,
  birth_place text,
  emploi text,                          -- B1 « Emploi »
  categorie text,                       -- B1 « Catégorie »
  echelon text,                         -- B1 « Échelon »
  tenure_status text check (tenure_status in ('T', 'S')),  -- B3 col. 4
  status text not null default 'actif' check (status in ('actif', 'parti')),
  commune_nomination_date date,         -- B3 col. 3
  first_teaching_nomination_date date,  -- B3 col. 7
  pupil_school_name text,               -- B3 col. 6 « élève à l'école de »
  pupil_school_entry_date date,         -- B3 col. 6 (date d'entrée)
  pupil_school_exit_date date,          -- B3 col. 6 (date de sortie)
  -- Dates de départ des anciennetés (B1) : les durées sont calculées
  -- à une date de référence paramétrable (official_forms.reference_date).
  seniority_general_from date,
  seniority_emploi_from date,
  seniority_region_from date,
  seniority_fonction_from date,
  commune_cessation_date date,          -- B3 col. 12 (date)
  new_post text,                        -- B3 col. 12 (nouveau poste)
  observations text,                    -- B3 col. 13
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);
create unique index teachers_matricule_uq on public.teachers (school_id, matricule)
  where matricule is not null and deleted_at is null;

alter table public.memberships
  add constraint memberships_teacher_fk foreign key (teacher_id) references public.teachers (id);

-- B3 col. 8 : communes successives (plusieurs lignes par enseignant).
create table public.teacher_postings (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  teacher_id uuid not null references public.teachers (id),
  commune text not null,
  nominated_on date,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- B3 col. 9 : interruptions de service (causes et durées).
create table public.teacher_interruptions (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  teacher_id uuid not null references public.teachers (id),
  cause text not null,
  starts_on date,
  ends_on date,
  duration_text text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- B3 col. 10 : récompenses obtenues.
create table public.teacher_awards (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  teacher_id uuid not null references public.teachers (id),
  label text not null,
  awarded_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- B3 col. 11 : titres de capacité (nature et date) ;
-- B1 « Dernier diplôme académique » = le plus récent avec is_academic.
create table public.teacher_diplomas (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  teacher_id uuid not null references public.teachers (id),
  nature text not null,
  delivered_on date,
  is_academic boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);
