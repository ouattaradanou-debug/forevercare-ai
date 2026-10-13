# Schéma Supabase — Atelier+

## Application du schéma

1. Créer un projet Supabase (https://supabase.com).
2. Dans **SQL Editor**, exécuter dans l'ordre (chaque script est idempotent) :
   `schema.sql`, puis `storage.sql`, puis `storage_photos_clients.sql`, puis
   `seed_gabarits.sql`.
3. Désactiver "Confirm email" (voir section suivante) et déployer la
   fonction Edge `creer-apprenti` (voir plus bas).
4. Récupérer l'URL du projet et la clé `anon` dans **Project Settings > API**
   pour les fournir à l'application (voir `lib/core/config/supabase_config.dart`).

Ou, avec la CLI Supabase :

```bash
supabase link --project-ref <votre-ref-projet>
supabase db push --file supabase/schema.sql
```

## Configuration Auth requise (Phase 1)

L'authentification se fait par **téléphone + PIN**, pas par email : voir
`lib/core/utils/telephone.dart`. Techniquement, un compte Auth email/mot de
passe classique est créé avec un email synthétique jamais délivré
(`tel-XXXXXXXX@gmail.com` — un domaine avec MX valide est requis par la
validation d'email de Supabase Auth, voir `telephone.dart`). Pour que la
connexion fonctionne, le
projet Supabase doit avoir la confirmation d'email **désactivée** :

> **Dashboard Supabase → Authentication → Sign In / Providers → Email →
> désactiver "Confirm email"**

Sans cela, un compte nouvellement créé resterait bloqué en attente d'une
confirmation qui ne peut jamais arriver (l'adresse est fictive).

## Fonction Edge `creer-apprenti`

Le propriétaire crée les comptes apprentis via la fonction Edge
`supabase/functions/creer-apprenti/` plutôt que directement depuis
l'application : un appel client à `auth.signUp` remplacerait la session du
propriétaire par celle du nouvel apprenti (le SDK Supabase ne gère qu'une
session à la fois). La fonction utilise la clé `service_role` côté serveur
pour créer le compte apprenti sans jamais affecter la session de l'appelant,
après avoir vérifié que l'appelant est bien `proprietaire` de l'atelier.

Déploiement :

```bash
supabase functions deploy creer-apprenti
```

Aucune variable d'environnement à configurer manuellement : `SUPABASE_URL`,
`SUPABASE_ANON_KEY` et `SUPABASE_SERVICE_ROLE_KEY` sont injectées
automatiquement par la plateforme Supabase à l'exécution des fonctions Edge.

## Fonction Edge `recuperer-compte`

Permet au propriétaire de récupérer l'accès à son compte s'il a oublié son
code PIN (téléphone perdu, changement d'appareil...), via la question
secrète définie à la création du compte (ou plus tard dans Paramètres) —
voir `supabase/functions/recuperer-compte/`. **Volontairement publique**
(fonctionne sans session, condition même du scénario "PIN oublié") : doit
être déployée avec `--no-verify-jwt`, sinon Supabase refuse tout appel non
authentifié.

```bash
supabase functions deploy recuperer-compte --no-verify-jwt
```

## Storage : bucket des logos d'atelier

Voir `supabase/storage.sql` pour la création du bucket `logos-ateliers` et
ses politiques d'accès (upload/suppression réservés au propriétaire de
l'atelier concerné). À exécuter après `schema.sql`, dans le même SQL
Editor.

## Gabarits de mesure par défaut (Phase 2)

`supabase/seed_gabarits.sql` insère les types de tenue par défaut (7
gabarits Femme, 5 gabarits Homme) et leurs champs de mesure. Script
idempotent (identifiants fixes + index unique), à exécuter une fois après
`schema.sql`. Ces gabarits ont `atelier_id = null` : visibles par tous les
ateliers en lecture, jamais modifiables directement (RLS) — un atelier qui
veut les adapter doit les **dupliquer** depuis l'écran "Gérer mes types de
tenues" (Phase 2), ce qui crée une copie avec son propre `atelier_id`.

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
- **Authentification téléphone + PIN** (Phase 1) : compte Auth email/mot de
  passe standard avec email synthétique dérivé du téléphone (Supabase Auth
  n'a pas de mode PIN natif sans SMS payant). Détail dans la section
  "Configuration Auth requise" ci-dessus.
- **Création d'apprenti** (Phase 1) : passe par la fonction Edge
  `creer-apprenti` (clé `service_role`) plutôt qu'un appel client direct, pour
  ne pas remplacer la session du propriétaire par celle du nouvel apprenti.
