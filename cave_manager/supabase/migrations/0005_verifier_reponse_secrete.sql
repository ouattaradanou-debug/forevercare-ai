-- ============================================================================
-- Phase 1 — Vérification de la réponse secrète en deux étapes distinctes
--
-- Demandé explicitement : sur l'écran "Code PIN oublié", ne montrer les
-- champs "Nouveau code PIN" / "Confirmez" qu'APRÈS avoir confirmé que la
-- réponse à la question secrète est correcte, au lieu de tout afficher
-- d'un coup (comme c'était le cas jusqu'ici, où la réponse n'était en
-- réalité vérifiée qu'au moment de soumettre le nouveau PIN).
--
-- Nouvelle fonction `verifier_reponse_secrete`, qui reprend exactement la
-- même logique de vérification + anti-brute-force que `reinitialiser_pin`
-- (migration 0002), mais SANS toucher au mot de passe. `reinitialiser_pin`
-- n'est pas modifiée : elle revérifie la réponse à son tour au moment du
-- vrai changement de PIN — ne jamais faire confiance à un "déjà vérifié"
-- annoncé par le client pour une action sensible.
-- ============================================================================

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

  return 'ok';
end;
$$;

grant execute on function public.verifier_reponse_secrete to anon, authenticated;

-- ============================================================================
-- Fin de la migration 0005.
-- ============================================================================
