-- ============================================================================
-- Phase 2 — Produits & Stock
--
-- Enrichit les squelettes posés en Phase 1 (produits, stock) et ajoute
-- deux nouvelles tables :
--   - produits_couts : le prix d'achat, dans une table séparée avec ses
--     propres policies RLS (admin uniquement) — jamais dans `produits`,
--     lisible par tous les membres de la cave (point 18 du cahier des
--     charges : l'Agent de vente ne doit jamais voir le prix d'achat).
--   - mouvements_stock : journal append-only des variations de stock
--     (jamais de valeur absolue). Stratégie validée avec l'utilisateur en
--     Phase 2 (voir PHASE1.md section 7) : deux appareils qui modifient
--     le même produit hors ligne voient leurs deltas s'additionner tous
--     les deux au retour de connexion, au lieu que l'un écrase l'autre
--     (pas de Last-Write-Wins sur une quantité cumulative).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. produits : ajoute le nombre de bouteilles par carton (demandé
--    explicitement, nécessaire pour que quantite_cartons et
--    quantite_bouteilles aient un sens cohérent ensemble).
-- ----------------------------------------------------------------------------
alter table public.produits
  add column if not exists bouteilles_par_carton integer not null default 1
    check (bouteilles_par_carton > 0);

comment on column public.produits.bouteilles_par_carton is 'Nombre de bouteilles dans un carton de ce produit (ex: 12) — permet d''interpréter quantite_cartons/quantite_bouteilles ensemble.';

-- ----------------------------------------------------------------------------
-- 2. produits_couts : prix d'achat, table séparée, admin only (R/W).
--    Aucune policy pour Gérant/Agent -> refus RLS par défaut, pas un
--    simple masquage côté UI.
-- ----------------------------------------------------------------------------
create table public.produits_couts (
  produit_id uuid primary key references public.produits(id) on delete cascade,
  cave_id uuid not null references public.caves(id) on delete cascade,
  prix_achat bigint not null default 0 check (prix_achat >= 0),
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

comment on table public.produits_couts is 'Prix d''achat, séparé de `produits` : jamais visible par le Gérant ni l''Agent de vente (point 18 du cahier des charges).';

alter table public.produits_couts enable row level security;

grant select, insert, update, delete on public.produits_couts to authenticated;

create policy produits_couts_select on public.produits_couts
  for select using (cave_id = public.current_cave_id() and public.is_admin());

create policy produits_couts_write on public.produits_couts
  for all using (cave_id = public.current_cave_id() and public.is_admin())
  with check (cave_id = public.current_cave_id() and public.is_admin());

-- ----------------------------------------------------------------------------
-- 3. mouvements_stock : journal append-only des deltas de stock.
--    Mêmes rôles autorisés que `stock` (PROP/PG/GER en écriture, Agent
--    exclu). Aucune policy UPDATE ni DELETE : une fois créé, un mouvement
--    est immuable (corriger un mouvement se fait en en ajoutant un
--    nouveau, jamais en modifiant l'historique).
-- ----------------------------------------------------------------------------
create table public.mouvements_stock (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  produit_id uuid not null references public.produits(id) on delete cascade,
  delta_cartons integer not null default 0,
  delta_bouteilles integer not null default 0,
  motif text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

comment on table public.mouvements_stock is 'Journal append-only des mouvements de stock : chaque ligne est un DELTA (jamais une valeur absolue), pour permettre la fusion additive de deux appareils ayant modifié le même produit hors ligne. La table stock est recalculée par trigger à chaque insertion.';

alter table public.mouvements_stock enable row level security;

grant select, insert on public.mouvements_stock to authenticated;

create policy mouvements_stock_select on public.mouvements_stock
  for select using (
    cave_id = public.current_cave_id()
    and public.current_role() in ('proprietaire', 'proprietaire_gerant', 'gerant')
  );

create policy mouvements_stock_insert on public.mouvements_stock
  for insert with check (
    cave_id = public.current_cave_id()
    and public.current_role() in ('proprietaire', 'proprietaire_gerant', 'gerant')
  );

-- ----------------------------------------------------------------------------
-- 4. Trigger : applique chaque mouvement à `stock` en l'additionnant au
--    total existant (jamais en l'écrasant). `greatest(..., 0)` : filet de
--    sécurité pour ne jamais afficher un stock négatif si deux appareils
--    décrémentent au-delà du disponible hors ligne — l'écart réel reste
--    visible dans l'historique des mouvements pour réconciliation
--    manuelle (mécanisme de seuil/alerte non implémenté en Phase 2,
--    reporté si un usage réel le montre nécessaire).
--
--    Déclenché uniquement sur INSERT (jamais UPDATE) : c'est ce qui rend
--    la resynchronisation sûre en cas de retry réseau. Le client
--    (RemoteWriter générique) envoie chaque mouvement via `upsert` avec
--    un id généré côté client ; si le même mouvement est renvoyé deux
--    fois (accusé de réception perdu, pas l'écriture elle-même),
--    PostgreSQL traite la deuxième tentative comme une mise à jour d'une
--    ligne déjà existante (ON CONFLICT DO UPDATE), pas comme une nouvelle
--    insertion — le trigger AFTER INSERT ne se redéclenche donc pas, et
--    le delta n'est jamais appliqué deux fois.
-- ----------------------------------------------------------------------------
create or replace function public.appliquer_mouvement_stock() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.stock (cave_id, produit_id, quantite_cartons, quantite_bouteilles, updated_at, updated_by)
  values (
    new.cave_id, new.produit_id,
    greatest(new.delta_cartons, 0), greatest(new.delta_bouteilles, 0),
    now(), new.created_by
  )
  on conflict (produit_id) do update
    set quantite_cartons = greatest(public.stock.quantite_cartons + new.delta_cartons, 0),
        quantite_bouteilles = greatest(public.stock.quantite_bouteilles + new.delta_bouteilles, 0),
        updated_at = now(),
        updated_by = new.created_by;
  return new;
end;
$$;

create trigger trg_appliquer_mouvement_stock
  after insert on public.mouvements_stock
  for each row execute function public.appliquer_mouvement_stock();

-- ============================================================================
-- Fin de la migration 0007.
-- ============================================================================
