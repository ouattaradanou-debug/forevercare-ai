-- ============================================================================
-- Phase 1 — Récupération de code PIN par question secrète
--
-- Ajout demandé par l'utilisateur après la Phase 1 initiale : nos comptes
-- utilisent un email technique (<téléphone>@cave.internal, voir
-- telephone_identifiant.dart) que personne ne peut consulter — le flux de
-- récupération par email standard de Supabase Auth est donc inutilisable
-- tel quel. Solution retenue avec l'utilisateur : une question secrète
-- choisie à la création du compte, valable pour les 4 rôles (y compris le
-- tout premier Propriétaire/Gérant, qui n'a personne au-dessus de lui pour
-- le dépanner).
--
-- Choix explicitement signalés :
-- - La réponse est hachée avec pgcrypto (bcrypt, `crypt()`/`gen_salt('bf')`),
--   jamais stockée en clair — même précaution que pour le code PIN lui-même
--   (qui est le mot de passe Supabase Auth, déjà haché par GoTrue).
-- - Anti-brute-force minimal : 5 tentatives, puis blocage 30 minutes. Sans
--   ça, une question secrète serait triviale à deviner par essais répétés
--   — protection nécessaire, pas un confort.
-- - `obtenir_question_secrete` révèle si un numéro de téléphone est associé
--   à un compte (une question vide/absente = pas de compte ou pas de
--   question définie). C'est un compromis assumé pour rester simple (point
--   29 du cahier des charges) plutôt que de renvoyer une fausse question
--   décoy ; à revoir si un usage réel montre un risque d'énumération
--   problématique.
-- ============================================================================

alter table public.profiles
  add column question_secrete text,
  add column reponse_secrete_hash text,
  add column tentatives_reponse_secrete integer not null default 0,
  add column bloque_jusqu_a timestamptz;

comment on column public.profiles.question_secrete is 'Question choisie à la création du compte, utilisée pour la récupération de PIN.';
comment on column public.profiles.reponse_secrete_hash is 'Réponse hachée (bcrypt via pgcrypto), jamais stockée en clair.';

-- ----------------------------------------------------------------------------
-- creer_cave_et_proprietaire : accepte désormais la question/réponse
-- secrète du premier compte (Propriétaire ou Propriétaire/Gérant).
--
-- `CREATE OR REPLACE` ne remplace une fonction que si sa signature
-- (types de paramètres) est identique ; comme on ajoute 2 paramètres, il
-- faut explicitement supprimer l'ancienne version pour éviter une
-- ambiguïté de surcharge (deux fonctions de même nom).
-- ----------------------------------------------------------------------------
drop function if exists public.creer_cave_et_proprietaire(
  text, public.type_cave, text, text, text, text, text, public.role_utilisateur
);

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
    p_question_secrete, crypt(lower(trim(p_reponse_secrete)), gen_salt('bf'))
  );

  return v_cave;
end;
$$;

grant execute on function public.creer_cave_et_proprietaire to authenticated;

-- ----------------------------------------------------------------------------
-- obtenir_question_secrete : consultée AVANT authentification (l'utilisateur
-- a justement perdu son code d'accès), donc ouverte au rôle `anon`.
-- Ne renvoie que la question, jamais la réponse ni aucune autre donnée.
-- ----------------------------------------------------------------------------
create or replace function public.obtenir_question_secrete(p_telephone text)
returns text
language plpgsql security definer set search_path = public, extensions, auth as $$
declare
  v_email text;
  v_user_id uuid;
  v_question text;
begin
  v_email := regexp_replace(coalesce(p_telephone, ''), '\D', '', 'g') || '@cave.internal';

  select id into v_user_id from auth.users where email = v_email;
  if v_user_id is null then
    return null;
  end if;

  select question_secrete into v_question from public.profiles where id = v_user_id;
  return v_question;
end;
$$;

grant execute on function public.obtenir_question_secrete to anon, authenticated;

-- ----------------------------------------------------------------------------
-- reinitialiser_pin : vérifie la réponse (avec anti-brute-force), puis
-- remplace directement le mot de passe Supabase Auth (encrypted_password)
-- avec le même schéma de hachage que GoTrue (bcrypt) — technique standard
-- pour réinitialiser un mot de passe sans passer par un e-mail réel.
--
-- Renvoie un texte de statut ('ok' / 'reponse_incorrecte' / 'bloque') au
-- lieu de RAISE EXCEPTION pour le cas "mauvaise réponse" : une exception
-- annule tout le travail fait dans le même appel de fonction (y compris
-- l'incrémentation du compteur de tentatives, testé et confirmé en local),
-- ce qui aurait rendu l'anti-brute-force totalement inopérant. Seules les
-- erreurs de format d'entrée (PIN trop court) restent de vraies exceptions,
-- car ce sont des bugs côté client, pas un comportement utilisateur normal
-- à comptabiliser.
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

  -- Numéro inconnu : même statut que "mauvaise réponse", pour ne pas
  -- ajouter une deuxième façon de deviner si un numéro est enregistré (la
  -- question elle-même a déjà pu être consultée à l'étape précédente).
  if v_user_id is null then
    return 'reponse_incorrecte';
  end if;

  select reponse_secrete_hash, tentatives_reponse_secrete, bloque_jusqu_a
    into v_hash, v_tentatives, v_bloque_jusqu_a
    from public.profiles where id = v_user_id;

  if v_bloque_jusqu_a is not null and v_bloque_jusqu_a > now() then
    return 'bloque';
  end if;

  if v_hash is null or crypt(lower(trim(p_reponse)), v_hash) <> v_hash then
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

grant execute on function public.reinitialiser_pin to anon, authenticated;

-- ============================================================================
-- Fin de la migration 0002.
-- ============================================================================
