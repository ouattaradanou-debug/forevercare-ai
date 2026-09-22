-- ============================================================================
-- Phase 1 — Fondations
-- Cave à boissons — configuration cave, authentification, 4 rôles, structure RLS
--
-- Portée de cette migration (voir PHASE1.md pour la matrice complète) :
--   - Tables métier créées : caves, profiles.
--   - Tables "squelette" créées uniquement pour permettre le test de sécurité
--     obligatoire de la Phase 1 (RLS sur stock/clôtures dès la fondation) :
--     produits (colonnes minimales, sans prix d'achat), stock, clotures.
--     Leur enrichissement fonctionnel complet (CRUD, écrans) est repoussé
--     aux phases 2 et 5 respectivement, conformément au découpage validé.
--   - clients, commandes, commande_lignes, encaissements, historique_corrections
--     ne sont PAS créées ici : elles arrivent avec leur phase (3, 3, 4, 5).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Extensions
-- ----------------------------------------------------------------------------
create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 2. Types énumérés
-- ----------------------------------------------------------------------------
create type public.type_cave as enum ('vin', 'boissons_diverses', 'vin_et_boissons');

create type public.role_utilisateur as enum (
  'proprietaire',
  'proprietaire_gerant',
  'gerant',
  'agent_vente'
);

-- ----------------------------------------------------------------------------
-- 3. Table caves
-- ----------------------------------------------------------------------------
create table public.caves (
  id uuid primary key default gen_random_uuid(),
  nom text not null check (char_length(trim(nom)) > 0),
  type_cave public.type_cave not null,
  telephone text not null,
  localisation text not null,
  devise text not null default 'FCFA',
  journee_ouverte boolean not null default true,
  -- Point 20 du cahier des charges : la clôture est accessible au Gérant et
  -- au Propriétaire/Gérant par défaut ; l'accès du Propriétaire seul est
  -- "si souhaité" -> configurable par cave plutôt que figé dans le code.
  cloture_accessible_proprietaire boolean not null default false,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.caves is 'Configuration de la cave (point 1 du cahier des charges). Une seule ligne par cave cliente.';

-- ----------------------------------------------------------------------------
-- 4. Table profiles (utilisateurs applicatifs, liés à auth.users)
-- ----------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  cave_id uuid not null references public.caves(id) on delete restrict,
  nom text not null check (char_length(trim(nom)) > 0),
  prenom text not null check (char_length(trim(prenom)) > 0),
  telephone text not null,
  role public.role_utilisateur not null,
  actif boolean not null default true,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is 'Un profil = un utilisateur applicatif (les 4 rôles du point 2). id = auth.users.id.';

-- ----------------------------------------------------------------------------
-- 5. Fonctions utilitaires (SECURITY DEFINER pour éviter la récursion RLS
--    sur profiles : une policy sur "profiles" qui interroge "profiles" en
--    passant par une policy provoquerait une boucle. Ces fonctions
--    contournent volontairement RLS en lecture seule sur profiles.)
-- ----------------------------------------------------------------------------
-- Cas limite explicitement traité (voir PHASE1.md, "Gestion des cas
-- limites") : "un agent de vente crée une commande, puis son compte est
-- désactivé avant validation". Réponse structurelle retenue ici :
-- current_cave_id() renvoie NULL dès que le compte est inactif, ce qui
-- fait automatiquement échouer TOUTES les policies basées sur
-- `cave_id = current_cave_id()` (caves, produits, stock, clotures) pour
-- ce compte — la désactivation coupe l'accès immédiatement et
-- globalement, sans avoir à répéter la vérification dans chaque policy.
-- Les commandes déjà créées par l'agent avant désactivation restent
-- traitables par les responsables : elles ne dépendent pas de l'état
-- `actif` de leur créateur, seulement du leur (voir matrice, table
-- commandes, Phase 3).
create or replace function public.current_cave_id() returns uuid
language sql stable security definer set search_path = public as $$
  select cave_id from public.profiles where id = auth.uid() and actif = true;
$$;

create or replace function public.current_role() returns public.role_utilisateur
language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid() and actif = true;
$$;

create or replace function public.current_actif() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(actif, false) from public.profiles where id = auth.uid();
$$;

create or replace function public.is_responsable() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(role in ('proprietaire', 'proprietaire_gerant', 'gerant') and actif, false)
  from public.profiles where id = auth.uid();
$$;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(role in ('proprietaire', 'proprietaire_gerant') and actif, false)
  from public.profiles where id = auth.uid();
$$;

-- Grants explicites plutôt que de compter sur le défaut implicite
-- (EXECUTE à PUBLIC) : ces fonctions sont invoquées à l'intérieur des
-- policies RLS ci-dessous, le rôle `authenticated` doit pouvoir les
-- exécuter.
grant execute on function public.current_cave_id to authenticated;
grant execute on function public.current_role to authenticated;
grant execute on function public.current_actif to authenticated;
grant execute on function public.is_responsable to authenticated;
grant execute on function public.is_admin to authenticated;

-- ----------------------------------------------------------------------------
-- 6. Règle métier point 2.2 : le modèle "Propriétaire/Gérant" ne peut pas
--    coexister avec un Propriétaire et/ou un Gérant distincts dans la même
--    cave. Une seule cave = un seul Propriétaire actif au plus.
--    Appliqué par trigger (défense en profondeur en plus de la validation
--    côté application) car RLS seule ne peut pas exprimer cette contrainte
--    inter-lignes.
-- ----------------------------------------------------------------------------
create or replace function public.check_role_model() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_has_pg boolean;
  v_has_prop boolean;
begin
  select exists(
    select 1 from public.profiles
    where cave_id = new.cave_id and role = 'proprietaire_gerant' and id <> new.id
  ) into v_has_pg;

  select exists(
    select 1 from public.profiles
    where cave_id = new.cave_id and role = 'proprietaire' and id <> new.id
  ) into v_has_prop;

  if new.role in ('proprietaire', 'gerant') and v_has_pg then
    raise exception 'Cette cave utilise le modèle Propriétaire/Gérant unique : impossible de créer un Propriétaire ou un Gérant distinct.'
      using errcode = '23514';
  end if;

  if new.role = 'proprietaire_gerant' and v_has_prop then
    raise exception 'Cette cave a déjà un Propriétaire distinct : impossible de créer un Propriétaire/Gérant.'
      using errcode = '23514';
  end if;

  if new.role = 'proprietaire' and v_has_prop then
    raise exception 'Cette cave a déjà un Propriétaire.'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

create trigger trg_check_role_model
before insert or update of role on public.profiles
for each row execute function public.check_role_model();

-- ----------------------------------------------------------------------------
-- 7. Trigger de protection : un utilisateur non-admin ne peut pas modifier
--    son propre rôle, sa cave ou son statut actif/inactif (uniquement un
--    Propriétaire ou Propriétaire/Gérant le peut). Défense en profondeur en
--    complément des policies RLS (section 9).
-- ----------------------------------------------------------------------------
create or replace function public.protect_sensitive_profile_fields() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then
    if new.role <> old.role or new.cave_id <> old.cave_id or new.actif <> old.actif then
      raise exception 'Seul un Propriétaire ou Propriétaire/Gérant peut modifier le rôle, la cave ou le statut actif d''un utilisateur.'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_protect_sensitive_profile_fields
before update on public.profiles
for each row execute function public.protect_sensitive_profile_fields();

-- ----------------------------------------------------------------------------
-- 8. Squelettes des tables sensibles (produits / stock / clôtures)
--    Créées ici uniquement pour porter les policies RLS testées dès la
--    Phase 1 (contrainte de sécurité non négociable du prompt). Aucun écran
--    Flutter ne les utilise en Phase 1. Colonnes complètes ajoutées en
--    Phase 2 (produits, stock) et Phase 5 (clôtures) via ALTER TABLE.
-- ----------------------------------------------------------------------------
create table public.produits (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  nom text not null check (char_length(trim(nom)) > 0),
  prix_vente_detail bigint not null default 0 check (prix_vente_detail >= 0),
  prix_vente_gros bigint not null default 0 check (prix_vente_gros >= 0),
  actif boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.produits is 'Squelette Phase 1 : ne contient volontairement pas le prix d''achat (donnée sensible). Enrichi en Phase 2.';

create table public.stock (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  produit_id uuid not null references public.produits(id) on delete cascade,
  quantite_cartons integer not null default 0 check (quantite_cartons >= 0),
  quantite_bouteilles integer not null default 0 check (quantite_bouteilles >= 0),
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id),
  unique (produit_id)
);

comment on table public.stock is 'Squelette Phase 1, créé pour porter la policy RLS "agent de vente = aucun accès" testée dès la Phase 1.';

create table public.clotures (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  date_cloture date not null,
  cloture_par uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  unique (cave_id, date_cloture)
);

comment on table public.clotures is 'Squelette Phase 1, créé pour porter la policy RLS "agent de vente = aucun accès" testée dès la Phase 1. Colonnes financières ajoutées en Phase 5.';

-- ----------------------------------------------------------------------------
-- 9. Activation RLS + policies
-- ----------------------------------------------------------------------------
alter table public.caves enable row level security;
alter table public.profiles enable row level security;
alter table public.produits enable row level security;
alter table public.stock enable row level security;
alter table public.clotures enable row level security;

-- Grants de niveau table (prérequis Postgres avant que RLS puisse filtrer
-- quoi que ce soit : sans ce GRANT, toute requête échoue avant même
-- d'atteindre les policies, quel que soit le rôle applicatif). RLS reste
-- la seule ligne de défense réelle ci-dessous ; ces GRANT ne donnent accès
-- à rien qu'une policy n'autorise pas explicitement.
grant select, insert, update, delete on public.caves to authenticated;
grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.produits to authenticated;
grant select, insert, update, delete on public.stock to authenticated;
grant select, insert, update, delete on public.clotures to authenticated;

-- caves : tout membre actif de la cave peut lire sa cave ; seuls PROP/PG
-- peuvent la modifier. Aucune policy insert/delete : la création passe par
-- la fonction creer_cave_et_proprietaire (section 10).
create policy caves_select on public.caves
  for select using (id = public.current_cave_id());

create policy caves_update on public.caves
  for update using (id = public.current_cave_id() and public.is_admin())
  with check (id = public.current_cave_id() and public.is_admin());

-- profiles : chacun voit sa propre ligne ; PROP/PG/GER voient tous les
-- profils de leur cave (traçabilité Agent -> Validateur, point 19).
-- L'agent de vente ne voit QUE sa propre ligne (pas de vue d'ensemble RH).
create policy profiles_select_self on public.profiles
  for select using (id = auth.uid());

create policy profiles_select_responsables on public.profiles
  for select using (cave_id = public.current_cave_id() and public.is_responsable());

create policy profiles_update_self on public.profiles
  for update using (id = auth.uid())
  with check (id = auth.uid());

create policy profiles_update_admin on public.profiles
  for update using (cave_id = public.current_cave_id() and public.is_admin())
  with check (cave_id = public.current_cave_id() and public.is_admin());

-- Aucune policy insert sur profiles : la création passe exclusivement par
-- creer_cave_et_proprietaire (premier compte) ou par l'Edge Function
-- create-team-member (Gérant/Agent, appelée par un PROP/PG authentifié avec
-- la service role key côté serveur). Aucune policy delete : désactivation
-- via le champ actif, jamais de suppression physique (traçabilité).

-- produits : lecture ouverte à tous les rôles de la cave (aucune donnée
-- sensible dans ce squelette) ; écriture réservée à PROP/PG (point 18).
create policy produits_select on public.produits
  for select using (cave_id = public.current_cave_id());

create policy produits_write on public.produits
  for all using (cave_id = public.current_cave_id() and public.is_admin())
  with check (cave_id = public.current_cave_id() and public.is_admin());

-- stock : PROP/PG/GER uniquement (point 2.3). AUCUNE policy pour
-- agent_vente => 0 ligne visible et toute tentative d'écriture est rejetée
-- avec une erreur "row-level security policy" (test obligatoire Phase 1).
create policy stock_select on public.stock
  for select using (
    cave_id = public.current_cave_id()
    and public.current_role() in ('proprietaire', 'proprietaire_gerant', 'gerant')
  );

create policy stock_write on public.stock
  for all using (
    cave_id = public.current_cave_id()
    and public.current_role() in ('proprietaire', 'proprietaire_gerant', 'gerant')
  )
  with check (
    cave_id = public.current_cave_id()
    and public.current_role() in ('proprietaire', 'proprietaire_gerant', 'gerant')
  );

-- clotures : PG/GER toujours ; PROP seulement si la cave l'autorise
-- explicitement (cloture_accessible_proprietaire). AUCUNE policy pour
-- agent_vente.
create policy clotures_select on public.clotures
  for select using (
    cave_id = public.current_cave_id()
    and (
      public.current_role() in ('proprietaire_gerant', 'gerant')
      or (
        public.current_role() = 'proprietaire'
        and exists (
          select 1 from public.caves c
          where c.id = clotures.cave_id and c.cloture_accessible_proprietaire
        )
      )
    )
  );

create policy clotures_write on public.clotures
  for all using (
    cave_id = public.current_cave_id()
    and public.current_role() in ('proprietaire_gerant', 'gerant')
  )
  with check (
    cave_id = public.current_cave_id()
    and public.current_role() in ('proprietaire_gerant', 'gerant')
  );

-- ----------------------------------------------------------------------------
-- 10. Fonction de bootstrap : création de la cave + du premier compte
--     (Propriétaire ou Propriétaire/Gérant). Appelée juste après
--     supabase.auth.signUp() côté Flutter, avec l'utilisateur déjà
--     authentifié (auth.uid() disponible) mais sans profil existant.
-- ----------------------------------------------------------------------------
create or replace function public.creer_cave_et_proprietaire(
  p_nom_cave text,
  p_type_cave public.type_cave,
  p_telephone_cave text,
  p_localisation text,
  p_nom_utilisateur text,
  p_prenom_utilisateur text,
  p_telephone_utilisateur text,
  p_role public.role_utilisateur
) returns public.caves
language plpgsql security definer set search_path = public as $$
declare
  v_cave public.caves;
begin
  if auth.uid() is null then
    raise exception 'Authentification requise.' using errcode = '42501';
  end if;

  if exists (select 1 from public.profiles where id = auth.uid()) then
    raise exception 'Ce compte possède déjà un profil.' using errcode = '23505';
  end if;

  if p_role not in ('proprietaire', 'proprietaire_gerant') then
    raise exception 'Le premier compte d''une cave doit être Propriétaire ou Propriétaire/Gérant.'
      using errcode = '22023';
  end if;

  insert into public.caves (nom, type_cave, telephone, localisation, created_by)
  values (p_nom_cave, p_type_cave, p_telephone_cave, p_localisation, auth.uid())
  returning * into v_cave;

  insert into public.profiles (id, cave_id, nom, prenom, telephone, role, created_by)
  values (auth.uid(), v_cave.id, p_nom_utilisateur, p_prenom_utilisateur, p_telephone_utilisateur, p_role, auth.uid());

  return v_cave;
end;
$$;

grant execute on function public.creer_cave_et_proprietaire to authenticated;

-- ============================================================================
-- Fin de la migration Phase 1.
-- ============================================================================
