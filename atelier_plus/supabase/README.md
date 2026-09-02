# Schéma Supabase — Atelier+

## Application du schéma

1. Créer un projet Supabase (https://supabase.com).
2. Dans **SQL Editor**, exécuter `schema.sql` en une fois (script idempotent,
   peut être rejoué sans erreur grâce aux `if not exists` / `drop ... if
   exists`).
3. Récupérer l'URL du projet et la clé `anon` dans **Project Settings > API**
   pour les fournir à l'application (voir `lib/core/config/supabase_config.dart`).

Ou, avec la CLI Supabase :

```bash
supabase link --project-ref <votre-ref-projet>
supabase db push --file supabase/schema.sql
```

## Résumé des garanties de sécurité (RLS)

| Règle demandée | Mise en œuvre |
|---|---|
| Un utilisateur ne voit que les données de son atelier | Toutes les tables filtrent par `atelier_id = mon_atelier_id()` (colonne directe ou dénormalisée pour les tables liées à un client). |
| Un apprenti ne peut jamais lire/écrire `commandes`/`paiements` | Politiques `for all` restreintes à `est_proprietaire()`, sans aucune condition de permission. `permissions_apprenti` ne contient d'ailleurs aucune colonne financière. |
| Seul le propriétaire modifie `ateliers` (nom/logo) | `ateliers_update` exige `est_proprietaire()`. |
| Seul le propriétaire modifie `types_tenue`/`champs_mesure` | `*_insert`/`*_update`/`*_delete` exigent `est_proprietaire()`, même si `permissions_apprenti.modifier_gabarits` est activé (cette colonne est réservée à un usage UI futur, pas à un droit RLS — voir commentaire en tête de `schema.sql`). |
| Un champ de mesure utilisé n'est jamais supprimé | Aucune politique `DELETE` sur `champs_mesure` : seul un `UPDATE statut = 'masque'` est possible. La vérification "des mesures existent-elles sur ce champ ?" reste une **validation applicative** avant de proposer le masquage (Phase 2), la RLS ne peut pas exprimer cette dépendance inter-tables au niveau du masquage lui-même. |

## Décisions d'architecture (à valider en Phase 0)

- **Dénormalisation de `atelier_id`** sur `mesures`, `photos`, `rendez_vous`,
  `commandes`, `paiements` (en plus de la relation via `client_id`) : simplifie
  et accélère considérablement les politiques RLS (un seul filtre direct au
  lieu d'une sous-requête de jointure sur chaque ligne). Choix standard
  recommandé par la documentation Supabase pour les schémas multi-tenants.
- **`utilisateurs.id = auth.users.id`** : pas de table de mapping séparée,
  conformément au pattern Supabase standard.
- **Fonctions `SECURITY DEFINER`** (`mon_atelier_id()`, `mon_role()`,
  `est_proprietaire()`, `a_permission_*()`) : évitent toute récursion RLS
  lors de l'évaluation d'une politique qui doit elle-même lire `utilisateurs`
  ou `permissions_apprenti`.
- **`abonnements`** : aucune politique d'écriture pour le rôle `authenticated`.
  La transition essai → actif sera gérée par une fonction Edge Supabase
  utilisant la clé `service_role`, après confirmation de paiement (Phase 4).
