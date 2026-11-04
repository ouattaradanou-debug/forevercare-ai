-- =====================================================================
-- Phase 11 — Cantine (module 10.9, OPTIONNEL, dans le volet financier).
-- Les tables existent depuis la phase 0 (20261020000600) et sont gardées
-- par app.guard_module depuis la phase 1 : module désactivé = invisibles
-- et non modifiables. Ici : droits (directeur et délégué « cantine »),
-- participation des familles en mode mixte, contrôles des mouvements de
-- stock (ajout seul, annulation miroir), dépenses de cantine dans la
-- caisse commune, synchronisation et journal.
-- Les cotisations de cantine passent par les reçus des Finances
-- (rubrique « cantine ») : même numérotation, mêmes règles d'intégrité.
-- =====================================================================

-- Mode mixte : certaines familles participent, d'autres non.
alter table public.canteen_beneficiaries
  add column contributes boolean not null default true;

-- Deux téléphones hors ligne qui créent le même produit obtiennent le même
-- identifiant (calculé à partir du nom) : la contrainte d'unicité sur le
-- nom bloquerait la synchronisation après un renommage croisé. Le
-- téléphone empêche lui-même les doublons de nom.
alter table public.stock_products drop constraint stock_products_school_id_name_key;

-- ------------------------------ Droits -------------------------------
do $$
declare
  t text;
begin
  -- Réglages et bénéficiaires : lus aussi par les Finances (calcul des
  -- cotisations dues) ; modifiés par le directeur et le délégué « cantine ».
  foreach t in array array['canteen_settings', 'canteen_beneficiaries'] loop
    execute format('create policy %1$I on public.%2$I for select to authenticated '
                   'using (app.has_any_perm(school_id, array[''cantine'', ''finances'']))', t || '_read', t);
    execute format('create policy %1$I on public.%2$I for insert to authenticated '
                   'with check (app.has_perm(school_id, ''cantine''))', t || '_insert', t);
    execute format('create policy %1$I on public.%2$I for update to authenticated '
                   'using (app.has_perm(school_id, ''cantine'')) '
                   'with check (app.has_perm(school_id, ''cantine''))', t || '_update', t);
  end loop;
  -- Pointage et produits : réservés à la cantine.
  foreach t in array array['meal_services', 'stock_products'] loop
    execute format('create policy %1$I on public.%2$I for select to authenticated '
                   'using (app.has_perm(school_id, ''cantine''))', t || '_read', t);
    execute format('create policy %1$I on public.%2$I for insert to authenticated '
                   'with check (app.has_perm(school_id, ''cantine''))', t || '_insert', t);
    execute format('create policy %1$I on public.%2$I for update to authenticated '
                   'using (app.has_perm(school_id, ''cantine'')) '
                   'with check (app.has_perm(school_id, ''cantine''))', t || '_update', t);
  end loop;
end $$;

-- Mouvements de stock : AJOUT SEUL (trigger append_only de la phase 0).
create policy stock_movements_read on public.stock_movements for select to authenticated
  using (app.has_perm(school_id, 'cantine'));
create policy stock_movements_insert on public.stock_movements for insert to authenticated
  with check (app.has_perm(school_id, 'cantine'));

-- Menus de la semaine : affichables pour toute l'école.
create policy canteen_menus_read on public.canteen_menus for select to authenticated
  using (app.is_member(school_id));
create policy canteen_menus_insert on public.canteen_menus for insert to authenticated
  with check (app.has_perm(school_id, 'cantine'));
create policy canteen_menus_update on public.canteen_menus for update to authenticated
  using (app.has_perm(school_id, 'cantine')) with check (app.has_perm(school_id, 'cantine'));

