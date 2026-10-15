-- =============================================================================
-- ATELIER+ — Gabarits par défaut (Phase 2)
-- =============================================================================
-- À exécuter après schema.sql. Idempotent : rejouable sans dupliquer les
-- lignes (identifiants de types_tenue fixés en dur + index unique sur
-- champs_mesure(type_tenue_id, nom)).
--
-- Ces gabarits ont atelier_id = NULL : visibles en lecture par tous les
-- ateliers (politique types_tenue_select), non modifiables depuis un
-- atelier (politique types_tenue_update exige atelier_id = mon_atelier_id(),
-- donc jamais vrai pour une ligne NULL). Un atelier qui veut personnaliser
-- un gabarit par défaut doit le DUPLIQUER (voir EcranGestionTypesTenue,
-- Phase 2) plutôt que le modifier.
-- =============================================================================

-- Index unique nécessaire pour l'idempotence des INSERT ... ON CONFLICT
-- ci-dessous sur champs_mesure.
create unique index if not exists ux_champs_mesure_type_nom
  on public.champs_mesure (type_tenue_id, nom);

-- -----------------------------------------------------------------------------
-- Types de tenue par défaut
-- -----------------------------------------------------------------------------
insert into public.types_tenue (id, atelier_id, nom, sexe) values
  ('a0000000-0000-0000-0000-000000000001', null, 'Robe', 'femme'),
  ('a0000000-0000-0000-0000-000000000002', null, 'Tunique', 'femme'),
  ('a0000000-0000-0000-0000-000000000003', null, 'Demi-boubou', 'femme'),
  ('a0000000-0000-0000-0000-000000000004', null, 'Mini-jupe', 'femme'),
  ('a0000000-0000-0000-0000-000000000005', null, 'Jupe longue', 'femme'),
  ('a0000000-0000-0000-0000-000000000006', null, 'Boubou complet', 'femme'),
  ('a0000000-0000-0000-0000-000000000007', null, 'Pagne deux-pièces', 'femme'),
  ('a0000000-0000-0000-0000-000000000008', null, 'Costume', 'homme'),
  ('a0000000-0000-0000-0000-000000000009', null, 'Boubou complet', 'homme'),
  ('a0000000-0000-0000-0000-00000000000a', null, 'Tunique', 'homme'),
  ('a0000000-0000-0000-0000-00000000000b', null, 'Chemise', 'homme'),
  ('a0000000-0000-0000-0000-00000000000c', null, 'Pantalon', 'homme')
on conflict (id) do nothing;

-- -----------------------------------------------------------------------------
-- Champs de mesure — Femme
-- -----------------------------------------------------------------------------

-- Robe
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000001', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000001', 'Tour de taille', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000001', 'Tour de bassin', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000001', 'Hauteur poitrine', 'cm', 4),
  ('a0000000-0000-0000-0000-000000000001', 'Largeur épaule', 'cm', 5),
  ('a0000000-0000-0000-0000-000000000001', 'Tour de cou', 'cm', 6),
  ('a0000000-0000-0000-0000-000000000001', 'Longueur manche', 'cm', 7),
  ('a0000000-0000-0000-0000-000000000001', 'Tour de bras', 'cm', 8),
  ('a0000000-0000-0000-0000-000000000001', 'Longueur robe', 'cm', 9)
on conflict (type_tenue_id, nom) do nothing;

-- Tunique (femme)
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000002', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000002', 'Tour de taille', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000002', 'Tour de bassin', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000002', 'Largeur épaule', 'cm', 4),
  ('a0000000-0000-0000-0000-000000000002', 'Tour de cou', 'cm', 5),
  ('a0000000-0000-0000-0000-000000000002', 'Longueur manche', 'cm', 6),
  ('a0000000-0000-0000-0000-000000000002', 'Tour de bras', 'cm', 7),
  ('a0000000-0000-0000-0000-000000000002', 'Longueur tunique', 'cm', 8)
on conflict (type_tenue_id, nom) do nothing;

-- Demi-boubou
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000003', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000003', 'Tour de bassin', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000003', 'Largeur épaule', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000003', 'Tour de cou', 'cm', 4),
  ('a0000000-0000-0000-0000-000000000003', 'Longueur manche', 'cm', 5),
  ('a0000000-0000-0000-0000-000000000003', 'Tour de bras', 'cm', 6),
  ('a0000000-0000-0000-0000-000000000003', 'Longueur demi-boubou', 'cm', 7)
on conflict (type_tenue_id, nom) do nothing;

-- Mini-jupe
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000004', 'Tour de taille', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000004', 'Tour de bassin', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000004', 'Tour de cuisse', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000004', 'Longueur jupe', 'cm', 4)
on conflict (type_tenue_id, nom) do nothing;

-- Jupe longue
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000005', 'Tour de taille', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000005', 'Tour de bassin', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000005', 'Tour de cuisse', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000005', 'Longueur jupe', 'cm', 4),
  ('a0000000-0000-0000-0000-000000000005', 'Ouverture bas', 'cm', 5)
on conflict (type_tenue_id, nom) do nothing;

