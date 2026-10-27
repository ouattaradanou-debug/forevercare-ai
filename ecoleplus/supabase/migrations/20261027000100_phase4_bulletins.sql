-- =====================================================================
-- Phase 4 — bulletins et fiche de scolarité (B4) : droits d'accès et
-- synchronisation. Les bulletins et la fiche sont calculés et mis en page
-- sur le téléphone (hors ligne) ; le serveur garde les appréciations, les
-- observations, les décisions, le modèle et le journal des copies.
-- =====================================================================

-- Modèle de bulletin : lu par tous les membres, choisi par le directeur.
create policy report_templates_read on public.report_templates for select to authenticated
  using (app.is_member(school_id));
create policy report_templates_insert on public.report_templates for insert to authenticated
  with check (app.is_director(school_id));
create policy report_templates_update on public.report_templates for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

-- Bulletins (un par élève et par période : trimestre = composition du
-- trimestre, année = assessment_id nul). L'enseignant écrit l'appréciation
-- pour SA classe ; le directeur écrit aussi l'observation et la décision.
create policy report_cards_read on public.report_cards for select to authenticated
  using (app.has_any_perm(school_id, array['registres', 'formulaires'])
         or class_id in (select app.my_class_ids()));
create policy report_cards_insert on public.report_cards for insert to authenticated
  with check (app.is_director(school_id) or class_id in (select app.my_class_ids()));
create policy report_cards_update on public.report_cards for update to authenticated
  using (app.is_director(school_id) or class_id in (select app.my_class_ids()))
  with check (app.is_director(school_id) or class_id in (select app.my_class_ids()));

-- Un enseignant ne peut ni écrire ni effacer l'observation du directeur ou
-- la décision : ses valeurs sont ignorées (pas de refus, pour qu'un envoi
-- complet depuis son téléphone ne bloque pas son appréciation).
create or replace function app.report_card_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or app.is_director(new.school_id) then
    return new;
  end if;
  if tg_op = 'INSERT' then
    new.director_observation := null;
    new.decision := null;
  else
    new.director_observation := old.director_observation;
    new.decision := old.decision;
  end if;
  return new;
end $$;
create trigger report_cards_guard before insert or update on public.report_cards
  for each row execute function app.report_card_guard();

-- Journal des fiches de scolarité générées (copie conforme ou non) :
-- ajout seul, synchronisé depuis le téléphone, visible dans le journal.
alter table public.scolarity_copy_log
  add column updated_at timestamptz not null default now(),
  add column synced_at timestamptz not null default now();
create trigger scolarity_copy_log_synced_at before insert on public.scolarity_copy_log
  for each row execute function app.touch_synced_at();

create or replace function app.stamp_generated_by() returns trigger
language plpgsql as $$
begin
  new.generated_by := auth.uid();
  return new;
end $$;
create trigger scolarity_copy_log_generated_by before insert on public.scolarity_copy_log
  for each row execute function app.stamp_generated_by();

create policy scolarity_copy_log_read on public.scolarity_copy_log for select to authenticated
  using (app.has_any_perm(school_id, array['registres']));
create policy scolarity_copy_log_insert on public.scolarity_copy_log for insert to authenticated
  with check (app.has_any_perm(school_id, array['registres']));

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('report_templates', 'lww', '{id}'),
  ('report_cards', 'lww', '{id}'),
  ('scolarity_copy_log', 'append', '{id}');

do $$
declare
  t text;
begin
  foreach t in array array['report_templates', 'report_cards', 'scolarity_copy_log'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;
