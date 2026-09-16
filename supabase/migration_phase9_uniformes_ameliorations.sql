-- =============================================================================
-- Atelier+ — Migration Phase 9 : améliorations du module "Mesures des uniformes"
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase.
--
-- Ajoute le suivi "couture terminée" par membre — un tailleur peut cocher
-- qu'il a fini de confectionner la tenue d'un membre donné, ce qui met en
-- évidence son nom (fond vert foncé) dans la liste du groupe. Les policies
-- RLS existantes (membres_groupe_uniforme_update_autorise,
-- groupes_uniformes_update_autorise, *_delete_proprietaire) couvrent déjà
-- la modification des informations générales du groupe et la suppression
-- d'un groupe/membre : aucune nouvelle policy n'est nécessaire ici.
-- =============================================================================

alter table public.membres_groupe_uniforme
  add column if not exists tenue_terminee boolean not null default false;
