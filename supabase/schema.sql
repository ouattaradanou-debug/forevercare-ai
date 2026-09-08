-- =============================================================================
-- Atelier+ — Schéma Supabase (PostgreSQL) — Phase 0
-- =============================================================================
-- Ce script est idempotent-safe pour une première exécution sur un projet
-- Supabase neuf. À exécuter dans l'éditeur SQL du projet Supabase, ou via
-- `supabase db push` si vous utilisez la CLI Supabase avec un dossier
-- migrations/.
--
-- Décisions d'architecture prises pour ce script (non précisées dans la
-- demande initiale, choisies pour leur stabilité et documentées ici) :
--
-- 1. Les valeurs "énumérées" (role, sexe, statut, type, source...) sont
--    stockées en `text` avec une contrainte CHECK plutôt qu'un type ENUM
--    Postgres natif. Un CHECK se modifie avec un simple ALTER TABLE, alors
--    qu'un ENUM Postgres est pénible à faire évoluer (ajout de valeur
--    seulement, jamais de suppression). Cette flexibilité est importante
--    pour un produit encore jeune.
--
-- 2. Toutes les tables ont `created_at` et `updated_at`. `updated_at` est
--    positionné automatiquement par un trigger serveur (jamais par le
--    client) : la Phase 3 doit résoudre les conflits de synchronisation
--    "par horodatage", et un horodatage fourni par le client (horloge du
--    téléphone, souvent fausse) ne serait pas fiable pour arbitrer un
--    conflit. L'horodatage qui fait foi est donc toujours celui du serveur.
--
-- 3. Aucune table ne dispose de politique RLS de suppression (DELETE) côté
--    client, sauf mention explicite ci-dessous. Conformément à l'esprit du
--    cahier des charges ("jamais de suppression définitive si des mesures
--    existent déjà", "jamais de perte de données"), la philosophie générale
--    du produit est : on masque / on annule / on corrige, on ne supprime
--    pas d'historique. Quand une suppression réelle a du sens (ex. fiche
--    client créée par erreur), elle est explicitement autorisée et documentée
--    table par table ci-dessous.
--
-- 4. `types_tenue` et `champs_mesure` "de premier niveau" désignent les
--    gabarits par défaut fournis par l'application (types_tenue.atelier_id
--    IS NULL). Ces lignes ne sont jamais modifiables depuis le client, pas
--    même par un propriétaire d'atelier : elles ne sont gérées que par une
--    migration (ou par la clé service_role). Un propriétaire peut en
--    revanche créer/modifier librement les gabarits propres à son atelier
--    (atelier_id = son atelier), et peut déléguer ce droit à un apprenti via
--    la permission `modifier_gabarits`.
--
-- 5. Les comptes apprenti sont créés côté serveur (Edge Function utilisant
--    la clé service_role), jamais directement depuis l'app cliente : créer
--    un compte Supabase Auth pour un tiers nécessite des privilèges qu'on
--    ne donne jamais à un client mobile. Ce point sera implémenté en
--    Phase 1 ; le schéma n'a donc pas besoin de policy INSERT complexe pour
--    les lignes `utilisateurs` d'un apprenti.
--
-- 6. Écriture de `abonnements` : jamais depuis le client (un utilisateur ne
--    doit pas pouvoir s'auto-attribuer un abonnement payant). La ligne
--    d'essai gratuit de 30 jours est créée automatiquement par un trigger
--    serveur dès la création de l'atelier. Les mises à jour ultérieures
--    (renouvellement) seront faites par une Edge Function liée au moyen de
--    paiement, en Phase 4.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Extensions
-- -----------------------------------------------------------------------------
create extension if not exists "pgcrypto";


-- -----------------------------------------------------------------------------
-- Fonction utilitaire : horodatage de mise à jour automatique
-- -----------------------------------------------------------------------------
create or replace function public.definir_horodatage_modification()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


-- =============================================================================
-- TABLE : ateliers
-- =============================================================================
create table if not exists public.ateliers (
  id          uuid primary key default gen_random_uuid(),
  nom         text not null check (char_length(trim(nom)) > 0),
  logo_url    text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger trg_ateliers_updated_at
  before update on public.ateliers
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : utilisateurs
-- (id = auth.users.id : un compte Supabase Auth = une ligne utilisateur)
-- =============================================================================
create table if not exists public.utilisateurs (
  id          uuid primary key references auth.users (id) on delete cascade,
  atelier_id  uuid not null references public.ateliers (id) on delete cascade,
  nom         text not null check (char_length(trim(nom)) > 0),
  telephone   text not null,
  role        text not null check (role in ('proprietaire', 'apprenti')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_utilisateurs_atelier on public.utilisateurs (atelier_id);

create trigger trg_utilisateurs_updated_at
  before update on public.utilisateurs
  for each row execute function public.definir_horodatage_modification();


-- -----------------------------------------------------------------------------
-- Fonctions utilitaires de sécurité (SECURITY DEFINER : contournent la RLS de
-- `utilisateurs` pour éviter toute récursion de policy, mais ne renvoient
-- que des informations sur l'utilisateur courant lui-même).
-- -----------------------------------------------------------------------------
create or replace function public.mon_atelier_id()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select atelier_id from public.utilisateurs where id = auth.uid();
$$;

create or replace function public.mon_role()
returns text
language sql
security definer
set search_path = public
stable
as $$
  select role from public.utilisateurs where id = auth.uid();
$$;

create or replace function public.ma_permission(nom_colonne text)
returns boolean
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  resultat boolean;
begin
  execute format(
    'select %I from public.permissions_apprenti where utilisateur_id = $1',
    nom_colonne
  )
  into resultat
  using auth.uid();

  return coalesce(resultat, false);
end;
$$;

comment on function public.ma_permission(text) is
  'Lit une colonne booléenne de permissions_apprenti pour l''utilisateur courant. Retourne false si aucune ligne (ex : propriétaire, qui n''a jamais de ligne de permissions).';


-- =============================================================================
-- TABLE : permissions_apprenti
-- Volontairement dépourvue de toute colonne financière : un apprenti ne peut
-- jamais se voir accorder l'accès aux commandes/paiements, quelle que soit
-- la configuration choisie par le propriétaire.
-- =============================================================================
create table if not exists public.permissions_apprenti (
  id               uuid primary key default gen_random_uuid(),
  utilisateur_id   uuid not null unique references public.utilisateurs (id) on delete cascade,
  creer_client     boolean not null default false,
  modifier_client  boolean not null default false,
  prendre_mesures  boolean not null default false,
  ajouter_photos   boolean not null default false,
  modifier_gabarits boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create trigger trg_permissions_apprenti_updated_at
  before update on public.permissions_apprenti
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : clients
-- =============================================================================
-- Remarque (correctif formulaire continu) : aucun champ d'identité n'est
-- obligatoire ici. Seule l'existence d'au moins une mesure (table
-- `mesures`) conditionne la création "officielle" d'un client côté
-- application ; voir supabase/migration_phase2_champs_optionnels.sql pour
-- la migration d'un projet déjà créé avec l'ancienne version de ce schéma.
create table if not exists public.clients (
  id                    uuid primary key default gen_random_uuid(),
  atelier_id            uuid not null references public.ateliers (id) on delete cascade,
  nom                   text,
  prenom                text,
  telephone             text,
  sexe                  text check (sexe in ('Homme', 'Femme')),
  date_prise_mesures    date,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists idx_clients_atelier on public.clients (atelier_id);
create index if not exists idx_clients_recherche on public.clients (atelier_id, nom, telephone);

create trigger trg_clients_updated_at
  before update on public.clients
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : types_tenue
-- atelier_id NULL = gabarit par défaut fourni par Atelier+ (voir décision 4).
-- =============================================================================
create table if not exists public.types_tenue (
  id          uuid primary key default gen_random_uuid(),
  atelier_id  uuid references public.ateliers (id) on delete cascade,
  nom         text not null check (char_length(trim(nom)) > 0),
  sexe        text not null check (sexe in ('Homme', 'Femme')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_types_tenue_atelier on public.types_tenue (atelier_id);

create trigger trg_types_tenue_updated_at
  before update on public.types_tenue
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : champs_mesure
-- Un champ n'est jamais supprimé, seulement masqué (statut = 'masque') dès
-- lors que des mesures existent dessus — voir décision 3 et RLS plus bas
-- (aucune policy DELETE n'est créée pour cette table).
-- =============================================================================
create table if not exists public.champs_mesure (
  id             uuid primary key default gen_random_uuid(),
  type_tenue_id  uuid not null references public.types_tenue (id) on delete cascade,
  nom            text not null check (char_length(trim(nom)) > 0),
  unite          text,
  statut         text not null default 'actif' check (statut in ('actif', 'masque')),
  ordre          integer not null default 0,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (type_tenue_id, nom)
);

create index if not exists idx_champs_mesure_type_tenue on public.champs_mesure (type_tenue_id);

create trigger trg_champs_mesure_updated_at
  before update on public.champs_mesure
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : mesures
-- Table historisée : une nouvelle prise de mesure crée une nouvelle ligne,
-- jamais une mise à jour d'une ligne existante (aucune policy UPDATE/DELETE
-- n'est créée pour cette table — voir RLS plus bas).
-- =============================================================================
create table if not exists public.mesures (
  id             uuid primary key default gen_random_uuid(),
  client_id      uuid not null references public.clients (id) on delete cascade,
  type_tenue_id  uuid not null references public.types_tenue (id),
  date_prise     timestamptz not null default now(),
  valeurs        jsonb not null default '{}'::jsonb,
  prise_par      uuid not null references public.utilisateurs (id),
  created_at     timestamptz not null default now()
);

create index if not exists idx_mesures_client on public.mesures (client_id, date_prise desc);
create index if not exists idx_mesures_type_tenue on public.mesures (type_tenue_id);


-- =============================================================================
-- TABLE : photos
-- =============================================================================
create table if not exists public.photos (
  id          uuid primary key default gen_random_uuid(),
  client_id   uuid not null references public.clients (id) on delete cascade,
  type        text not null check (type in ('tissu', 'modele')),
  url         text not null,
  source      text not null check (source in ('camera', 'galerie')),
  created_at  timestamptz not null default now()
);

create index if not exists idx_photos_client on public.photos (client_id);


-- =============================================================================
-- TABLE : rendez_vous
-- =============================================================================
create table if not exists public.rendez_vous (
  id          uuid primary key default gen_random_uuid(),
  client_id   uuid not null references public.clients (id) on delete cascade,
  date_heure  timestamptz not null,
  type        text not null check (type in ('essayage', 'livraison')),
  statut      text not null default 'planifie'
              check (statut in ('planifie', 'confirme', 'termine', 'annule')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_rendez_vous_client on public.rendez_vous (client_id);
create index if not exists idx_rendez_vous_date on public.rendez_vous (date_heure);

create trigger trg_rendez_vous_updated_at
  before update on public.rendez_vous
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : commandes  — accès strictement réservé au rôle propriétaire (RLS)
-- =============================================================================
create table if not exists public.commandes (
  id             uuid primary key default gen_random_uuid(),
  client_id      uuid not null references public.clients (id) on delete cascade,
  montant_total  numeric(12, 2) not null check (montant_total >= 0),
  avance         numeric(12, 2) not null default 0 check (avance >= 0),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint avance_ne_depasse_pas_total check (avance <= montant_total)
);

create index if not exists idx_commandes_client on public.commandes (client_id);

create trigger trg_commandes_updated_at
  before update on public.commandes
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : paiements  — accès strictement réservé au rôle propriétaire (RLS)
-- =============================================================================
create table if not exists public.paiements (
  id             uuid primary key default gen_random_uuid(),
  commande_id    uuid not null references public.commandes (id) on delete cascade,
  montant        numeric(12, 2) not null check (montant > 0),
  date_paiement  timestamptz not null default now(),
  created_at     timestamptz not null default now()
);

create index if not exists idx_paiements_commande on public.paiements (commande_id);


-- =============================================================================
-- TABLE : journal_actions
-- Journal d'audit en lecture seule (aucune policy UPDATE/DELETE).
-- =============================================================================
create table if not exists public.journal_actions (
  id              uuid primary key default gen_random_uuid(),
  utilisateur_id  uuid not null references public.utilisateurs (id) on delete cascade,
  action          text not null,
  cible_id        uuid,
  timestamp       timestamptz not null default now()
);

create index if not exists idx_journal_actions_utilisateur on public.journal_actions (utilisateur_id);
create index if not exists idx_journal_actions_timestamp on public.journal_actions (timestamp desc);


-- =============================================================================
-- TABLE : abonnements — jamais écrite par le client (voir décision 6)
-- =============================================================================
create table if not exists public.abonnements (
  id                    uuid primary key default gen_random_uuid(),
  atelier_id            uuid not null unique references public.ateliers (id) on delete cascade,
  statut                text not null default 'essai'
                        check (statut in ('essai', 'actif', 'expire', 'annule')),
  date_fin_essai        timestamptz not null,
  date_renouvellement   timestamptz,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create trigger trg_abonnements_updated_at
  before update on public.abonnements
  for each row execute function public.definir_horodatage_modification();

-- Création automatique de l'essai gratuit de 30 jours dès qu'un atelier est créé.
create or replace function public.creer_essai_gratuit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.abonnements (atelier_id, statut, date_fin_essai)
  values (new.id, 'essai', now() + interval '30 days');
  return new;
end;
$$;

create trigger trg_ateliers_creer_essai_gratuit
  after insert on public.ateliers
  for each row execute function public.creer_essai_gratuit();


-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
alter table public.ateliers            enable row level security;
alter table public.utilisateurs        enable row level security;
alter table public.permissions_apprenti enable row level security;
alter table public.clients             enable row level security;
alter table public.types_tenue         enable row level security;
alter table public.champs_mesure       enable row level security;
alter table public.mesures             enable row level security;
alter table public.photos              enable row level security;
alter table public.rendez_vous         enable row level security;
alter table public.commandes           enable row level security;
alter table public.paiements           enable row level security;
alter table public.journal_actions     enable row level security;
alter table public.abonnements         enable row level security;

-- -----------------------------------------------------------------------------
-- ateliers
-- -----------------------------------------------------------------------------
create policy "ateliers_select_mon_atelier"
  on public.ateliers for select
  using (id = public.mon_atelier_id());

create policy "ateliers_insert_bootstrap_compte"
  on public.ateliers for insert
  with check (auth.uid() is not null);

create policy "ateliers_update_proprietaire"
  on public.ateliers for update
  using (id = public.mon_atelier_id() and public.mon_role() = 'proprietaire')
  with check (id = public.mon_atelier_id() and public.mon_role() = 'proprietaire');

-- Pas de policy DELETE : un atelier ne se supprime jamais depuis le client.

-- -----------------------------------------------------------------------------
-- utilisateurs
-- -----------------------------------------------------------------------------
create policy "utilisateurs_select_mon_atelier"
  on public.utilisateurs for select
  using (atelier_id = public.mon_atelier_id());

-- Bootstrap : un utilisateur ne peut créer que SA PROPRE ligne (id = son
-- propre auth.uid()), au moment de la création de son compte atelier. Les
-- comptes apprentis sont créés côté serveur (service_role, Phase 1) et ne
-- passent donc pas par cette policy.
create policy "utilisateurs_insert_soi_meme"
  on public.utilisateurs for insert
  with check (id = auth.uid());

create policy "utilisateurs_update_proprietaire_ou_soi_meme"
  on public.utilisateurs for update
  using (
    id = auth.uid()
    or (atelier_id = public.mon_atelier_id() and public.mon_role() = 'proprietaire')
  )
  with check (
    id = auth.uid()
    or (atelier_id = public.mon_atelier_id() and public.mon_role() = 'proprietaire')
  );

create policy "utilisateurs_delete_proprietaire"
  on public.utilisateurs for delete
  using (
    atelier_id = public.mon_atelier_id()
    and public.mon_role() = 'proprietaire'
    and id <> auth.uid()
  );

-- -----------------------------------------------------------------------------
-- permissions_apprenti — aucune donnée financière, mais accès restreint
-- au propriétaire pour l'écriture, et à l'apprenti concerné en lecture seule.
-- -----------------------------------------------------------------------------
create policy "permissions_select_soi_meme_ou_proprietaire"
  on public.permissions_apprenti for select
  using (
    utilisateur_id = auth.uid()
    or exists (
      select 1 from public.utilisateurs u
      where u.id = permissions_apprenti.utilisateur_id
        and u.atelier_id = public.mon_atelier_id()
        and public.mon_role() = 'proprietaire'
    )
  );

create policy "permissions_insert_proprietaire"
  on public.permissions_apprenti for insert
  with check (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.utilisateurs u
      where u.id = permissions_apprenti.utilisateur_id
        and u.atelier_id = public.mon_atelier_id()
        and u.role = 'apprenti'
    )
  );

create policy "permissions_update_proprietaire"
  on public.permissions_apprenti for update
  using (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.utilisateurs u
      where u.id = permissions_apprenti.utilisateur_id
        and u.atelier_id = public.mon_atelier_id()
    )
  )
  with check (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.utilisateurs u
      where u.id = permissions_apprenti.utilisateur_id
        and u.atelier_id = public.mon_atelier_id()
    )
  );

-- -----------------------------------------------------------------------------
-- clients
-- -----------------------------------------------------------------------------
create policy "clients_select_mon_atelier"
  on public.clients for select
  using (atelier_id = public.mon_atelier_id());

create policy "clients_insert_autorise"
  on public.clients for insert
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.mon_role() = 'proprietaire' or public.ma_permission('creer_client'))
  );

create policy "clients_update_autorise"
  on public.clients for update
  using (atelier_id = public.mon_atelier_id())
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.mon_role() = 'proprietaire' or public.ma_permission('modifier_client'))
  );

create policy "clients_delete_proprietaire"
  on public.clients for delete
  using (atelier_id = public.mon_atelier_id() and public.mon_role() = 'proprietaire');

-- -----------------------------------------------------------------------------
-- types_tenue — voir décision 4 (gabarits "de premier niveau" = atelier_id NULL)
-- -----------------------------------------------------------------------------
create policy "types_tenue_select_defaut_ou_mon_atelier"
  on public.types_tenue for select
  using (atelier_id is null or atelier_id = public.mon_atelier_id());

create policy "types_tenue_insert_mon_atelier"
  on public.types_tenue for insert
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.mon_role() = 'proprietaire' or public.ma_permission('modifier_gabarits'))
  );

create policy "types_tenue_update_mon_atelier"
  on public.types_tenue for update
  using (atelier_id = public.mon_atelier_id())
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.mon_role() = 'proprietaire' or public.ma_permission('modifier_gabarits'))
  );

-- Pas de policy DELETE (jamais de suppression définitive d'un type de tenue).

-- -----------------------------------------------------------------------------
-- champs_mesure — visibilité et écriture héritées du type_tenue parent.
-- -----------------------------------------------------------------------------
create policy "champs_mesure_select_defaut_ou_mon_atelier"
  on public.champs_mesure for select
  using (
    exists (
      select 1 from public.types_tenue t
      where t.id = champs_mesure.type_tenue_id
        and (t.atelier_id is null or t.atelier_id = public.mon_atelier_id())
    )
  );

create policy "champs_mesure_insert_mon_atelier"
  on public.champs_mesure for insert
  with check (
    exists (
      select 1 from public.types_tenue t
      where t.id = champs_mesure.type_tenue_id
        and t.atelier_id = public.mon_atelier_id()
        and (public.mon_role() = 'proprietaire' or public.ma_permission('modifier_gabarits'))
    )
  );

create policy "champs_mesure_update_mon_atelier"
  on public.champs_mesure for update
  using (
    exists (
      select 1 from public.types_tenue t
      where t.id = champs_mesure.type_tenue_id
        and t.atelier_id = public.mon_atelier_id()
    )
  )
  with check (
    exists (
      select 1 from public.types_tenue t
      where t.id = champs_mesure.type_tenue_id
        and t.atelier_id = public.mon_atelier_id()
        and (public.mon_role() = 'proprietaire' or public.ma_permission('modifier_gabarits'))
    )
  );

-- Pas de policy DELETE : un champ se masque (statut = 'masque'), il ne se
-- supprime jamais — qu'il ait déjà des mesures ou non, la règle est
-- volontairement la même pour tous les champs, plus simple et plus sûre.

-- -----------------------------------------------------------------------------
-- mesures — historisées, jamais modifiées ni supprimées après écriture.
-- -----------------------------------------------------------------------------
create policy "mesures_select_mon_atelier"
  on public.mesures for select
  using (
    exists (
      select 1 from public.clients c
      where c.id = mesures.client_id and c.atelier_id = public.mon_atelier_id()
    )
  );

create policy "mesures_insert_autorise"
  on public.mesures for insert
  with check (
    prise_par = auth.uid()
    and exists (
      select 1 from public.clients c
      where c.id = mesures.client_id and c.atelier_id = public.mon_atelier_id()
    )
    and (public.mon_role() = 'proprietaire' or public.ma_permission('prendre_mesures'))
  );

-- Pas de policy UPDATE ni DELETE : chaque prise de mesure est un nouvel
-- enregistrement, l'historique n'est jamais réécrit.

-- -----------------------------------------------------------------------------
-- photos
-- -----------------------------------------------------------------------------
create policy "photos_select_mon_atelier"
  on public.photos for select
  using (
    exists (
      select 1 from public.clients c
      where c.id = photos.client_id and c.atelier_id = public.mon_atelier_id()
    )
  );

create policy "photos_insert_autorise"
  on public.photos for insert
  with check (
    exists (
      select 1 from public.clients c
      where c.id = photos.client_id and c.atelier_id = public.mon_atelier_id()
    )
    and (public.mon_role() = 'proprietaire' or public.ma_permission('ajouter_photos'))
  );

create policy "photos_delete_proprietaire"
  on public.photos for delete
  using (
    exists (
      select 1 from public.clients c
      where c.id = photos.client_id
        and c.atelier_id = public.mon_atelier_id()
        and public.mon_role() = 'proprietaire'
    )
  );

-- -----------------------------------------------------------------------------
-- rendez_vous — aucune permission dédiée dans permissions_apprenti : ouvert
-- à tout membre de l'atelier (ni financier, ni sensible).
-- -----------------------------------------------------------------------------
create policy "rendez_vous_select_mon_atelier"
  on public.rendez_vous for select
  using (
    exists (
      select 1 from public.clients c
      where c.id = rendez_vous.client_id and c.atelier_id = public.mon_atelier_id()
    )
  );

create policy "rendez_vous_insert_mon_atelier"
  on public.rendez_vous for insert
  with check (
    exists (
      select 1 from public.clients c
      where c.id = rendez_vous.client_id and c.atelier_id = public.mon_atelier_id()
    )
  );

create policy "rendez_vous_update_mon_atelier"
  on public.rendez_vous for update
  using (
    exists (
      select 1 from public.clients c
      where c.id = rendez_vous.client_id and c.atelier_id = public.mon_atelier_id()
    )
  )
  with check (
    exists (
      select 1 from public.clients c
      where c.id = rendez_vous.client_id and c.atelier_id = public.mon_atelier_id()
    )
  );

-- Pas de policy DELETE : un rendez-vous s'annule (statut = 'annule'), il ne
-- se supprime pas, pour conserver l'historique.

-- -----------------------------------------------------------------------------
-- commandes — RÉSERVÉ AU PROPRIÉTAIRE, sans aucune exception de permission.
-- -----------------------------------------------------------------------------
create policy "commandes_select_proprietaire_uniquement"
  on public.commandes for select
  using (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.clients c
      where c.id = commandes.client_id and c.atelier_id = public.mon_atelier_id()
    )
  );

create policy "commandes_insert_proprietaire_uniquement"
  on public.commandes for insert
  with check (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.clients c
      where c.id = commandes.client_id and c.atelier_id = public.mon_atelier_id()
    )
  );

create policy "commandes_update_proprietaire_uniquement"
  on public.commandes for update
  using (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.clients c
      where c.id = commandes.client_id and c.atelier_id = public.mon_atelier_id()
    )
  )
  with check (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.clients c
      where c.id = commandes.client_id and c.atelier_id = public.mon_atelier_id()
    )
  );

