-- =====================================================================
-- Phase 1 — Stockage privé des images de l'école (image d'en-tête par année).
-- Chemin : {school_id}/entetes/{fichier}. Aucun lien public : lecture par
-- URL signée courte ou téléchargement authentifié.
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('ecole-medias', 'ecole-medias', false, 2097152, array['image/png', 'image/jpeg'])
on conflict (id) do nothing;

create or replace function app.try_uuid(p text) returns uuid
language plpgsql immutable as $$
begin
  return p::uuid;
exception when others then
  return null;
end $$;

create policy ecole_medias_read on storage.objects for select to authenticated
  using (bucket_id = 'ecole-medias'
         and app.is_member(app.try_uuid((storage.foldername(name))[1])));

create policy ecole_medias_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'ecole-medias'
              and (storage.foldername(name))[2] = 'entetes'
              and app.has_perm(app.try_uuid((storage.foldername(name))[1]), 'formulaires'));

create policy ecole_medias_update on storage.objects for update to authenticated
  using (bucket_id = 'ecole-medias'
         and (storage.foldername(name))[2] = 'entetes'
         and app.has_perm(app.try_uuid((storage.foldername(name))[1]), 'formulaires'))
  with check (bucket_id = 'ecole-medias'
              and (storage.foldername(name))[2] = 'entetes'
              and app.has_perm(app.try_uuid((storage.foldername(name))[1]), 'formulaires'));
