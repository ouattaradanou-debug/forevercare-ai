-- =====================================================================
-- Phase 9 — Bibliothèque pédagogique et archives administratives (18).
-- Fichiers : compartiment privé « documents », chemin
-- {school_id}/{document_id}/{nom}. Le fichier, la fiche ET l'index
-- (passages) obéissent aux mêmes règles d'accès. Archives : jamais pour un
-- enseignant, jamais pour l'IA. Les vecteurs viendront en phase 12.
-- =====================================================================

-- Classes et niveaux visés : tableaux sur la fiche (synchronisables).
alter table public.documents
  add column class_ids uuid[] not null default '{}',
  add column level_codes text[] not null default '{}',
  add column original_name text,
  add column uploaded_at timestamptz,          -- fichier entièrement envoyé
  add column index_attempts integer not null default 0;

-- Quota par école (5 Go par défaut, réglable) ; ajout des enseignants.
alter table public.schools
  add column storage_quota_bytes bigint not null default 5368709120 check (storage_quota_bytes > 0),
  add column library_teacher_mode text not null default 'validation'
    check (library_teacher_mode in ('validation', 'libre', 'interdit'));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('documents', 'documents', false, 52428800, array[
  'application/pdf', 'text/plain', 'image/jpeg', 'image/png',
  'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'application/vnd.oasis.opendocument.text', 'application/vnd.oasis.opendocument.spreadsheet',
  'application/octet-stream'])
on conflict (id) do nothing;

-- Gère la bibliothèque : directeur (les délégués « archives » gèrent les
-- archives).
create or replace function app.document_manager(p_school uuid, p_space text) returns boolean
language sql stable security definer set search_path = '' as $$
  select case p_space
           when 'archives' then app.has_any_perm(p_school, array['archives'])
           else app.is_director(p_school)
         end;
$$;

-- Enseignant sans aucun droit délégué (lecture limitée à sa classe).
create or replace function app.is_teacher_only(p_school uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.memberships m
                  where m.school_id = p_school and m.user_id = auth.uid() and m.active
                    and m.deleted_at is null and m.role = 'enseignant');
$$;

-- Lecture d'une fiche (et donc de son fichier et de ses passages).
create or replace function app.document_readable(p_doc uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.documents d
     where d.id = p_doc and d.deleted_at is null
       and (
         app.document_manager(d.school_id, d.space)
         or (d.space = 'bibliotheque' and app.is_member(d.school_id) and (
               d.uploaded_by = auth.uid()
               or (d.approved and d.trashed_at is null and (
                     d.is_common
                     or not app.is_teacher_only(d.school_id)
                     or d.class_ids && array(select app.my_class_ids())
                     or d.level_codes && array(select c.level_code from public.classes c
                                                where c.id in (select app.my_class_ids())))))))
  );
$$;

create policy documents_read on public.documents for select to authenticated
  using (app.document_readable(id));
create policy documents_insert on public.documents for insert to authenticated
  with check (app.document_manager(school_id, space)
              or (space = 'bibliotheque' and app.is_teacher_only(school_id)));
create policy documents_update on public.documents for update to authenticated
  using (app.document_manager(school_id, space)
         or (space = 'bibliotheque' and uploaded_by = auth.uid() and not approved))
  with check (app.document_manager(school_id, space)
              or (space = 'bibliotheque' and uploaded_by = auth.uid() and not approved));

