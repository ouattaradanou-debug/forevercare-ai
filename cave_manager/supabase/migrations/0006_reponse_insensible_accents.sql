-- ============================================================================
-- Phase 1 — Réponse secrète insensible à la casse ET aux accents
--
-- Demandé explicitement : "riz sauce", "Riz Sauce", "rîz saucé" doivent
-- tous être acceptés comme la même réponse. La casse était déjà ignorée
-- (`lower()`, migration 0002) mais pas les accents. Ajoute `unaccent()`
-- (extension pgcrypto's cousin, standard PostgreSQL) à la même
-- normalisation, à la fois là où la réponse est hachée à la création du
-- compte ET là où elle est comparée à la vérification — les deux doivent
-- rester identiques, sinon plus aucune réponse ne correspondrait à son
-- hash.
--
-- Sans risque pour les comptes déjà créés : `unaccent()` ne change rien
-- pour une réponse qui ne contient aucun caractère accentué (le cas de
-- "riz sauce" déjà enregistré) — seules les réponses accentuées,
-- nouvellement créées ou vérifiées à partir de maintenant, en profitent.
-- ============================================================================

create extension if not exists "unaccent";

-- ----------------------------------------------------------------------------
-- creer_cave_et_proprietaire : même signature qu'avant, seule la
-- normalisation de la réponse au moment du hachage change.
-- ----------------------------------------------------------------------------
create or replace function public.creer_cave_et_proprietaire(
  p_nom_cave text,
  p_type_cave public.type_cave,
  p_telephone_cave text,
  p_localisation text,
  p_nom_utilisateur text,
  p_prenom_utilisateur text,
  p_telephone_utilisateur text,
  p_role public.role_utilisateur,
  p_question_secrete text,
  p_reponse_secrete text
) returns public.caves
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_cave public.caves;
begin
  if auth.uid() is null then
    raise exception 'Authentification requise.' using errcode = '42501';
  end if;

  if exists (select 1 from public.profiles where id = auth.uid()) then
    raise exception 'Ce compte possède déjà un profil.' using errcode = '23505';
  end if;

  if p_role not in ('proprietaire', 'proprietaire_gerant') then
    raise exception 'Le premier compte d''une cave doit être Propriétaire ou Propriétaire/Gérant.'
      using errcode = '22023';
  end if;

  if p_question_secrete is null or trim(p_question_secrete) = ''
     or p_reponse_secrete is null or trim(p_reponse_secrete) = '' then
    raise exception 'La question secrète et sa réponse sont obligatoires.'
      using errcode = '22023';
  end if;

  insert into public.caves (nom, type_cave, telephone, localisation, created_by)
  values (p_nom_cave, p_type_cave, p_telephone_cave, p_localisation, auth.uid())
  returning * into v_cave;

  insert into public.profiles (
    id, cave_id, nom, prenom, telephone, role, created_by,
    question_secrete, reponse_secrete_hash
  )
  values (
    auth.uid(), v_cave.id, p_nom_utilisateur, p_prenom_utilisateur, p_telephone_utilisateur, p_role, auth.uid(),
    p_question_secrete, crypt(unaccent(lower(trim(p_reponse_secrete))), gen_salt('bf'))
  );

  return v_cave;
end;
$$;

-- ----------------------------------------------------------------------------
-- reinitialiser_pin : même chose, normalisation de la réponse à comparer.
-- ----------------------------------------------------------------------------
create or replace function public.reinitialiser_pin(
  p_telephone text,
  p_reponse text,
  p_nouveau_pin text
) returns text
language plpgsql security definer set search_path = public, extensions, auth as $$
declare
  v_email text;
  v_user_id uuid;
  v_hash text;
  v_tentatives integer;
  v_bloque_jusqu_a timestamptz;
begin
  if p_nouveau_pin is null or char_length(p_nouveau_pin) < 6 then
    raise exception 'Le nouveau code PIN doit contenir au moins 6 chiffres.' using errcode = '22023';
  end if;

  v_email := regexp_replace(coalesce(p_telephone, ''), '\D', '', 'g') || '@cave.internal';
  select id into v_user_id from auth.users where email = v_email;

  if v_user_id is null then
    return 'reponse_incorrecte';
  end if;

  select reponse_secrete_hash, tentatives_reponse_secrete, bloque_jusqu_a
    into v_hash, v_tentatives, v_bloque_jusqu_a
    from public.profiles where id = v_user_id;

  if v_bloque_jusqu_a is not null and v_bloque_jusqu_a > now() then
    return 'bloque';
  end if;

  if v_hash is null or crypt(unaccent(lower(trim(p_reponse))), v_hash) <> v_hash then
    update public.profiles
      set tentatives_reponse_secrete = tentatives_reponse_secrete + 1,
          bloque_jusqu_a = case
            when tentatives_reponse_secrete + 1 >= 5 then now() + interval '30 minutes'
            else bloque_jusqu_a
          end
      where id = v_user_id;
    return 'reponse_incorrecte';
  end if;

  update public.profiles
    set tentatives_reponse_secrete = 0, bloque_jusqu_a = null
    where id = v_user_id;

  update auth.users
    set encrypted_password = crypt(p_nouveau_pin, gen_salt('bf')),
        updated_at = now()
    where id = v_user_id;

  return 'ok';
end;
$$;

-- ----------------------------------------------------------------------------
-- verifier_reponse_secrete : idem.
-- ----------------------------------------------------------------------------
create or replace function public.verifier_reponse_secrete(
  p_telephone text,
  p_reponse text
) returns text
language plpgsql security definer set search_path = public, extensions, auth as $$
declare
  v_email text;
  v_user_id uuid;
  v_hash text;
  v_tentatives integer;
  v_bloque_jusqu_a timestamptz;
begin
  v_email := regexp_replace(coalesce(p_telephone, ''), '\D', '', 'g') || '@cave.internal';
  select id into v_user_id from auth.users where email = v_email;

  if v_user_id is null then
    return 'reponse_incorrecte';
  end if;

  select reponse_secrete_hash, tentatives_reponse_secrete, bloque_jusqu_a
    into v_hash, v_tentatives, v_bloque_jusqu_a
    from public.profiles where id = v_user_id;

  if v_bloque_jusqu_a is not null and v_bloque_jusqu_a > now() then
    return 'bloque';
  end if;

  if v_hash is null or crypt(unaccent(lower(trim(p_reponse))), v_hash) <> v_hash then
    update public.profiles
      set tentatives_reponse_secrete = tentatives_reponse_secrete + 1,
          bloque_jusqu_a = case
            when tentatives_reponse_secrete + 1 >= 5 then now() + interval '30 minutes'
            else bloque_jusqu_a
          end
      where id = v_user_id;
    return 'reponse_incorrecte';
  end if;

  update public.profiles
    set tentatives_reponse_secrete = 0, bloque_jusqu_a = null
    where id = v_user_id;

  return 'ok';
end;
$$;

-- ============================================================================
-- Fin de la migration 0006.
-- ============================================================================
