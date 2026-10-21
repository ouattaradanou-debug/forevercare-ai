-- =====================================================================
-- Phase 1 (compléments demandés le 21/10/2026) :
--   A6 : suivi des téléphones (dernière synchronisation, éléments en
--        attente), déconnexion d'un téléphone perdu, journal d'activité ;
--   A5 : mot de passe oublié par question secrète (réponse jamais stockée
--        en clair, 5 essais par heure, récupération signalée au directeur).
-- =====================================================================

-- ---------------------------- Téléphones -----------------------------
alter table public.devices
  add column last_sync_at timestamptz,
  add column pending_count integer not null default 0 check (pending_count >= 0),
  add column app_version text,
  add column revoked_at timestamptz,
  add column revoked_by uuid;

-- ------------------------- Journal d'activité ------------------------
-- Le journal est synchronisé (lecture seule) vers le téléphone du directeur.
alter table public.audit_log add column synced_at timestamptz not null default now();
create trigger audit_log_synced_at before insert on public.audit_log
  for each row execute function app.touch_synced_at();

-- Trace automatique de chaque création, modification ou suppression logique :
-- qui, quand, quelle ligne, quelles colonnes, nouvelles valeurs.
create or replace function app.audit_row() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_new jsonb := to_jsonb(new);
  v_old jsonb := case when tg_op = 'UPDATE' then to_jsonb(old) end;
  v_changed text[];
  v_action text;
begin
  select array_agg(k order by k) into v_changed
    from jsonb_object_keys(v_new) k
   where k not in ('created_at', 'created_by', 'updated_at', 'updated_by', 'synced_at')
     and (tg_op = 'INSERT' or v_new -> k is distinct from v_old -> k);
  if tg_op = 'UPDATE' and v_changed is null then
    return null; -- renvoi identique : rien à tracer
  end if;
  v_action := case
    when tg_op = 'INSERT' then 'creation'
    when v_old ->> 'deleted_at' is null and v_new ->> 'deleted_at' is not null then 'suppression'
    else 'modification' end;
  insert into public.audit_log (school_id, actor_id, action, table_name, row_id, details)
  values (
    coalesce((v_new ->> 'school_id')::uuid, (v_new ->> 'id')::uuid),
    auth.uid(), v_action, tg_table_name, (v_new ->> 'id')::uuid,
    jsonb_build_object(
      'colonnes', to_jsonb(v_changed),
      'valeurs', (select jsonb_object_agg(k, v_new -> k) from unnest(v_changed) k),
      'module', v_new ->> 'module_key'));
  return null;
end $$;

do $$
declare
  t text;
begin
  foreach t in array array['schools', 'school_years', 'admin_headers', 'school_modules',
                           'memberships', 'delegate_permissions'] loop
    execute format('create trigger %I after insert or update on public.%I '
                   'for each row execute function app.audit_row()', t || '_audit', t);
  end loop;
end $$;

