-- Le Gérant doit pouvoir enregistrer, voir et modifier le prix d'achat.
-- Ceci remplace la restriction "admin only" posée en migration 0007
-- (point 18 du cahier des charges) : seul l'Agent de vente reste exclu de
-- `produits_couts`, le Gérant y a désormais le même accès que le
-- Propriétaire/Propriétaire-Gérant.

drop policy if exists produits_couts_select on public.produits_couts;
drop policy if exists produits_couts_write on public.produits_couts;

create policy produits_couts_select on public.produits_couts
  for select using (cave_id = public.current_cave_id() and public.is_responsable());

create policy produits_couts_write on public.produits_couts
  for all using (cave_id = public.current_cave_id() and public.is_responsable())
  with check (cave_id = public.current_cave_id() and public.is_responsable());
