-- ============================================================================
-- Phase 3 — Vente & Commandes
--
-- Périmètre exact (voir PHASE1.md section 7 et 9, déjà planifié) : la
-- prise de commande par l'Agent de vente, hors ligne. La VALIDATION d'une
-- commande (qui décrémente le stock, transaction atomique commande+stock —
-- voir PHASE1.md section 7) et l'ENCAISSEMENT restent hors périmètre,
-- réservés à la Phase 4. Pour ne pas laisser cette frontière dépendre
-- uniquement de l'interface (un appel API direct pourrait la contourner),
-- la policy RLS d'UPDATE sur `commandes` autorise UNIQUEMENT la
-- transition 'en_attente' -> 'annulee' : aucune ligne ne peut passer à
-- 'validee' avant que la Phase 4 n'ajoute sa propre policy dédiée.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. clients : R/W ouvert à tous les rôles de la cave (y compris créer),
--    modification réservée aux responsables, suppression aux admins
--    seulement (matrice PHASE1.md section 9).
-- ----------------------------------------------------------------------------
create table public.clients (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  nom text not null check (char_length(trim(nom)) > 0),
  telephone text,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);

comment on table public.clients is 'Client optionnel rattaché à une commande (vente comptoir anonyme si absent).';

alter table public.clients enable row level security;

grant select, insert, update, delete on public.clients to authenticated;

create policy clients_select on public.clients
  for select using (cave_id = public.current_cave_id());

create policy clients_insert on public.clients
  for insert with check (cave_id = public.current_cave_id());

create policy clients_update on public.clients
  for update using (cave_id = public.current_cave_id() and public.is_responsable())
  with check (cave_id = public.current_cave_id() and public.is_responsable());

create policy clients_delete on public.clients
  for delete using (cave_id = public.current_cave_id() and public.is_admin());

-- ----------------------------------------------------------------------------
-- 2. commandes : une vente. `total` recalculé par trigger depuis
--    `commande_lignes` (même mécanisme AFTER INSERT que `mouvements_stock`
--    en Phase 2 : sûr en cas de retry réseau, voir commentaire section 3).
-- ----------------------------------------------------------------------------
create type public.statut_commande as enum ('en_attente', 'validee', 'annulee');

create table public.commandes (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  client_id uuid references public.clients(id) on delete set null,
  statut public.statut_commande not null default 'en_attente',
  total bigint not null default 0 check (total >= 0),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.commandes is 'Une vente. La validation (statut -> validee, décrément atomique du stock) est ajoutée en Phase 4 — voir la policy commandes_update qui bloque cette transition ici.';

alter table public.commandes enable row level security;

grant select, insert, update on public.commandes to authenticated;

-- Un responsable voit toutes les commandes de sa cave ; un Agent ne voit
-- que celles qu'il a lui-même créées (point 19 : traçabilité, pas de vue
-- d'ensemble pour l'Agent).
create policy commandes_select on public.commandes
  for select using (
    cave_id = public.current_cave_id()
    and (public.is_responsable() or created_by = auth.uid())
  );

-- Les 4 rôles peuvent créer une commande (matrice PHASE1.md section 9).
create policy commandes_insert on public.commandes
  for insert with check (
    cave_id = public.current_cave_id()
    and created_by = auth.uid()
  );

-- Seuls les responsables peuvent modifier une commande, et uniquement pour
-- l'annuler (jamais la valider depuis cette phase) : la ligne doit être
-- 'en_attente' avant, 'annulee' après. Aucune policy DELETE : une
-- commande n'est jamais supprimée, seulement annulée (traçabilité, même
-- principe que `clotures`/`mouvements_stock`).
create policy commandes_update on public.commandes
  for update using (
    cave_id = public.current_cave_id()
    and public.is_responsable()
    and statut = 'en_attente'
  )
  with check (
    cave_id = public.current_cave_id()
    and public.is_responsable()
    and statut = 'annulee'
  );

-- ----------------------------------------------------------------------------
-- 3. commande_lignes : lignes d'une commande, immuables une fois créées
--    (pas de policy UPDATE/DELETE — corriger = annuler la commande entière
--    et en recréer une, jamais modifier une ligne). Prix figés au moment
--    de la vente (`prix_detail_unitaire`/`prix_gros_unitaire`) : si le
--    catalogue change plus tard, l'historique des ventes reste exact.
-- ----------------------------------------------------------------------------
create table public.commande_lignes (
  id uuid primary key default gen_random_uuid(),
  commande_id uuid not null references public.commandes(id) on delete cascade,
  produit_id uuid not null references public.produits(id),
  quantite_cartons integer not null default 0 check (quantite_cartons >= 0),
  quantite_bouteilles integer not null default 0 check (quantite_bouteilles >= 0),
  prix_gros_unitaire bigint not null check (prix_gros_unitaire >= 0),
  prix_detail_unitaire bigint not null check (prix_detail_unitaire >= 0),
  sous_total bigint not null check (sous_total >= 0),
  created_at timestamptz not null default now(),
  check (
    quantite_cartons + quantite_bouteilles > 0
    and sous_total = quantite_cartons * prix_gros_unitaire
                    + quantite_bouteilles * prix_detail_unitaire
  )
);

comment on table public.commande_lignes is 'Une ligne de vente (un produit) dans une commande. sous_total est vérifié par contrainte, pas seulement calculé côté client.';

alter table public.commande_lignes enable row level security;

grant select, insert on public.commande_lignes to authenticated;

-- Hérite de la visibilité de la commande parente (matrice : "idem" pour
-- les 4 rôles).
create policy commande_lignes_select on public.commande_lignes
  for select using (
    exists (
      select 1 from public.commandes c
      where c.id = commande_lignes.commande_id
        and c.cave_id = public.current_cave_id()
        and (public.is_responsable() or c.created_by = auth.uid())
    )
  );

-- Une ligne ne peut être ajoutée que par le créateur de la commande
-- parente, et seulement tant qu'elle est encore 'en_attente' (jamais sur
-- une commande déjà annulée).
create policy commande_lignes_insert on public.commande_lignes
  for insert with check (
    exists (
      select 1 from public.commandes c
      where c.id = commande_id
        and c.cave_id = public.current_cave_id()
        and c.created_by = auth.uid()
        and c.statut = 'en_attente'
    )
  );

-- ----------------------------------------------------------------------------
-- 4. Trigger : ajoute chaque ligne au total de la commande. AFTER INSERT
--    uniquement (jamais UPDATE), exactement comme
--    `appliquer_mouvement_stock` en Phase 2 : un retry réseau renvoyant la
--    même ligne (même id généré côté client) devient un UPDATE via
--    upsert côté sync engine, donc le trigger ne se redéclenche pas et le
--    total n'est jamais compté deux fois.
-- ----------------------------------------------------------------------------
create or replace function public.appliquer_ligne_commande() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  update public.commandes
    set total = total + new.sous_total,
        updated_at = now()
    where id = new.commande_id;
  return new;
end;
$$;

create trigger trg_appliquer_ligne_commande
  after insert on public.commande_lignes
  for each row execute function public.appliquer_ligne_commande();
