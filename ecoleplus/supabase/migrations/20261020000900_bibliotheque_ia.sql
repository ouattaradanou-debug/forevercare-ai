-- =====================================================================
-- Bibliothèque pédagogique, archives administratives (module 18) et
-- IA pédagogique (module 11). L'index (passages, vecteurs) obéit aux mêmes
-- règles d'accès que les documents (RLS en phase 9). Les archives et les
-- documents sensibles ne reçoivent jamais de vecteur (trigger ci-dessous).
-- =====================================================================

create table public.documents (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  space text not null check (space in ('bibliotheque', 'archives')),
  title text not null,
  is_common boolean not null default false,    -- « commun à l'école »
  subject_id uuid references public.subjects (id),
  doc_type text,
  school_year_id uuid references public.school_years (id),
  source_author text,
  keywords text[] not null default '{}',
  storage_path text,
  mime_type text,
  size_bytes bigint check (size_bytes >= 0),
  sha256 text check (sha256 ~ '^[0-9a-f]{64}$'),
  page_count integer,
  ai_allowed boolean not null default true,
  is_sensitive boolean not null default false,
  index_status text not null default 'en_attente'
    check (index_status in ('en_attente', 'indexe', 'echec', 'exclu')),
  index_error text,
  index_cost_microusd bigint,
  indexed_at timestamptz,
  approved boolean not null default true,      -- validation optionnelle des ajouts enseignants
  trashed_at timestamptz,                       -- corbeille (30 jours, à valider)
  uploaded_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  -- Archives : jamais pour l'IA, non modifiable.
  check (space <> 'archives' or ai_allowed = false)
);
create unique index documents_sha256_uq on public.documents (school_id, sha256)
  where sha256 is not null and deleted_at is null;

create table public.document_levels (
  document_id uuid not null references public.documents (id) on delete cascade,
  level_code text not null references public.levels (code),
  school_id uuid not null references public.schools (id),
  primary key (document_id, level_code)
);

create table public.document_classes (
  document_id uuid not null references public.documents (id) on delete cascade,
  class_id uuid not null references public.classes (id),
  school_id uuid not null references public.schools (id),
  primary key (document_id, class_id)
);

-- Passages : texte intégral (recherche) + vecteur (IA, documents autorisés seulement).
-- Dimension 1024 provisoire : fixée définitivement en phase 9 selon le modèle retenu.
create table public.document_chunks (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  document_id uuid not null references public.documents (id) on delete cascade,
  page integer,
  chunk_index integer not null,
  content text not null,
  tsv tsvector generated always as (to_tsvector('french', content)) stored,
  embedding extensions.vector(1024),
  created_at timestamptz not null default now(),
  unique (document_id, chunk_index)
);
create index document_chunks_tsv on public.document_chunks using gin (tsv);

create or replace function app.check_chunk_ai_eligibility() returns trigger
language plpgsql as $$
declare
  d public.documents;
begin
  if new.embedding is null then
    return new;
  end if;
  select * into d from public.documents where id = new.document_id;
  if d.space <> 'bibliotheque' or not d.ai_allowed or d.is_sensitive then
    raise exception 'Document exclu de l''IA : aucun vecteur autorisé.' using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger document_chunks_ai_eligibility
  before insert or update of embedding on public.document_chunks
  for each row execute function app.check_chunk_ai_eligibility();

-- Préparations de cours, exercices, remédiations enregistrées.
create table public.lesson_preps (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  author_id uuid not null,
  kind text not null check (kind in ('preparation', 'exercices', 'remediation')),
  level_code text references public.levels (code),
  subject_id uuid references public.subjects (id),
  theme text,
  request jsonb not null default '{}'::jsonb,
  content jsonb not null default '{}'::jsonb,
  sources jsonb not null default '[]'::jsonb,   -- « Sources utilisées » (titre, page)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- Demandes à l'IA (conservées hors ligne puis envoyées via Edge Function).
create table public.ai_requests (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  user_id uuid not null,
  kind text not null,
  status text not null default 'en_attente'
    check (status in ('en_attente', 'envoyee', 'terminee', 'echec')),
  request jsonb not null,
  response jsonb,
  used_document_ids uuid[] not null default '{}',
  tokens_in integer,
  tokens_out integer,
  cost_microusd bigint,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

create table public.ai_quotas (
  school_id uuid primary key references public.schools (id),
  monthly_request_limit integer not null default 300 check (monthly_request_limit >= 0),
  monthly_budget_microusd bigint not null default 5000000 check (monthly_budget_microusd >= 0),
  updated_at timestamptz not null default now()
);

alter table public.official_forms
  add constraint official_forms_signed_scan_fk
  foreign key (signed_scan_document_id) references public.documents (id);
