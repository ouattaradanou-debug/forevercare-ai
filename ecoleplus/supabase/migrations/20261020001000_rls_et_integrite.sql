-- =====================================================================
-- RLS sur TOUTES les tables (R4) et triggers génériques d'intégrité.
-- Phase 0 : RLS activée sans aucune politique = refus total pour les rôles
-- anon et authenticated. Les politiques par profil arrivent en phase 1
-- (tables de base) puis avec chaque module.
-- =====================================================================

do $$
declare
  t record;
begin
  for t in
    select n.nspname, c.relname
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where c.relkind = 'r' and n.nspname in ('public', 'medical')
  loop
    execute format('alter table %I.%I enable row level security', t.nspname, t.relname);
  end loop;
end $$;

-- Le référentiel des niveaux est public en lecture (aucune donnée d'école).
create policy levels_read on public.levels for select to authenticated using (true);

-- synced_at = horloge du serveur à chaque écriture.
do $$
declare
  t record;
begin
  for t in
    select table_schema, table_name from information_schema.columns
     where column_name = 'synced_at' and table_schema in ('public', 'medical')
  loop
    execute format(
      'create trigger %I before insert or update on %I.%I for each row execute function app.touch_synced_at()',
      t.table_name || '_synced_at', t.table_schema, t.table_name);
  end loop;
end $$;

-- Aucune suppression physique des données scolaires et financières :
-- toutes les tables qui portent deleted_at (suppression logique), sauf les
-- documents (corbeille purgée après délai, phase 9).
do $$
declare
  t record;
begin
  for t in
    select table_schema, table_name from information_schema.columns
     where column_name = 'deleted_at' and table_schema in ('public', 'medical')
       and table_name not in ('documents')
  loop
    execute format(
      'create trigger %I before delete on %I.%I for each row execute function app.forbid_delete()',
      t.table_name || '_no_delete', t.table_schema, t.table_name);
  end loop;
end $$;

-- Tables en AJOUT SEUL : ni modification ni suppression.
do $$
declare
  t text;
begin
  foreach t in array array[
    'public.payments', 'public.payment_allocations', 'public.expenses', 'public.cash_closings',
    'public.stock_movements', 'public.audit_log', 'public.sync_conflicts',
    'public.scolarity_copy_log', 'medical.access_log'
  ] loop
    execute format(
      'create trigger append_only before update or delete on %s for each row execute function app.forbid_update()', t);
  end loop;
end $$;
