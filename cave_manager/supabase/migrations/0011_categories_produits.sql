-- ============================================================================
-- Phase 2 (suite) — Catégories de produits + catalogue de démarrage
--
-- Demande : organiser les boissons par type/catégorie (Bières, Sucreries,
-- Vins rouges/blancs/rosés/marocains, Vins non alcoolisés), avec la
-- possibilité d'ajouter/supprimer des catégories et des boissons, ou de
-- masquer celles qu'on ne veut pas.
--
-- Les catégories sont une table par cave, pas un enum fermé : l'utilisateur
-- doit pouvoir en ajouter lui-même, sans dépendre d'une nouvelle migration.
-- Le "masquage" et la suppression d'un produit existent déjà (`actif`, et
-- delete sur `produits`) ; cette migration ajoute l'équivalent pour les
-- catégories.
-- ============================================================================

create table public.categories_produits (
  id uuid primary key default gen_random_uuid(),
  cave_id uuid not null references public.caves(id) on delete cascade,
  nom text not null check (char_length(trim(nom)) > 0),
  ordre integer not null default 0,
  visible boolean not null default true,
  created_at timestamptz not null default now(),
  unique (cave_id, nom)
);

comment on table public.categories_produits is 'Catégories de boissons (Bières, Vins rouges, ...), propres à chaque cave et personnalisables (ajout, suppression si vide, masquage) — remplace un enum fermé pour permettre à l''utilisateur d''en ajouter sans migration.';

alter table public.categories_produits enable row level security;

grant select, insert, update, delete on public.categories_produits to authenticated;

-- Lecture ouverte à tous les membres de la cave (comme produits_select) :
-- même l'Agent de vente doit voir les catégories pour naviguer le
-- catalogue ; seule leur gestion (créer/modifier/supprimer/masquer) est
-- réservée à Propriétaire/Propriétaire-Gérant/Gérant.
create policy categories_produits_select on public.categories_produits
  for select using (cave_id = public.current_cave_id());

create policy categories_produits_write on public.categories_produits
  for all using (cave_id = public.current_cave_id() and public.is_responsable())
  with check (cave_id = public.current_cave_id() and public.is_responsable());

-- produits.categorie_id : chaque produit appartient à une catégorie.
-- on delete restrict : on ne doit jamais pouvoir supprimer une catégorie
-- encore utilisée par un produit — le masquage (visible=false) est le bon
-- outil pour "je ne veux plus voir cette catégorie", pas la suppression,
-- qui reste réservée aux catégories vides.
alter table public.produits
  add column categorie_id uuid references public.categories_produits(id) on delete restrict;

comment on column public.produits.categorie_id is 'Catégorie de ce produit (Bières, Vins rouges, ...) — voir categories_produits.';

-- ----------------------------------------------------------------------------
-- Pour chaque cave déjà existante : une catégorie "Autres" pour les
-- produits déjà créés avant cette migration (ex. un produit de test créé
-- sans catégorie), puis le catalogue de démarrage demandé (catégories +
-- boissons courantes au Burkina Faso). L'utilisateur peut ensuite
-- supprimer/masquer ce qu'il ne vend pas, ou ajouter d'autres boissons et
-- catégories. Les prix sont laissés à 0 (valeur par défaut de
-- prix_vente_detail/gros) : à renseigner ensuite via "Modifier le
-- produit", comme n'importe quel produit créé manuellement.
-- ----------------------------------------------------------------------------
do $$
declare
  v_cave_id uuid;
  v_cat_autres uuid;
  v_cat_id uuid;
begin
  for v_cave_id in select id from public.caves loop

    insert into public.categories_produits (cave_id, nom, ordre)
    values (v_cave_id, 'Autres', 99)
    returning id into v_cat_autres;

    update public.produits
      set categorie_id = v_cat_autres
      where cave_id = v_cave_id and categorie_id is null;

    insert into public.categories_produits (cave_id, nom, ordre) values (v_cave_id, 'Bières', 1) returning id into v_cat_id;
    insert into public.produits (cave_id, nom, categorie_id)
    select v_cave_id, b.nom, v_cat_id
    from unnest(array['Brakina','Flag','Guinness','Beaufort','Castel','Dopel','Tekila','Braf''or','Sobbra','Brafaso','Libs']) as b(nom);

    insert into public.categories_produits (cave_id, nom, ordre) values (v_cave_id, 'Sucreries', 2) returning id into v_cat_id;
    insert into public.produits (cave_id, nom, categorie_id)
    select v_cave_id, b.nom, v_cat_id
    from unnest(array['Coca-Cola','Fanta','Sprite','Youki','Planet','Dafani','Malia']) as b(nom);

    insert into public.categories_produits (cave_id, nom, ordre) values (v_cave_id, 'Vins rouges', 3) returning id into v_cat_id;
    insert into public.produits (cave_id, nom, categorie_id)
    select v_cave_id, b.nom, v_cat_id
    from unnest(array['Vieux Papes Rouge','JP. Chenet Rouge','Baron de Lestac Rouge','Calvet Rouge','Cellier des Dauphins Rouge','Nederburg Rouge','Kumala Rouge','Robertson Winery Rouge','Le Grand Noir (bag-in-box)']) as b(nom);

    insert into public.categories_produits (cave_id, nom, ordre) values (v_cave_id, 'Vins blancs', 4) returning id into v_cat_id;
    insert into public.produits (cave_id, nom, categorie_id)
    select v_cave_id, b.nom, v_cat_id
    from unnest(array['Vieux Papes Blanc','JP. Chenet Blanc','Baron de Lestac Blanc','Nederburg Blanc','Two Oceans Blanc']) as b(nom);

    insert into public.categories_produits (cave_id, nom, ordre) values (v_cave_id, 'Vins rosés', 5) returning id into v_cat_id;
    insert into public.produits (cave_id, nom, categorie_id)
    select v_cave_id, b.nom, v_cat_id
    from unnest(array['Vieux Papes Rosé','JP. Chenet Rosé','Listel Rosé','Drostdy-Hof Rosé']) as b(nom);

    insert into public.categories_produits (cave_id, nom, ordre) values (v_cave_id, 'Vins marocains', 6) returning id into v_cat_id;
    insert into public.produits (cave_id, nom, categorie_id)
    select v_cave_id, b.nom, v_cat_id
    from unnest(array['Médaillon (rouge/rosé)','Guerrouane (rouge/gris)','Chaud Soleil (rosé)']) as b(nom);

    insert into public.categories_produits (cave_id, nom, ordre) values (v_cave_id, 'Vins non alcoolisés', 7) returning id into v_cat_id;
    insert into public.produits (cave_id, nom, categorie_id)
    select v_cave_id, b.nom, v_cat_id
    from unnest(array['Vintense','Pierre Chavin','Les Ormes de Cambras','Grain d''Envie','Eisberg']) as b(nom);

  end loop;
end $$;

alter table public.produits alter column categorie_id set not null;
