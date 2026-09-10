-- =============================================================================
-- Atelier+ — Politiques Supabase Storage — photos de clients
-- =============================================================================
-- À exécuter après supabase/schema.sql et migration_phase5_photos_sync.sql
-- (utilise public.mon_role(), public.mon_atelier_id() et
-- public.ma_permission(), définies dans schema.sql).
--
-- Bucket "photos-clients" : photos de tissu et de modèle prises pour un
-- client. Bucket public en lecture, comme le bucket "logos" (voir
-- storage_policies.sql) : évite d'avoir à gérer des URLs signées à
-- renouveler, alors que chaque fichier est nommé par un identifiant
-- aléatoire (uuid) impossible à deviner. L'écriture reste réservée aux
-- membres de l'atelier concerné, propriétaire ou apprenti autorisé à
-- ajouter des photos (voir PermissionsApprenti.ajouterPhotos).
--
-- Convention de chemin : chaque fichier est stocké sous
-- "<atelier_id>/<client_id>/<photo_id>.jpg" — le premier segment du
-- chemin identifie l'atelier propriétaire du fichier, comme pour "logos".
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('photos-clients', 'photos-clients', true)
on conflict (id) do nothing;

create policy "photos_clients_lecture_publique"
  on storage.objects for select
  using (bucket_id = 'photos-clients');

create policy "photos_clients_ecriture_autorisee"
  on storage.objects for insert
  with check (
    bucket_id = 'photos-clients'
    and (storage.foldername(name))[1] = public.mon_atelier_id()::text
    and (public.mon_role() = 'proprietaire' or public.ma_permission('ajouter_photos'))
  );

create policy "photos_clients_suppression_proprietaire"
  on storage.objects for delete
  using (
    bucket_id = 'photos-clients'
    and (storage.foldername(name))[1] = public.mon_atelier_id()::text
    and public.mon_role() = 'proprietaire'
  );
