-- A22 : rubriques de frais propres à chaque école (ajouter, renommer,
-- retirer), en plus de celles proposées (Inscription, Scolarité,
-- Cotisation, Fournitures, Carte scolaire, Assurance). La rubrique reste
-- un code court sur les frais et les reçus ; son libellé est dans cette
-- table. « Autre » reste toujours disponible (recette sans élève).

alter table public.fee_items drop constraint if exists fee_items_rubric_check;

create table public.fee_rubrics (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools (id),
  code text not null check (code ~ '^[a-z0-9_]{2,40}$' and code <> 'autre'),
  label text not null check (length(trim(label)) > 0),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  created_by uuid,
  updated_by uuid,
  synced_at timestamptz not null default now(),
  unique (school_id, code)
);

alter table public.fee_rubrics enable row level security;

create policy fee_rubrics_read on public.fee_rubrics for select to authenticated
  using (app.has_any_perm(school_id, array['finances']));
create policy fee_rubrics_insert on public.fee_rubrics for insert to authenticated
  with check (app.has_any_perm(school_id, array['finances']));
create policy fee_rubrics_update on public.fee_rubrics for update to authenticated
  using (app.has_any_perm(school_id, array['finances']))
  with check (app.has_any_perm(school_id, array['finances']));

create trigger fee_rubrics_synced_at before insert or update on public.fee_rubrics
  for each row execute function app.touch_synced_at();
create trigger fee_rubrics_no_delete before delete on public.fee_rubrics
  for each row execute function app.forbid_delete();
create trigger fee_rubrics_audit after insert or update on public.fee_rubrics
  for each row execute function app.audit_row();

-- Une rubrique utilisée par un frais encore actif ne peut pas être retirée.
create or replace function app.fee_rubric_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.deleted_at is not null and old.deleted_at is null and exists (
       select 1 from public.fee_items f
        where f.school_id = new.school_id and f.rubric = new.code and f.deleted_at is null) then
    raise exception 'La rubrique « % » est utilisée dans la grille des frais : retirez d''abord ces frais.',
      new.label using errcode = 'P0001';
  end if;
  new.code := old.code;  -- le code ne change jamais (reçus déjà faits)
  return new;
end $$;

create trigger fee_rubrics_guard before update on public.fee_rubrics
  for each row execute function app.fee_rubric_guard();

insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('fee_rubrics', 'lww', '{id}');
