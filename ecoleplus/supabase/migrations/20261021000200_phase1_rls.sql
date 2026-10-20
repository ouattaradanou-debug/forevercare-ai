-- =====================================================================
-- Phase 1 — Règles d'accès (RLS) des tables de base et du noyau
-- classes/élèves, gardes des modules optionnels (R11).
--   directeur : toute son école ; enseignant : sa classe ; délégué : droits
--   accordés ; jamais d'accès à une autre école. Aucune politique DELETE :
--   la suppression physique reste impossible.
-- =====================================================================

create policy modules_catalog_read on public.modules_catalog for select to authenticated using (true);

-- École, années, en-têtes, options
create policy schools_read on public.schools for select to authenticated using (app.is_member(id));
create policy schools_update on public.schools for update to authenticated
  using (app.is_director(id)) with check (app.is_director(id));

create policy school_years_read on public.school_years for select to authenticated using (app.is_member(school_id));
create policy school_years_insert on public.school_years for insert to authenticated with check (app.is_director(school_id));
create policy school_years_update on public.school_years for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

-- Informations administratives : directeur, ou délégué « formulaires ».
create policy admin_headers_read on public.admin_headers for select to authenticated using (app.is_member(school_id));
create policy admin_headers_insert on public.admin_headers for insert to authenticated
  with check (app.has_perm(school_id, 'formulaires'));
create policy admin_headers_update on public.admin_headers for update to authenticated
  using (app.has_perm(school_id, 'formulaires')) with check (app.has_perm(school_id, 'formulaires'));

create policy school_modules_read on public.school_modules for select to authenticated using (app.is_member(school_id));
create policy school_modules_insert on public.school_modules for insert to authenticated with check (app.is_director(school_id));
create policy school_modules_update on public.school_modules for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

-- Comptes : le directeur gère ; chacun voit sa propre ligne.
create policy memberships_read on public.memberships for select to authenticated
  using (app.is_director(school_id) or user_id = auth.uid());
create policy memberships_update on public.memberships for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

create policy delegate_permissions_read on public.delegate_permissions for select to authenticated
  using (app.is_director(school_id)
         or membership_id in (select m.id from public.memberships m where m.user_id = auth.uid()));
create policy delegate_permissions_insert on public.delegate_permissions for insert to authenticated
  with check (app.is_director(school_id));
create policy delegate_permissions_update on public.delegate_permissions for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));

create policy devices_read on public.devices for select to authenticated
  using (app.is_director(school_id) or user_id = auth.uid());

create policy audit_log_read on public.audit_log for select to authenticated using (app.is_director(school_id));
create policy sync_conflicts_read on public.sync_conflicts for select to authenticated using (app.is_director(school_id));

-- Personnel : directeur ou délégué « registres » ; l'enseignant voit sa propre fiche.
create policy teachers_read on public.teachers for select to authenticated
  using (app.has_perm(school_id, 'registres') or id in (select app.my_teacher_ids()));
create policy teachers_insert on public.teachers for insert to authenticated
  with check (app.has_perm(school_id, 'registres'));
create policy teachers_update on public.teachers for update to authenticated
  using (app.has_perm(school_id, 'registres')) with check (app.has_perm(school_id, 'registres'));

create policy teacher_year_assignments_read on public.teacher_year_assignments for select to authenticated
  using (app.has_perm(school_id, 'registres') or teacher_id in (select app.my_teacher_ids()));
create policy teacher_year_assignments_insert on public.teacher_year_assignments for insert to authenticated
  with check (app.has_perm(school_id, 'registres'));
create policy teacher_year_assignments_update on public.teacher_year_assignments for update to authenticated
  using (app.has_perm(school_id, 'registres')) with check (app.has_perm(school_id, 'registres'));

-- Classes : le personnel de direction voit toutes les classes, l'enseignant les siennes.
create policy classes_read on public.classes for select to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres', 'cartes', 'finances', 'cantine', 'formulaires'])
         or id in (select app.my_class_ids()));
create policy classes_insert on public.classes for insert to authenticated with check (app.is_director(school_id));
create policy classes_update on public.classes for update to authenticated
  using (app.is_director(school_id)) with check (app.is_director(school_id));
-- Niveau non géré (primaire décoché, maternelle désactivée) : invisible et non modifiable.
create policy classes_level_guard on public.classes as restrictive for all to authenticated
  using (app.level_allowed(school_id, level_code)) with check (app.level_allowed(school_id, level_code));

-- Élèves, inscriptions, parents : selon les droits, l'enseignant pour sa classe.
create policy students_read on public.students for select to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres', 'cartes', 'finances', 'cantine'])
         or app.teacher_sees_student(id));
create policy students_insert on public.students for insert to authenticated
  with check (app.has_any_perm(school_id, array['eleves', 'registres']));
create policy students_update on public.students for update to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres']))
  with check (app.has_any_perm(school_id, array['eleves', 'registres']));

create policy enrollments_read on public.enrollments for select to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres', 'cartes', 'finances', 'cantine'])
         or class_id in (select app.my_class_ids()));
create policy enrollments_insert on public.enrollments for insert to authenticated
  with check (app.has_any_perm(school_id, array['eleves', 'registres']));
create policy enrollments_update on public.enrollments for update to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres']))
  with check (app.has_any_perm(school_id, array['eleves', 'registres']));

create policy guardians_read on public.guardians for select to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres', 'cartes', 'finances', 'cantine'])
         or app.teacher_sees_student(student_id));
create policy guardians_insert on public.guardians for insert to authenticated
  with check (app.has_any_perm(school_id, array['eleves', 'registres']));
create policy guardians_update on public.guardians for update to authenticated
  using (app.has_any_perm(school_id, array['eleves', 'registres']))
  with check (app.has_any_perm(school_id, array['eleves', 'registres']));

-- Gardes des modules optionnels (R11), posées dès maintenant sur toutes leurs tables.
select app.guard_module(t::regclass, 'maternelle') from unnest(array[
  'public.learning_domains', 'public.qualitative_levels', 'public.preschool_periods',
  'public.preschool_evaluations', 'public.preschool_booklets']) t;
select app.guard_module(t::regclass, 'cantine') from unnest(array[
  'public.canteen_settings', 'public.canteen_beneficiaries', 'public.meal_services', 'public.meal_checks',
  'public.stock_products', 'public.stock_movements', 'public.canteen_menus']) t;
select app.guard_module(t::regclass, 'medico_scolaire') from unnest(array[
  'medical.records', 'medical.yearly_exams', 'medical.fitness', 'medical.access_log']) t;
