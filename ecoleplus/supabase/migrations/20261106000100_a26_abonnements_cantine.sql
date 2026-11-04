-- =====================================================================
-- A26 — Cantine scolaire par abonnement mensuel payé d'avance.
--   * réglages de l'année : mois de fonctionnement, jour limite de
--     paiement ;
--   * tarifs mensuels avec historique (« à partir de tel mois ») : un
--     changement de tarif ne touche jamais les mois déjà abonnés ;
--   * abonnement d'un élève pour UN mois (une ligne par élève et par mois,
--     montant dû figé à la création) : aucun mois n'entraîne le suivant,
--     un élève non abonné ne doit rien ;
--   * réduction mensuelle ou exonération par élève (canteen_beneficiaries) ;
--   * un reçu (payments, rubrique « cantine ») peut régler plusieurs mois :
--     son détail (payment_allocations) pointe chaque abonnement ;
--   * le responsable de cantine (droit « cantine ») encaisse la cantine,
--     et seulement elle.
-- La cotisation par trimestre de la phase 11 (rubrique « cantine » de la
-- grille des frais) n'est plus utilisée ; ses données restent intactes.
-- =====================================================================

create table public.canteen_years (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  -- Mois de fonctionnement : premiers jours des mois (« 2025-10-01 »…).
  months date[] not null default '{}',
  -- Jour limite de paiement du mois (facultatif, 1 à 31).
  due_day smallint check (due_day between 1 and 31),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_year_id)
);

create table public.canteen_rates (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  -- Tarif applicable à partir de ce mois (premier jour du mois).
  from_month date not null,
  amount integer not null check (amount >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_year_id, from_month)
);

create table public.canteen_subscriptions (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  student_id uuid not null references public.students (id),
  month date not null,
  -- Classe au moment de l'abonnement (historique si l'élève change).
  class_id uuid references public.classes (id),
  -- Montant dû figé : tarif du mois − réduction (0 : exonéré).
  amount_due integer not null check (amount_due >= 0),
  exempt boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (student_id, month)
);

alter table public.canteen_beneficiaries
  add column monthly_reduction integer check (monthly_reduction >= 0);

alter table public.payment_allocations
  add column canteen_subscription_id uuid references public.canteen_subscriptions (id);

-- Le montant dû d'un abonnement ne change plus une fois créé (les mois
-- déjà abonnés gardent leur tarif) ; seul le retrait (deleted_at) reste
-- possible, et seulement sans aucun paiement.
create or replace function app.canteen_subscription_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'UPDATE' then
    new.amount_due := old.amount_due;
    new.exempt := old.exempt;
    new.student_id := old.student_id;
    new.month := old.month;
    if new.deleted_at is not null and old.deleted_at is null and exists (
         select 1 from public.payment_allocations a
          where a.canteen_subscription_id = old.id
          group by a.canteen_subscription_id having sum(a.amount) <> 0) then
      raise exception 'Ce mois a déjà été payé : annulez d''abord le reçu.' using errcode = 'P0001';
    end if;
  end if;
  return new;
end $$;

create trigger canteen_subscriptions_guard before insert or update on public.canteen_subscriptions
  for each row execute function app.canteen_subscription_guard();

-- Détail d'un reçu de cantine : l'abonnement est celui de l'élève du reçu.
create or replace function app.canteen_allocation_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  s public.canteen_subscriptions;
  p public.payments;
begin
  if new.canteen_subscription_id is null then
    return new;
  end if;
  select * into s from public.canteen_subscriptions where id = new.canteen_subscription_id;
  select * into p from public.payments where id = new.payment_id;
  if not found or s.school_id <> new.school_id or s.student_id is distinct from p.student_id then
    raise exception 'Abonnement de cantine incohérent avec le reçu.' using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger payment_allocations_canteen_guard before insert on public.payment_allocations
  for each row execute function app.canteen_allocation_guard();

-- ------------------------------ Droits -------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['canteen_years', 'canteen_rates', 'canteen_subscriptions'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %1$I on public.%2$I for select to authenticated '
                   'using (app.has_any_perm(school_id, array[''cantine'', ''finances'']))', t || '_read', t);
    execute format('create policy %1$I on public.%2$I for insert to authenticated '
                   'with check (app.has_any_perm(school_id, array[''cantine'', ''finances'']))', t || '_insert', t);
    execute format('create policy %1$I on public.%2$I for update to authenticated '
                   'using (app.has_any_perm(school_id, array[''cantine'', ''finances''])) '
                   'with check (app.has_any_perm(school_id, array[''cantine'', ''finances'']))', t || '_update', t);
    perform app.guard_module(('public.' || t)::regclass, 'cantine');
  end loop;
end $$;

-- Bénéficiaires (réductions, exonérations) : modifiables aussi par les
-- Finances, qui encaissent.
create policy canteen_beneficiaries_finances_insert on public.canteen_beneficiaries for insert to authenticated
  with check (app.has_perm(school_id, 'finances'));
create policy canteen_beneficiaries_finances_update on public.canteen_beneficiaries for update to authenticated
  using (app.has_perm(school_id, 'finances')) with check (app.has_perm(school_id, 'finances'));

-- Le responsable de cantine encaisse la cantine (et ne voit que ses reçus).
create policy payments_cantine_read on public.payments for select to authenticated
  using (rubric = 'cantine' and app.has_perm(school_id, 'cantine'));
create policy payments_cantine_insert on public.payments for insert to authenticated
  with check (rubric = 'cantine' and app.has_perm(school_id, 'cantine'));
create policy payment_allocations_cantine_read on public.payment_allocations for select to authenticated
  using (rubric = 'cantine' and app.has_perm(school_id, 'cantine'));
create policy payment_allocations_cantine_insert on public.payment_allocations for insert to authenticated
  with check (rubric = 'cantine' and app.has_perm(school_id, 'cantine'));

-- --------------------------- Synchronisation ---------------------------
insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('canteen_years', 'lww', '{id}'),
  ('canteen_rates', 'lww', '{id}'),
  ('canteen_subscriptions', 'lww', '{id}');

do $$
declare
  t text;
begin
  foreach t in array array['canteen_years', 'canteen_rates', 'canteen_subscriptions'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;
