-- =============================================================================
-- Atelier+ — Politiques Supabase Storage — photos des groupes d'uniformes
-- =============================================================================
-- À exécuter après supabase/schema.sql et migration_phase8_uniformes.sql
-- (utilise public.mon_role(), public.mon_atelier_id() et
-- public.ma_permission(), définies dans schema.sql).
--
-- Bucket "photos-uniformes" : photos de modèles et de tissus d'un groupe
-- (promotion, établissement...). Même logique que "photos-clients" (voir
-- storage_policies_photos.sql) : public en lecture (nom de fichier
-- imprévisible, pas de donnée sensible), écriture réservée aux membres de
-- l'atelier concerné, propriétaire ou apprenti autorisé à ajouter des
-- photos (voir PermissionsApprenti.ajouterPhotos).
--
-- Convention de chemin : "<atelier_id>/<groupe_id>/<photo_id>.jpg".
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('photos-uniformes', 'photos-uniformes', true)
on conflict (id) do nothing;

create policy "photos_uniformes_lecture_publique"
  on storage.objects for select
  using (bucket_id = 'photos-uniformes');

create policy "photos_uniformes_ecriture_autorisee"
  on storage.objects for insert
  with check (
    bucket_id = 'photos-uniformes'
    and (storage.foldername(name))[1] = public.mon_atelier_id()::text
    and (public.mon_role() = 'proprietaire' or public.ma_permission('ajouter_photos'))
  );

create policy "photos_uniformes_suppression_proprietaire"
  on storage.objects for delete
  using (
    bucket_id = 'photos-uniformes'
    and (storage.foldername(name))[1] = public.mon_atelier_id()::text
    and public.mon_role() = 'proprietaire'
  );
