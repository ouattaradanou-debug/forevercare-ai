-- =====================================================================
-- Finances (module 10) et Cantine (10.9, OPTIONNELLE).
-- Montants en FCFA, entiers. Paiements, dépenses et mouvements de stock
-- sont en AJOUT SEUL : ni modification ni suppression (triggers en fin de
-- schéma) ; une erreur se corrige par une écriture d'annulation motivée.
-- Numérotation hors ligne : série de l'appareil + compteur local
-- (voir docs/ARCHITECTURE.md §6).
-- =====================================================================

create table public.fee_items (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  rubric text not null check (rubric in (
    'inscription', 'scolarite', 'cantine', 'cotisation', 'fournitures', 'autre'
  )),
  label text not null,
  level_code text references public.levels (code),   -- null = tous niveaux
  class_id uuid references public.classes (id),       -- null = toutes classes
  billing_period text not null default 'unique' check (billing_period in (
    'unique', 'repas', 'semaine', 'mois', 'trimestre', 'annee'
  )),
  amount bigint not null check (amount >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

create table public.fee_installments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  fee_item_id uuid not null references public.fee_items (id),
  label text not null,
  due_on date,
  amount bigint not null check (amount >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

create table public.discounts (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  label text not null,
  kind text not null check (kind in ('pourcentage', 'montant')),
  value numeric(12, 2) not null check (value >= 0),
  rubric text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  check (kind <> 'pourcentage' or value <= 100)
);

create table public.student_discounts (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  discount_id uuid not null references public.discounts (id),
  school_year_id uuid not null references public.school_years (id),
  fee_item_id uuid references public.fee_items (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

-- « 2025-2026 » + série « A » + 12 → « R2526-A-00012 ».
create or replace function app.format_receipt_number(p_year_label text, p_series text, p_seq integer)
returns text language sql immutable as $$
  select 'R' || substr(p_year_label, 3, 2) || substr(p_year_label, 8, 2)
         || '-' || p_series || '-' || lpad(p_seq::text, 5, '0');
$$;

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  student_id uuid references public.students (id),
  rubric text not null,
  amount bigint not null check (amount <> 0),
  method text not null check (method in (
    'especes', 'orange_money', 'moov_money', 'coris_money', 'virement', 'cheque'
  )),
  reference text,
  paid_at timestamptz not null,
  received_by uuid,
  device_id uuid not null references public.devices (id),
  device_seq integer not null check (device_seq > 0),
  receipt_number text not null,
  reverses_payment_id uuid unique references public.payments (id),
  reversal_reason text,
  created_at timestamptz not null default now(),
  synced_at timestamptz not null default now(),
  unique (school_id, receipt_number),
  unique (device_id, school_year_id, device_seq),
  -- Une contre-passation est négative et motivée ; un encaissement est positif.
  check ((reverses_payment_id is null and amount > 0 and reversal_reason is null)
      or (reverses_payment_id is not null and amount < 0 and coalesce(length(trim(reversal_reason)), 0) > 0))
);

-- Vérifie que le numéro de reçu correspond à la série de l'appareil et au compteur.
create or replace function app.check_receipt_number() returns trigger
language plpgsql as $$
declare
  v_expected text;
begin
  select app.format_receipt_number(y.label, d.series_code, new.device_seq)
    into v_expected
    from public.school_years y, public.devices d
   where y.id = new.school_year_id and d.id = new.device_id and d.school_id = new.school_id;
  if v_expected is null or new.receipt_number <> v_expected then
    raise exception 'Numéro de reçu incohérent : % (attendu %).', new.receipt_number, v_expected
      using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger payments_check_receipt_number
  before insert on public.payments
  for each row execute function app.check_receipt_number();

create table public.payment_allocations (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  payment_id uuid not null references public.payments (id),
  fee_item_id uuid references public.fee_items (id),
  installment_id uuid references public.fee_installments (id),
  amount bigint not null check (amount <> 0),
  created_at timestamptz not null default now(),
  synced_at timestamptz not null default now()
);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  school_year_id uuid not null references public.school_years (id),
  category text not null,               -- 'cantine' pour les dépenses de cantine
  label text not null,
  amount bigint not null check (amount <> 0),
  spent_on date not null,
  method text,
  justification_path text,              -- photo du justificatif (stockage privé)
  device_id uuid not null references public.devices (id),
  device_seq integer not null check (device_seq > 0),
  reverses_expense_id uuid unique references public.expenses (id),
  reversal_reason text,
  created_by uuid,
  created_at timestamptz not null default now(),
  synced_at timestamptz not null default now(),
  unique (device_id, school_year_id, device_seq),
  check ((reverses_expense_id is null and amount > 0 and reversal_reason is null)
      or (reverses_expense_id is not null and amount < 0 and coalesce(length(trim(reversal_reason)), 0) > 0))
);

create table public.cash_closings (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  period_month date not null check (extract(day from period_month) = 1),
  closing_balance bigint not null,
  closed_by uuid,
  notes text,
  created_at timestamptz not null default now(),
  synced_at timestamptz not null default now(),
  unique (school_id, period_month)
);

-- ---------------------------- Cantine --------------------------------
create table public.canteen_settings (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null unique references public.schools (id),
  mode text not null default 'sans_participation'
    check (mode in ('avec_participation', 'sans_participation', 'mixte')),
  local_definition text,   -- ce que l'école entend par « cantine endogène »
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now()
);

create table public.canteen_beneficiaries (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  school_year_id uuid not null references public.school_years (id),
  is_beneficiary boolean not null default true,
  since date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (student_id, school_year_id)
);

-- Pointage par nombre (par jour, et par classe si souhaité) : dernière modification gagne.
create table public.meal_services (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  day date not null,
  class_id uuid references public.classes (id),
  meals_count integer not null check (meals_count >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique nulls not distinct (school_id, day, class_id)
);

-- Pointage par liste cochée : fusion par (élève, jour).
create table public.meal_checks (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  student_id uuid not null references public.students (id),
  day date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (student_id, day)
);

create table public.stock_products (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  name text not null,
  unit text not null,                       -- kg, sac, litre…
  alert_threshold numeric(12, 3) check (alert_threshold >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, name)
);

-- Stock courant = somme des quantity_delta (entrées positives, sorties négatives).
create table public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  product_id uuid not null references public.stock_products (id),
  kind text not null check (kind in ('entree', 'sortie', 'ajustement', 'annulation')),
  quantity_delta numeric(12, 3) not null check (quantity_delta <> 0),
  provenance text check (provenance in (
    'achat', 'don', 'produits_locaux', 'parents', 'partenaire', 'autre'
  )),
  out_reason text check (out_reason in ('repas', 'perte', 'autre')),
  occurred_on date not null,
  notes text,
  device_id uuid not null references public.devices (id),
  device_seq integer not null check (device_seq > 0),
  reverses_movement_id uuid unique references public.stock_movements (id),
  reason text,              -- obligatoire pour ajustement et annulation
  created_by uuid,
  created_at timestamptz not null default now(),
  synced_at timestamptz not null default now(),
  unique (device_id, device_seq),
  check (kind <> 'entree' or (quantity_delta > 0 and provenance is not null)),
  check (kind <> 'sortie' or (quantity_delta < 0 and out_reason is not null)),
  check (kind not in ('ajustement', 'annulation') or coalesce(length(trim(reason)), 0) > 0),
  check ((kind = 'annulation') = (reverses_movement_id is not null))
);

create table public.canteen_menus (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  week_start date not null,
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, week_start)
);
