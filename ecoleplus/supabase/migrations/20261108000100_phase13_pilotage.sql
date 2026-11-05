-- =====================================================================
-- Phase 13 — Pilotage : emploi du temps, appel du jour, tableaux de bord,
-- rapports, recherche, notifications.
--   * emploi du temps (timetable_slots, table prévue en phase 0) : lu par
--     toute l'école, rédigé par le directeur (ou un délégué « registres »)
--     et par l'enseignant pour SA classe ; synchronisé ;
--   * l'appel du jour utilise la table « attendance » (droits de la
--     phase 6 : l'enseignant de la classe, le directeur corrige) ;
--   * tableaux de bord, rapports, recherche et notifications sont calculés
--     sur le téléphone à partir des données déjà synchronisées (aucune
--     nouvelle donnée envoyée, rien quand l'application est fermée).
-- =====================================================================

create policy timetable_slots_read on public.timetable_slots for select to authenticated
  using (app.is_member(school_id));
create policy timetable_slots_insert on public.timetable_slots for insert to authenticated
  with check (app.has_perm(school_id, 'registres') or class_id in (select app.my_class_ids()));
create policy timetable_slots_update on public.timetable_slots for update to authenticated
  using (app.has_perm(school_id, 'registres') or class_id in (select app.my_class_ids()))
  with check (app.has_perm(school_id, 'registres') or class_id in (select app.my_class_ids()));

-- La classe et la matière doivent être de la même école que le créneau.
create or replace function app.timetable_slot_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.classes c where c.id = new.class_id and c.school_id = new.school_id) then
    raise exception 'Classe d''une autre école.' using errcode = '42501';
  end if;
  if new.subject_id is not null and not exists (
       select 1 from public.subjects s where s.id = new.subject_id and s.school_id = new.school_id) then
    raise exception 'Matière d''une autre école.' using errcode = '42501';
  end if;
  return new;
end $$;
create trigger timetable_slots_guard before insert or update on public.timetable_slots
  for each row execute function app.timetable_slot_guard();

create index timetable_slots_class on public.timetable_slots (class_id, weekday, starts_at)
  where deleted_at is null;
create index attendance_class_day on public.attendance (class_id, day) where deleted_at is null;

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('timetable_slots', 'lww', '{id}');

create trigger timetable_slots_audit after insert or update on public.timetable_slots
  for each row execute function app.audit_row();
