-- =====================================================================
-- Phase 14 — Durcissement (audit de sécurité).
-- Défense en profondeur : le rôle « anon » (personne non connectée) n'a
-- plus AUCUN droit sur les tables ni sur les fonctions de l'application.
-- La RLS les fermait déjà (aucune politique pour « anon ») ; ces droits
-- par défaut de Supabase sont maintenant retirés aussi.
-- Avant la connexion, l'application n'utilise que l'authentification et
-- les fonctions serveur (connexion-telephone, recuperer-mot-de-passe), qui
-- travaillent avec la clé du serveur.
-- =====================================================================

revoke all on all tables in schema public from anon;
revoke all on all tables in schema medical from anon;
revoke all on all sequences in schema public from anon;

-- Fonctions de l'application : retirées à « anon » et à « public », mais
-- gardées pour les personnes connectées qui les avaient.
do $$
declare
  f record;
begin
  for f in
    select p.oid::regprocedure as sig,
           has_function_privilege('authenticated', p.oid, 'execute') as connecte
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname in ('public', 'medical', 'app') and p.prokind = 'f'
  loop
    execute format('revoke execute on function %s from public, anon', f.sig);
    if f.connecte then
      execute format('grant execute on function %s to authenticated', f.sig);
    end if;
  end loop;
end $$;

-- Tables et fonctions créées plus tard : jamais ouvertes à « anon ».
alter default privileges in schema public revoke all on tables from anon;
alter default privileges in schema public revoke all on sequences from anon;
alter default privileges in schema public revoke execute on functions from anon;
