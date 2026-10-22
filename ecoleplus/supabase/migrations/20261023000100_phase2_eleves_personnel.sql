-- =====================================================================
-- Phase 2 — élèves, classes, enseignants, registres.
-- =====================================================================

-- ----------------------------------------------------------------------
-- 1. Champs des registres et de la fiche de scolarité (B2, B4) séparés de
--    la fiche élève : l'enseignant lit la fiche des élèves de sa classe,
--    mais n'a AUCUN accès aux registres ni à la fiche de scolarité (17.7).
--    La RLS est par ligne : ces champs vont donc dans une table à part.
-- ----------------------------------------------------------------------
create table public.student_registry (
  id uuid primary key references public.students (id),   -- = students.id
  school_id uuid not null references public.schools (id),
  origin_school text,                -- B4 « Venant de »
  destination text,                  -- B4 « allant à »
  exit_reason text,                  -- B4 « Motif du départ »
  cep_date date,                     -- B2 col. 7
  diplomas text,                     -- B4 « Diplômes obtenus et date d'obtention »
  director_observations text,        -- B4 « Observations du Directeur »
  registry_observations text,        -- B2 col. 9
  race text,                         -- B4, facultatif, masqué par défaut
  religion text,                     -- B4, facultatif, masqué par défaut
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);
insert into public.student_registry (id, school_id, origin_school, destination, exit_reason, cep_date,
                                     diplomas, director_observations, registry_observations, race, religion)
select id, school_id, origin_school, destination, exit_reason, cep_date, diplomas,
       director_observations, registry_observations, race, religion
  from public.students
 where coalesce(origin_school, destination, exit_reason, diplomas, director_observations,
                registry_observations, race, religion, cep_date::text) is not null;
alter table public.students
  drop column origin_school, drop column destination, drop column exit_reason, drop column cep_date,
  drop column diplomas, drop column director_observations, drop column registry_observations,
  drop column race, drop column religion;

alter table public.student_registry enable row level security;
create trigger student_registry_synced_at before insert or update on public.student_registry
  for each row execute function app.touch_synced_at();
create trigger student_registry_no_delete before delete on public.student_registry
  for each row execute function app.forbid_delete();
create trigger student_registry_created_by before insert on public.student_registry
  for each row execute function app.stamp_created_by();
create trigger student_registry_updated_by before insert or update on public.student_registry
  for each row execute function app.stamp_updated_by();

create policy student_registry_read on public.student_registry for select to authenticated
  using (app.has_any_perm(school_id, array['registres', 'formulaires']));
create policy student_registry_insert on public.student_registry for insert to authenticated
  with check (app.has_perm(school_id, 'registres'));
create policy student_registry_update on public.student_registry for update to authenticated
  using (app.has_perm(school_id, 'registres')) with check (app.has_perm(school_id, 'registres'));

-- ----------------------------------------------------------------------
-- 2. Historiques du personnel (B3 col. 8 à 11) : mêmes droits que la fiche.
-- ----------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['teacher_postings', 'teacher_interruptions', 'teacher_awards',
                           'teacher_diplomas'] loop
    execute format('create policy %I on public.%I for select to authenticated '
                   'using (app.has_perm(school_id, ''registres'') or teacher_id in (select app.my_teacher_ids()))',
                   t || '_read', t);
    execute format('create policy %I on public.%I for insert to authenticated '
                   'with check (app.has_perm(school_id, ''registres''))', t || '_insert', t);
    execute format('create policy %I on public.%I for update to authenticated '
                   'using (app.has_perm(school_id, ''registres'')) with check (app.has_perm(school_id, ''registres''))',
                   t || '_update', t);
  end loop;
end $$;

-- ----------------------------------------------------------------------
-- 3. Numéro d'ordre du registre matricule : un téléphone qui renvoie une
--    fiche sans le numéro (pas encore reçu du serveur) ne l'efface pas.
-- ----------------------------------------------------------------------
create or replace function app.assign_registry_number() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'UPDATE' then
    if new.registry_number is null and old.registry_number is not null then
      new.registry_number := old.registry_number;
    end if;
    if old.registry_number is not null and new.registry_number is distinct from old.registry_number then
      raise exception 'Le numéro d''ordre du registre matricule ne peut pas être modifié.' using errcode = 'P0001';
    end if;
    if new.registry_number is null then
      new.registry_number := app.next_counter(new.school_id, 'registre_matricule');
    end if;
    return new;
  end if;
  if new.registry_number is null then
    new.registry_number := app.next_counter(new.school_id, 'registre_matricule');
  else
    perform app.bump_counter(new.school_id, 'registre_matricule', new.registry_number);
  end if;
  return new;
end $$;
drop trigger students_registry_number on public.students;
create trigger students_registry_number
  before insert or update on public.students
  for each row execute function app.assign_registry_number();

-- ----------------------------------------------------------------------
-- 4. Synchronisation et journal d'activité.
-- ----------------------------------------------------------------------
insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('teachers', 'lww', '{id}'),
  ('teacher_postings', 'lww', '{id}'),
  ('teacher_interruptions', 'lww', '{id}'),
  ('teacher_awards', 'lww', '{id}'),
  ('teacher_diplomas', 'lww', '{id}'),
  ('classes', 'lww', '{id}'),
  ('teacher_year_assignments', 'lww', '{id}'),
  ('students', 'lww', '{id}'),
  ('student_registry', 'lww', '{id}'),
  ('guardians', 'lww', '{id}'),
  ('enrollments', 'lww', '{id}');

do $$
declare
  t text;
begin
  foreach t in array array['teachers', 'classes', 'teacher_year_assignments', 'students',
                           'student_registry', 'enrollments'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;

-- ----------------------------------------------------------------------
-- 5. Compteurs (numéro d'ordre) : la table des compteurs n'est pas
--    accessible directement ; les fonctions s'exécutent avec les droits du
--    propriétaire (appelées uniquement par les triggers).
-- ----------------------------------------------------------------------
alter function app.next_counter(uuid, text) security definer set search_path = '';
alter function app.bump_counter(uuid, text, bigint) security definer set search_path = '';
revoke execute on function app.next_counter(uuid, text), app.bump_counter(uuid, text, bigint)
  from public, anon, authenticated;
