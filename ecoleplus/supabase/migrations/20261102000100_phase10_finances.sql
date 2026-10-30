-- =====================================================================
-- Phase 10 — Finances (hors cantine). Les tables existent depuis la phase 0
-- (20261020000600) : ici les droits (directeur et délégué « finances »
-- seulement ; un enseignant ne lit rien), la synchronisation, le journal
-- d'activité, les contrôles des encaissements et des annulations, et le
-- compartiment privé des justificatifs de dépenses.
-- Rappel : paiements, dépenses et clôtures sont en AJOUT SEUL (trigger
-- append_only) ; une erreur se corrige par une contre-passation motivée.
-- =====================================================================

-- Un encaissement porte sur une ligne de la grille (ou « autre ») et sur le
-- nom de la personne qui paie (imprimé sur le reçu).
alter table public.payments
  add column fee_item_id uuid references public.fee_items (id),
  add column payer_name text;

-- Dépense : numéro de pièce imprimé (série de l'appareil), comme les reçus.
alter table public.expenses
  add column voucher_number text;

-- ------------------------------ Droits -------------------------------
do $$
declare
  t text;
begin
  -- Paramétrage (modifiable) : grille, échéancier, remises.
  foreach t in array array['fee_items', 'fee_installments', 'discounts', 'student_discounts'] loop
    execute format('create policy %1$I on public.%2$I for select to authenticated '
                   'using (app.has_any_perm(school_id, array[''finances'']))', t || '_read', t);
    execute format('create policy %1$I on public.%2$I for insert to authenticated '
                   'with check (app.has_any_perm(school_id, array[''finances'']))', t || '_insert', t);
    execute format('create policy %1$I on public.%2$I for update to authenticated '
                   'using (app.has_any_perm(school_id, array[''finances''])) '
                   'with check (app.has_any_perm(school_id, array[''finances'']))', t || '_update', t);
  end loop;
  -- Écritures (ajout seul) : lecture et ajout, jamais de modification.
  foreach t in array array['payments', 'expenses', 'cash_closings'] loop
    execute format('create policy %1$I on public.%2$I for select to authenticated '
                   'using (app.has_any_perm(school_id, array[''finances'']))', t || '_read', t);
    execute format('create policy %1$I on public.%2$I for insert to authenticated '
                   'with check (app.has_any_perm(school_id, array[''finances'']))', t || '_insert', t);
  end loop;
end $$;

-- ------------------------ Contrôles d'intégrité -----------------------
-- Encaissement : auteur imposé ; l'appareil doit être celui de la personne
-- connectée (on ne peut pas utiliser la série d'un autre téléphone) ;
-- une annulation reprend exactement le montant opposé, sur la même école,
-- et n'annule pas une annulation.
create or replace function app.payment_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  o public.payments;
begin
  if auth.uid() is not null then
    new.received_by := auth.uid();
    if not exists (select 1 from public.devices d
                    where d.id = new.device_id and d.school_id = new.school_id
                      and d.user_id = auth.uid() and d.deleted_at is null) then
      raise exception 'Ce téléphone n''est pas enregistré à votre nom pour cette école.'
        using errcode = '42501';
    end if;
  end if;
  if new.reverses_payment_id is not null then
    select * into o from public.payments where id = new.reverses_payment_id;
    if not found or o.school_id <> new.school_id then
      raise exception 'Reçu à annuler introuvable.' using errcode = 'P0001';
    end if;
    if o.reverses_payment_id is not null then
      raise exception 'Une annulation ne peut pas être annulée : faites un nouvel encaissement.'
        using errcode = 'P0001';
    end if;
    if new.amount <> -o.amount then
      raise exception 'L''annulation doit reprendre exactement le montant du reçu (%).', o.amount
        using errcode = 'P0001';
    end if;
    new.student_id := o.student_id;
    new.rubric := o.rubric;
    new.fee_item_id := o.fee_item_id;
  end if;
  return new;
end $$;

create trigger payments_guard before insert on public.payments
  for each row execute function app.payment_guard();

create or replace function app.expense_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  o public.expenses;
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
  if new.reverses_expense_id is not null then
    select * into o from public.expenses where id = new.reverses_expense_id;
    if not found or o.school_id <> new.school_id then
      raise exception 'Dépense à annuler introuvable.' using errcode = 'P0001';
    end if;
    if o.reverses_expense_id is not null then
      raise exception 'Une annulation ne peut pas être annulée : saisissez une nouvelle dépense.'
        using errcode = 'P0001';
    end if;
    if new.amount <> -o.amount then
      raise exception 'L''annulation doit reprendre exactement le montant de la dépense (%).', o.amount
        using errcode = 'P0001';
    end if;
    new.category := o.category;
  end if;
  return new;
end $$;

create trigger expenses_guard before insert on public.expenses
  for each row execute function app.expense_guard();

create or replace function app.cash_closing_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is not null then
    new.closed_by := auth.uid();
  end if;
  return new;
end $$;

create trigger cash_closings_guard before insert on public.cash_closings
  for each row execute function app.cash_closing_guard();

-- --------------------- Justificatifs de dépenses ----------------------
-- Compartiment privé : « <école>/depenses/<nom> » ; lu et déposé par le
-- directeur et le délégué « finances » seulement ; jamais de lien public.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('finances', 'finances', false, 10485760,
        array['image/jpeg', 'image/png', 'application/pdf'])
on conflict (id) do nothing;

create policy finances_files_read on storage.objects for select to authenticated
  using (bucket_id = 'finances'
         and app.has_any_perm(app.try_uuid((storage.foldername(name))[1]), array['finances']));
create policy finances_files_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'finances' and (storage.foldername(name))[2] = 'depenses'
              and app.has_any_perm(app.try_uuid((storage.foldername(name))[1]), array['finances']));

-- --------------------------- Synchronisation ---------------------------
insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('fee_items', 'lww', '{id}'),
  ('fee_installments', 'lww', '{id}'),
  ('discounts', 'lww', '{id}'),
  ('student_discounts', 'lww', '{id}'),
  ('payments', 'append', '{id}'),
  ('expenses', 'append', '{id}'),
  ('cash_closings', 'append', '{id}');

-- ----------------------- Journal d'activité ----------------------------
do $$
declare
  t text;
begin
  foreach t in array array['fee_items', 'fee_installments', 'discounts', 'student_discounts'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
  foreach t in array array['payments', 'expenses', 'cash_closings'] loop
    execute format('create trigger %I after insert on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;
