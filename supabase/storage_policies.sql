-- =============================================================================
-- Atelier+ — Politiques Supabase Storage — Phase 1
-- =============================================================================
-- À exécuter après supabase/schema.sql (utilise les fonctions
-- public.mon_role() et public.mon_atelier_id() qui y sont définies).
--
-- Bucket "logos" : logo de l'atelier, affiché en clair dans l'app et
-- réutilisé sur les exports PDF (Phase 4). Bucket public en lecture (un
-- logo n'est pas une donnée sensible ; cela évite d'avoir à gérer des URLs
-- signées à renouveler). L'écriture reste strictement réservée au
-- propriétaire de l'atelier concerné.
--
-- Convention de chemin : chaque fichier est stocké sous
-- "<atelier_id>/logo.jpg" — le premier segment du chemin identifie
-- l'atelier propriétaire du fichier.
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('logos', 'logos', true)
on conflict (id) do nothing;

create policy "logos_lecture_publique"
  on storage.objects for select
  using (bucket_id = 'logos');

create policy "logos_ecriture_proprietaire"
  on storage.objects for insert
  with check (
    bucket_id = 'logos'
    and public.mon_role() = 'proprietaire'
    and (storage.foldername(name))[1] = public.mon_atelier_id()::text
  );

create policy "logos_modification_proprietaire"
  on storage.objects for update
  using (
    bucket_id = 'logos'
    and public.mon_role() = 'proprietaire'
    and (storage.foldername(name))[1] = public.mon_atelier_id()::text
  )
  with check (
    bucket_id = 'logos'
    and public.mon_role() = 'proprietaire'
    and (storage.foldername(name))[1] = public.mon_atelier_id()::text
  );

create policy "logos_suppression_proprietaire"
  on storage.objects for delete
  using (
    bucket_id = 'logos'
    and public.mon_role() = 'proprietaire'
    and (storage.foldername(name))[1] = public.mon_atelier_id()::text
  );
