-- =============================================================================
-- ATELIER+ — Bucket de stockage du logo d'atelier (Phase 1)
-- =============================================================================
-- À exécuter après schema.sql. Le bucket des photos clients (tissus/modèles)
-- sera ajouté en Phase 2 dans un fichier séparé.
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('logos-ateliers', 'logos-ateliers', true)
on conflict (id) do nothing;

-- Lecture publique : le logo est affiché sur l'écran d'accueil et l'export
-- PDF (Phase 4), sans notion d'atelier tiers à protéger (un logo n'est pas
-- une donnée sensible).
drop policy if exists logos_lecture_publique on storage.objects;
create policy logos_lecture_publique on storage.objects
  for select to public
  using (bucket_id = 'logos-ateliers');

-- Écriture (upload/suppression) réservée aux utilisateurs authentifiés,
-- dans un dossier nommé d'après leur propre utilisateur_id (préfixe de
-- chemin), conformément à l'organisation choisie dans
-- StockageRepository.televerserImageCompressee.
drop policy if exists logos_ecriture_authentifie on storage.objects;
create policy logos_ecriture_authentifie on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'logos-ateliers'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists logos_suppression_authentifie on storage.objects;
create policy logos_suppression_authentifie on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'logos-ateliers'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
