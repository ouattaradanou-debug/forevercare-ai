-- Phase 9 — A21 : « Effacer définitivement » un document de la corbeille
-- (directeur ; délégué « archives » pour les archives), sans attendre les
-- 30 jours. Le fichier est effacé par l'application (API de stockage), puis
-- la fiche est marquée effacée par cette fonction (le serveur garde la
-- trace : qui, quand, dans le journal d'activité).

create policy documents_files_delete on storage.objects for delete to authenticated
  using (bucket_id = 'documents' and exists (
    select 1 from public.documents d
     where d.id = app.document_of(name)
       and d.deleted_at is null and d.trashed_at is not null
       and app.document_manager(d.school_id, d.space)));

create or replace function public.document_effacer(p_doc uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  d public.documents;
begin
  select * into d from public.documents where id = p_doc and deleted_at is null for update;
  if not found or not app.document_manager(d.school_id, d.space) then
    raise exception 'Seul le directeur (ou la personne chargée des archives) peut effacer ce document.'
      using errcode = '42501';
  end if;
  if d.trashed_at is null then
    raise exception 'Mettez d''abord le document à la corbeille.' using errcode = 'P0001';
  end if;
  delete from public.document_chunks where document_id = p_doc;
  update public.documents set deleted_at = now(), updated_at = now() where id = p_doc;
end $$;

revoke all on function public.document_effacer(uuid) from public, anon;
grant execute on function public.document_effacer(uuid) to authenticated;
