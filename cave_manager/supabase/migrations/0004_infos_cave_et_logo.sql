-- ============================================================================
-- Phase 1 — Informations de la cave modifiables + logo
--
-- Demandé explicitement : pouvoir renseigner/modifier depuis l'écran
-- d'accueil (icône ⚙️, déjà en place pour le type de cave) le nom de la
-- cave, son numéro de téléphone, la ville, un logo affiché sous "Ma Cave",
-- et son propre nom/prénom.
--
-- Aucune nouvelle policy RLS nécessaire pour nom/téléphone/ville : la
-- policy `caves_update` (migration 0001, étendue au Gérant en 0003 via
-- `is_responsable()`) couvre déjà TOUTES les colonnes de `caves`, pas
-- seulement `type_cave`. Idem pour nom/prénom personnels : `profiles_update_self`
-- + le trigger `protect_sensitive_profile_fields` (migration 0001)
-- couvrent déjà ce cas pour les 4 rôles (ces deux colonnes ne sont pas
-- parmi les colonnes protégées).
--
-- Seul ajout de schéma nécessaire : la colonne pour stocker l'URL du
-- logo, plus le bucket de stockage (section suivante).
-- ============================================================================

alter table public.caves add column if not exists logo_url text;

comment on column public.caves.logo_url is 'URL publique du logo de la cave (bucket de stockage logos-cave), affiché sous le titre de l''écran d''accueil.';

-- ----------------------------------------------------------------------------
-- Bucket de stockage pour les logos. Public en lecture (nécessaire pour
-- l'affichage direct via Image.network sans re-signer une URL à chaque
-- fois), mais l'écriture reste restreinte par les policies ci-dessous à
-- Propriétaire/Propriétaire-Gérant/Gérant de la cave concernée — un logo
-- de cave n'est pas une donnée sensible (contrairement au stock ou aux
-- clôtures), donc ce compromis est raisonnable.
-- ----------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('logos-cave', 'logos-cave', true)
on conflict (id) do nothing;

-- Convention de chemin : "<cave_id>/logo.<ext>" — le premier segment du
-- chemin sert à vérifier que l'utilisateur agit bien sur SA cave.
create policy logos_cave_lecture_publique on storage.objects
  for select using (bucket_id = 'logos-cave');

create policy logos_cave_ecriture_responsables on storage.objects
  for insert with check (
    bucket_id = 'logos-cave'
    and (storage.foldername(name))[1] = public.current_cave_id()::text
    and public.is_responsable()
  );

create policy logos_cave_maj_responsables on storage.objects
  for update using (
    bucket_id = 'logos-cave'
    and (storage.foldername(name))[1] = public.current_cave_id()::text
    and public.is_responsable()
  ) with check (
    bucket_id = 'logos-cave'
    and (storage.foldername(name))[1] = public.current_cave_id()::text
    and public.is_responsable()
  );

-- ============================================================================
-- Fin de la migration 0004.
-- ============================================================================
