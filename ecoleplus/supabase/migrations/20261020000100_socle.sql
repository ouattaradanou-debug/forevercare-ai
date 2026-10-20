-- =====================================================================
-- EcolePlus — Socle : extensions, utilitaires, école, années, en-têtes,
-- options (modules), comptes, appareils, compteurs, journaux.
-- Conventions (voir docs/ARCHITECTURE.md §4) :
--   * id UUID généré côté client (gen_random_uuid() seulement par défaut) ;
--   * updated_at = horloge de l'appareil (règle « dernière modification
--     gagne »), synced_at = horloge du serveur (trigger) ;
--   * deleted_at = suppression logique ; la suppression physique est
--     refusée par trigger sur les données scolaires et financières ;
--   * énumérations en texte + CHECK (simples à reproduire dans Drift).
-- =====================================================================

create extension if not exists vector with schema extensions;
create extension if not exists pg_trgm with schema extensions;
create extension if not exists unaccent with schema extensions;

create schema if not exists app;

-- ---------------------------------------------------------------------
-- Fonctions utilitaires génériques
-- ---------------------------------------------------------------------
create or replace function app.touch_synced_at() returns trigger
language plpgsql as $$
begin
  new.synced_at := now();
  return new;
end $$;

create or replace function app.forbid_delete() returns trigger
language plpgsql as $$
begin
  raise exception 'Suppression physique interdite sur %. Utilisez l''archivage (deleted_at).', tg_table_name
    using errcode = 'P0001';
end $$;

create or replace function app.forbid_update() returns trigger
language plpgsql as $$
begin
  raise exception 'Écriture inaltérable sur % : corrigez par une écriture d''annulation motivée.', tg_table_name
    using errcode = 'P0001';
end $$;

-- ---------------------------------------------------------------------
-- Référentiel des niveaux (global, non synchronisé par école)
-- ---------------------------------------------------------------------
create table public.levels (
  code text primary key,
  cycle text not null check (cycle in ('maternelle', 'primaire')),
  label text not null,
  sort_order smallint not null unique
);

-- Terminologie de la maternelle : à confirmer avec les usages officiels.
insert into public.levels (code, cycle, label, sort_order) values
  ('PS', 'maternelle', 'Petite section', 1),
  ('MS', 'maternelle', 'Moyenne section', 2),
  ('GS', 'maternelle', 'Grande section', 3),
  ('CP1', 'primaire', 'CP1', 4),
  ('CP2', 'primaire', 'CP2', 5),
  ('CE1', 'primaire', 'CE1', 6),
  ('CE2', 'primaire', 'CE2', 7),
  ('CM1', 'primaire', 'CM1', 8),
  ('CM2', 'primaire', 'CM2', 9);

-- ---------------------------------------------------------------------
-- École (module 1)
-- ---------------------------------------------------------------------
create table public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  commune text,
  departement text,
  province text,
  region text,
  school_type text not null default 'publique' check (school_type in ('publique', 'privee')),
  phone text,
  email text,
  address text,
  director_name text,
  logo_path text,
  director_signature_path text,
  stamp_path text,
  manages_primary boolean not null default true,
  manages_preschool boolean not null default false,
  -- Barème par défaut des notes (hypothèse : sur 10, paramétrable).
  grading_scale numeric(5, 2) not null default 10 check (grading_scale > 0),
  -- Champs « race » et « religion » de la fiche de scolarité : masqués par défaut.
  show_race_religion boolean not null default false,
  -- Quota de la bibliothèque (défaut 5 Go, à confirmer après mesures).
  library_quota_bytes bigint not null default 5368709120 check (library_quota_bytes >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  check (manages_primary or manages_preschool)
);

create table public.school_years (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  label text not null check (label ~ '^\d{4}-\d{4}$'),
  starts_on date,
  ends_on date,
  is_current boolean not null default false,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, label)
);
create unique index school_years_one_current on public.school_years (school_id) where is_current;

-- En-têtes administratifs : un jeu par école ET par année scolaire (jamais en dur).
create table public.admin_headers (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  country text not null default 'BURKINA FASO',
  motto text,
  ministry text,
  region text,
  regional_direction text,
  provincial_direction text,
  ceb text,                -- circonscription d'éducation de base
  province text,
  departement text,
  commune text,
  school_label text,
  emblem_path text,        -- image d'en-tête fournie par l'école
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_year_id)
);

-- Options de l'école (module 0) : tous désactivés par défaut (R11).
-- P6 (Finances, Cartes, Bibliothèque IA activables) reporté : non listés ici.
create table public.school_modules (
  school_id uuid not null references public.schools (id),
  module_key text not null check (module_key in ('maternelle', 'cantine', 'medico_scolaire')),
  enabled boolean not null default false,
  changed_at timestamptz not null default now(),
  changed_by uuid,
  synced_at timestamptz not null default now(),
  primary key (school_id, module_key)
);

-- ---------------------------------------------------------------------
-- Comptes, profils et droits délégués
-- ---------------------------------------------------------------------
create table public.memberships (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  user_id uuid not null references auth.users (id),
  role text not null check (role in ('directeur', 'enseignant', 'delegue')),
  teacher_id uuid,         -- clé étrangère ajoutée avec la table teachers
  display_name text not null,
  phone text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, user_id)
);

create table public.delegate_permissions (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  membership_id uuid not null references public.memberships (id),
  permission_key text not null check (permission_key in (
    'finances', 'cartes', 'eleves', 'registres', 'formulaires', 'archives', 'cantine'
  )),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (membership_id, permission_key)
);

-- Appareils : chaque téléphone reçoit une « série » (A, B, …) en ligne,
-- qui permet ensuite de numéroter reçus et mouvements hors ligne sans collision.
create table public.devices (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  user_id uuid references auth.users (id),
  label text not null,
  series_code text not null check (series_code ~ '^[A-Z]{1,2}$'),
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, series_code)
);

-- Compteurs côté serveur (numéro d'ordre du registre matricule, etc.).
create table public.school_counters (
  school_id uuid not null references public.schools (id),
  counter_key text not null,
  last_value bigint not null default 0 check (last_value >= 0),
  primary key (school_id, counter_key)
);

create or replace function app.next_counter(p_school uuid, p_key text) returns bigint
language plpgsql as $$
declare
  v bigint;
begin
  insert into public.school_counters as c (school_id, counter_key, last_value)
  values (p_school, p_key, 1)
  on conflict (school_id, counter_key) do update set last_value = c.last_value + 1
  returning last_value into v;
  return v;
end $$;

-- Garantit qu'un compteur n'est jamais en dessous d'une valeur déjà utilisée
-- (import d'un registre papier existant, par exemple).
create or replace function app.bump_counter(p_school uuid, p_key text, p_value bigint) returns void
language sql as $$
  insert into public.school_counters as c (school_id, counter_key, last_value)
  values (p_school, p_key, p_value)
  on conflict (school_id, counter_key) do update set last_value = greatest(c.last_value, excluded.last_value);
$$;

-- ---------------------------------------------------------------------
-- Journaux (ajout seul)
-- ---------------------------------------------------------------------
create table public.audit_log (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  occurred_at timestamptz not null default now(),
  actor_id uuid,
  action text not null,
  table_name text,
  row_id uuid,
  details jsonb
);

-- Trace des conflits « dernière modification gagne » (R3).
create table public.sync_conflicts (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  table_name text not null,
  row_id uuid not null,
  winner jsonb not null,
  loser jsonb not null,
  loser_device_id uuid,
  detected_at timestamptz not null default now()
);
