-- =====================================================================
-- Classes, élèves, parents/tuteurs, inscriptions, résultats annuels,
-- suites de fiche de scolarité, absences (modules 3, 4, 9 ; B2 et B4).
-- =====================================================================

create table public.classes (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  level_code text not null references public.levels (code),
  name text not null,
  main_teacher_id uuid references public.teachers (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_year_id, name)
);

-- B1 « Service/classe tenue » et « Fonction ou poste occupé », par année.
create table public.teacher_year_assignments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  teacher_id uuid not null references public.teachers (id),
  class_id uuid references public.classes (id),
  service_label text,     -- texte libre si le service n'est pas une classe
  fonction text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_year_id, teacher_id)
);

create table public.students (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  last_name text not null,
  first_names text not null,
  sex text check (sex in ('F', 'M')),
  birth_date date,
  birth_place text,
  student_code text,                 -- identifiant élève (carte scolaire)
  -- B2 col. 1 « Numéro d'ordre » (= « N° Mle » de B4, à confirmer) :
  -- attribué par le serveur, une seule fois, jamais réutilisé.
  registry_number integer check (registry_number > 0),
  registry_provisional text,         -- numéro provisoire affiché hors ligne
  domicile text,                     -- B4 « Domicilié à »
  entry_date date,                   -- B2 col. 6 / B4 « Entré le »
  origin_school text,                -- B4 « Venant de »
  exit_date date,                    -- B2 col. 8 / B4 « Sorti le »
  destination text,                  -- B4 « allant à »
  exit_reason text,                  -- B4 « Motif du départ »
  cep_date date,                     -- B2 col. 7
  diplomas text,                     -- B4 « Diplômes obtenus et date d'obtention »
  director_observations text,        -- B4 « Observations du Directeur »
  registry_observations text,        -- B2 col. 9
  observations text,                 -- fiche élève (dictable)
  race text,                         -- B4, facultatif, masqué par défaut
  religion text,                     -- B4, facultatif, masqué par défaut
  photo_path text,
  photo_updated_at timestamptz,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, registry_number)
);
create unique index students_code_uq on public.students (school_id, student_code)
  where student_code is not null;
create index students_name_trgm on public.students
  using gin ((lower(last_name || ' ' || first_names)) extensions.gin_trgm_ops);

-- Attribution du numéro d'ordre : séquence serveur continue ; un numéro fourni
-- (reprise d'un registre papier) est accepté et fait avancer le compteur.
create or replace function app.assign_registry_number() returns trigger
language plpgsql as $$
begin
  if tg_op = 'UPDATE' then
    if old.registry_number is not null and new.registry_number is distinct from old.registry_number then
      raise exception 'Le numéro d''ordre du registre matricule ne peut pas être modifié.' using errcode = 'P0001';
    end if;
    if new.registry_number is null then
      new.registry_number := app.next_counter(new.school_id, 'registre_matricule');
    end if;
    return new;
  end if;
  if new.registry_number is null then
    new.registry_number := app.next_counter(new.school_id, 'registre_matricule');
  else
    perform app.bump_counter(new.school_id, 'registre_matricule', new.registry_number);
  end if;
  return new;
end $$;

create trigger students_registry_number
  before insert or update of registry_number on public.students
  for each row execute function app.assign_registry_number();

-- Parents, tuteurs, logeur (B2 col. 4-5 ; B4 « Fils ou fille de », « Nom et adresse du logeur »).
create table public.guardians (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  relation text not null check (relation in ('pere', 'mere', 'tuteur', 'logeur', 'autre')),
  full_name text not null,
  profession text,
  domicile text,
  address text,
  phone text,
  is_lodger boolean not null default false,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- Affectation d'un élève à une classe pour une année (changement de classe,
-- redoublement, mutation en cours d'année).
create table public.enrollments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  class_id uuid not null references public.classes (id),
  school_year_id uuid not null references public.school_years (id),
  level_code text not null references public.levels (code),
  starts_on date,
  ends_on date,
  end_reason text,
  is_repeat boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (student_id, class_id)
);

-- Résultats annuels conservés (alimentent B4 : « Moyenne générale »,
-- « Classement » au format 7e/39, « Date »).
create table public.annual_results (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  school_year_id uuid not null references public.school_years (id),
  class_id uuid references public.classes (id),
  level_code text not null references public.levels (code),
  attempt smallint not null default 1 check (attempt in (1, 2)),  -- 2 = redoublement
  result_date date,
  general_average numeric(5, 2),
  rank integer check (rank > 0),
  rank_ex_aequo boolean not null default false,
  class_size integer check (class_size > 0),
  decision text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (student_id, school_year_id),
  check (rank is null or class_size is null or rank <= class_size)
);

-- B4 : blocs de suite (établissements suivants, en cas de mutation).
create table public.scolarity_followups (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  sort_order smallint not null default 1,
  registry_number text,          -- « N° Mle » dans l'autre établissement
  school_name text,
  lodger_name_address text,
  entered_on date,
  came_from text,
  left_on date,
  going_to text,
  exit_reason text,
  diplomas text,
  director_observations text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

create table public.scolarity_followup_courses (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  followup_id uuid not null references public.scolarity_followups (id),
  level_code text not null references public.levels (code),
  attempt smallint not null default 1 check (attempt in (1, 2)),
  result_date date,
  ranking_text text,             -- ex. « 7e/39 »
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (followup_id, level_code, attempt)
);

-- Absences : fusion par (élève, date) lors de la synchronisation (R3).
create table public.attendance (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  class_id uuid not null references public.classes (id),
  student_id uuid not null references public.students (id),
  day date not null,
  status text not null check (status in ('present', 'absent', 'retard')),
  reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (student_id, day)
);
