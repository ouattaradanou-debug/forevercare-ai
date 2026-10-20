-- =====================================================================
-- Dossier médico-scolaire (module 19, OPTIONNEL, SENSIBLE ; formulaire B5).
-- Schéma séparé « medical » : non exposé par l'API, aucun droit pour les
-- rôles anon/authenticated. L'accès passera par des fonctions dédiées
-- (directeur uniquement, journalisées) si le module est confirmé (phase 7).
-- Tous les champs sont facultatifs.
-- =====================================================================

create schema if not exists medical;
revoke all on schema medical from public, anon, authenticated;

create table medical.records (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null unique references public.students (id),
  -- A) I — Antécédents familiaux
  fam_diabete text,
  fam_asthme text,
  fam_hta text,
  fam_autres text,
  -- A) II a) — Antécédents personnels médicaux
  hemoglobine text,
  groupe_sanguin_rhesus text,
  diabete text,
  asthme text,
  rhinites_repetition text,
  angines_repetition text,
  trachome text,
  poliomyelite text,
  rougeole text,
  autres_medicaux text,
  -- Vaccinations
  vacc_bcg text,
  vacc_dtcp text,
  vacc_antirougeoleux text,
  vacc_antiamarile text,
  vacc_antimeningococcique text,
  -- A) II b) — Antécédents chirurgicaux
  antecedents_chirurgicaux text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- B) I — Constantes et B) II — Examen physique, une ligne par année (8 sur le modèle).
create table medical.yearly_exams (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  record_id uuid not null references medical.records (id),
  year_label text not null,
  urines_alb text,
  urines_sucre text,
  av_od text,
  av_og text,
  aa_od text,
  aa_og text,
  poids text,
  taille text,
  examen_physique text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (record_id, year_label)
);

-- OBSERVATIONS (aptitude) : seule information exposable à l'enseignant, si le directeur l'active.
create table medical.fitness (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  school_year_id uuid not null references public.school_years (id),
  aptitude text not null check (aptitude in (
    'apte', 'a_surveiller', 'inapte_temporaire', 'inapte_definitif'
  )),
  expose_to_teacher boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (student_id, school_year_id)
);

-- Journal d'accès (qui, quand, quel élève, quoi) — ajout seul.
create table medical.access_log (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  actor_id uuid,
  student_id uuid references public.students (id),
  action text not null,
  allowed boolean not null,
  occurred_at timestamptz not null default now()
);
