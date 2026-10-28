-- =====================================================================
-- Phase 6 — Maternelle (module 8, OPTIONNEL) : droits, synchronisation,
-- option de classement ; présences des classes de maternelle.
-- Les tables du module sont déjà gardées par app.guard_module (phase 1) :
-- module désactivé = invisible et non modifiable.
-- =====================================================================

-- Classement des enfants : désactivé par défaut (choix du directeur).
alter table public.schools add column preschool_ranking boolean not null default false;

-- La période appartient-elle à une classe de l'enseignant connecté ?
create or replace function app.preschool_period_mine(p_period uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.preschool_periods p
     where p.id = p_period and p.class_id in (select app.my_class_ids()));
$$;

-- Domaines et niveaux qualitatifs : lus par toute l'école, réglés par le
-- directeur.
create policy learning_domains_read on public.learning_domains for select to authenticated
  using (app.is_member(school_id));
create policy learning_domains_insert on public.learning_domains for insert to authenticated
  with check (app.is_director(school_id));
create policy learning_domains_update on public.learning_domains for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

create policy qualitative_levels_read on public.qualitative_levels for select to authenticated
  using (app.is_member(school_id));
create policy qualitative_levels_insert on public.qualitative_levels for insert to authenticated
  with check (app.is_director(school_id));
create policy qualitative_levels_update on public.qualitative_levels for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

-- Périodes (trimestres) : le directeur, ou l'enseignant de la classe.
create policy preschool_periods_read on public.preschool_periods for select to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres', 'formulaires'])
         or class_id in (select app.my_class_ids()));
create policy preschool_periods_insert on public.preschool_periods for insert to authenticated
  with check (app.is_director(school_id) or class_id in (select app.my_class_ids()));
create policy preschool_periods_update on public.preschool_periods for update to authenticated
  using (app.is_director(school_id) or class_id in (select app.my_class_ids()))
  with check (app.is_director(school_id) or class_id in (select app.my_class_ids()));

-- Évaluations et livrets : le directeur, ou l'enseignant de la classe.
create policy preschool_evaluations_read on public.preschool_evaluations for select to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres', 'formulaires'])
         or app.preschool_period_mine(period_id));
create policy preschool_evaluations_insert on public.preschool_evaluations for insert to authenticated
  with check (app.is_director(school_id) or app.preschool_period_mine(period_id));
create policy preschool_evaluations_update on public.preschool_evaluations for update to authenticated
  using (app.is_director(school_id) or app.preschool_period_mine(period_id))
  with check (app.is_director(school_id) or app.preschool_period_mine(period_id));

create policy preschool_booklets_read on public.preschool_booklets for select to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres', 'formulaires'])
         or app.preschool_period_mine(period_id));
create policy preschool_booklets_insert on public.preschool_booklets for insert to authenticated
  with check (app.is_director(school_id) or app.preschool_period_mine(period_id));
create policy preschool_booklets_update on public.preschool_booklets for update to authenticated
  using (app.is_director(school_id) or app.preschool_period_mine(period_id))
  with check (app.is_director(school_id) or app.preschool_period_mine(period_id));

-- Livret : seul le directeur écrit l'observation (valeur d'un enseignant
-- ignorée, comme pour les bulletins du primaire).
create or replace function app.preschool_booklet_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or app.is_director(new.school_id) then
    return new;
  end if;
  if tg_op = 'INSERT' then
    new.observation := null;
  else
    new.observation := old.observation;
  end if;
  return new;
end $$;
create trigger preschool_booklets_guard before insert or update on public.preschool_booklets
  for each row execute function app.preschool_booklet_guard();

-- Présences : l'enseignant de la classe et le directeur ; lues aussi par
-- les délégués « élèves » ou « registres ».
create policy attendance_read on public.attendance for select to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres'])
         or class_id in (select app.my_class_ids()));
create policy attendance_insert on public.attendance for insert to authenticated
  with check (app.is_director(school_id) or class_id in (select app.my_class_ids()));
create policy attendance_update on public.attendance for update to authenticated
  using (app.is_director(school_id) or class_id in (select app.my_class_ids()))
  with check (app.is_director(school_id) or class_id in (select app.my_class_ids()));

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('learning_domains', 'lww', '{id}'),
  ('qualitative_levels', 'lww', '{id}'),
  ('preschool_periods', 'lww', '{id}'),
  ('preschool_evaluations', 'lww', '{id}'),
  ('preschool_booklets', 'lww', '{id}'),
  ('attendance', 'lww', '{id}');

-- Journal : réglages et livrets (les évaluations et présences, nombreuses,
-- n'y figurent pas, comme les notes du primaire).
do $$
declare
  t text;
begin
  foreach t in array array['learning_domains', 'qualitative_levels', 'preschool_booklets'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;
