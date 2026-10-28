-- =====================================================================
-- Phase 8 — Photos des élèves et cartes scolaires (module 12).
-- Photos : compartiment privé « ecole-medias », chemin
-- {school_id}/eleves/{student_id}-{horodatage}.jpg ; aucun lien public.
-- Lecture : directeur, délégués « élèves », « registres » ou « cartes »,
-- et l'enseignant(e) de la classe de l'élève seulement.
-- Logo de l'école : {school_id}/logo/… (directeur).
-- =====================================================================

-- Élève désigné par le nom du fichier (36 premiers caractères).
create or replace function app.media_student(p_name text) returns uuid
language sql immutable as $$
  select app.try_uuid(left(storage.filename(p_name), 36));
$$;

-- Lecture : en-têtes et logo pour toute l'école ; photos selon les droits.
drop policy ecole_medias_read on storage.objects;
create policy ecole_medias_read on storage.objects for select to authenticated
  using (bucket_id = 'ecole-medias'
         and case (storage.foldername(name))[2]
               when 'eleves' then
                 app.has_any_perm(app.try_uuid((storage.foldername(name))[1]), array['eleves', 'registres', 'cartes'])
                 or app.teacher_sees_student(app.media_student(name))
               else app.is_member(app.try_uuid((storage.foldername(name))[1]))
             end);

-- Photos : ajoutées ou remplacées par le directeur ou un délégué
-- « élèves » / « registres », pour un élève de l'école.
create policy ecole_medias_photos_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'ecole-medias'
              and (storage.foldername(name))[2] = 'eleves'
              and app.has_any_perm(app.try_uuid((storage.foldername(name))[1]), array['eleves', 'registres'])
              and exists (select 1 from public.students s
                           where s.id = app.media_student(name)
                             and s.school_id = app.try_uuid((storage.foldername(name))[1])));
create policy ecole_medias_photos_update on storage.objects for update to authenticated
  using (bucket_id = 'ecole-medias'
         and (storage.foldername(name))[2] = 'eleves'
         and app.has_any_perm(app.try_uuid((storage.foldername(name))[1]), array['eleves', 'registres']))
  with check (bucket_id = 'ecole-medias'
              and (storage.foldername(name))[2] = 'eleves'
              and app.has_any_perm(app.try_uuid((storage.foldername(name))[1]), array['eleves', 'registres']));

-- Logo : le directeur.
create policy ecole_medias_logo_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'ecole-medias'
              and (storage.foldername(name))[2] = 'logo'
              and app.is_director(app.try_uuid((storage.foldername(name))[1])));
create policy ecole_medias_logo_update on storage.objects for update to authenticated
  using (bucket_id = 'ecole-medias'
         and (storage.foldername(name))[2] = 'logo'
         and app.is_director(app.try_uuid((storage.foldername(name))[1])))
  with check (bucket_id = 'ecole-medias'
              and (storage.foldername(name))[2] = 'logo'
              and app.is_director(app.try_uuid((storage.foldername(name))[1])));

-- Modèle de carte (couleurs) : lu par toute l'école, réglé par le
-- directeur ou le délégué « cartes ».
create policy card_templates_read on public.card_templates for select to authenticated
  using (app.is_member(school_id));
create policy card_templates_insert on public.card_templates for insert to authenticated
  with check (app.has_any_perm(school_id, array['cartes']));
create policy card_templates_update on public.card_templates for update to authenticated
  using (app.has_any_perm(school_id, array['cartes']))
  with check (app.has_any_perm(school_id, array['cartes']));

-- Cartes : identifiant opaque du QR code par élève et par année.
create policy student_cards_read on public.student_cards for select to authenticated
  using (app.has_any_perm(school_id, array['cartes', 'eleves', 'registres']));
create policy student_cards_insert on public.student_cards for insert to authenticated
  with check (app.has_any_perm(school_id, array['cartes', 'eleves', 'registres']));
create policy student_cards_update on public.student_cards for update to authenticated
  using (app.has_any_perm(school_id, array['cartes', 'eleves', 'registres']))
  with check (app.has_any_perm(school_id, array['cartes', 'eleves', 'registres']));

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('card_templates', 'lww', '{id}'),
  ('student_cards', 'lww', '{id}');

do $$
declare
  t text;
begin
  foreach t in array array['card_templates'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;
