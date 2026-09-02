-- =============================================================================
-- ATELIER+ — Bucket de stockage des photos clients (Phase 2)
-- =============================================================================
-- À exécuter après schema.sql.
--
-- Bucket PUBLIC (comme logos-ateliers), par choix assumé et documenté :
-- `StockageRepository.televerserImageCompressee` utilise `getPublicUrl()`
-- (URL directe, sans jeton), stockée telle quelle dans `photos.url` et
-- affichée via `Image.network(url)` côté application. Un bucket privé
-- exigerait des URLs signées à renouveler périodiquement — complexité hors
-- périmètre de cette phase, pour des photos de tissus/modèles qui ne sont
-- PAS classées comme données sensibles dans le cahier des charges (contrairement
-- aux données financières, elles, toujours protégées par la RLS de la table
-- `photos` elle-même et de `commandes`/`paiements`).
--
-- Le chemin de chaque fichier étant "<client_id>/<uuid-aléatoire>.jpg", une
-- photo n'est accessible qu'à qui connaît déjà son URL exacte (non
-- énumérable) : protection par obscurité en complément, pas en remplacement,
-- de la RLS sur la table `photos` qui reste la source de vérité contrôlant
-- qui peut découvrir ces URLs via l'application.
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('photos-clients', 'photos-clients', true)
on conflict (id) do nothing;

drop policy if exists photos_clients_lecture on storage.objects;
create policy photos_clients_lecture on storage.objects
  for select to public
  using (bucket_id = 'photos-clients');

-- Écriture (upload/suppression) : le chemin de chaque fichier est
-- "<client_id>/<uuid>.jpg" (voir PhotosRepository) ; la politique retrouve
-- l'atelier du client concerné pour vérifier l'appartenance et la
-- permission, exactement comme la RLS de la table `photos`.
drop policy if exists photos_clients_ecriture on storage.objects;
create policy photos_clients_ecriture on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'photos-clients'
    and exists (
      select 1 from public.clients c
      where c.id::text = (storage.foldername(name))[1]
        and c.atelier_id = public.mon_atelier_id()
        and (public.est_proprietaire() or public.a_permission_ajouter_photos())
    )
  );

drop policy if exists photos_clients_suppression on storage.objects;
create policy photos_clients_suppression on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'photos-clients'
    and exists (
      select 1 from public.clients c
      where c.id::text = (storage.foldername(name))[1]
        and c.atelier_id = public.mon_atelier_id()
        and (public.est_proprietaire() or public.a_permission_ajouter_photos())
    )
  );