-- Boubou complet (femme)
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000006', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000006', 'Tour de bassin', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000006', 'Largeur épaule', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000006', 'Tour de cou', 'cm', 4),
  ('a0000000-0000-0000-0000-000000000006', 'Longueur manche', 'cm', 5),
  ('a0000000-0000-0000-0000-000000000006', 'Tour de bras', 'cm', 6),
  ('a0000000-0000-0000-0000-000000000006', 'Longueur boubou', 'cm', 7)
on conflict (type_tenue_id, nom) do nothing;

-- Pagne deux-pièces
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000007', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000007', 'Tour de taille', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000007', 'Tour de bassin', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000007', 'Longueur haut', 'cm', 4),
  ('a0000000-0000-0000-0000-000000000007', 'Longueur manche', 'cm', 5),
  ('a0000000-0000-0000-0000-000000000007', 'Tour de cuisse', 'cm', 6),
  ('a0000000-0000-0000-0000-000000000007', 'Longueur pagne', 'cm', 7)
on conflict (type_tenue_id, nom) do nothing;

-- -----------------------------------------------------------------------------
-- Champs de mesure — Homme
-- -----------------------------------------------------------------------------

-- Costume
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000008', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000008', 'Tour de taille', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000008', 'Tour de bassin', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000008', 'Largeur épaule', 'cm', 4),
  ('a0000000-0000-0000-0000-000000000008', 'Tour de cou', 'cm', 5),
  ('a0000000-0000-0000-0000-000000000008', 'Longueur veste', 'cm', 6),
  ('a0000000-0000-0000-0000-000000000008', 'Longueur manche', 'cm', 7),
  ('a0000000-0000-0000-0000-000000000008', 'Tour de bras', 'cm', 8),
  ('a0000000-0000-0000-0000-000000000008', 'Longueur pantalon', 'cm', 9),
  ('a0000000-0000-0000-0000-000000000008', 'Tour de cuisse', 'cm', 10),
  ('a0000000-0000-0000-0000-000000000008', 'Tour de genou', 'cm', 11),
  ('a0000000-0000-0000-0000-000000000008', 'Ouverture bas pantalon', 'cm', 12)
on conflict (type_tenue_id, nom) do nothing;

-- Boubou complet (homme)
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-000000000009', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-000000000009', 'Tour de bassin', 'cm', 2),
  ('a0000000-0000-0000-0000-000000000009', 'Largeur épaule', 'cm', 3),
  ('a0000000-0000-0000-0000-000000000009', 'Tour de cou', 'cm', 4),
  ('a0000000-0000-0000-0000-000000000009', 'Longueur manche', 'cm', 5),
  ('a0000000-0000-0000-0000-000000000009', 'Tour de bras', 'cm', 6),
  ('a0000000-0000-0000-0000-000000000009', 'Longueur boubou', 'cm', 7),
  ('a0000000-0000-0000-0000-000000000009', 'Tour de taille (pantalon)', 'cm', 8),
  ('a0000000-0000-0000-0000-000000000009', 'Longueur pantalon', 'cm', 9)
on conflict (type_tenue_id, nom) do nothing;

-- Tunique (homme)
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-00000000000a', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-00000000000a', 'Tour de taille', 'cm', 2),
  ('a0000000-0000-0000-0000-00000000000a', 'Largeur épaule', 'cm', 3),
  ('a0000000-0000-0000-0000-00000000000a', 'Tour de cou', 'cm', 4),
  ('a0000000-0000-0000-0000-00000000000a', 'Longueur manche', 'cm', 5),
  ('a0000000-0000-0000-0000-00000000000a', 'Tour de bras', 'cm', 6),
  ('a0000000-0000-0000-0000-00000000000a', 'Longueur tunique', 'cm', 7)
on conflict (type_tenue_id, nom) do nothing;

-- Chemise
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-00000000000b', 'Tour de poitrine', 'cm', 1),
  ('a0000000-0000-0000-0000-00000000000b', 'Tour de taille', 'cm', 2),
  ('a0000000-0000-0000-0000-00000000000b', 'Largeur épaule', 'cm', 3),
  ('a0000000-0000-0000-0000-00000000000b', 'Tour de cou', 'cm', 4),
  ('a0000000-0000-0000-0000-00000000000b', 'Longueur manche', 'cm', 5),
  ('a0000000-0000-0000-0000-00000000000b', 'Tour de bras', 'cm', 6),
  ('a0000000-0000-0000-0000-00000000000b', 'Tour de poignet', 'cm', 7),
  ('a0000000-0000-0000-0000-00000000000b', 'Longueur chemise', 'cm', 8)
on conflict (type_tenue_id, nom) do nothing;

-- Pantalon
insert into public.champs_mesure (type_tenue_id, nom, unite, ordre) values
  ('a0000000-0000-0000-0000-00000000000c', 'Tour de taille', 'cm', 1),
  ('a0000000-0000-0000-0000-00000000000c', 'Tour de bassin', 'cm', 2),
  ('a0000000-0000-0000-0000-00000000000c', 'Tour de cuisse', 'cm', 3),
  ('a0000000-0000-0000-0000-00000000000c', 'Tour de genou', 'cm', 4),
  ('a0000000-0000-0000-0000-00000000000c', 'Longueur pantalon', 'cm', 5),
  ('a0000000-0000-0000-0000-00000000000c', 'Ouverture bas', 'cm', 6)
on conflict (type_tenue_id, nom) do nothing;
