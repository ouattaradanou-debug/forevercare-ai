-- =============================================================================
-- ATELIER+ — Schéma Supabase (PostgreSQL) complet
-- =============================================================================
-- Ce script est idempotent (peut être rejoué sans erreur) et couvre :
--   1. Extensions
--   2. Tables et relations
--   3. Déclencheurs (updated_at, permissions par défaut, abonnement d'essai)
--   4. Fonctions utilitaires pour les politiques RLS
--   5. Activation et définition des politiques RLS
--
-- Principe central des politiques RLS :
--   - Un utilisateur ne voit/écrit que les données de SON atelier.
--   - Un apprenti ne peut JAMAIS lire ni écrire dans commandes/paiements,
--     quelle que soit la permission qui lui a été accordée (aucune colonne
--     financière n'existe même dans permissions_apprenti, par conception).
--   - Seul le rôle "proprietaire" peut modifier ateliers (nom/logo) et les
--     types_tenue / champs_mesure de premier niveau (structure des gabarits),
--     même si la colonne permissions_apprenti.modifier_gabarits est activée :
--     cette colonne est réservée à un usage futur / UI (ex : affichage de
--     l'écran de gestion des gabarits), pas à un droit d'écriture RLS.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. EXTENSIONS
-- -----------------------------------------------------------------------------
create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- 2. TABLES
-- -----------------------------------------------------------------------------

-- Un atelier = un compte "entreprise" (le tailleur et ses éventuels apprentis).
create table if not exists public.ateliers (
  id          uuid primary key default gen_random_uuid(),
  nom         text not null,
  logo_url    text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table public.ateliers is 'Un atelier de couture = un compte client de l''application.';

-- Un utilisateur applicatif = auth.users(id) + informations métier (atelier, rôle).
-- utilisateurs.id doit être identique à auth.users.id (créé lors du sign-up).
create table if not exists public.utilisateurs (
  id          uuid primary key references auth.users (id) on delete cascade,
  atelier_id  uuid not null references public.ateliers (id) on delete cascade,
  nom         text not null,
  telephone   text not null unique,
  role        text not null check (role in ('proprietaire', 'apprenti')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table public.utilisateurs is 'Utilisateurs applicatifs : le propriétaire de l''atelier et ses apprentis.';

create index if not exists idx_utilisateurs_atelier on public.utilisateurs (atelier_id);

-- Permissions accordées à un compte apprenti. Volontairement AUCUNE colonne
-- financière : un apprenti ne peut jamais se voir accorder un accès à
-- commandes/paiements, même par erreur d'un propriétaire.
create table if not exists public.permissions_apprenti (
  id                 uuid primary key default gen_random_uuid(),
  utilisateur_id     uuid not null unique references public.utilisateurs (id) on delete cascade,
  creer_client       boolean not null default false,
  modifier_client    boolean not null default false,
  prendre_mesures    boolean not null default false,
  ajouter_photos     boolean not null default false,
  modifier_gabarits  boolean not null default false,
  updated_at         timestamptz not null default now()
);

comment on table public.permissions_apprenti is
  'Permissions fines d''un apprenti. Aucune colonne financière par conception.';

-- Clients de l'atelier (les personnes habillées par le tailleur).
create table if not exists public.clients (
  id          uuid primary key default gen_random_uuid(),
  atelier_id  uuid not null references public.ateliers (id) on delete cascade,
  nom         text not null,
  prenom      text,
  telephone   text,
  sexe        text check (sexe in ('homme', 'femme')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_clients_atelier on public.clients (atelier_id);
create index if not exists idx_clients_recherche on public.clients (atelier_id, nom, prenom, telephone);

-- Types de tenue : gabarits par défaut (atelier_id NULL, partagés par tous)
-- ou gabarits personnalisés d'un atelier (atelier_id renseigné).
create table if not exists public.types_tenue (
  id          uuid primary key default gen_random_uuid(),
  atelier_id  uuid references public.ateliers (id) on delete cascade,
  nom         text not null,
  sexe        text not null check (sexe in ('homme', 'femme', 'mixte')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table public.types_tenue is
  'atelier_id NULL = gabarit par défaut fourni par l''application (lecture seule côté client).';

create index if not exists idx_types_tenue_atelier on public.types_tenue (atelier_id);

-- Groupes de mesures d'uniformes (promotion, établissement, équipe) : un
-- conteneur sous lequel on prendra les mesures de plusieurs personnes en une
-- fois, séparément des fiches clients individuelles.
create table if not exists public.groupes_uniformes (
  id          uuid primary key default gen_random_uuid(),
  atelier_id  uuid not null references public.ateliers (id) on delete cascade,
  nom         text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_groupes_uniformes_atelier on public.groupes_uniformes (atelier_id);

-- Champs de mesure appartenant à un type de tenue.
create table if not exists public.champs_mesure (
  id            uuid primary key default gen_random_uuid(),
  type_tenue_id uuid not null references public.types_tenue (id) on delete cascade,
  nom           text not null,
  unite         text not null default 'cm',
  statut        text not null default 'actif' check (statut in ('actif', 'masque')),
  ordre         integer not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

comment on column public.champs_mesure.statut is
  'Un champ utilisé par au moins une mesure existante ne doit jamais être supprimé, seulement masqué (vérification applicative avant tout masquage/suppression).';

create index if not exists idx_champs_mesure_type on public.champs_mesure (type_tenue_id);

-- Mesures prises pour un client, pour un type de tenue donné.
-- Chaque prise crée une NOUVELLE ligne (historique), jamais d'écrasement.
create table if not exists public.mesures (
  id             uuid primary key default gen_random_uuid(),
  atelier_id     uuid not null references public.ateliers (id) on delete cascade,
  client_id      uuid not null references public.clients (id) on delete cascade,
  type_tenue_id  uuid not null references public.types_tenue (id),
  date_prise     timestamptz not null default now(),
  valeurs        jsonb not null default '{}'::jsonb,
  prise_par      uuid references public.utilisateurs (id),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

comment on column public.mesures.valeurs is
  'Paires {champ_mesure_id: valeur} correspondant au gabarit au moment de la prise.';

create index if not exists idx_mesures_client on public.mesures (client_id, type_tenue_id, date_prise desc);
create index if not exists idx_mesures_atelier on public.mesures (atelier_id);

-- Photos de tissus ou de modèles associées à un client.
create table if not exists public.photos (
  id          uuid primary key default gen_random_uuid(),
  atelier_id  uuid not null references public.ateliers (id) on delete cascade,
  client_id   uuid not null references public.clients (id) on delete cascade,
  type        text not null check (type in ('tissu', 'modele')),
  url         text not null,
  source      text not null check (source in ('camera', 'galerie')),
  created_at  timestamptz not null default now()
);

create index if not exists idx_photos_client on public.photos (client_id);
create index if not exists idx_photos_atelier on public.photos (atelier_id);

-- Rendez-vous (essayage ou livraison).
create table if not exists public.rendez_vous (
  id          uuid primary key default gen_random_uuid(),
  atelier_id  uuid not null references public.ateliers (id) on delete cascade,
  client_id   uuid not null references public.clients (id) on delete cascade,
  date_heure  timestamptz not null,
  type        text not null check (type in ('essayage', 'livraison')),
  statut      text not null default 'planifie' check (statut in ('planifie', 'confirme', 'termine', 'annule')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_rdv_atelier_date on public.rendez_vous (atelier_id, date_heure);
create index if not exists idx_rdv_client on public.rendez_vous (client_id);

-- Commandes (montant total, avance). Table financière — jamais accessible
-- à un apprenti, quelle que soit sa permission.
create table if not exists public.commandes (
  id             uuid primary key default gen_random_uuid(),
  atelier_id     uuid not null references public.ateliers (id) on delete cascade,
  client_id      uuid not null references public.clients (id) on delete cascade,
  montant_total  numeric(12, 2) not null default 0 check (montant_total >= 0),
  avance         numeric(12, 2) not null default 0 check (avance >= 0),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index if not exists idx_commandes_client on public.commandes (client_id);
create index if not exists idx_commandes_atelier on public.commandes (atelier_id);

-- Paiements successifs sur une commande. Table financière — même règle.
create table if not exists public.paiements (
  id             uuid primary key default gen_random_uuid(),
  atelier_id     uuid not null references public.ateliers (id) on delete cascade,
  commande_id    uuid not null references public.commandes (id) on delete cascade,
  montant        numeric(12, 2) not null check (montant > 0),
  date_paiement  timestamptz not null default now(),
  created_at     timestamptz not null default now()
);

create index if not exists idx_paiements_commande on public.paiements (commande_id);
create index if not exists idx_paiements_atelier on public.paiements (atelier_id);

-- Dépenses de l'atelier (loyer, fournitures, etc.). Table financière — même
-- règle que commandes/paiements : jamais accessible à un apprenti.
create table if not exists public.depenses (
  id           uuid primary key default gen_random_uuid(),
  atelier_id   uuid not null references public.ateliers (id) on delete cascade,
  montant      numeric(12, 2) not null check (montant > 0),
  description  text,
  date         date not null,
  created_at   timestamptz not null default now()
);

create index if not exists idx_depenses_atelier on public.depenses (atelier_id, date);

-- Journal d'actions : trace d'audit append-only (utilisée aussi pour logguer
-- les résolutions de conflit de synchronisation "dernière modification gagne").
create table if not exists public.journal_actions (
  id              uuid primary key default gen_random_uuid(),
  utilisateur_id  uuid references public.utilisateurs (id) on delete set null,
  action          text not null,
  cible_table     text,
  cible_id        uuid,
  details         jsonb,
  "timestamp"     timestamptz not null default now()
);

create index if not exists idx_journal_utilisateur on public.journal_actions (utilisateur_id);
create index if not exists idx_journal_cible on public.journal_actions (cible_table, cible_id);

-- Abonnement d'un atelier (essai gratuit de 30 jours puis abonnement payant).
create table if not exists public.abonnements (
  id                   uuid primary key default gen_random_uuid(),
  atelier_id           uuid not null unique references public.ateliers (id) on delete cascade,
  statut               text not null default 'essai' check (statut in ('essai', 'actif', 'expire', 'suspendu')),
  date_fin_essai       timestamptz not null,
  date_renouvellement  timestamptz,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 3. DÉCLENCHEURS
-- -----------------------------------------------------------------------------

-- 3.1 Maintien automatique de updated_at (utilisé par la résolution de
--     conflit "dernière modification gagne" de la synchronisation Phase 3).
create or replace function public.maj_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  for t in
    select unnest(array[
      'ateliers', 'utilisateurs', 'permissions_apprenti', 'clients',
      'types_tenue', 'champs_mesure', 'mesures', 'rendez_vous',
      'commandes', 'abonnements', 'groupes_uniformes'
    ])
  loop
    execute format(
      'drop trigger if exists trg_%1$s_updated_at on public.%1$s;
       create trigger trg_%1$s_updated_at
       before update on public.%1$s
       for each row execute function public.maj_updated_at();',
      t
    );
  end loop;
end $$;

-- 3.2 À la création d'un compte apprenti : ligne de permissions créée
--     automatiquement avec AUCUNE permission active par défaut.
create or replace function public.creer_permissions_apprenti_par_defaut()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role = 'apprenti' then
    insert into public.permissions_apprenti (utilisateur_id)
    values (new.id)
    on conflict (utilisateur_id) do nothing;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_utilisateurs_permissions_defaut on public.utilisateurs;
create trigger trg_utilisateurs_permissions_defaut
after insert on public.utilisateurs
for each row execute function public.creer_permissions_apprenti_par_defaut();

-- 3.3 À la création d'un atelier : abonnement d'essai de 30 jours créé
--     automatiquement.
create or replace function public.creer_abonnement_essai()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.abonnements (atelier_id, statut, date_fin_essai)
  values (new.id, 'essai', now() + interval '30 days')
  on conflict (atelier_id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_ateliers_abonnement_essai on public.ateliers;
create trigger trg_ateliers_abonnement_essai
after insert on public.ateliers
for each row execute function public.creer_abonnement_essai();

-- -----------------------------------------------------------------------------
-- 4. FONCTIONS UTILITAIRES POUR LES POLITIQUES RLS
-- -----------------------------------------------------------------------------
-- SECURITY DEFINER + search_path fixé : évite toute récursion RLS lors de la
-- lecture de la table utilisateurs/permissions_apprenti depuis une policy.

create or replace function public.mon_atelier_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select atelier_id from public.utilisateurs where id = auth.uid();
$$;

create or replace function public.mon_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.utilisateurs where id = auth.uid();
$$;

create or replace function public.est_proprietaire()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.mon_role() = 'proprietaire', false);
$$;

create or replace function public.a_permission_creer_client()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select creer_client from public.permissions_apprenti where utilisateur_id = auth.uid()),
    false
  );
$$;

create or replace function public.a_permission_modifier_client()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select modifier_client from public.permissions_apprenti where utilisateur_id = auth.uid()),
    false
  );
$$;

create or replace function public.a_permission_prendre_mesures()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select prendre_mesures from public.permissions_apprenti where utilisateur_id = auth.uid()),
    false
  );
$$;

create or replace function public.a_permission_ajouter_photos()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select ajouter_photos from public.permissions_apprenti where utilisateur_id = auth.uid()),
    false
  );
$$;

-- -----------------------------------------------------------------------------
-- 5. ACTIVATION DE LA ROW LEVEL SECURITY
-- -----------------------------------------------------------------------------
alter table public.ateliers enable row level security;
alter table public.utilisateurs enable row level security;
alter table public.permissions_apprenti enable row level security;
alter table public.clients enable row level security;
alter table public.types_tenue enable row level security;
alter table public.champs_mesure enable row level security;
alter table public.mesures enable row level security;
alter table public.photos enable row level security;
alter table public.rendez_vous enable row level security;
alter table public.commandes enable row level security;
alter table public.paiements enable row level security;
alter table public.depenses enable row level security;
alter table public.groupes_uniformes enable row level security;
alter table public.journal_actions enable row level security;
alter table public.abonnements enable row level security;

-- -----------------------------------------------------------------------------
-- 5.1 ATELIERS — seul le propriétaire peut modifier nom/logo.
-- -----------------------------------------------------------------------------
drop policy if exists ateliers_select on public.ateliers;
create policy ateliers_select on public.ateliers
  for select to authenticated
  using (id = public.mon_atelier_id());

-- Création autorisée à tout utilisateur authentifié (chicken-and-egg : au
-- moment de l'inscription, l'utilisateur n'a pas encore de ligne dans
-- utilisateurs). L'application crée l'atelier PUIS la ligne utilisateur
-- "proprietaire" dans la même transaction logique côté client.
drop policy if exists ateliers_insert on public.ateliers;
create policy ateliers_insert on public.ateliers
  for insert to authenticated
  with check (true);

drop policy if exists ateliers_update on public.ateliers;
create policy ateliers_update on public.ateliers
  for update to authenticated
  using (id = public.mon_atelier_id() and public.est_proprietaire())
  with check (id = public.mon_atelier_id() and public.est_proprietaire());

-- Aucune politique DELETE : la suppression d'un atelier est bloquée par
-- défaut (principe "jamais de perte de données").

-- -----------------------------------------------------------------------------
-- 5.2 UTILISATEURS
-- -----------------------------------------------------------------------------
drop policy if exists utilisateurs_select on public.utilisateurs;
create policy utilisateurs_select on public.utilisateurs
  for select to authenticated
  using (atelier_id = public.mon_atelier_id());

-- Auto-inscription (propriétaire créant son propre compte) OU propriétaire
-- créant un compte apprenti dans son atelier.
drop policy if exists utilisateurs_insert on public.utilisateurs;
create policy utilisateurs_insert on public.utilisateurs
  for insert to authenticated
  with check (
    id = auth.uid()
    or (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  );

drop policy if exists utilisateurs_update on public.utilisateurs;
create policy utilisateurs_update on public.utilisateurs
  for update to authenticated
  using (
    id = auth.uid()
    or (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  )
  with check (
    id = auth.uid()
    or (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  );

drop policy if exists utilisateurs_delete on public.utilisateurs;
create policy utilisateurs_delete on public.utilisateurs
  for delete to authenticated
  using (
    atelier_id = public.mon_atelier_id()
    and public.est_proprietaire()
    and id <> auth.uid()
  );

-- -----------------------------------------------------------------------------
-- 5.3 PERMISSIONS_APPRENTI — seul le propriétaire écrit ; l'apprenti peut
--     lire uniquement sa propre ligne (pour piloter son UI).
-- -----------------------------------------------------------------------------
drop policy if exists permissions_select on public.permissions_apprenti;
create policy permissions_select on public.permissions_apprenti
  for select to authenticated
  using (
    utilisateur_id = auth.uid()
    or exists (
      select 1 from public.utilisateurs u
      where u.id = permissions_apprenti.utilisateur_id
        and u.atelier_id = public.mon_atelier_id()
        and public.est_proprietaire()
    )
  );

drop policy if exists permissions_insert on public.permissions_apprenti;
create policy permissions_insert on public.permissions_apprenti
  for insert to authenticated
  with check (
    public.est_proprietaire()
    and exists (
      select 1 from public.utilisateurs u
      where u.id = permissions_apprenti.utilisateur_id
        and u.atelier_id = public.mon_atelier_id()
    )
  );

drop policy if exists permissions_update on public.permissions_apprenti;
create policy permissions_update on public.permissions_apprenti
  for update to authenticated
  using (
    public.est_proprietaire()
    and exists (
      select 1 from public.utilisateurs u
      where u.id = permissions_apprenti.utilisateur_id
        and u.atelier_id = public.mon_atelier_id()
    )
  )
  with check (
    public.est_proprietaire()
    and exists (
      select 1 from public.utilisateurs u
      where u.id = permissions_apprenti.utilisateur_id
        and u.atelier_id = public.mon_atelier_id()
    )
  );

-- -----------------------------------------------------------------------------
-- 5.4 CLIENTS
-- -----------------------------------------------------------------------------
drop policy if exists clients_select on public.clients;
create policy clients_select on public.clients
  for select to authenticated
  using (atelier_id = public.mon_atelier_id());

drop policy if exists clients_insert on public.clients;
create policy clients_insert on public.clients
  for insert to authenticated
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.est_proprietaire() or public.a_permission_creer_client())
  );

drop policy if exists clients_update on public.clients;
create policy clients_update on public.clients
  for update to authenticated
  using (
    atelier_id = public.mon_atelier_id()
    and (public.est_proprietaire() or public.a_permission_modifier_client())
  )
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.est_proprietaire() or public.a_permission_modifier_client())
  );

-- Suppression réservée au propriétaire (protection contre la perte de données).
drop policy if exists clients_delete on public.clients;
create policy clients_delete on public.clients
  for delete to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

-- -----------------------------------------------------------------------------
-- 5.5 TYPES_TENUE — lecture des gabarits par défaut + gabarits de l'atelier ;
--     écriture réservée AU PROPRIÉTAIRE UNIQUEMENT (voir note en tête de
--     fichier concernant permissions_apprenti.modifier_gabarits).
-- -----------------------------------------------------------------------------
drop policy if exists types_tenue_select on public.types_tenue;
create policy types_tenue_select on public.types_tenue
  for select to authenticated
  using (atelier_id is null or atelier_id = public.mon_atelier_id());

drop policy if exists types_tenue_insert on public.types_tenue;
create policy types_tenue_insert on public.types_tenue
  for insert to authenticated
  with check (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

drop policy if exists types_tenue_update on public.types_tenue;
create policy types_tenue_update on public.types_tenue
  for update to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  with check (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

drop policy if exists types_tenue_delete on public.types_tenue;
create policy types_tenue_delete on public.types_tenue
  for delete to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

-- -----------------------------------------------------------------------------
-- 5.6 CHAMPS_MESURE — même règle que types_tenue (accès via le type de tenue
--     parent, propriétaire uniquement en écriture).
-- -----------------------------------------------------------------------------
drop policy if exists champs_mesure_select on public.champs_mesure;
create policy champs_mesure_select on public.champs_mesure
  for select to authenticated
  using (
    exists (
      select 1 from public.types_tenue tt
      where tt.id = champs_mesure.type_tenue_id
        and (tt.atelier_id is null or tt.atelier_id = public.mon_atelier_id())
    )
  );

drop policy if exists champs_mesure_insert on public.champs_mesure;
create policy champs_mesure_insert on public.champs_mesure
  for insert to authenticated
  with check (
    public.est_proprietaire()
    and exists (
      select 1 from public.types_tenue tt
      where tt.id = champs_mesure.type_tenue_id
        and tt.atelier_id = public.mon_atelier_id()
    )
  );

drop policy if exists champs_mesure_update on public.champs_mesure;
create policy champs_mesure_update on public.champs_mesure
  for update to authenticated
  using (
    public.est_proprietaire()
    and exists (
      select 1 from public.types_tenue tt
      where tt.id = champs_mesure.type_tenue_id
        and tt.atelier_id = public.mon_atelier_id()
    )
  )
  with check (
    public.est_proprietaire()
    and exists (
      select 1 from public.types_tenue tt
      where tt.id = champs_mesure.type_tenue_id
        and tt.atelier_id = public.mon_atelier_id()
    )
  );

-- Pas de politique DELETE : un champ de mesure n'est jamais supprimé
-- (uniquement masqué via UPDATE statut='masque'), y compris par le
-- propriétaire, afin de ne jamais casser l'historique des mesures existantes.

-- -----------------------------------------------------------------------------
-- 5.7 MESURES — écriture par le propriétaire ou l'apprenti autorisé ;
--     modification/suppression réservées au propriétaire (intégrité de
--     l'historique).
-- -----------------------------------------------------------------------------
drop policy if exists mesures_select on public.mesures;
create policy mesures_select on public.mesures
  for select to authenticated
  using (atelier_id = public.mon_atelier_id());

drop policy if exists mesures_insert on public.mesures;
create policy mesures_insert on public.mesures
  for insert to authenticated
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.est_proprietaire() or public.a_permission_prendre_mesures())
  );

drop policy if exists mesures_update on public.mesures;
create policy mesures_update on public.mesures
  for update to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  with check (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

drop policy if exists mesures_delete on public.mesures;
create policy mesures_delete on public.mesures
  for delete to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

-- -----------------------------------------------------------------------------
-- 5.8 PHOTOS
-- -----------------------------------------------------------------------------
drop policy if exists photos_select on public.photos;
create policy photos_select on public.photos
  for select to authenticated
  using (atelier_id = public.mon_atelier_id());

drop policy if exists photos_insert on public.photos;
create policy photos_insert on public.photos
  for insert to authenticated
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.est_proprietaire() or public.a_permission_ajouter_photos())
  );

drop policy if exists photos_delete on public.photos;
create policy photos_delete on public.photos
  for delete to authenticated
  using (
    atelier_id = public.mon_atelier_id()
    and (public.est_proprietaire() or public.a_permission_ajouter_photos())
  );

-- -----------------------------------------------------------------------------
-- 5.9 RENDEZ_VOUS — accessible à tout membre de l'atelier (aucune permission
--     dédiée dans permissions_apprenti : action non sensible, non financière).
-- -----------------------------------------------------------------------------
drop policy if exists rdv_select on public.rendez_vous;
create policy rdv_select on public.rendez_vous
  for select to authenticated
  using (atelier_id = public.mon_atelier_id());

drop policy if exists rdv_insert on public.rendez_vous;
create policy rdv_insert on public.rendez_vous
  for insert to authenticated
  with check (atelier_id = public.mon_atelier_id());

drop policy if exists rdv_update on public.rendez_vous;
create policy rdv_update on public.rendez_vous
  for update to authenticated
  using (atelier_id = public.mon_atelier_id())
  with check (atelier_id = public.mon_atelier_id());

drop policy if exists rdv_delete on public.rendez_vous;
create policy rdv_delete on public.rendez_vous
  for delete to authenticated
  using (atelier_id = public.mon_atelier_id());

-- -----------------------------------------------------------------------------
-- 5.10 COMMANDES — PROPRIÉTAIRE UNIQUEMENT, sans aucune exception. C'est la
--      garantie centrale demandée : un apprenti n'a JAMAIS accès à cette
--      table, quelle que soit sa permission (qui n'existe même pas ici).
-- -----------------------------------------------------------------------------
drop policy if exists commandes_all on public.commandes;
create policy commandes_all on public.commandes
  for all to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  with check (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

-- -----------------------------------------------------------------------------
-- 5.11 PAIEMENTS — même garantie que commandes.
-- -----------------------------------------------------------------------------
drop policy if exists paiements_all on public.paiements;
create policy paiements_all on public.paiements
  for all to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  with check (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

-- -----------------------------------------------------------------------------
-- 5.11bis DÉPENSES — même garantie que commandes/paiements.
-- -----------------------------------------------------------------------------
drop policy if exists depenses_all on public.depenses;
create policy depenses_all on public.depenses
  for all to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  with check (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

-- -----------------------------------------------------------------------------
-- 5.11ter GROUPES_UNIFORMES — lecture par tout l'atelier, écriture réservée
--         au propriétaire (même règle que types_tenue).
-- -----------------------------------------------------------------------------
drop policy if exists groupes_uniformes_select on public.groupes_uniformes;
create policy groupes_uniformes_select on public.groupes_uniformes
  for select to authenticated
  using (atelier_id = public.mon_atelier_id());

drop policy if exists groupes_uniformes_insert on public.groupes_uniformes;
create policy groupes_uniformes_insert on public.groupes_uniformes
  for insert to authenticated
  with check (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

drop policy if exists groupes_uniformes_update on public.groupes_uniformes;
create policy groupes_uniformes_update on public.groupes_uniformes
  for update to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire())
  with check (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

drop policy if exists groupes_uniformes_delete on public.groupes_uniformes;
create policy groupes_uniformes_delete on public.groupes_uniformes
  for delete to authenticated
  using (atelier_id = public.mon_atelier_id() and public.est_proprietaire());

-- -----------------------------------------------------------------------------
-- 5.12 JOURNAL_ACTIONS — append-only. Le propriétaire voit tout le journal
--      de son atelier ; chaque utilisateur voit ses propres actions.
-- -----------------------------------------------------------------------------
drop policy if exists journal_select on public.journal_actions;
create policy journal_select on public.journal_actions
  for select to authenticated
  using (
    utilisateur_id = auth.uid()
    or (
      public.est_proprietaire()
      and exists (
        select 1 from public.utilisateurs u
        where u.id = journal_actions.utilisateur_id
          and u.atelier_id = public.mon_atelier_id()
      )
    )
  );

drop policy if exists journal_insert on public.journal_actions;
create policy journal_insert on public.journal_actions
  for insert to authenticated
  with check (utilisateur_id = auth.uid());

-- Aucune politique UPDATE/DELETE : le journal est immuable.

-- -----------------------------------------------------------------------------
-- 5.13 ABONNEMENTS — lecture par tous les membres de l'atelier (nécessaire
--      pour afficher le bandeau d'essai/le mode consultation seule) ;
--      écriture interdite depuis le client (gérée côté serveur via une
--      fonction Edge avec la clé service_role, après confirmation de
--      paiement — voir Phase 4).
-- -----------------------------------------------------------------------------
drop policy if exists abonnements_select on public.abonnements;
create policy abonnements_select on public.abonnements
  for select to authenticated
  using (atelier_id = public.mon_atelier_id());

-- Pas de politique INSERT/UPDATE/DELETE pour le rôle "authenticated" :
-- seule une fonction utilisant la clé service_role (donc contournant RLS)
-- peut modifier cette table.
