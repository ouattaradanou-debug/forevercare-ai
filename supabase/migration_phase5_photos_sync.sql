-- =============================================================================
-- Atelier+ — Migration Phase 5 : synchronisation des photos
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase.
--
-- Les photos n'ont jamais été envoyées à Supabase jusqu'ici (uniquement
-- stockées sur le téléphone qui les a prises, voir ClientRepository) : la
-- table `photos` existait déjà (schema.sql), mais sans colonne
-- `commentaire` (ajoutée en cours de route, seulement côté cache local) ni
-- policy UPDATE (nécessaire pour l'upsert utilisé par
-- ClientRepository.pousserPhoto, et pour modifier un commentaire après
-- coup). Voir aussi storage_policies_photos.sql, à exécuter avec ce
-- fichier, pour le bucket où les fichiers eux-mêmes sont envoyés.
-- =============================================================================

alter table public.photos add column if not exists commentaire text;

create policy "photos_update_autorise"
  on public.photos for update
  using (
    exists (
      select 1 from public.clients c
      where c.id = photos.client_id and c.atelier_id = public.mon_atelier_id()
    )
  )
  with check (
    exists (
      select 1 from public.clients c
      where c.id = photos.client_id and c.atelier_id = public.mon_atelier_id()
    )
    and (public.mon_role() = 'proprietaire' or public.ma_permission('ajouter_photos'))
  );
