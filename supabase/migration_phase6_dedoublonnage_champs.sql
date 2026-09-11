-- =============================================================================
-- Atelier+ — Migration Phase 6 : suppression des champs de mesure en double
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase.
--
-- Un même champ (même gabarit `type_tenue_id`, même nom à la casse et aux
-- espaces près) pouvait apparaître deux fois — par exemple en ajoutant un
-- champ personnalisé qui existait déjà (corrigé côté application,
-- GabaritRepository.ajouterChamp empêche maintenant ce cas). Ne garde que
-- la ligne la plus ancienne pour chaque doublon ; sans conséquence sur les
-- mesures déjà enregistrées, qui ne référencent jamais un champ par son
-- identifiant mais par son nom (voir section_mesures.dart).
--
-- Une fois exécuté ici, le cache local de chaque appareil se nettoie tout
-- seul à la prochaine connexion (voir
-- GabaritRepository.nettoyerChampsDupliques, appelée à chaque
-- synchronisation des gabarits).
-- =============================================================================

delete from public.champs_mesure a
using public.champs_mesure b
where lower(trim(a.nom)) = lower(trim(b.nom))
  and a.type_tenue_id = b.type_tenue_id
  and (a.created_at, a.id) > (b.created_at, b.id);
