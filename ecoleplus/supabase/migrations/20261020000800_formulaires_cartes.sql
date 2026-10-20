-- =====================================================================
-- Formulaires officiels (module 17 ; B1 à B7) : suivi, versions,
-- programme d'activités / bilan, copies conformes ; cartes scolaires (12).
-- =====================================================================

create table public.official_forms (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  form_code text not null check (form_code in ('B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7')),
  student_id uuid references public.students (id),   -- B4 (et B5) : une fiche par élève
  status text not null default 'a_completer'
    check (status in ('a_completer', 'complet', 'imprime', 'signe_archive')),
  reference_date date,       -- B1 : date de référence du calcul des anciennetés
  register_period_from date, -- B2 couverture : « admis à l'école du … »
  register_period_to date,   -- B2 couverture : « … au … »
  signed_place text,         -- « Fait à … »
  signed_on date,            -- « … le … »
  director_name text,
  signed_scan_document_id uuid,   -- copie signée et scannée (archives, phase 9)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique nulls not distinct (school_year_id, form_code, student_id)
);

-- Version finale verrouillée : toute modification crée une nouvelle version.
create table public.form_versions (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  form_id uuid not null references public.official_forms (id),
  version_no integer not null check (version_no > 0),
  is_final boolean not null default false,
  is_certified_copy boolean not null default false,   -- « copie conforme » (B4)
  snapshot jsonb not null,    -- valeurs imprimées, y compris les retouches avant impression
  pdf_path text,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  synced_at timestamptz not null default now(),
  unique (form_id, version_no)
);

create or replace function app.lock_final_form_version() returns trigger
language plpgsql as $$
begin
  if old.is_final then
    raise exception 'Version finale verrouillée : créez une nouvelle version.' using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger form_versions_lock_final
  before update or delete on public.form_versions
  for each row execute function app.lock_final_form_version();

-- B6 / B7 : un seul jeu de lignes « objectif → activités ».
create table public.activity_objectives (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  order_no integer not null check (order_no > 0),     -- « N° d'ordre »
  label text not null,                                 -- « Objectifs »
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_year_id, order_no)
);

create table public.activity_lines (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  objective_id uuid not null references public.activity_objectives (id),
  sort_order smallint not null default 0,
  planned_activity text not null,     -- « Activités prévues » (B6, B7)
  deadline_on date,                   -- « Échéances » (B6)
  deadline_text text,                 -- échéance exprimée en texte si besoin
  constraint_text text,               -- « Contrainte de réalisation » (B6)
  expected_result text,               -- « Résultats attendus » (B6, B7)
  achieved_result text,               -- « Résultats atteints » (B7)
  success_rate numeric(5, 2) check (success_rate between 0 and 100),  -- « Taux de réussite » (B7)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- Journal des générations de fiche de scolarité / copies conformes (ajout seul).
create table public.scolarity_copy_log (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  form_version_id uuid references public.form_versions (id),
  is_certified_copy boolean not null,
  generated_by uuid,
  generated_at timestamptz not null default now()
);

-- ---------------------------- Cartes ---------------------------------
create table public.card_templates (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  name text not null,
  primary_color text not null default '#1B6E3C' check (primary_color ~ '^#[0-9A-Fa-f]{6}$'),
  secondary_color text not null default '#FFFFFF' check (secondary_color ~ '^#[0-9A-Fa-f]{6}$'),
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- Le QR code ne contient que qr_token (identifiant opaque aléatoire).
create table public.student_cards (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  school_year_id uuid not null references public.school_years (id),
  qr_token text not null unique default encode(extensions.gen_random_bytes(16), 'hex'),
  generated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (student_id, school_year_id)
);
