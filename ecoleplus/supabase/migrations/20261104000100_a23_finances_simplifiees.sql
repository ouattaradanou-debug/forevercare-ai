-- A23 : finances simplifiées (demande du porteur du 03/11/2026).
-- * un reçu peut régler plusieurs rubriques ou versements : le détail est
--   dans payment_allocations (ajout seul, comme les reçus), avec le libellé
--   et la rubrique figés au moment de l'encaissement (un frais modifié ou
--   retiré ensuite ne change pas les anciens reçus) ;
-- * modalité de chaque frais : en une fois (intégral) ou partiel autorisé ;
-- * période de paiement « du … au … » de chaque versement ;
-- * mode de paiement libre (« Autre » précisé) ; téléphone du payeur ;
-- * observations imprimées sur le récapitulatif des frais d'une classe.

alter table public.payments drop constraint if exists payments_method_check;
alter table public.payments
  add constraint payments_method_check check (length(trim(method)) between 1 and 40),
  add column method_label text,
  add column payer_phone text;

alter table public.payment_allocations
  add column rubric text,
  add column label text;

alter table public.fee_items
  add column payment_terms text not null default 'partiel'
    check (payment_terms in ('integral', 'partiel'));

alter table public.fee_installments
  add column starts_on date;

create table public.fee_notes (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  class_id uuid references public.classes (id),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);
alter table public.fee_notes enable row level security;
create trigger fee_notes_synced_at before insert or update on public.fee_notes
  for each row execute function app.touch_synced_at();
create trigger fee_notes_no_delete before delete on public.fee_notes
  for each row execute function app.forbid_delete();

-- ------------------------------ Droits -------------------------------
create policy payment_allocations_read on public.payment_allocations for select to authenticated
  using (app.has_any_perm(school_id, array['finances']));
create policy payment_allocations_insert on public.payment_allocations for insert to authenticated
  with check (app.has_any_perm(school_id, array['finances']));

create policy fee_notes_read on public.fee_notes for select to authenticated
  using (app.has_any_perm(school_id, array['finances']));
create policy fee_notes_insert on public.fee_notes for insert to authenticated
  with check (app.has_any_perm(school_id, array['finances']));
create policy fee_notes_update on public.fee_notes for update to authenticated
  using (app.has_any_perm(school_id, array['finances']))
  with check (app.has_any_perm(school_id, array['finances']));

-- Détail d'un reçu : même école que le reçu ; signe identique (une
-- annulation a un détail négatif) ; jamais plus que le reçu.
create or replace function app.allocation_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  p public.payments;
  v_total bigint;
begin
  select * into p from public.payments where id = new.payment_id;
  if not found or p.school_id <> new.school_id then
    raise exception 'Reçu introuvable pour ce détail.' using errcode = 'P0001';
  end if;
  if sign(new.amount) <> sign(p.amount) then
    raise exception 'Le détail d''un reçu doit avoir le même signe que le reçu.' using errcode = 'P0001';
  end if;
  select coalesce(sum(amount), 0) into v_total
    from public.payment_allocations where payment_id = new.payment_id and id <> new.id;
  if abs(v_total + new.amount) > abs(p.amount) then
    raise exception 'Le détail dépasse le montant du reçu %.', p.receipt_number using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger payment_allocations_guard before insert on public.payment_allocations
  for each row execute function app.allocation_guard();

-- Une annulation reprend le mode de paiement libre et le payeur du reçu.
create or replace function app.payment_reversal_copy() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  o public.payments;
begin
  if new.reverses_payment_id is not null then
    select * into o from public.payments where id = new.reverses_payment_id;
    if found then
      new.method_label := o.method_label;
      new.payer_name := coalesce(new.payer_name, o.payer_name);
      new.payer_phone := coalesce(new.payer_phone, o.payer_phone);
    end if;
  end if;
  return new;
end $$;

create trigger payments_reversal_copy before insert on public.payments
  for each row execute function app.payment_reversal_copy();

-- --------------------------- Synchronisation ---------------------------
insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('payment_allocations', 'append', '{id}'),
  ('fee_notes', 'lww', '{id}');

create trigger fee_notes_audit after insert or update on public.fee_notes
  for each row execute function app.audit_row();
