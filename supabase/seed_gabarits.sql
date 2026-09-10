-- =============================================================================
-- Atelier+ — Gabarits par défaut (Homme / Femme)
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase, après schema.sql. Ce
-- script est idempotent : le réexécuter ne duplique pas les gabarits déjà
-- présents (vérification par nom + sexe avant chaque insertion).
--
-- Un seul gabarit par sexe, réunissant l'ensemble de la bibliothèque de
-- champs de mesure. La section "Mesures" du formulaire propose directement
-- ces champs dès que le sexe du client est renseigné, sans étape de
-- sélection.
--
-- Liste et ordre des champs fournis par l'atelier (voir
-- supabase/migration_phase3_nouveaux_champs_mesure.sql pour la mise à jour
-- d'un projet où l'ancienne liste a déjà été exécutée).
--
-- `atelier_id` reste NULL : ce sont des gabarits "de premier niveau" (voir
-- décision 4 de schema.sql), visibles par tous les ateliers. Un tailleur
-- peut masquer un champ ou en ajouter un personnalisé depuis l'application
-- (voir GabaritRepository.assurerGabaritPersonnalise) — ça crée alors une
-- copie de ce gabarit propre à son atelier, sans toucher à celui-ci.
-- =============================================================================

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Toutes les mesures' and sexe = 'Homme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Toutes les mesures', 'Homme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Dos', 'cm', 1),
      (v_id, 'Épaule', 'cm', 2),
      (v_id, 'Poitrine', 'cm', 3),
      (v_id, 'Hauteur de taille', 'cm', 4),
      (v_id, 'Long. Manche', 'cm', 5),
      (v_id, 'Poignet', 'cm', 6),
      (v_id, 'Tour de manche', 'cm', 7),
      (v_id, 'Tour de taille', 'cm', 8),
      (v_id, 'Long. Chemise', 'cm', 9),
      (v_id, 'Long. Veste', 'cm', 10),
      (v_id, 'Long. Tunique', 'cm', 11),
      (v_id, 'Tour de Cou', 'cm', 12),
      (v_id, 'Bonnet', 'cm', 13),
      (v_id, 'Ceinture', 'cm', 14),
      (v_id, 'Bassin', 'cm', 15),
      (v_id, 'Cuisse', 'cm', 16),
      (v_id, 'Long. Pantalon', 'cm', 17),
      (v_id, 'Long. Genoux', 'cm', 18),
      (v_id, 'Tour de mollet', 'cm', 19),
      (v_id, 'Bas', 'cm', 20);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Toutes les mesures' and sexe = 'Femme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Toutes les mesures', 'Femme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Épaule', 'cm', 1),
      (v_id, 'Poitrine', 'cm', 2),
      (v_id, 'Tour de taille', 'cm', 3),
      (v_id, 'Long. Taille', 'cm', 4),
      (v_id, 'Long. Manche', 'cm', 5),
      (v_id, 'Tour manche', 'cm', 6),
      (v_id, 'Col', 'cm', 7),
      (v_id, 'Long. Habit', 'cm', 8),
      (v_id, 'Long. Sein', 'cm', 9),
      (v_id, 'Pinces', 'cm', 10),
      (v_id, 'Long. Camisole', 'cm', 11),
      (v_id, 'Long. Robe', 'cm', 12),
      (v_id, 'Frappe', 'cm', 13),
      (v_id, 'Long. Chemise', 'cm', 14),
      (v_id, 'Ceinture', 'cm', 15),
      (v_id, 'Bassin', 'cm', 16),
      (v_id, 'Cuisse', 'cm', 17),
      (v_id, 'Long. Genoux', 'cm', 18),
      (v_id, 'Long. Jupe', 'cm', 19),
      (v_id, 'Poignet', 'cm', 20),
      (v_id, 'Long. Pantalon', 'cm', 21),
      (v_id, 'Bas', 'cm', 22),
      (v_id, 'Long. Tunique', 'cm', 23);
  end if;
end $$;
