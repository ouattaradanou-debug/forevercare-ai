-- ============================================================================
-- Phase 3 (suite) — Modifier/supprimer une ligne de commande en attente
--
-- Demande : pouvoir corriger une vente avant validation (le client renonce
-- à un produit, ou change une quantité) sans devoir annuler toute la
-- commande. `commande_lignes` n'avait jusqu'ici aucune policy UPDATE/
-- DELETE (immuable par design, migration 0012). On l'ouvre, mais
-- strictement encadré : uniquement tant que la commande parente est
-- 'en_attente', et par son créateur ou un responsable — jamais après
-- annulation ou (plus tard, Phase 4) validation.
-- ============================================================================

grant update, delete on public.commande_lignes to authenticated;

create policy commande_lignes_update on public.commande_lignes
  for update using (
    exists (
      select 1 from public.commandes c
      where c.id = commande_lignes.commande_id
        and c.cave_id = public.current_cave_id()
        and c.statut = 'en_attente'
        and (c.created_by = auth.uid() or public.is_responsable())
    )
  )
  with check (
    exists (
      select 1 from public.commandes c
      where c.id = commande_id
        and c.cave_id = public.current_cave_id()
        and c.statut = 'en_attente'
        and (c.created_by = auth.uid() or public.is_responsable())
    )
  );

create policy commande_lignes_delete on public.commande_lignes
  for delete using (
    exists (
      select 1 from public.commandes c
      where c.id = commande_lignes.commande_id
        and c.cave_id = public.current_cave_id()
        and c.statut = 'en_attente'
        and (c.created_by = auth.uid() or public.is_responsable())
    )
  );

-- ----------------------------------------------------------------------------
-- Le trigger devient AFTER INSERT OR UPDATE OR DELETE : il applique le
-- DELTA réel (new.sous_total - old.sous_total en update, -old.sous_total
-- en delete), donc reste sûr en cas de retry réseau exactement comme
-- avant (un insert rejoué à l'identique devient un update côté sync
-- engine, mais new.sous_total = old.sous_total => delta nul => aucun
-- double comptage).
-- ----------------------------------------------------------------------------
create or replace function public.appliquer_ligne_commande() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if TG_OP = 'INSERT' then
    update public.commandes
      set total = total + new.sous_total, updated_at = now()
      where id = new.commande_id;
    return new;
  elsif TG_OP = 'UPDATE' then
    update public.commandes
      set total = total + (new.sous_total - old.sous_total), updated_at = now()
      where id = new.commande_id;
    return new;
  elsif TG_OP = 'DELETE' then
    update public.commandes
      set total = total - old.sous_total, updated_at = now()
      where id = old.commande_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists trg_appliquer_ligne_commande on public.commande_lignes;

create trigger trg_appliquer_ligne_commande
  after insert or update or delete on public.commande_lignes
  for each row execute function public.appliquer_ligne_commande();