-- Pas de policy DELETE : une commande erronée se corrige, elle ne se
-- supprime pas (elle reste liée à des paiements potentiels).

-- -----------------------------------------------------------------------------
-- paiements — RÉSERVÉ AU PROPRIÉTAIRE, sans aucune exception de permission.
-- -----------------------------------------------------------------------------
create policy "paiements_select_proprietaire_uniquement"
  on public.paiements for select
  using (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.commandes co
      join public.clients c on c.id = co.client_id
      where co.id = paiements.commande_id and c.atelier_id = public.mon_atelier_id()
    )
  );

create policy "paiements_insert_proprietaire_uniquement"
  on public.paiements for insert
  with check (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.commandes co
      join public.clients c on c.id = co.client_id
      where co.id = paiements.commande_id and c.atelier_id = public.mon_atelier_id()
    )
  );

-- Pas de policy UPDATE ni DELETE : un paiement enregistré est définitif ;
-- une correction se fait par un nouveau paiement (avoir/ajustement).

-- -----------------------------------------------------------------------------
-- journal_actions — journal d'audit en lecture seule pour le propriétaire.
-- Restreint au propriétaire en lecture car certaines actions journalisées
-- peuvent faire référence à des opérations financières (ex. "a enregistré
-- un paiement") : un apprenti ne doit jamais pouvoir consulter le journal.
-- -----------------------------------------------------------------------------
create policy "journal_actions_select_proprietaire"
  on public.journal_actions for select
  using (
    public.mon_role() = 'proprietaire'
    and exists (
      select 1 from public.utilisateurs u
      where u.id = journal_actions.utilisateur_id and u.atelier_id = public.mon_atelier_id()
    )
  );

create policy "journal_actions_insert_soi_meme"
  on public.journal_actions for insert
  with check (utilisateur_id = auth.uid());

-- Pas de policy UPDATE ni DELETE : un journal d'audit est immuable.

-- -----------------------------------------------------------------------------
-- abonnements — lecture pour tout l'atelier (bandeau essai / mode
-- consultation seule), écriture jamais côté client (voir décision 6).
-- -----------------------------------------------------------------------------
create policy "abonnements_select_mon_atelier"
  on public.abonnements for select
  using (atelier_id = public.mon_atelier_id());

-- Aucune policy INSERT / UPDATE / DELETE pour le rôle authenticated : la
-- ligne d'essai est créée par trigger serveur, et les renouvellements sont
-- écrits par une Edge Function utilisant la clé service_role (Phase 4).