-- -------------------- Contrôle des mouvements de stock -----------------
-- Auteur imposé ; téléphone de la personne connectée ; une annulation
-- reprend exactement la quantité opposée du même produit et n'annule pas
-- une annulation (une seule annulation par mouvement : unique).
create or replace function app.stock_movement_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  o public.stock_movements;
begin
  if auth.uid() is not null then
    new.created_by := auth.uid();
    if not exists (select 1 from public.devices d
                    where d.id = new.device_id and d.school_id = new.school_id
                      and d.user_id = auth.uid() and d.deleted_at is null) then
      raise exception 'Ce téléphone n''est pas enregistré à votre nom pour cette école.'
        using errcode = '42501';
    end if;
  end if;
  if not exists (select 1 from public.stock_products p
                  where p.id = new.product_id and p.school_id = new.school_id) then
    raise exception 'Produit introuvable.' using errcode = 'P0001';
  end if;
  if new.reverses_movement_id is not null then
    select * into o from public.stock_movements where id = new.reverses_movement_id;
    if not found or o.school_id <> new.school_id then
      raise exception 'Mouvement à annuler introuvable.' using errcode = 'P0001';
    end if;
    if o.kind = 'annulation' then
      raise exception 'Une annulation ne peut pas être annulée : saisissez un nouveau mouvement.'
        using errcode = 'P0001';
    end if;
    if new.product_id <> o.product_id or new.quantity_delta <> -o.quantity_delta then
      raise exception 'L''annulation doit reprendre exactement la quantité du mouvement (%).', o.quantity_delta
        using errcode = 'P0001';
    end if;
  end if;
  return new;
end $$;

create trigger stock_movements_guard before insert on public.stock_movements
  for each row execute function app.stock_movement_guard();

-- ---------------- Dépenses et cotisations de cantine ------------------
-- Dépenses de cantine (catégorie « cantine ») : dans le journal de caisse
-- commun ; saisies aussi par le délégué « cantine », qui ne voit que
-- celles-ci.
create policy expenses_cantine_read on public.expenses for select to authenticated
  using (category = 'cantine' and app.has_perm(school_id, 'cantine'));
create policy expenses_cantine_insert on public.expenses for insert to authenticated
  with check (category = 'cantine' and app.has_perm(school_id, 'cantine'));

-- Module désactivé : aucune nouvelle écriture de cantine (dépense,
-- cotisation, ligne de la grille). Les reçus et dépenses déjà faits restent
-- lisibles (c'est de l'argent réellement en caisse) et une annulation reste
-- possible (correction d'une erreur).
create policy expenses_module_cantine on public.expenses as restrictive for insert to authenticated
  with check (category <> 'cantine' or reverses_expense_id is not null
              or app.module_enabled(school_id, 'cantine'));
create policy payments_module_cantine on public.payments as restrictive for insert to authenticated
  with check (rubric <> 'cantine' or reverses_payment_id is not null
              or app.module_enabled(school_id, 'cantine'));
create policy payment_allocations_module_cantine on public.payment_allocations
  as restrictive for insert to authenticated
  with check (coalesce(rubric, '') <> 'cantine' or amount < 0
              or app.module_enabled(school_id, 'cantine'));
create policy fee_items_module_cantine_insert on public.fee_items as restrictive for insert to authenticated
  with check (rubric <> 'cantine' or app.module_enabled(school_id, 'cantine'));
create policy fee_items_module_cantine_update on public.fee_items as restrictive for update to authenticated
  using (true)
  with check (rubric <> 'cantine' or app.module_enabled(school_id, 'cantine'));

-- Justificatifs des dépenses de cantine : « <école>/cantine/<nom> ».
create policy finances_files_cantine_read on storage.objects for select to authenticated
  using (bucket_id = 'finances' and (storage.foldername(name))[2] = 'cantine'
         and app.has_perm(app.try_uuid((storage.foldername(name))[1]), 'cantine'));
create policy finances_files_cantine_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'finances' and (storage.foldername(name))[2] = 'cantine'
              and app.has_any_perm(app.try_uuid((storage.foldername(name))[1]), array['cantine', 'finances'])
              and app.module_enabled(app.try_uuid((storage.foldername(name))[1]), 'cantine'));

-- --------------------------- Synchronisation ---------------------------
insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('canteen_settings', 'lww', '{id}'),
  ('canteen_beneficiaries', 'lww', '{id}'),
  ('meal_services', 'lww', '{id}'),
  ('stock_products', 'lww', '{id}'),
  ('stock_movements', 'append', '{id}'),
  ('canteen_menus', 'lww', '{id}');

-- ----------------------- Journal d'activité ----------------------------
-- Réglages, bénéficiaires, produits, menus et mouvements de stock (les
-- pointages quotidiens, nombreux, n'y figurent pas, comme les notes).
do $$
declare
  t text;
begin
  foreach t in array array['canteen_settings', 'canteen_beneficiaries', 'stock_products', 'canteen_menus'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
  execute 'create trigger stock_movements_audit after insert on public.stock_movements '
          'for each row execute function app.audit_row()';
end $$;
