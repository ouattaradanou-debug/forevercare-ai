-- Le Gérant doit pouvoir créer et modifier des produits (nom, prix de
-- vente, bouteilles/carton), au même titre que le Propriétaire et le
-- Propriétaire/Gérant. Seul le prix d'achat (table séparée
-- `produits_couts`, policy `produits_couts_write` inchangée) reste
-- réservé à Propriétaire/Propriétaire-Gérant (`is_admin()`) : le Gérant ne
-- doit jamais le voir ni le modifier (point 18 du cahier des charges).
--
-- On remplace donc uniquement `is_admin()` par `is_responsable()` sur la
-- policy d'écriture de `produits` (déjà utilisée à l'identique pour
-- `caves_update` en migration 0003).

drop policy if exists produits_write on public.produits;

create policy produits_write on public.produits
  for all using (cave_id = public.current_cave_id() and public.is_responsable())
  with check (cave_id = public.current_cave_id() and public.is_responsable());