-- Garde (archives jamais pour l'IA : contrainte CHECK de la table) ; ajout d'un enseignant selon le réglage
-- de l'école (validation par le directeur par défaut) ; auteur imposé ;
-- statut d'indexation tenu par le serveur ; quota.
create or replace function app.document_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_mode text;
  v_quota bigint;
  v_used bigint;
begin
  if tg_op = 'INSERT' then
    new.uploaded_by := coalesce(auth.uid(), new.uploaded_by);
  else
    new.uploaded_by := old.uploaded_by;
  end if;
  if auth.uid() is not null and not app.document_manager(new.school_id, new.space) then
    select library_teacher_mode into v_mode from public.schools where id = new.school_id;
    if v_mode = 'interdit' then
      raise exception 'Le directeur n''a pas ouvert l''ajout de documents aux enseignants.' using errcode = '42501';
    end if;
    new.approved := (v_mode = 'libre');
    new.is_common := false;
  end if;
  -- Indexation : seul le serveur (travailleur) change ces champs.
  if auth.uid() is not null then
    if tg_op = 'INSERT' then
      new.index_status := 'en_attente';
      new.index_error := null;
      new.index_cost_microusd := null;
      new.indexed_at := null;
      new.index_attempts := 0;
    else
      new.index_status := old.index_status;
      new.index_error := old.index_error;
      new.index_cost_microusd := old.index_cost_microusd;
      new.indexed_at := old.indexed_at;
      new.index_attempts := old.index_attempts;
      new.page_count := old.page_count;
    end if;
  end if;
  if coalesce(new.size_bytes, 0) > coalesce(case when tg_op = 'UPDATE' then old.size_bytes end, 0) then
    select storage_quota_bytes into v_quota from public.schools where id = new.school_id;
    select coalesce(sum(size_bytes), 0) into v_used from public.documents
     where school_id = new.school_id and deleted_at is null and id <> new.id;
    if v_used + new.size_bytes > v_quota then
      raise exception 'Espace plein : % Mo utilisés sur % Mo. Videz la corbeille ou demandez plus d''espace.',
        round(v_used / 1048576.0), round(v_quota / 1048576.0) using errcode = 'P0001';
    end if;
  end if;
  return new;
end $$;
create trigger documents_guard before insert or update on public.documents
  for each row execute function app.document_guard();

-- Passages (texte intégral, plus tard vecteurs) : mêmes règles que le
-- document ; écrits seulement par le travailleur d'indexation.
create policy document_chunks_read on public.document_chunks for select to authenticated
  using (app.document_readable(document_id));

-- Fichiers : lus et déposés selon la fiche du document.
create or replace function app.document_of(p_name text) returns uuid
language sql immutable as $$
  select app.try_uuid((storage.foldername(p_name))[2]);
$$;

create policy documents_files_read on storage.objects for select to authenticated
  using (bucket_id = 'documents' and app.document_readable(app.document_of(name)));
create policy documents_files_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'documents' and exists (
    select 1 from public.documents d
     where d.id = app.document_of(name)
       and d.school_id = app.try_uuid((storage.foldername(name))[1])
       and d.deleted_at is null
       and (app.document_manager(d.school_id, d.space) or d.uploaded_by = auth.uid())));
create policy documents_files_update on storage.objects for update to authenticated
  using (bucket_id = 'documents' and exists (
    select 1 from public.documents d
     where d.id = app.document_of(name)
       and (app.document_manager(d.school_id, d.space) or d.uploaded_by = auth.uid())))
  with check (bucket_id = 'documents');

-- Recherche par mots dans le texte intégral (droits de la personne
-- connectée : les passages illisibles ne sont pas renvoyés).
create or replace function public.documents_search(p_school uuid, p_query text, p_limit integer default 50)
returns table (document_id uuid, page integer, extrait text, score real)
language sql stable security invoker set search_path = '' as $$
  with q as (select websearch_to_tsquery('french', p_query) as tsq)
  select c.document_id, c.page,
         ts_headline('french', c.content, q.tsq,
                     'MaxWords=18, MinWords=6, StartSel=«, StopSel=», MaxFragments=1'),
         ts_rank(c.tsv, q.tsq)
    from public.document_chunks c, q
   where c.school_id = p_school and c.tsv @@ q.tsq
   order by 4 desc
   limit least(greatest(p_limit, 1), 200);
$$;

-- Espace utilisé (corbeille comprise) et quota.
create or replace function public.documents_usage(p_school uuid)
returns table (used_bytes bigint, quota_bytes bigint, documents integer)
language sql stable security definer set search_path = '' as $$
  select coalesce(sum(d.size_bytes), 0)::bigint, s.storage_quota_bytes, count(d.id)::int
    from public.schools s
    left join public.documents d on d.school_id = s.id and d.deleted_at is null
   where s.id = p_school and app.is_member(p_school)
   group by s.storage_quota_bytes;
$$;
revoke all on function public.documents_usage(uuid) from public, anon;
grant execute on function public.documents_usage(uuid) to authenticated;

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('documents', 'lww', '{id}');

create trigger documents_audit after insert or update on public.documents
  for each row execute function app.audit_row();
