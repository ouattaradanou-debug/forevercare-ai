-- =============================================================================
-- Atelier+ — Gabarits par défaut (Homme / Femme)
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase, après schema.sql. Ce
-- script est idempotent : le réexécuter ne duplique pas les gabarits déjà
-- présents (vérification par nom + sexe avant chaque insertion).
--
-- Décision (correctif) : plus de choix de "type de tenue" dans le
-- formulaire client — un seul gabarit par sexe, réunissant l'ensemble de
-- la bibliothèque de champs de mesure (fusion des anciens gabarits par
-- vêtement : Costume, Boubou, Tunique, Chemise, Pantalon, Robe...). La
-- section "Mesures" du formulaire propose directement ces champs dès que
-- le sexe du client est renseigné, sans étape de sélection.
--
-- `atelier_id` reste NULL : ce sont des gabarits "de premier niveau" (voir
-- décision 4 de schema.sql), visibles par tous les ateliers, non
-- modifiables depuis le client.
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
      (v_id, 'Tour de taille', 'cm', 5),
      (v_id, 'Longueur manche', 'cm', 6),
      (v_id, 'Tour de manche', 'cm', 7),
      (v_id, 'Poignet', 'cm', 8),
      (v_id, 'Cou', 'cm', 9),
      (v_id, 'Longueur veste', 'cm', 10),
      (v_id, 'Bassin', 'cm', 11),
      (v_id, 'Cuisse', 'cm', 12),
      (v_id, 'Longueur pantalon', 'cm', 13),
      (v_id, 'Longueur genoux', 'cm', 14),
      (v_id, 'Bas', 'cm', 15),
      (v_id, 'Longueur chemise', 'cm', 16),
      (v_id, 'Nombre de tenues', null, 17),
      (v_id, 'Tunique', 'cm', 18),
      (v_id, 'Ceinture', 'cm', 19);
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
      (v_id, 'Longueur manche', 'cm', 3),
      (v_id, 'Tour de manche', 'cm', 4),
      (v_id, 'Longueur taille', 'cm', 5),
      (v_id, 'Col', 'cm', 6),
      (v_id, 'Tour de taille', 'cm', 7),
      (v_id, 'Pinces', 'cm', 8),
      (v_id, 'Longueur robe', 'cm', 9),
      (v_id, 'Bassin', 'cm', 10),
      (v_id, 'Cuisse', 'cm', 11),
      (v_id, 'Longueur camisole', 'cm', 12),
      (v_id, 'Frappe', 'cm', 13),
      (v_id, 'Longueur jupe', 'cm', 14),
      (v_id, 'Genoux', 'cm', 15),
      (v_id, 'Longueur pantalon', 'cm', 16),
      (v_id, 'Nombre de pagnes ou tissus déposés', null, 17);
  end if;
end $$;
