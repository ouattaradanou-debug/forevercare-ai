-- =====================================================================
-- Phase 1 — Fonctions serveur : création d'école, inscription d'un appareil,
-- synchronisation (envoi). Le téléchargement passe par l'API REST standard
-- (filtre synced_at), donc par la RLS.
-- =====================================================================

create or replace function public.server_now() returns timestamptz
language sql stable as $$ select now() $$;

-- 1 → A, 26 → Z, 27 → AA … 702 → ZZ
create or replace function app.series_code(p_n bigint) returns text
language plpgsql immutable as $$
begin
  if p_n between 1 and 26 then
    return chr(64 + p_n::int);
  elsif p_n between 27 and 702 then
    return chr(64 + ((p_n - 27) / 26 + 1)::int) || chr(64 + ((p_n - 27) % 26 + 1)::int);
  end if;
  raise exception 'Nombre maximal d''appareils atteint pour cette école.' using errcode = 'P0001';
end $$;

-- Création d'une école par son directeur (en ligne, première utilisation).
-- Idempotente : un renvoi avec les mêmes identifiants renvoie l'école existante.
create or replace function public.create_school(p jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_school uuid := (p ->> 'school_id')::uuid;
  v_year uuid := (p ->> 'school_year_id')::uuid;
  v_member uuid := (p ->> 'membership_id')::uuid;
  v_primary boolean := coalesce((p ->> 'manages_primary')::boolean, true);
  v_preschool boolean := coalesce((p ->> 'manages_preschool')::boolean, false);
begin
  if v_uid is null then
    raise exception 'Connexion requise.' using errcode = '42501';
  end if;
  if exists (select 1 from public.schools s where s.id = v_school) then
    if app.is_director(v_school) then
      return jsonb_build_object('school_id', v_school, 'already_created', true);
    end if;
    raise exception 'Identifiant d''école déjà utilisé.' using errcode = '42501';
  end if;
  if not v_primary and not v_preschool then
    raise exception 'Au moins un niveau (primaire ou maternelle) doit être géré.' using errcode = 'P0001';
  end if;
  if coalesce(trim(p ->> 'name'), '') = '' or (p ->> 'year_label') !~ '^\d{4}-\d{4}$' then
    raise exception 'Nom de l''école et année scolaire obligatoires.' using errcode = 'P0001';
  end if;

  insert into public.schools (id, name, commune, departement, province, region, school_type, phone, email,
                              director_name, manages_primary, created_by, updated_by)
  values (v_school, trim(p ->> 'name'), p ->> 'commune', p ->> 'departement', p ->> 'province', p ->> 'region',
          coalesce(p ->> 'school_type', 'publique'), p ->> 'phone', p ->> 'email', p ->> 'director_name',
          v_primary, v_uid, v_uid);
  insert into public.school_years (id, school_id, label, starts_on, ends_on)
  values (v_year, v_school, p ->> 'year_label', (p ->> 'starts_on')::date, (p ->> 'ends_on')::date);
  update public.schools set current_school_year_id = v_year where id = v_school;
  insert into public.admin_headers (id, school_id, school_year_id, ministry, region, regional_direction,
                                    provincial_direction, ceb, province, departement, commune, school_label)
  values (coalesce((p ->> 'admin_header_id')::uuid, gen_random_uuid()), v_school, v_year,
          p ->> 'ministry', p ->> 'region', p ->> 'regional_direction', p ->> 'provincial_direction',
          p ->> 'ceb', p ->> 'province', p ->> 'departement', p ->> 'commune', trim(p ->> 'name'));
  insert into public.school_modules (school_id, module_key, enabled, updated_by)
  select v_school, mc.key, (mc.key = 'maternelle' and v_preschool), v_uid from public.modules_catalog mc;
  insert into public.memberships (id, school_id, user_id, role, display_name, phone, created_by, updated_by)
  values (v_member, v_school, v_uid, 'directeur', coalesce(p ->> 'director_name', 'Directeur'), p ->> 'phone',
          v_uid, v_uid);
  insert into public.audit_log (school_id, actor_id, action, table_name, row_id)
  values (v_school, v_uid, 'creation_ecole', 'schools', v_school);
  return jsonb_build_object('school_id', v_school, 'already_created', false);
end $$;

-- Inscription d'un appareil : attribue une série (A, B, …) une fois pour toutes.
create or replace function public.register_device(p_device_id uuid, p_school uuid, p_label text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  d public.devices;
begin
  if not app.is_member(p_school) then
    raise exception 'Accès refusé.' using errcode = '42501';
  end if;
  select * into d from public.devices where id = p_device_id;
  if found then
    if d.school_id <> p_school then
      raise exception 'Appareil inscrit dans une autre école.' using errcode = '42501';
    end if;
    update public.devices set last_seen_at = now(), user_id = auth.uid() where id = p_device_id
    returning * into d;
  else
    insert into public.devices (id, school_id, user_id, label, series_code, last_seen_at)
    values (p_device_id, p_school, auth.uid(), p_label,
            app.series_code(app.next_counter(p_school, 'device_series')), now())
    returning * into d;
  end if;
  return to_jsonb(d);
end $$;

-- ---------------- Synchronisation : envoi ----------------------------
create table app.sync_tables (
  table_name text primary key,
  strategy text not null check (strategy in ('lww', 'append')),
  conflict_cols text[] not null default '{id}'
);
insert into app.sync_tables (table_name, strategy, conflict_cols) values
  ('schools', 'lww', '{id}'),
  ('school_years', 'lww', '{id}'),
  ('admin_headers', 'lww', '{id}'),
  ('school_modules', 'lww', '{school_id,module_key}'),
  ('memberships', 'lww', '{id}'),
  ('delegate_permissions', 'lww', '{id}');
grant select on app.sync_tables to authenticated;

create or replace function app.log_conflict(p_school uuid, p_table text, p_row uuid, p_winner jsonb, p_loser jsonb)
returns void language sql security definer set search_path = '' as $$
  insert into public.sync_conflicts (school_id, table_name, row_id, winner, loser)
  values (p_school, p_table, coalesce(p_row, gen_random_uuid()), p_winner, p_loser);
$$;

-- Applique une liste de changements [{change_id, table, row}] avec les droits
-- de l'utilisateur (RLS). Chaque changement est traité isolément ; le résultat
-- indique pour chacun : ok | ignore_plus_ancien | deja_recu | rejete.
create or replace function public.sync_push(p_changes jsonb) returns jsonb
language plpgsql security invoker set search_path = '' as $$
declare
  c jsonb;
  v_cfg app.sync_tables;
  v_row jsonb;
  v_cols text[];
  v_upd text[];
  v_where text;
  v_old jsonb;
  v_new jsonb;
  v_status text;
  v_msg text;
  v_code text;
  v_out jsonb := '[]'::jsonb;
begin
  for c in select * from jsonb_array_elements(p_changes) loop
    v_status := null; v_msg := null; v_code := null; v_new := null;
    v_row := c -> 'row';
    select * into v_cfg from app.sync_tables where table_name = c ->> 'table';
    if not found then
      v_out := v_out || jsonb_build_object('change_id', c -> 'change_id', 'status', 'rejete',
                                           'message', 'Table non synchronisable.');
      continue;
    end if;
    begin
      if not v_row ? 'updated_at' then
        raise exception 'Date de modification manquante.' using errcode = 'P0002';
      end if;
      if (v_row ->> 'updated_at')::timestamptz > now() + interval '10 minutes' then
        raise exception 'Heure du téléphone en avance : corrigez la date et l''heure.' using errcode = 'P0002';
      end if;
      select array_agg(quote_ident(col.column_name) order by col.ordinal_position),
             array_agg(quote_ident(col.column_name) order by col.ordinal_position)
               filter (where col.column_name <> all (v_cfg.conflict_cols || array['id', 'school_id', 'created_at', 'created_by']))
        into v_cols, v_upd
        from information_schema.columns col
       where col.table_schema = 'public' and col.table_name = v_cfg.table_name
         and col.is_generated = 'NEVER' and col.column_name <> 'synced_at'
         and v_row ? col.column_name;
      select string_agg(format('t.%1$I = r.%1$I', k), ' and ') into v_where from unnest(v_cfg.conflict_cols) k;

      execute format('select to_jsonb(t) from public.%1$I t, jsonb_populate_record(null::public.%1$I, $1) r where %2$s',
                     v_cfg.table_name, v_where)
        into v_old using v_row;

      if v_old is null then
        execute format('insert into public.%1$I (%2$s) select %2$s from jsonb_populate_record(null::public.%1$I, $1) returning to_jsonb(%1$I.*)',
                       v_cfg.table_name, array_to_string(v_cols, ', '))
          into v_new using v_row;
        v_status := 'ok';
      elsif v_cfg.strategy = 'append' then
        v_status := 'deja_recu';
        v_new := v_old;
      elsif (v_old ->> 'updated_at')::timestamptz > (v_row ->> 'updated_at')::timestamptz then
        perform app.log_conflict((v_old ->> 'school_id')::uuid, v_cfg.table_name, (v_old ->> 'id')::uuid, v_old, v_row);
        v_status := 'ignore_plus_ancien';
        v_new := v_old;
      else
        execute format('update public.%1$I t set (%2$s) = (select %2$s from jsonb_populate_record(null::public.%1$I, $1)) '
                       'from jsonb_populate_record(null::public.%1$I, $1) r where %3$s returning to_jsonb(t)',
                       v_cfg.table_name, array_to_string(v_upd, ', '), v_where)
          into v_new using v_row;
        if v_new is null then
          raise exception 'Modification refusée.' using errcode = '42501';
        end if;
        if (v_old ->> 'updated_by') is distinct from auth.uid()::text then
          perform app.log_conflict((v_old ->> 'school_id')::uuid, v_cfg.table_name, (v_old ->> 'id')::uuid, v_new, v_old);
        end if;
        v_status := 'ok';
      end if;
    exception when others then
      get stacked diagnostics v_msg = message_text, v_code = returned_sqlstate;
      v_status := 'rejete';
    end;
    v_out := v_out || jsonb_build_object('change_id', c -> 'change_id', 'status', v_status,
                                         'code', v_code, 'message', v_msg, 'row', v_new);
  end loop;
  return v_out;
end $$;

grant execute on function public.sync_push(jsonb) to authenticated;
grant execute on function public.create_school(jsonb) to authenticated;
grant execute on function public.register_device(uuid, uuid, text) to authenticated;
revoke execute on function public.sync_push(jsonb), public.create_school(jsonb),
  public.register_device(uuid, uuid, text) from anon;
