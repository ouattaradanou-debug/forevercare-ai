-- =============================================================================
-- Atelier+ — Migration : champs client optionnels
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase, en plus de schema.sql
-- (déjà exécuté). Sans effet si déjà appliquée (idempotent).
--
-- Décision d'architecture : le formulaire de création client devient un
-- formulaire continu où AUCUN champ n'est individuellement obligatoire (y
-- compris nom, prénom, téléphone, sexe, date de prise des mesures). Seule
-- l'existence d'au moins une mesure conditionne la création officielle
-- d'un client. Les contraintes NOT NULL / CHECK de non-vacuité initiales
-- (Phase 0) sont donc retirées ici ; la contrainte CHECK sur `sexe` reste
-- en place mais accepte désormais NULL (comportement standard SQL : une
-- contrainte CHECK ne s'applique pas à une valeur NULL).
-- =============================================================================

alter table public.clients
  alter column nom drop not null,
  alter column prenom drop not null,
  alter column telephone drop not null,
  alter column sexe drop not null,
  alter column date_prise_mesures drop not null;

alter table public.clients
  drop constraint if exists clients_nom_check;

alter table public.clients
  drop constraint if exists clients_prenom_check;
