-- ============================================================================
-- Phase 4 — Contrôle, validation & encaissement
--
-- Le "contrôle" n'ajoute aucune table : c'est la relecture d'une commande
-- encore 'en_attente' par un responsable, déjà permise par
-- CommandeDetailScreen (Phase 3, migration 0013 : corriger une quantité,
-- retirer une ligne). Cette migration ajoute les deux actions qui suivent
-- ce contrôle :
--   1. Validation : commandes.statut 'en_attente' -> 'validee', réservée
--      aux responsables, qui décrémente le stock de façon ATOMIQUE et
--      AUTOMATIQUE via un trigger serveur (jamais confiée au client) —
--      cohérent avec le principe posé dès la Phase 1 (PHASE1.md section 7) :
--      "la validation d'une commande et la décrémentation du stock qu'elle
--      entraîne" ne doivent jamais exister en deux écritures indépendantes
--      pouvant diverger. Un trigger serveur est même plus strict que ce qui
--      était envisagé (bundling côté client) : même un appel API direct
--      contournant l'app ne peut PAS valider une commande sans décrémenter
--      le stock, l'un ne pouvant pas exister sans l'autre.
--   2. Encaissement : enregistrement d'un paiement (espèces/Mobile Money,
--      partiel possible — point 13 du cahier des charges, déjà modélisé par
--      `calculerResteAPayer` en Phase 1). Plusieurs encaissements par
--      commande sont possibles (paiement échelonné) : journal append-only,
--      même principe que `mouvements_stock`.
--
-- Offline-first (hypothèse 4, PHASE1.md section 10) : "toute prise de
-- commande, tout encaissement, toute mise à jour de stock" doivent
-- fonctionner hors ligne. Validation et encaissement passent donc par la
-- file de synchronisation locale (VentesDao), exactement comme la création
-- d'une commande en Phase 3 — jamais par un appel réseau direct.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. commandes_update : élargit la seule transition déjà permise
--    ('en_attente' -> 'annulee', migration 0012) pour accepter aussi
--    'en_attente' -> 'validee'. Toujours réservé aux responsables, toujours
--    au départ d'une commande encore en attente — la USING clause ne change
--    pas.
-- ----------------------------------------------------------------------------
drop policy if exists commandes_update on public.commandes;

create policy commandes_update on public.commandes
  for update using (
    cave_id = public.current_cave_id()
    and public.is_responsable()
    and statut = 'en_attente'
  )
  with check (
    cave_id = public.current_cave_id()
    and public.is_responsable()
    and statut in ('annulee', 'validee')
  );

-- ----------------------------------------------------------------------------
-- 2. Trigger de validation : à la transition 'en_attente' -> 'validee',
--    décrémente automatiquement le stock pour chaque ligne de la commande,
--    en réutilisant le mécanisme déjà existant `mouvements_stock` (Phase 2)
--    plutôt qu'en touchant `stock` directement — un seul chemin
--    d'écriture du stock dans toute l'application, jamais deux.
--
--    Sûr en cas de retry réseau (même raisonnement que
--    `appliquer_ligne_commande`) : si le même UPDATE 'validee' est renvoyé
--    deux fois (accusé de réception perdu), la deuxième tentative trouve
--    `OLD.statut` déjà à 'validee' (plus 'en_attente'), donc à la fois la
--    condition du trigger ET la USING clause de `commandes_update`
--    l'excluent — aucun double décrément possible.
-- ----------------------------------------------------------------------------
create or replace function public.appliquer_validation_commande() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.mouvements_stock
    (cave_id, produit_id, delta_cartons, delta_bouteilles, motif, created_by)
  select
    new.cave_id, cl.produit_id, -cl.quantite_cartons, -cl.quantite_bouteilles,
    'Vente validée (commande ' || new.id || ')', auth.uid()
  from public.commande_lignes cl
  where cl.commande_id = new.id;
  return new;
end;
$$;

create trigger trg_appliquer_validation_commande
  after update on public.commandes
  for each row
  when (old.statut = 'en_attente' and new.statut = 'validee')
  execute function public.appliquer_validation_commande();

-- ----------------------------------------------------------------------------
-- 3. encaissements : journal append-only des paiements reçus pour une
--    commande (espèces/Mobile Money séparés, comme `calculerResteAPayer`).
--    Immuable une fois créé (pas de policy UPDATE/DELETE, même principe que
--    `mouvements_stock`/`commande_lignes` en lecture seule après coup) :
--    corriger un encaissement erroné se fait en ajoutant un encaissement
--    négatif... non, les montants sont positifs par contrainte — une
--    correction exceptionnelle passe par `historique_corrections` (Phase 5),
--    jamais par une modification directe de la ligne.
--    Autorisé tant que la commande n'est pas annulée (un dépôt avant
--    validation reste possible : le cahier des charges ne limite pas
--    l'encaissement à l'après-validation).
-- ----------------------------------------------------------------------------
create table public.encaissements (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  commande_id uuid not null references public.commandes(id) on delete cascade,
  montant_especes bigint not null default 0 check (montant_especes >= 0),
  montant_mobile_money bigint not null default 0 check (montant_mobile_money >= 0),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  check (montant_especes + montant_mobile_money > 0)
);

comment on table public.encaissements is 'Journal append-only des paiements reçus pour une commande (espèces/Mobile Money). Plusieurs lignes par commande = paiement échelonné. commandes.montant_encaisse_especes/mobile est recalculé par trigger, jamais saisi côté client.';

alter table public.encaissements enable row level security;

grant select, insert on public.encaissements to authenticated;

create policy encaissements_select on public.encaissements
  for select using (cave_id = public.current_cave_id() and public.is_responsable());

create policy encaissements_insert on public.encaissements
  for insert with check (
    cave_id = public.current_cave_id()
    and public.is_responsable()
    and exists (
      select 1 from public.commandes c
      where c.id = commande_id
        and c.cave_id = public.current_cave_id()
        and c.statut <> 'annulee'
    )
  );

-- ----------------------------------------------------------------------------
-- 4. commandes.montant_encaisse_especes/mobile : totaux recalculés par
--    trigger à chaque encaissement (même mécanisme additif et sûr au retry
--    qu'`appliquer_ligne_commande` — AFTER INSERT uniquement).
-- ----------------------------------------------------------------------------
alter table public.commandes
  add column if not exists montant_encaisse_especes bigint not null default 0,
  add column if not exists montant_encaisse_mobile bigint not null default 0;

create or replace function public.appliquer_encaissement() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  update public.commandes
    set montant_encaisse_especes = montant_encaisse_especes + new.montant_especes,
        montant_encaisse_mobile = montant_encaisse_mobile + new.montant_mobile_money,
        updated_at = now()
    where id = new.commande_id;
  return new;
end;
$$;

create trigger trg_appliquer_encaissement
  after insert on public.encaissements
  for each row execute function public.appliquer_encaissement();

-- ============================================================================
-- Fin de la migration 0014.
-- ============================================================================