-- Connexion : chaque inscription / réouverture d'un téléphone est tracée.
create or replace function public.register_device(p_device_id uuid, p_school uuid, p_label text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  d public.devices;
  v_new boolean := false;
begin
  if not app.is_member(p_school) then
    raise exception 'Accès refusé.' using errcode = '42501';
  end if;
  select * into d from public.devices where id = p_device_id;
  if found then
    if d.school_id <> p_school then
      raise exception 'Ce téléphone est enregistré dans une autre école.' using errcode = '42501';
    end if;
    if d.revoked_at is not null then
      raise exception 'Ce téléphone a été déconnecté par le directeur.' using errcode = 'P0001';
    end if;
    update public.devices set last_seen_at = now(), user_id = auth.uid(), label = p_label
     where id = p_device_id returning * into d;
  else
    v_new := true;
    insert into public.devices (id, school_id, user_id, label, series_code, last_seen_at)
    values (p_device_id, p_school, auth.uid(), p_label,
            app.series_code(app.next_counter(p_school, 'device_series')), now())
    returning * into d;
  end if;
  insert into public.audit_log (school_id, actor_id, action, table_name, row_id, details)
  values (p_school, auth.uid(), 'connexion', 'devices', d.id,
          jsonb_build_object('telephone', d.label, 'serie', d.series_code, 'nouveau', v_new));
  return to_jsonb(d);
end $$;

-- Signal envoyé à chaque synchronisation : le directeur voit quels téléphones
-- ont des éléments non envoyés ; un téléphone déconnecté l'apprend ici.
create or replace function public.device_heartbeat(p_device_id uuid, p_pending integer, p_app_version text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  d public.devices;
begin
  select * into d from public.devices where id = p_device_id and user_id = auth.uid();
  if not found then
    return jsonb_build_object('known', false, 'revoked', false);
  end if;
  if d.revoked_at is not null then
    return jsonb_build_object('known', true, 'revoked', true);
  end if;
  update public.devices
     set last_sync_at = now(), last_seen_at = now(), pending_count = greatest(p_pending, 0),
         app_version = p_app_version
   where id = p_device_id;
  return jsonb_build_object('known', true, 'revoked', false);
end $$;

-- Téléphone perdu ou volé : coupe l'accès (toutes les sessions de la personne
-- sont fermées : elle se reconnecte sur son nouveau téléphone). Le téléphone
-- perdu efface ses données dès qu'il retrouve le réseau.
create or replace function public.revoke_device(p_device_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  d public.devices;
begin
  select * into d from public.devices where id = p_device_id;
  if not found or not (app.is_director(d.school_id) or d.user_id = auth.uid()) then
    raise exception 'Accès refusé.' using errcode = '42501';
  end if;
  update public.devices set revoked_at = now(), revoked_by = auth.uid() where id = p_device_id;
  if d.user_id is not null then
    delete from auth.sessions where user_id = d.user_id;
  end if;
  insert into public.audit_log (school_id, actor_id, action, table_name, row_id, details)
  values (d.school_id, auth.uid(), 'deconnexion_telephone', 'devices', d.id,
          jsonb_build_object('telephone', d.label, 'serie', d.series_code));
end $$;

-- ------------------------- Question secrète --------------------------
create table app.recovery_secrets (
  user_id uuid primary key references auth.users (id) on delete cascade,
  question text not null check (length(trim(question)) between 5 and 200),
  answer_hash text not null,
  updated_at timestamptz not null default now()
);
create table app.recovery_attempts (
  id bigserial primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  succeeded boolean not null,
  at timestamptz not null default now()
);
revoke all on app.recovery_secrets, app.recovery_attempts from public, anon, authenticated;

-- Réponse comparée sans majuscules, accents ni espaces superflus.
create or replace function app.normalize_answer(p text) returns text
language sql stable as $$
  select lower(extensions.unaccent(regexp_replace(trim(coalesce(p, '')), '\s+', ' ', 'g')));
$$;

create or replace function public.set_recovery_question(p_question text, p_answer text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_answer text := app.normalize_answer(p_answer);
begin
  if auth.uid() is null then
    raise exception 'Connexion requise.' using errcode = '42501';
  end if;
  if length(v_answer) < 4 then
    raise exception 'La réponse doit contenir au moins 4 caractères.' using errcode = 'P0001';
  end if;
  insert into app.recovery_secrets (user_id, question, answer_hash, updated_at)
  values (auth.uid(), trim(p_question), extensions.crypt(v_answer, extensions.gen_salt('bf')), now())
  on conflict (user_id) do update
    set question = excluded.question, answer_hash = excluded.answer_hash, updated_at = now();
end $$;

create or replace function public.has_recovery_question() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from app.recovery_secrets where user_id = auth.uid());
$$;

-- Réservées à la fonction serveur « recuperer-mot-de-passe » (service_role).
create or replace function public.recovery_lookup(p_email text) returns text
language sql stable security definer set search_path = '' as $$
  select s.question from app.recovery_secrets s join auth.users u on u.id = s.user_id
   where u.email = lower(trim(p_email));
$$;

create or replace function public.recovery_verify(p_email text, p_answer text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid;
  v_hash text;
  v_ok boolean;
begin
  select u.id, s.answer_hash into v_user, v_hash
    from auth.users u join app.recovery_secrets s on s.user_id = u.id
   where u.email = lower(trim(p_email));
  if v_user is null then
    return jsonb_build_object('statut', 'inconnu');
  end if;
  if (select count(*) from app.recovery_attempts
       where user_id = v_user and not succeeded and at > now() - interval '1 hour') >= 5 then
    return jsonb_build_object('statut', 'bloque');
  end if;
  v_ok := extensions.crypt(app.normalize_answer(p_answer), v_hash) = v_hash;
  insert into app.recovery_attempts (user_id, succeeded) values (v_user, v_ok);
  if not v_ok then
    return jsonb_build_object('statut', 'faux');
  end if;
  -- Signalé dans le journal de chaque école de la personne (alerte du directeur).
  insert into public.audit_log (school_id, actor_id, action, table_name, row_id, details)
  select m.school_id, v_user, 'recuperation_mot_de_passe', 'memberships', m.id,
         jsonb_build_object('personne', m.display_name, 'methode', 'question secrète')
    from public.memberships m where m.user_id = v_user and m.deleted_at is null;
  return jsonb_build_object('statut', 'ok', 'user_id', v_user);
end $$;

revoke execute on function public.recovery_lookup(text), public.recovery_verify(text, text)
  from public, anon, authenticated;
grant execute on function public.recovery_lookup(text), public.recovery_verify(text, text) to service_role;
revoke execute on function public.device_heartbeat(uuid, integer, text), public.revoke_device(uuid),
  public.set_recovery_question(text, text), public.has_recovery_question() from public, anon;
grant execute on function public.device_heartbeat(uuid, integer, text), public.revoke_device(uuid),
  public.set_recovery_question(text, text), public.has_recovery_question() to authenticated;
