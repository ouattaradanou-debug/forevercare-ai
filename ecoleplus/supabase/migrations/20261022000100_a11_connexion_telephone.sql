-- =====================================================================
-- A11 — Connexion du directeur (ou de tout compte à e-mail) avec son
-- numéro de téléphone, en plus de son e-mail. Sans SMS.
--   * un numéro = un seul compte dans toute l'application ;
--   * le serveur ne révèle l'e-mail du compte qu'à qui a le bon mot de
--     passe (fonction serveur « connexion-telephone », service_role) ;
--   * 5 essais ratés en une heure sur un numéro → blocage temporaire.
-- =====================================================================

create table app.login_phones (
  phone text primary key check (phone ~ '^226[0-9]{8}$'),
  user_id uuid not null unique references auth.users (id) on delete cascade,
  updated_at timestamptz not null default now()
);
create table app.login_phone_attempts (
  id bigserial primary key,
  phone text not null,
  succeeded boolean not null,
  at timestamptz not null default now()
);
create index on app.login_phone_attempts (phone, at);
revoke all on app.login_phones, app.login_phone_attempts from public, anon, authenticated;

-- Vrai si le numéro sert déjà d'identifiant à un AUTRE compte que p_user :
-- compte « numéro » (enseignant) ou numéro ajouté par un directeur.
create or replace function app.phone_taken(p_phone text, p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from auth.users
                  where email = p_phone || '@tel.ecoleplus.invalid'
                    and id is distinct from p_user)
      or exists (select 1 from app.login_phones
                  where phone = p_phone and user_id is distinct from p_user);
$$;

-- Le titulaire du compte choisit (ou retire, avec null) son numéro.
create or replace function public.set_login_phone(p_phone text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_phone text := nullif(trim(coalesce(p_phone, '')), '');
begin
  if auth.uid() is null then
    raise exception 'Connexion requise.' using errcode = '42501';
  end if;
  if v_phone is null then
    delete from app.login_phones where user_id = auth.uid();
    return;
  end if;
  if v_phone !~ '^226[0-9]{8}$' then
    raise exception 'Numéro invalide : 8 chiffres (ex. 70 12 34 56).' using errcode = 'P0001';
  end if;
  if (select email from auth.users where id = auth.uid()) like '%@tel.ecoleplus.invalid' then
    raise exception 'Ce compte se connecte déjà avec un numéro de téléphone.' using errcode = 'P0001';
  end if;
  if app.phone_taken(v_phone, auth.uid()) then
    raise exception 'Ce numéro est déjà utilisé pour se connecter à un autre compte.'
      using errcode = 'P0001';
  end if;
  insert into app.login_phones (phone, user_id) values (v_phone, auth.uid())
  on conflict (user_id) do update set phone = excluded.phone, updated_at = now();
end $$;

create or replace function public.get_login_phone() returns text
language sql stable security definer set search_path = '' as $$
  select phone from app.login_phones where user_id = auth.uid();
$$;

-- Réservée à « gerer-membres » : un enseignant ne peut pas recevoir un
-- numéro déjà pris comme identifiant par un directeur.
create or replace function public.login_phone_taken(p_phone text) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from app.login_phones where phone = p_phone);
$$;

-- Réservée à « connexion-telephone » : renvoie l'e-mail du compte SEULEMENT
-- si le mot de passe est le bon ; sinon rien (un inconnu n'apprend même pas
-- si le numéro existe).
create or replace function public.login_lookup(p_phone text, p_password text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid;
  v_email text;
  v_hash text;
  v_ok boolean;
begin
  if (select count(*) from app.login_phone_attempts
       where phone = p_phone and not succeeded and at > now() - interval '1 hour') >= 5 then
    return jsonb_build_object('statut', 'bloque');
  end if;
  select u.id, u.email, u.encrypted_password into v_user, v_email, v_hash
    from app.login_phones l join auth.users u on u.id = l.user_id
   where l.phone = p_phone;
  v_ok := v_hash is not null and v_hash <> ''
          and extensions.crypt(coalesce(p_password, ''), v_hash) = v_hash;
  insert into app.login_phone_attempts (phone, succeeded) values (p_phone, v_ok);
  if not v_ok then
    return jsonb_build_object('statut', 'faux');
  end if;
  insert into public.audit_log (school_id, actor_id, action, table_name, row_id, details)
  select m.school_id, v_user, 'connexion_par_numero', 'memberships', m.id,
         jsonb_build_object('personne', m.display_name)
    from public.memberships m where m.user_id = v_user and m.deleted_at is null;
  return jsonb_build_object('statut', 'ok', 'email', v_email);
end $$;

revoke execute on function app.phone_taken(text, uuid) from public, anon, authenticated;
revoke execute on function public.login_lookup(text, text), public.login_phone_taken(text)
  from public, anon, authenticated;
grant execute on function public.login_lookup(text, text), public.login_phone_taken(text)
  to service_role;
revoke execute on function public.set_login_phone(text), public.get_login_phone() from public, anon;
grant execute on function public.set_login_phone(text), public.get_login_phone() to authenticated;
