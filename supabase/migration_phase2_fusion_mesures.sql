-- =============================================================================
-- Atelier+ — Migration : fusion des gabarits en une seule liste de mesures
-- par sexe (plus de choix de "type de tenue")
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase, sur un projet où
-- l'ancienne version de supabase/seed_gabarits.sql (un gabarit par
-- vêtement : Costume, Boubou, Tunique, Chemise, Pantalon, Robe...) a déjà
-- été exécutée. Sans effet si déjà appliquée (idempotent) : rejouer ce
-- script ne duplique rien.
--
-- Supprime les anciens gabarits par défaut (et leurs champs de mesure,
-- supprimés en cascade) puis recrée les deux gabarits fusionnés — voir
-- supabase/seed_gabarits.sql pour le contenu à jour.
-- =============================================================================

delete from public.types_tenue
where atelier_id is null
  and nom <> 'Toutes les mesures';

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

-- Vérification : doit afficher exactement 2 lignes (une par sexe).
select nom, sexe from public.types_tenue where atelier_id is null;
