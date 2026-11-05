-- =====================================================================
-- Phase 12 — Assistant IA pédagogique avec la bibliothèque.
--   * l'IA est appelée UNIQUEMENT par la fonction serveur « assistant-ia »
--     (clé du fournisseur dans ses variables d'environnement, jamais dans
--     l'application) ;
--   * limites par mois : par école (demandes et budget, ai_quotas) et par
--     enseignant (30 par défaut, ajustable par le directeur) ;
--   * passages de la bibliothèque recherchés avec les droits de la personne
--     connectée : jamais une autre classe, jamais les archives, jamais un
--     document exclu de l'IA ou sensible ;
--   * fiches enregistrées (lesson_preps) synchronisées, propres à leur auteur.
-- =====================================================================

alter table public.ai_quotas
  add column teacher_monthly_limit integer not null default 30 check (teacher_monthly_limit >= 0);

-- Limite propre à un enseignant (réglée par le directeur).
create table public.ai_teacher_limits (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  membership_id uuid not null references public.memberships (id),
  monthly_limit integer not null check (monthly_limit between 0 and 1000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (membership_id)
);
alter table public.ai_teacher_limits enable row level security;

-- ------------------------------ Droits -------------------------------
-- Quotas de l'école : lus par l'école, fixés par le porteur du projet
-- (service_role) seulement.
create policy ai_quotas_read on public.ai_quotas for select to authenticated
  using (app.is_member(school_id));

create policy ai_teacher_limits_read on public.ai_teacher_limits for select to authenticated
  using (app.is_member(school_id));
create policy ai_teacher_limits_insert on public.ai_teacher_limits for insert to authenticated
  with check (app.is_director(school_id));
create policy ai_teacher_limits_update on public.ai_teacher_limits for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

-- Demandes à l'IA : écrites par la fonction serveur seulement ; chacun lit
-- les siennes, le directeur celles de l'école.
create policy ai_requests_read on public.ai_requests for select to authenticated
  using (user_id = auth.uid() or app.is_director(school_id));

-- Fiches enregistrées : l'auteur (et le directeur en lecture).
create policy lesson_preps_read on public.lesson_preps for select to authenticated
  using (author_id = auth.uid() or app.is_director(school_id));
create policy lesson_preps_insert on public.lesson_preps for insert to authenticated
  with check (author_id = auth.uid() and app.is_member(school_id));
create policy lesson_preps_update on public.lesson_preps for update to authenticated
  using (author_id = auth.uid()) with check (author_id = auth.uid());

-- ------------------- Passages utilisables par l'IA --------------------
-- Recherche « par les mots » (un mot suffit) dans les seuls documents de
-- bibliothèque autorisés pour l'IA, approuvés, hors corbeille, non
-- sensibles ; les droits de lecture de la personne connectée s'appliquent
-- (security invoker : RLS des documents et des passages).
create or replace function public.ia_passages(
  p_school uuid,
  p_query text,
  p_documents uuid[] default null,
  p_limit integer default 8
) returns table (document_id uuid, titre text, page integer, contenu text, score real)
language sql stable security invoker set search_path = '' as $$
  with q as (
    select nullif(replace(plainto_tsquery('french', coalesce(p_query, ''))::text, '&', '|'), '')::tsquery as tsq
  )
  select c.document_id, d.title, c.page, c.content, ts_rank(c.tsv, q.tsq)
    from public.document_chunks c
    join public.documents d on d.id = c.document_id
    cross join q
   where c.school_id = p_school
     and d.school_id = p_school
     and d.space = 'bibliotheque' and d.ai_allowed and not d.is_sensitive
     and d.approved and d.trashed_at is null and d.deleted_at is null
     and (p_documents is null or cardinality(p_documents) = 0 or d.id = any (p_documents))
     and (q.tsq is null or c.tsv @@ q.tsq)
   order by 5 desc, c.document_id, c.chunk_index
   limit least(greatest(coalesce(p_limit, 8), 1), 20);
$$;
revoke all on function public.ia_passages(uuid, text, uuid[], integer) from public, anon;
grant execute on function public.ia_passages(uuid, text, uuid[], integer) to authenticated;

-- Documents que la personne peut cocher pour l'IA (catalogue).
create or replace function public.ia_documents(p_school uuid)
returns table (document_id uuid, titre text, pages integer, indexe boolean)
language sql stable security invoker set search_path = '' as $$
  select d.id, d.title, d.page_count, d.index_status = 'indexe'
    from public.documents d
   where d.school_id = p_school and d.space = 'bibliotheque' and d.ai_allowed
     and not d.is_sensitive and d.approved and d.trashed_at is null and d.deleted_at is null
   order by d.title;
$$;
revoke all on function public.ia_documents(uuid) from public, anon;
grant execute on function public.ia_documents(uuid) to authenticated;

-- ------------------------- Usage du mois ------------------------------
-- Une ligne par personne : demandes réussies du mois, coût ; limite qui
-- s'applique. Le directeur voit toute l'école, les autres leur seule ligne.
create or replace function public.ia_usage(p_school uuid, p_mois date default null)
returns table (
  user_id uuid, membership_id uuid, nom text, demandes integer, cout_microusd bigint,
  limite integer, ecole_demandes integer, ecole_limite integer,
  ecole_cout_microusd bigint, ecole_budget_microusd bigint
)
language sql stable security definer set search_path = '' as $$
  with debut as (
    select date_trunc('month', coalesce(p_mois, (now() at time zone 'Africa/Ouagadougou')::date))::date as d
  ),
  quota as (
    select coalesce(max(q.monthly_request_limit), 300) as demandes,
           coalesce(max(q.monthly_budget_microusd), 5000000) as budget,
           coalesce(max(q.teacher_monthly_limit), 30) as enseignant
      from public.ai_quotas q where q.school_id = p_school
  ),
  fait as (
    select r.user_id, count(*)::int as n, coalesce(sum(r.cost_microusd), 0)::bigint as cout
      from public.ai_requests r, debut
     where r.school_id = p_school and r.status = 'terminee' and r.deleted_at is null
       and r.created_at >= debut.d and r.created_at < (debut.d + interval '1 month')
     group by r.user_id
  ),
  total as (select coalesce(sum(n), 0)::int as n, coalesce(sum(cout), 0)::bigint as cout from fait)
  select m.user_id, m.id, m.display_name, coalesce(f.n, 0), coalesce(f.cout, 0),
         coalesce(l.monthly_limit, quota.enseignant), total.n, quota.demandes, total.cout, quota.budget
    from public.memberships m
    cross join quota cross join total
    left join fait f on f.user_id = m.user_id
    left join public.ai_teacher_limits l on l.membership_id = m.id and l.deleted_at is null
   where m.school_id = p_school and m.active and m.deleted_at is null
     and m.role in ('directeur', 'enseignant')
     and app.is_member(p_school)
     and (app.is_director(p_school) or m.user_id = auth.uid())
   order by m.display_name;
$$;
revoke all on function public.ia_usage(uuid, date) from public, anon;
grant execute on function public.ia_usage(uuid, date) to authenticated, service_role;

-- --------------------------- Synchronisation ---------------------------
insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('lesson_preps', 'lww', '{id}'),
  ('ai_teacher_limits', 'lww', '{id}');

create trigger ai_teacher_limits_audit after insert or update on public.ai_teacher_limits
  for each row execute function app.audit_row();
