-- =============================================================================
-- Atelier+ — Migration Phase 8 : Mesures des uniformes (groupes de commande)
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase.
--
-- Nouveau module indépendant des clients classiques, pour un tailleur
-- confectionnant des uniformes pour un groupe (promotion scolaire,
-- établissement, équipe...) : un "groupe" (nom, répondant, contact, photos
-- de modèles/tissus) contient plusieurs "membres", chacun avec sa propre
-- fiche de mesures.
--
-- Règle centrale (demande explicite) : ces mesures ne doivent JAMAIS
-- apparaître dans la fiche "Nouveau client" ni dans aucun autre module —
-- d'où des tables entièrement séparées de `clients`/`mesures`/`photos`,
-- plutôt que de réutiliser ces tables avec une colonne optionnelle
-- supplémentaire (qui aurait risqué de mélanger les deux univers à la
-- moindre requête mal filtrée). Seuls `types_tenue`/`champs_mesure` (les
-- gabarits de mesure Homme/Femme) sont réutilisés tels quels : un membre
-- de groupe se mesure avec les mêmes champs qu'un client, juste stockés à
-- part (voir `mesures_uniforme.type_tenue_id`).
-- =============================================================================

create table if not exists public.groupes_uniformes (
  id                    uuid primary key default gen_random_uuid(),
  atelier_id            uuid not null references public.ateliers (id) on delete cascade,
  nom                   text not null check (char_length(trim(nom)) > 0),
  repondant_nom         text,
  repondant_telephone   text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists idx_groupes_uniformes_atelier on public.groupes_uniformes (atelier_id);

create trigger trg_groupes_uniformes_updated_at
  before update on public.groupes_uniformes
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : membres_groupe_uniforme
-- =============================================================================
create table if not exists public.membres_groupe_uniforme (
  id          uuid primary key default gen_random_uuid(),
  groupe_id   uuid not null references public.groupes_uniformes (id) on delete cascade,
  nom         text,
  prenom      text,
  sexe        text check (sexe in ('Homme', 'Femme')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_membres_groupe_uniforme_groupe on public.membres_groupe_uniforme (groupe_id);

create trigger trg_membres_groupe_uniforme_updated_at
  before update on public.membres_groupe_uniforme
  for each row execute function public.definir_horodatage_modification();


-- =============================================================================
-- TABLE : mesures_uniforme
-- Historisée comme `mesures` : une nouvelle prise crée une nouvelle ligne,
-- jamais de mise à jour (aucune policy UPDATE/DELETE, voir plus bas).
-- Réutilise le même gabarit `types_tenue`/`champs_mesure` que les clients.
-- =============================================================================
create table if not exists public.mesures_uniforme (
  id             uuid primary key default gen_random_uuid(),
  membre_id      uuid not null references public.membres_groupe_uniforme (id) on delete cascade,
  type_tenue_id  uuid not null references public.types_tenue (id),
  date_prise     timestamptz not null default now(),
  valeurs        jsonb not null default '{}'::jsonb,
  prise_par      uuid not null references public.utilisateurs (id),
  created_at     timestamptz not null default now()
);

create index if not exists idx_mesures_uniforme_membre on public.mesures_uniforme (membre_id, date_prise desc);


-- =============================================================================
-- TABLE : photos_groupe_uniforme
-- Rattachées au GROUPE (modèles/tissus communs à tout le groupe), pas à un
-- membre individuel — voir la demande : "Modèles hommes/femmes",
-- "Tissus hommes/femmes" sont des informations de groupe.
-- =============================================================================
create table if not exists public.photos_groupe_uniforme (
  id          uuid primary key default gen_random_uuid(),
  groupe_id   uuid not null references public.groupes_uniformes (id) on delete cascade,
  type        text not null check (
                type in ('modele_homme', 'modele_femme', 'tissu_homme', 'tissu_femme')
              ),
  url         text not null,
  source      text not null check (source in ('camera', 'galerie')),
  commentaire text,
  created_at  timestamptz not null default now()
);

create index if not exists idx_photos_groupe_uniforme_groupe on public.photos_groupe_uniforme (groupe_id);


-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
-- Réutilise les mêmes colonnes de permissions_apprenti que les clients :
-- un groupe d'uniformes se crée/modifie/mesure comme une fiche client
-- (creer_client, modifier_client, prendre_mesures, ajouter_photos) — pas de
-- nouvelle colonne de permission, pour rester simple à configurer pour le
-- propriétaire (voir PermissionsApprentiPage côté application).
alter table public.groupes_uniformes         enable row level security;
alter table public.membres_groupe_uniforme   enable row level security;
alter table public.mesures_uniforme          enable row level security;
alter table public.photos_groupe_uniforme    enable row level security;

-- -----------------------------------------------------------------------------
-- groupes_uniformes
-- -----------------------------------------------------------------------------
create policy "groupes_uniformes_select_mon_atelier"
  on public.groupes_uniformes for select
  using (atelier_id = public.mon_atelier_id());

create policy "groupes_uniformes_insert_autorise"
  on public.groupes_uniformes for insert
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.mon_role() = 'proprietaire' or public.ma_permission('creer_client'))
  );

create policy "groupes_uniformes_update_autorise"
  on public.groupes_uniformes for update
  using (atelier_id = public.mon_atelier_id())
  with check (
    atelier_id = public.mon_atelier_id()
    and (public.mon_role() = 'proprietaire' or public.ma_permission('modifier_client'))
  );

create policy "groupes_uniformes_delete_proprietaire"
  on public.groupes_uniformes for delete
  using (atelier_id = public.mon_atelier_id() and public.mon_role() = 'proprietaire');

-- -----------------------------------------------------------------------------
-- membres_groupe_uniforme
-- -----------------------------------------------------------------------------
create policy "membres_groupe_uniforme_select_mon_atelier"
  on public.membres_groupe_uniforme for select
  using (
    exists (
      select 1 from public.groupes_uniformes g
      where g.id = membres_groupe_uniforme.groupe_id
        and g.atelier_id = public.mon_atelier_id()
    )
  );

create policy "membres_groupe_uniforme_insert_autorise"
  on public.membres_groupe_uniforme for insert
  with check (
    exists (
      select 1 from public.groupes_uniformes g
      where g.id = membres_groupe_uniforme.groupe_id
        and g.atelier_id = public.mon_atelier_id()
    )
    and (public.mon_role() = 'proprietaire' or public.ma_permission('creer_client'))
  );

create policy "membres_groupe_uniforme_update_autorise"
  on public.membres_groupe_uniforme for update
  using (
    exists (
      select 1 from public.groupes_uniformes g
      where g.id = membres_groupe_uniforme.groupe_id
        and g.atelier_id = public.mon_atelier_id()
    )
  )
  with check (
    exists (
      select 1 from public.groupes_uniformes g
      where g.id = membres_groupe_uniforme.groupe_id
        and g.atelier_id = public.mon_atelier_id()
    )
    and (public.mon_role() = 'proprietaire' or public.ma_permission('modifier_client'))
  );

create policy "membres_groupe_uniforme_delete_proprietaire"
  on public.membres_groupe_uniforme for delete
  using (
    exists (
      select 1 from public.groupes_uniformes g
      where g.id = membres_groupe_uniforme.groupe_id
        and g.atelier_id = public.mon_atelier_id()
        and public.mon_role() = 'proprietaire'
    )
  );

-- -----------------------------------------------------------------------------
-- mesures_uniforme — historisées, jamais modifiées ni supprimées.
-- -----------------------------------------------------------------------------
create policy "mesures_uniforme_select_mon_atelier"
  on public.mesures_uniforme for select
  using (
    exists (
      select 1 from public.membres_groupe_uniforme m
      join public.groupes_uniformes g on g.id = m.groupe_id
      where m.id = mesures_uniforme.membre_id
        and g.atelier_id = public.mon_atelier_id()
    )
  );

create policy "mesures_uniforme_insert_autorise"
  on public.mesures_uniforme for insert
  with check (
    prise_par = auth.uid()
    and exists (
      select 1 from public.membres_groupe_uniforme m
      join public.groupes_uniformes g on g.id = m.groupe_id
      where m.id = mesures_uniforme.membre_id
        and g.atelier_id = public.mon_atelier_id()
    )
    and (public.mon_role() = 'proprietaire' or public.ma_permission('prendre_mesures'))
  );

-- -----------------------------------------------------------------------------
-- photos_groupe_uniforme
-- -----------------------------------------------------------------------------
create policy "photos_groupe_uniforme_select_mon_atelier"
  on public.photos_groupe_uniforme for select
  using (
    exists (
      select 1 from public.groupes_uniformes g
      where g.id = photos_groupe_uniforme.groupe_id
        and g.atelier_id = public.mon_atelier_id()
    )
  );

create policy "photos_groupe_uniforme_insert_autorise"
  on public.photos_groupe_uniforme for insert
  with check (
    exists (
      select 1 from public.groupes_uniformes g
      where g.id = photos_groupe_uniforme.groupe_id
        and g.atelier_id = public.mon_atelier_id()
    )
    and (public.mon_role() = 'proprietaire' or public.ma_permission('ajouter_photos'))
  );

create policy "photos_groupe_uniforme_delete_proprietaire"
  on public.photos_groupe_uniforme for delete
  using (
    exists (
      select 1 from public.groupes_uniformes g
      where g.id = photos_groupe_uniforme.groupe_id
        and g.atelier_id = public.mon_atelier_id()
        and public.mon_role() = 'proprietaire'
    )
  );
