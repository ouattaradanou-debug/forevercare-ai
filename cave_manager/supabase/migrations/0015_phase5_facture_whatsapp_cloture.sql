-- ============================================================================
-- Phase 5 — Facture, notification WhatsApp & clôture de caisse
--
-- Dernière phase du périmètre annoncé depuis la Phase 1 (PHASE1.md
-- sections 1 et 9). Trois volets :
--   1. Facture : générée côté client (Flutter), à partir des données déjà
--      lisibles (commandes/commande_lignes/clients) — aucune nouvelle
--      table nécessaire.
--   2. Notification WhatsApp : lien "wa.me" ouvert depuis l'app (aucun
--      backend, aucune clé API payante — voir PHASE5.md section 2 pour la
--      justification de ce choix face à l'API WhatsApp Business).
--   3. Clôture de caisse : complète le squelette posé en Phase 1
--      (`clotures`, déjà protégé par RLS "agent de vente = aucun accès" et
--      la règle PG/GER toujours, PROP conditionnel via
--      `cloture_accessible_proprietaire`).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. clotures : colonnes financières (annoncées dès le commentaire de la
--    Phase 1 : "Colonnes financières ajoutées en Phase 5").
-- ----------------------------------------------------------------------------
alter table public.clotures
  add column if not exists total_ventes bigint not null default 0,
  add column if not exists total_especes bigint not null default 0,
  add column if not exists total_mobile_money bigint not null default 0,
  add column if not exists nombre_commandes integer not null default 0;

-- ----------------------------------------------------------------------------
-- 2. Rattachement des commandes/encaissements à la clôture qui les a
--    "consommés" — permet de calculer la période de chaque clôture sans
--    dépendre des dates (une clôture couvre "tout ce qui n'est pas encore
--    rattaché à une clôture précédente", jamais une plage calendaire
--    fixe : un Gérant qui clôture après minuit ne doit rien perdre).
-- ----------------------------------------------------------------------------
alter table public.commandes
  add column if not exists cloture_id uuid references public.clotures(id);

alter table public.encaissements
  add column if not exists cloture_id uuid references public.clotures(id);

-- ----------------------------------------------------------------------------
-- 3. Durcissement de clotures_write (corrige un écart avec PHASE1.md
--    section 7 : "aucune policy UPDATE sur clotures n'existe pour
--    personne — une clôture est immuable une fois écrite", alors que la
--    policy `for all` posée en migration 0001 autorisait en réalité aussi
--    UPDATE/DELETE). Plus aucune policy d'écriture directe : la seule
--    façon de créer une clôture est désormais la fonction
--    `cloturer_caisse` ci-dessous (security definer, donc pas soumise à
--    RLS pour sa propre écriture — même mécanisme déjà utilisé par
--    `creer_cave_et_proprietaire` en Phase 1).
-- ----------------------------------------------------------------------------
drop policy if exists clotures_write on public.clotures;
revoke insert, update, delete on public.clotures from authenticated;

