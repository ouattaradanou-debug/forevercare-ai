-- =====================================================================
-- Phase 5 — bilan (B7) : imprimer la moyenne des taux de chaque objectif
-- (facultatif, choisi par le directeur).
-- =====================================================================

alter table public.official_forms
  add column show_objective_average boolean not null default false;
