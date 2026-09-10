-- =============================================================================
-- Atelier+ — Migration Phase 4 : suivi des dépenses
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase.
--
-- Nouvelle table `depenses`, rattachée directement à l'atelier (pas à un
-- client, contrairement à `paiements`). Réservée au propriétaire, comme le
-- reste des finances — même schéma d'accès que `commandes`/`paiements`
-- (voir schema.sql). Aucune remise à zéro n'est nécessaire pour changer
-- d'année : le "récapitulatif annuel" de l'application filtre simplement
-- l'historique complet par période, sans jamais rien supprimer.
-- =============================================================================

create table if not exists public.depenses (
  id            uuid primary key default gen_random_uuid(),
  atelier_id    uuid not null references public.ateliers (id) on delete cascade,
  montant       numeric(12, 2) not null check (montant > 0),
  description   text,
  date_depense  timestamptz not null default now(),
  created_at    timestamptz not null default now()
);

create index if not exists idx_depenses_atelier on public.depenses (atelier_id);

alter table public.depenses enable row level security;

create policy "depenses_select_proprietaire_uniquement"
  on public.depenses for select
  using (
    public.mon_role() = 'proprietaire'
    and atelier_id = public.mon_atelier_id()
  );

create policy "depenses_insert_proprietaire_uniquement"
  on public.depenses for insert
  with check (
    public.mon_role() = 'proprietaire'
    and atelier_id = public.mon_atelier_id()
  );

-- Pas de policy UPDATE ni DELETE : une dépense erronée se corrige par une
-- nouvelle dépense, comme pour `paiements`.
