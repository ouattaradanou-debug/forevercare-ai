-- =============================================================================
-- Atelier+ — Migration : ajout de "tenue retirée" sur les commandes
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase. Idempotent : rejouer ce
-- script ne fait rien de plus si la colonne existe déjà.
--
-- Permet au tailleur de cocher, sur la fiche d'un client, que la tenue
-- terminée a été retirée. Combiné à un solde entièrement réglé, le client
-- disparaît alors de la liste "Clients concernés par ce rappel" sur
-- l'écran d'accueil (voir Commande.estSoldee côté application).
-- =============================================================================

alter table public.commandes
  add column if not exists tenue_retiree boolean not null default false;
