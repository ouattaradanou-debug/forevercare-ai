-- =============================================================================
-- Atelier+ — Correctif : re-création des policies RLS sur `ateliers` et
-- `utilisateurs`.
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase (Table Editor > SQL
-- Editor > New query), en plus de schema.sql (déjà exécuté).
--
-- Contexte : la création de compte échoue avec l'erreur "new row violates
-- row-level security policy for table ateliers" (code 42501) lors de
-- l'insertion dans `ateliers`, alors que schema.sql définit bien une policy
-- qui devrait l'autoriser. Ce script est sans danger à exécuter même
-- plusieurs fois (chaque policy est supprimée si elle existe déjà, puis
-- recréée à l'identique) : il corrige le problème que la policy d'origine
-- soit absente, mal appliquée, ou ait été modifiée manuellement depuis.
-- =============================================================================

-- S'assure que les deux fonctions utilisées par les policies existent bien
-- et sont à jour (sans effet si elles existent déjà correctement).
create or replace function public.mon_atelier_id()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select atelier_id from public.utilisateurs where id = auth.uid();
$$;

create or replace function public.mon_role()
returns text
language sql
security definer
set search_path = public
stable
as $$
  select role from public.utilisateurs where id = auth.uid();
$$;

-- -----------------------------------------------------------------------------
-- ateliers
-- -----------------------------------------------------------------------------
alter table public.ateliers enable row level security;

drop policy if exists "ateliers_select_mon_atelier" on public.ateliers;
create policy "ateliers_select_mon_atelier"
  on public.ateliers for select
  using (id = public.mon_atelier_id());

drop policy if exists "ateliers_insert_bootstrap_compte" on public.ateliers;
create policy "ateliers_insert_bootstrap_compte"
  on public.ateliers for insert
  with check (auth.uid() is not null);

drop policy if exists "ateliers_update_proprietaire" on public.ateliers;
create policy "ateliers_update_proprietaire"
  on public.ateliers for update
  using (id = public.mon_atelier_id() and public.mon_role() = 'proprietaire')
  with check (id = public.mon_atelier_id() and public.mon_role() = 'proprietaire');

-- -----------------------------------------------------------------------------
-- utilisateurs
-- -----------------------------------------------------------------------------
alter table public.utilisateurs enable row level security;

drop policy if exists "utilisateurs_select_mon_atelier" on public.utilisateurs;
create policy "utilisateurs_select_mon_atelier"
  on public.utilisateurs for select
  using (atelier_id = public.mon_atelier_id());

drop policy if exists "utilisateurs_insert_soi_meme" on public.utilisateurs;
create policy "utilisateurs_insert_soi_meme"
  on public.utilisateurs for insert
  with check (id = auth.uid());

drop policy if exists "utilisateurs_update_proprietaire_ou_soi_meme" on public.utilisateurs;
create policy "utilisateurs_update_proprietaire_ou_soi_meme"
  on public.utilisateurs for update
  using (
    id = auth.uid()
    or (atelier_id = public.mon_atelier_id() and public.mon_role() = 'proprietaire')
  )
  with check (
    id = auth.uid()
    or (atelier_id = public.mon_atelier_id() and public.mon_role() = 'proprietaire')
  );

drop policy if exists "utilisateurs_delete_proprietaire" on public.utilisateurs;
create policy "utilisateurs_delete_proprietaire"
  on public.utilisateurs for delete
  using (
    atelier_id = public.mon_atelier_id()
    and public.mon_role() = 'proprietaire'
    and id <> auth.uid()
  );

-- -----------------------------------------------------------------------------
-- Vérification : doit afficher 3 lignes pour ateliers, 4 pour utilisateurs.
-- -----------------------------------------------------------------------------
select tablename, policyname, cmd
from pg_policies
where schemaname = 'public' and tablename in ('ateliers', 'utilisateurs')
order by tablename, cmd;
