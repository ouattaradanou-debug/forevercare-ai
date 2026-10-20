-- =====================================================================
-- Phase 1 — Ajustements du socle :
--   * catalogue des modules (remplace la liste figée) ;
--   * année en cours portée par l'école (une seule ligne à modifier : sûr hors ligne) ;
--   * « Niveaux gérés » : primaire (case) + maternelle (= module Maternelle) ;
--   * règle de l'élève absent paramétrable par école ;
--   * auteur des écritures fixé par le serveur.
-- =====================================================================

-- ---------------- Catalogue des modules optionnels -------------------
create table public.modules_catalog (
  key text primary key,
  label text not null,
  description text not null,
  depends_on text references public.modules_catalog (key),
  sort_order smallint not null default 0
);
alter table public.modules_catalog enable row level security;

insert into public.modules_catalog (key, label, description, sort_order) values
  ('maternelle', 'Maternelle',
   'Classes de maternelle, domaines d''apprentissage, livrets d''évaluation.', 1),
  ('cantine', 'Cantine',
   'Bénéficiaires, repas servis, stock de vivres, cotisations de cantine.', 2),
  ('medico_scolaire', 'Dossier médico-scolaire',
   'Fiche médico-scolaire des élèves (données de santé, accès directeur uniquement).', 3);
-- La Cantine nécessite les Finances : en version 1 les Finances sont toujours
-- actives (P6 reporté), la dépendance n'a donc pas encore de clé à référencer.

alter table public.school_modules drop constraint school_modules_module_key_check;
alter table public.school_modules
  add constraint school_modules_module_key_fk foreign key (module_key) references public.modules_catalog (key);
alter table public.school_modules rename column changed_at to updated_at;
alter table public.school_modules rename column changed_by to updated_by;
alter table public.school_modules add column created_at timestamptz not null default now();

-- ---------------- Année en cours et niveaux gérés --------------------
drop index public.school_years_one_current;
alter table public.school_years drop column is_current;
alter table public.schools add column current_school_year_id uuid references public.school_years (id);

alter table public.schools drop constraint schools_check;
alter table public.schools drop column manages_preschool;

-- Règle de l'élève absent (valeur de départ décidée le 21/10/2026, à confirmer
-- avec un directeur avant la phase 3) : 'non_compte' = « Abs. », la composition
-- manquante n'est pas comptée ; 'zero' = comptée 0.
alter table public.schools add column absent_rule text not null default 'non_compte'
  check (absent_rule in ('non_compte', 'zero'));

-- ---------------- Fonctions d'accès (utilisées par les politiques) ---
grant usage on schema app to authenticated;

create or replace function app.is_member(p_school uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.memberships m
     where m.school_id = p_school and m.user_id = auth.uid() and m.active and m.deleted_at is null);
$$;

create or replace function app.is_director(p_school uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.memberships m
     where m.school_id = p_school and m.user_id = auth.uid() and m.active and m.deleted_at is null
       and m.role = 'directeur');
$$;

-- Directeur, ou délégué ayant reçu ce droit.
create or replace function app.has_perm(p_school uuid, p_key text) returns boolean
language sql stable security definer set search_path = '' as $$
  select app.is_director(p_school) or exists (
    select 1 from public.memberships m
      join public.delegate_permissions p on p.membership_id = m.id and p.deleted_at is null
     where m.school_id = p_school and m.user_id = auth.uid() and m.active and m.deleted_at is null
       and m.role = 'delegue' and p.permission_key = p_key);
$$;

create or replace function app.has_any_perm(p_school uuid, p_keys text[]) returns boolean
language sql stable security definer set search_path = '' as $$
  select app.is_director(p_school) or exists (
    select 1 from public.memberships m
      join public.delegate_permissions p on p.membership_id = m.id and p.deleted_at is null
     where m.school_id = p_school and m.user_id = auth.uid() and m.active and m.deleted_at is null
       and m.role = 'delegue' and p.permission_key = any (p_keys));
$$;

create or replace function app.my_teacher_ids() returns setof uuid
language sql stable security definer set search_path = '' as $$
  select m.teacher_id from public.memberships m
   where m.user_id = auth.uid() and m.active and m.deleted_at is null and m.teacher_id is not null;
$$;

-- Classes tenues par l'enseignant connecté pendant l'année EN COURS de l'école
-- (titulaire ou affectation). Les années archivées restent réservées au directeur.
create or replace function app.my_class_ids() returns setof uuid
language sql stable security definer set search_path = '' as $$
  select c.id from public.classes c
    join public.schools s on s.id = c.school_id and s.current_school_year_id = c.school_year_id
   where c.deleted_at is null
     and (c.main_teacher_id in (select app.my_teacher_ids())
          or c.id in (select a.class_id from public.teacher_year_assignments a
                       where a.deleted_at is null and a.teacher_id in (select app.my_teacher_ids())));
