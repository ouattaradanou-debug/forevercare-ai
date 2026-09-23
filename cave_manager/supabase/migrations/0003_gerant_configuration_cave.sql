-- ============================================================================
-- Phase 1 — Le Gérant peut aussi modifier la configuration de la cave
--
-- Demandé explicitement après l'ajout de l'icône ⚙️ sur l'écran d'accueil
-- (visible pour Propriétaire et Propriétaire/Gérant) : l'étendre au
-- Gérant, qui gère la cave au quotidien au même titre (point 2 du cahier
-- des charges : Propriétaire, Gérant, Agent de vente — le Gérant a un
-- rôle de gestion complet, distinct de l'Agent de vente).
--
-- La policy `caves_update` (migration 0001) était restreinte à
-- `is_admin()` (Propriétaire/Propriétaire-Gérant uniquement). On la
-- remplace par `is_responsable()`, déjà définie en 0001 et qui inclut
-- exactement Propriétaire, Propriétaire/Gérant et Gérant — la même
-- distinction que `RoleUtilisateur.estResponsable` côté Flutter.
-- L'Agent de vente reste explicitement exclu.
-- ============================================================================

drop policy if exists caves_update on public.caves;

create policy caves_update on public.caves
  for update using (id = public.current_cave_id() and public.is_responsable())
  with check (id = public.current_cave_id() and public.is_responsable());

-- ============================================================================
-- Fin de la migration 0003.
-- ============================================================================
