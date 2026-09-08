-- =============================================================================
-- Atelier+ — Gabarits par défaut (Homme / Femme)
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase, après schema.sql. Ce
-- script est idempotent : le réexécuter ne duplique pas les gabarits déjà
-- présents (vérification par nom + sexe avant chaque insertion).
--
-- Chaque gabarit sélectionne un sous-ensemble de la bibliothèque de champs
-- de mesure définie dans le cahier des charges (une même mesure peut être
-- réutilisée par plusieurs gabarits — c'est le même champ conceptuel, mais
-- chaque gabarit en garde sa propre ligne `champs_mesure`, car un champ
-- peut être masqué gabarit par gabarit indépendamment).
--
-- `atelier_id` reste NULL : ce sont des gabarits "de premier niveau" (voir
-- décision 4 de schema.sql), visibles par tous les ateliers, non
-- modifiables depuis le client.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- HOMME
-- -----------------------------------------------------------------------------

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Costume' and sexe = 'Homme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Costume', 'Homme') returning id into v_id;
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
      (v_id, 'Bas', 'cm', 15);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Boubou complet' and sexe = 'Homme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Boubou complet', 'Homme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Dos', 'cm', 1),
      (v_id, 'Épaule', 'cm', 2),
      (v_id, 'Poitrine', 'cm', 3),
      (v_id, 'Longueur chemise', 'cm', 4),
      (v_id, 'Tour de taille', 'cm', 5),
      (v_id, 'Bassin', 'cm', 6),
      (v_id, 'Longueur manche', 'cm', 7),
      (v_id, 'Tour de manche', 'cm', 8),
      (v_id, 'Longueur pantalon', 'cm', 9),
      (v_id, 'Bas', 'cm', 10),
      (v_id, 'Nombre de tenues', null, 11);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Tunique' and sexe = 'Homme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Tunique', 'Homme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Poitrine', 'cm', 1),
      (v_id, 'Dos', 'cm', 2),
      (v_id, 'Épaule', 'cm', 3),
      (v_id, 'Tunique', 'cm', 4),
      (v_id, 'Longueur manche', 'cm', 5),
      (v_id, 'Tour de manche', 'cm', 6);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Chemise' and sexe = 'Homme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Chemise', 'Homme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Dos', 'cm', 1),
      (v_id, 'Épaule', 'cm', 2),
      (v_id, 'Poitrine', 'cm', 3),
      (v_id, 'Tour de taille', 'cm', 4),
      (v_id, 'Longueur manche', 'cm', 5),
      (v_id, 'Tour de manche', 'cm', 6),
      (v_id, 'Poignet', 'cm', 7),
      (v_id, 'Longueur chemise', 'cm', 8),
      (v_id, 'Cou', 'cm', 9);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Pantalon' and sexe = 'Homme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Pantalon', 'Homme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Tour de taille', 'cm', 1),
      (v_id, 'Hauteur de taille', 'cm', 2),
      (v_id, 'Bassin', 'cm', 3),
      (v_id, 'Cuisse', 'cm', 4),
      (v_id, 'Longueur pantalon', 'cm', 5),
      (v_id, 'Longueur genoux', 'cm', 6),
      (v_id, 'Bas', 'cm', 7),
      (v_id, 'Ceinture', 'cm', 8);
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- FEMME
-- -----------------------------------------------------------------------------

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Robe' and sexe = 'Femme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Robe', 'Femme') returning id into v_id;
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
      (v_id, 'Cuisse', 'cm', 11);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Tunique' and sexe = 'Femme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Tunique', 'Femme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Épaule', 'cm', 1),
      (v_id, 'Poitrine', 'cm', 2),
      (v_id, 'Longueur manche', 'cm', 3),
      (v_id, 'Tour de manche', 'cm', 4),
      (v_id, 'Longueur camisole', 'cm', 5),
      (v_id, 'Tour de taille', 'cm', 6),
      (v_id, 'Col', 'cm', 7);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Demi-boubou' and sexe = 'Femme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Demi-boubou', 'Femme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Épaule', 'cm', 1),
      (v_id, 'Poitrine', 'cm', 2),
      (v_id, 'Longueur manche', 'cm', 3),
      (v_id, 'Tour de manche', 'cm', 4),
      (v_id, 'Longueur camisole', 'cm', 5),
      (v_id, 'Tour de taille', 'cm', 6),
      (v_id, 'Bassin', 'cm', 7),
      (v_id, 'Frappe', 'cm', 8);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Mini-jupe' and sexe = 'Femme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Mini-jupe', 'Femme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Tour de taille', 'cm', 1),
      (v_id, 'Bassin', 'cm', 2),
      (v_id, 'Longueur jupe', 'cm', 3);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Jupe longue' and sexe = 'Femme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Jupe longue', 'Femme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Tour de taille', 'cm', 1),
      (v_id, 'Bassin', 'cm', 2),
      (v_id, 'Cuisse', 'cm', 3),
      (v_id, 'Longueur jupe', 'cm', 4),
      (v_id, 'Genoux', 'cm', 5);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Boubou complet' and sexe = 'Femme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Boubou complet', 'Femme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Épaule', 'cm', 1),
      (v_id, 'Poitrine', 'cm', 2),
      (v_id, 'Longueur manche', 'cm', 3),
      (v_id, 'Tour de manche', 'cm', 4),
      (v_id, 'Longueur robe', 'cm', 5),
      (v_id, 'Tour de taille', 'cm', 6),
      (v_id, 'Bassin', 'cm', 7),
      (v_id, 'Longueur pantalon', 'cm', 8),
      (v_id, 'Nombre de pagnes ou tissus déposés', null, 9);
  end if;
end $$;

do $$
declare v_id uuid;
begin
  if not exists (select 1 from public.types_tenue where nom = 'Pagne deux-pièces' and sexe = 'Femme' and atelier_id is null) then
    insert into public.types_tenue (nom, sexe) values ('Pagne deux-pièces', 'Femme') returning id into v_id;
    insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
      (v_id, 'Épaule', 'cm', 1),
      (v_id, 'Poitrine', 'cm', 2),
      (v_id, 'Longueur manche', 'cm', 3),
      (v_id, 'Tour de manche', 'cm', 4),
      (v_id, 'Longueur camisole', 'cm', 5),
      (v_id, 'Tour de taille', 'cm', 6),
      (v_id, 'Bassin', 'cm', 7),
      (v_id, 'Longueur jupe', 'cm', 8),
      (v_id, 'Nombre de pagnes ou tissus déposés', null, 9);
  end if;
end $$;
