-- =====================================================================
-- Phase 5 — programme d'activités (B6) et bilan annuel (B7) : un seul jeu
-- de lignes « objectif → activités » ; versions finales verrouillées
-- (17.4) ; droits et synchronisation.
-- =====================================================================

-- N° d'ordre : sert seulement à trier (le numéro imprimé est la position).
-- Sans unicité, deux téléphones hors ligne peuvent ajouter un objectif.
alter table public.activity_objectives
  drop constraint activity_objectives_school_year_id_order_no_key;

-- Version finale verrouillée : numéro de la version (null = modifiable).
alter table public.official_forms add column locked_version integer
  check (locked_version is null or locked_version > 0);

-- Programme et bilan : directeur et délégué « formulaires » ; jamais
-- l'enseignant (17.7).
create policy activity_objectives_read on public.activity_objectives for select to authenticated
  using (app.has_any_perm(school_id, array['formulaires']));
create policy activity_objectives_insert on public.activity_objectives for insert to authenticated
  with check (app.has_any_perm(school_id, array['formulaires']));
create policy activity_objectives_update on public.activity_objectives for update to authenticated
  using (app.has_any_perm(school_id, array['formulaires']))
  with check (app.has_any_perm(school_id, array['formulaires']));

create policy activity_lines_read on public.activity_lines for select to authenticated
  using (app.has_any_perm(school_id, array['formulaires']));
create policy activity_lines_insert on public.activity_lines for insert to authenticated
  with check (app.has_any_perm(school_id, array['formulaires']));
create policy activity_lines_update on public.activity_lines for update to authenticated
  using (app.has_any_perm(school_id, array['formulaires']))
  with check (app.has_any_perm(school_id, array['formulaires']));

-- Versions (instantanés imprimés) : ajout seul.
create policy form_versions_read on public.form_versions for select to authenticated
  using (app.has_any_perm(school_id, array['formulaires', 'registres']));
create policy form_versions_insert on public.form_versions for insert to authenticated
  with check (app.has_any_perm(school_id, array['formulaires', 'registres']));

-- Verrou : tant qu'une version finale est verrouillée, ses colonnes ne
-- changent plus (B6 : objectifs, activités, échéances, contraintes,
-- résultats attendus ; B7 : résultats atteints, taux). « Modifier » lève le
-- verrou : l'ancienne version reste conservée.
create or replace function app.activity_form_locked(p_year uuid, p_code text) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.official_forms f
     where f.school_year_id = p_year and f.form_code = p_code and f.student_id is null
       and f.deleted_at is null and f.locked_version is not null);
$$;

create or replace function app.guard_activity_objective() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if app.activity_form_locked(new.school_year_id, 'B6')
     and (tg_op = 'INSERT' or new.label is distinct from old.label
          or new.order_no is distinct from old.order_no
          or new.deleted_at is distinct from old.deleted_at) then
    raise exception 'Programme verrouillé (version finale) : touchez « Modifier » pour créer une nouvelle version.'
      using errcode = 'P0001';
  end if;
  return new;
end $$;
create trigger activity_objectives_guard before insert or update on public.activity_objectives
  for each row execute function app.guard_activity_objective();

create or replace function app.guard_activity_line() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_year uuid;
begin
  select school_year_id into v_year from public.activity_objectives where id = new.objective_id;
  if app.activity_form_locked(v_year, 'B6')
     and (tg_op = 'INSERT'
          or new.objective_id is distinct from old.objective_id
          or new.sort_order is distinct from old.sort_order
          or new.planned_activity is distinct from old.planned_activity
          or new.deadline_on is distinct from old.deadline_on
          or new.deadline_text is distinct from old.deadline_text
          or new.constraint_text is distinct from old.constraint_text
          or new.expected_result is distinct from old.expected_result
          or new.deleted_at is distinct from old.deleted_at) then
    raise exception 'Programme verrouillé (version finale) : touchez « Modifier » pour créer une nouvelle version.'
      using errcode = 'P0001';
  end if;
  if tg_op = 'UPDATE' and app.activity_form_locked(v_year, 'B7')
     and (new.achieved_result is distinct from old.achieved_result
          or new.success_rate is distinct from old.success_rate) then
    raise exception 'Bilan verrouillé (version finale) : touchez « Modifier » pour créer une nouvelle version.'
      using errcode = 'P0001';
  end if;
  return new;
end $$;
create trigger activity_lines_guard before insert or update on public.activity_lines
  for each row execute function app.guard_activity_line();

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('activity_objectives', 'lww', '{id}'),
  ('activity_lines', 'lww', '{id}'),
  ('form_versions', 'append', '{id}');

do $$
declare
  t text;
begin
  foreach t in array array['activity_objectives', 'activity_lines', 'form_versions'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;
