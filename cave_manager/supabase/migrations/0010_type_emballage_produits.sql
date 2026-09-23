-- Ajoute le type d'emballage (carton ou casier) au catalogue produits, sur
-- demande explicite : à la création d'un produit, on choisit son type
-- d'emballage, et le stock s'exprime ensuite en nombre d'emballages
-- (cartons OU casiers selon le produit) + un reliquat en bouteilles qui
-- n'atteint pas un emballage complet. Le mécanisme de stock existant
-- (quantite_cartons/quantite_bouteilles, mouvements_stock) reste
-- inchangé : c'était déjà exactement cette logique, seul l'intitulé
-- affiché ("carton" en dur) doit maintenant dépendre du produit.

create type public.type_emballage as enum ('carton', 'casier');

-- La colonne bouteilles_par_carton (migration 0007) est renommée : son nom
-- mentionnait "carton" alors qu'elle s'applique aussi bien à un casier.
-- Un rename de colonne Postgres conserve les données et la contrainte
-- check existante (bouteilles_par_carton > 0).
alter table public.produits rename column bouteilles_par_carton to bouteilles_par_emballage;

alter table public.produits
  add column type_emballage public.type_emballage not null default 'carton';

comment on column public.produits.type_emballage is 'Type d''emballage de ce produit (carton ou casier) : détermine le libellé affiché pour bouteilles_par_emballage et pour le stock correspondant.';
comment on column public.produits.bouteilles_par_emballage is 'Nombre de bouteilles dans un emballage (carton ou casier, voir type_emballage) de ce produit.';
