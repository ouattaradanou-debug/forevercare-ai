-- =============================================================================
-- Atelier+ — Migration Phase 3 : nouvelle liste de champs de mesure
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase, sur un projet où
-- seed_gabarits.sql a déjà été exécuté avec l'ANCIENNE liste de champs.
--
-- Remplace le contenu des gabarits par défaut (Homme / Femme, atelier_id
-- NULL) par la nouvelle liste et le nouvel ordre demandés par l'atelier.
-- Les lignes `types_tenue` elles-mêmes ne sont PAS supprimées ni
-- recréées : seul leur `id` doit rester stable (des `mesures` existantes
-- y font peut-être déjà référence via `type_tenue_id`). Seuls leurs
-- `champs_mesure` sont remplacés.
--
-- Effet de bord attendu et accepté : toute valeur de mesure déjà
-- enregistrée sous un nom de champ qui disparaît ou change (ex. "Long.
-- Chemise " -> "Long. Chemise") reste présente telle quelle dans
-- `mesures.valeurs` (rien n'y est jamais modifié par ce script), mais ne
-- s'affichera plus sous aucun champ actuel puisque l'application
-- retrouve chaque valeur par le NOM du champ (voir section_mesures.dart).
-- =============================================================================

do $$
declare v_id_homme uuid;
declare v_id_femme uuid;
begin
  select id into v_id_homme from public.types_tenue
    where nom = 'Toutes les mesures' and sexe = 'Homme' and atelier_id is null;
  select id into v_id_femme from public.types_tenue
    where nom = 'Toutes les mesures' and sexe = 'Femme' and atelier_id is null;

  if v_id_homme is null or v_id_femme is null then
    raise exception 'Gabarit(s) par défaut introuvable(s) : exécute d''abord seed_gabarits.sql.';
  end if;

  delete from public.champs_mesure where type_tenue_id = v_id_homme;
  insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
    (v_id_homme, 'Dos', 'cm', 1),
    (v_id_homme, 'Épaule', 'cm', 2),
    (v_id_homme, 'Poitrine', 'cm', 3),
    (v_id_homme, 'Hauteur de taille', 'cm', 4),
    (v_id_homme, 'Long. Manche', 'cm', 5),
    (v_id_homme, 'Poignet', 'cm', 6),
    (v_id_homme, 'Tour de manche', 'cm', 7),
    (v_id_homme, 'Tour de taille', 'cm', 8),
    (v_id_homme, 'Long. Chemise', 'cm', 9),
    (v_id_homme, 'Long. Veste', 'cm', 10),
    (v_id_homme, 'Long. Tunique', 'cm', 11),
    (v_id_homme, 'Tour de Cou', 'cm', 12),
    (v_id_homme, 'Bonnet', 'cm', 13),
    (v_id_homme, 'Ceinture', 'cm', 14),
    (v_id_homme, 'Bassin', 'cm', 15),
    (v_id_homme, 'Cuisse', 'cm', 16),
    (v_id_homme, 'Long. Pantalon', 'cm', 17),
    (v_id_homme, 'Long. Genoux', 'cm', 18),
    (v_id_homme, 'Tour de mollet', 'cm', 19),
    (v_id_homme, 'Bas', 'cm', 20);

  delete from public.champs_mesure where type_tenue_id = v_id_femme;
  insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
    (v_id_femme, 'Épaule', 'cm', 1),
    (v_id_femme, 'Poitrine', 'cm', 2),
    (v_id_femme, 'Tour de taille', 'cm', 3),
    (v_id_femme, 'Long. Taille', 'cm', 4),
    (v_id_femme, 'Long. Manche', 'cm', 5),
    (v_id_femme, 'Tour manche', 'cm', 6),
    (v_id_femme, 'Col', 'cm', 7),
    (v_id_femme, 'Long. Habit', 'cm', 8),
    (v_id_femme, 'Long. Sein', 'cm', 9),
    (v_id_femme, 'Pinces', 'cm', 10),
    (v_id_femme, 'Long. Camisole', 'cm', 11),
    (v_id_femme, 'Long. Robe', 'cm', 12),
    (v_id_femme, 'Frappe', 'cm', 13),
    (v_id_femme, 'Long. Chemise', 'cm', 14),
    (v_id_femme, 'Ceinture', 'cm', 15),
    (v_id_femme, 'Bassin', 'cm', 16),
    (v_id_femme, 'Cuisse', 'cm', 17),
    (v_id_femme, 'Long. Genoux', 'cm', 18),
    (v_id_femme, 'Long. Jupe', 'cm', 19),
    (v_id_femme, 'Poignet', 'cm', 20),
    (v_id_femme, 'Long. Pantalon', 'cm', 21),
    (v_id_femme, 'Bas', 'cm', 22),
    (v_id_femme, 'Long. Tunique', 'cm', 23);
end $$;
