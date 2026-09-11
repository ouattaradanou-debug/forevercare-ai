-- =============================================================================
-- Atelier+ — Migration Phase 7 : récupération de compte (code PIN oublié)
-- =============================================================================
-- À exécuter une fois dans l'éditeur SQL Supabase.
--
-- Jusqu'ici, un tailleur qui oubliait son code PIN n'avait aucun moyen de
-- récupérer son compte lui-même (pas de vrai email, voir TelephoneUtils —
-- la réinitialisation par email de Supabase Auth est donc inutilisable).
--
-- Cette table stocke, pour un compte propriétaire qui l'a configurée, une
-- question secrète et la réponse (hachée, jamais en clair — voir les Edge
-- Functions ci-dessous). AUCUNE policy RLS n'est accordée ici : ni le
-- client "anon", ni un utilisateur authentifié ne peut lire ou écrire
-- cette table par un appel direct depuis l'application — seules les Edge
-- Functions (clé service_role, qui contourne RLS) le peuvent. Sans ça,
-- n'importe quel membre de l'atelier pourrait lire la question/réponse du
-- propriétaire via un simple appel à l'API (les policies RLS de
-- `utilisateurs` sont au niveau de la ligne, pas de la colonne).
-- =============================================================================

create table if not exists public.recuperation_compte (
  utilisateur_id  uuid primary key references public.utilisateurs (id) on delete cascade,
  question        text not null,
  reponse_hash    text not null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

alter table public.recuperation_compte enable row level security;

create trigger trg_recuperation_compte_updated_at
  before update on public.recuperation_compte
  for each row execute function public.definir_horodatage_modification();

-- Pas de policy : voir le commentaire ci-dessus, c'est volontaire.
