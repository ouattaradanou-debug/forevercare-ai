-- Phase 9 (correctif) : la règle de lecture d'une fiche de document est
-- évaluée sur la ligne elle-même. Avant, elle relisait la ligne par son
-- identifiant : à l'ajout depuis le téléphone (insert … returning de
-- sync_push), la ligne neuve n'était pas encore visible et l'ajout était
-- refusé (42501), même pour le directeur.

create or replace function app.document_row_readable(d public.documents) returns boolean
language sql stable security definer set search_path = '' as $$
  select d.deleted_at is null
     and (
       app.document_manager(d.school_id, d.space)
       or (d.space = 'bibliotheque' and app.is_member(d.school_id) and (
             d.uploaded_by = auth.uid()
             or (d.approved and d.trashed_at is null and (
                   d.is_common
                   or not app.is_teacher_only(d.school_id)
                   or d.class_ids && array(select app.my_class_ids())
                   or d.level_codes && array(select c.level_code from public.classes c
                                              where c.id in (select app.my_class_ids())))))));
$$;

-- Passages et fichiers : même règle, par l'identifiant du document.
create or replace function app.document_readable(p_doc uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce((select app.document_row_readable(d) from public.documents d
                    where d.id = p_doc), false);
$$;

drop policy documents_read on public.documents;
create policy documents_read on public.documents for select to authenticated
  using (app.document_row_readable(documents));