-- ----------------------------------------------------------------------------
-- 4. cloturer_caisse : calcule les totaux de tout ce qui n'est pas encore
--    rattaché à une clôture (commandes validées, encaissements), écrit une
--    ligne clotures, puis rattache ces lignes à la nouvelle clôture. Une
--    seule clôture par jour calendaire et par cave (contrainte unique déjà
--    posée en Phase 1 sur (cave_id, date_cloture)) : un message d'erreur
--    explicite est levé avant d'atteindre cette contrainte, plutôt que de
--    laisser remonter l'erreur Postgres brute.
--
--    Vérification de rôle reproduite manuellement (pas de RLS ici, la
--    fonction s'exécute avec les privilèges de son propriétaire) : mêmes
--    règles que clotures_select (PG/GER toujours, PROP seulement si la
--    cave l'autorise).
-- ----------------------------------------------------------------------------
create or replace function public.cloturer_caisse(p_cave_id uuid)
returns public.clotures
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role public.role_utilisateur;
  v_autorise boolean;
  v_total_ventes bigint;
  v_total_especes bigint;
  v_total_mobile bigint;
  v_nombre_commandes integer;
  v_cloture public.clotures;
begin
  if p_cave_id is distinct from public.current_cave_id() then
    raise exception 'Cave non autorisée.';
  end if;

  v_role := public.current_role();
  v_autorise := v_role in ('proprietaire_gerant', 'gerant')
    or (
      v_role = 'proprietaire'
      and exists (
        select 1 from public.caves c
        where c.id = p_cave_id and c.cloture_accessible_proprietaire
      )
    );
  if not v_autorise then
    raise exception 'Clôture refusée : rôle insuffisant.';
  end if;

  if exists (
    select 1 from public.clotures
    where cave_id = p_cave_id and date_cloture = current_date
  ) then
    raise exception 'La caisse a déjà été clôturée aujourd''hui.';
  end if;

  select coalesce(sum(total), 0), count(*)
    into v_total_ventes, v_nombre_commandes
    from public.commandes
    where cave_id = p_cave_id and statut = 'validee' and cloture_id is null;

  select coalesce(sum(montant_especes), 0), coalesce(sum(montant_mobile_money), 0)
    into v_total_especes, v_total_mobile
    from public.encaissements
    where cave_id = p_cave_id and cloture_id is null;

  insert into public.clotures
    (cave_id, date_cloture, cloture_par, total_ventes, total_especes, total_mobile_money, nombre_commandes)
  values
    (p_cave_id, current_date, auth.uid(), v_total_ventes, v_total_especes, v_total_mobile, v_nombre_commandes)
  returning * into v_cloture;

  update public.commandes
    set cloture_id = v_cloture.id
    where cave_id = p_cave_id and statut = 'validee' and cloture_id is null;

  update public.encaissements
    set cloture_id = v_cloture.id
    where cave_id = p_cave_id and cloture_id is null;

  return v_cloture;
end;
$$;

grant execute on function public.cloturer_caisse(uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- 5. historique_corrections : correction exceptionnelle d'une clôture déjà
--    écrite (PHASE1.md section 7, point 24) — jamais une modification
--    directe de la ligne `clotures`. Lecture/écriture réservées au
--    Propriétaire/Propriétaire-Gérant uniquement (même un Gérant, qui peut
--    clôturer, ne peut PAS corriger une clôture déjà faite).
-- ----------------------------------------------------------------------------
create table public.historique_corrections (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  cloture_id uuid not null references public.clotures(id) on delete cascade,
  montant_correction bigint not null,
  motif text not null check (char_length(trim(motif)) > 0),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

comment on table public.historique_corrections is 'Correction exceptionnelle d''une clôture déjà écrite. montant_correction est un delta signé (positif = ajout, négatif = retrait) appliqué au total constaté ; la ligne clotures elle-même n''est jamais modifiée.';

alter table public.historique_corrections enable row level security;

grant select on public.historique_corrections to authenticated;

create policy historique_corrections_select on public.historique_corrections
  for select using (
    cave_id = public.current_cave_id()
    and public.current_role() in ('proprietaire', 'proprietaire_gerant')
  );

-- Pas de policy insert/update/delete : la création passe exclusivement par
-- la fonction corriger_cloture (security definer), jamais par un insert
-- direct.

create or replace function public.corriger_cloture(
  p_cloture_id uuid,
  p_montant_correction bigint,
  p_motif text
) returns public.historique_corrections
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role public.role_utilisateur;
  v_cave_id uuid;
  v_correction public.historique_corrections;
begin
  v_role := public.current_role();
  if v_role not in ('proprietaire', 'proprietaire_gerant') then
    raise exception 'Correction refusée : réservée au Propriétaire.';
  end if;

  select cave_id into v_cave_id from public.clotures where id = p_cloture_id;
  if v_cave_id is null or v_cave_id is distinct from public.current_cave_id() then
    raise exception 'Clôture introuvable.';
  end if;

  if p_motif is null or char_length(trim(p_motif)) = 0 then
    raise exception 'Motif obligatoire.';
  end if;

  insert into public.historique_corrections
    (cave_id, cloture_id, montant_correction, motif, created_by)
  values
    (v_cave_id, p_cloture_id, p_montant_correction, trim(p_motif), auth.uid())
  returning * into v_correction;

  return v_correction;
end;
$$;

grant execute on function public.corriger_cloture(uuid, bigint, text) to authenticated;

-- ============================================================================
-- Fin de la migration 0015.
-- ============================================================================