$$;

create or replace function app.teacher_sees_student(p_student uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.enrollments e
     where e.student_id = p_student and e.deleted_at is null
       and e.class_id in (select app.my_class_ids()));
$$;

-- Un module est actif si l'école l'a activé et si son module requis l'est aussi.
create or replace function app.module_enabled(p_school uuid, p_module text) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.school_modules sm
      join public.modules_catalog mc on mc.key = sm.module_key
     where sm.school_id = p_school and sm.module_key = p_module and sm.enabled
       and (mc.depends_on is null or exists (
             select 1 from public.school_modules d
              where d.school_id = p_school and d.module_key = mc.depends_on and d.enabled)));
$$;

-- Un niveau est visible si l'école le gère (primaire : case ; maternelle : module).
create or replace function app.level_allowed(p_school uuid, p_level text) returns boolean
language sql stable security definer set search_path = '' as $$
  select case (select l.cycle from public.levels l where l.code = p_level)
           when 'primaire' then coalesce((select s.manages_primary from public.schools s where s.id = p_school), false)
           when 'maternelle' then app.module_enabled(p_school, 'maternelle')
           else false
         end;
$$;

-- Mécanisme générique R11 : une politique RESTRICTIVE ajoutée à une table de
-- module. Module désactivé => lectures vides et écritures refusées, quelles que
-- soient les autres politiques ; les données restent en base.
create or replace function app.guard_module(p_table regclass, p_module text) returns void
language plpgsql as $$
begin
  execute format(
    'create policy %I on %s as restrictive for all to authenticated '
    'using (app.module_enabled(school_id, %L)) with check (app.module_enabled(school_id, %L))',
    'module_' || p_module, p_table, p_module, p_module);
end $$;

-- Au moins un niveau doit rester géré.
create or replace function app.check_levels() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_school uuid := case tg_table_name when 'schools' then (to_jsonb(new) ->> 'id')::uuid
                                      else (to_jsonb(new) ->> 'school_id')::uuid end;
begin
  if not coalesce((select s.manages_primary from public.schools s where s.id = v_school), false)
     and not exists (select 1 from public.school_modules sm
                      where sm.school_id = v_school and sm.module_key = 'maternelle' and sm.enabled) then
    raise exception 'Au moins un niveau (primaire ou maternelle) doit rester actif.' using errcode = 'P0001';
  end if;
  return null;
end $$;

create constraint trigger schools_check_levels after update of manages_primary on public.schools
  for each row execute function app.check_levels();
create constraint trigger school_modules_check_levels after update of enabled on public.school_modules
  for each row when (new.module_key = 'maternelle')
  execute function app.check_levels();

-- Un directeur ne peut pas retirer le dernier compte directeur actif.
create or replace function app.keep_one_director() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.memberships m
                  where m.school_id = old.school_id and m.role = 'directeur' and m.active and m.deleted_at is null) then
    raise exception 'L''école doit garder au moins un directeur actif.' using errcode = 'P0001';
  end if;
  return null;
end $$;
create constraint trigger memberships_keep_one_director after update on public.memberships
  for each row when (old.role = 'directeur')
  execute function app.keep_one_director();

-- ---------------- Auteur des écritures fixé par le serveur -----------
create or replace function app.stamp_created_by() returns trigger
language plpgsql as $$
begin
  if auth.uid() is not null then
    new.created_by := auth.uid();
  end if;
  return new;
end $$;

create or replace function app.stamp_updated_by() returns trigger
language plpgsql as $$
begin
  if auth.uid() is not null then
    new.updated_by := auth.uid();
  end if;
  return new;
end $$;

do $$
declare
  t record;
begin
  for t in select table_schema, table_name from information_schema.columns
            where column_name = 'created_by' and table_schema in ('public', 'medical')
  loop
    execute format('create trigger %I before insert on %I.%I for each row execute function app.stamp_created_by()',
                   t.table_name || '_created_by', t.table_schema, t.table_name);
  end loop;
  for t in select table_schema, table_name from information_schema.columns
            where column_name = 'updated_by' and table_schema in ('public', 'medical')
  loop
    execute format('create trigger %I before insert or update on %I.%I for each row execute function app.stamp_updated_by()',
                   t.table_name || '_updated_by', t.table_schema, t.table_name);
  end loop;
end $$;
