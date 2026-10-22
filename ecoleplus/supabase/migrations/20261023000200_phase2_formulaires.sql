-- =====================================================================
-- Phase 2 — formulaires officiels B1, B2, B3 : paramètres d'impression
-- (« Fait à … le … », directeur, date de référence des anciennetés,
-- période du registre matricule) et état (17.3).
-- =====================================================================

-- Formulaires du personnel (B1, B3) et registre matricule (B2) :
-- directeur, délégués « formulaires » ou « registres ». Jamais l'enseignant.
create policy official_forms_read on public.official_forms for select to authenticated
  using (app.has_any_perm(school_id, array['formulaires', 'registres']));
create policy official_forms_insert on public.official_forms for insert to authenticated
  with check (app.has_any_perm(school_id, array['formulaires', 'registres']));
create policy official_forms_update on public.official_forms for update to authenticated
  using (app.has_any_perm(school_id, array['formulaires', 'registres']))
  with check (app.has_any_perm(school_id, array['formulaires', 'registres']));

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('official_forms', 'lww', '{id}');
