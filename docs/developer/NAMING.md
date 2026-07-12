# NAMING.md

**Projet :** ForeverCare AI

**Version :** 1.0

**Statut :** Officiel

**Dernière mise à jour :** Sprint A.1.6.5

---

# 1. Objectif

Ce document définit les conventions de nommage officielles de ForeverCare AI.

Une convention unique facilite :

* la lecture du code ;
* la recherche des fichiers ;
* la maintenance ;
* l'intégration de nouveaux développeurs.

Ces conventions sont obligatoires pour tout le projet.

---

# 2. Conventions générales

| Élément               | Convention | Exemple                  |
| --------------------- | ---------- | ------------------------ |
| Dossiers              | snake_case | `client_followup`        |
| Fichiers              | snake_case | `client_repository.dart` |
| Classes               | PascalCase | `ClientRepository`       |
| Variables             | camelCase  | `clientName`             |
| Fonctions             | camelCase  | `loadClients()`          |
| Paramètres            | camelCase  | `clientId`               |
| Énumérations          | PascalCase | `FollowupStatus`         |
| Valeurs d'énumération | camelCase  | `inProgress`             |

---

# 3. Suffixes obligatoires

## Pages

Toutes les pages se terminent par :

* `Page`

Exemple :

* DashboardPage
* ClientDetailsPage

---

## Dialogues

Toutes les boîtes de dialogue se terminent par :

* `Dialog`

Exemple :

* DeleteClientDialog
* RenewalDialog

---

## Bottom Sheets

Toutes les feuilles inférieures se terminent par :

* `BottomSheet`

Exemple :

* ClientOptionsBottomSheet

---

## Widgets

Les widgets réutilisables utilisent un nom descriptif.

Exemple :

* ClientCard
* ProductTile
* FollowupTimeline

---

## Services

Tous les services se terminent par :

* `Service`

Exemple :

* NotificationService
* StorageService

---

## Repositories

Tous les repositories se terminent par :

* `Repository`

Exemple :

* ClientRepository
* ProductRepository

---

## Providers

Tous les providers se terminent par :

* `Provider`

Exemple :

* clientProvider
* dashboardProvider

---

## Controllers

Tous les contrôleurs se terminent par :

* `Controller`

Exemple :

* DashboardController
* ClientController

---

## Use Cases

Tous les cas d'utilisation commencent par un verbe.

Exemple :

* GetClients
* CreateClient
* UpdateClient
* DeleteClient

---

## Data Sources

Toutes les sources de données se terminent par :

* `DataSource`

Exemple :

* LocalClientDataSource
* RemoteClientDataSource

---

# 4. Préfixes officiels

Les composants du Design System utilisent le préfixe :

* FC

Exemple :

* FCButton
* FCCard
* FCInput
* FCDialog
* FCBadge
* FCBottomNavigation

---

# 5. Fichiers Dart

Chaque fichier Dart porte le même nom que sa classe principale.

Exemple :

```text
client_repository.dart

↓

class ClientRepository
```

---

# 6. Constantes

Les constantes publiques utilisent le préfixe :

* `k`

Exemple :

* kPrimaryColor
* kBorderRadius
* kDefaultPadding

Les constantes privées utilisent le préfixe :

* `_`

Exemple :

* _defaultAnimationDuration

---

# 7. Assets

Les ressources utilisent uniquement des noms en minuscules.

Exemples :

* logo_forevercare.png
* background_dashboard.jpg
* icon_clients.svg

Les espaces sont interdits.

---

# 8. Base de données

## Tables

Nom au pluriel.

Exemples :

* clients
* products
* followups

## Colonnes

Nom explicite.

Exemples :

* first_name
* phone_number
* created_at

---

# 9. Documentation

Les documents Markdown utilisent des noms explicites.

Exemples :

* PROJECT_GOVERNANCE.md
* DATABASE_SCHEMA.md
* CLIENT_LIFECYCLE.md

---

# 10. Interdictions

Les éléments suivants sont interdits :

* abréviations ambiguës ;
* noms à une seule lettre (hors boucles simples) ;
* noms dépendant d'une langue différente de celle retenue pour le code ;
* espaces dans les noms de fichiers ;
* caractères spéciaux dans les noms.

---

# 11. Langue officielle

Le code source est rédigé en anglais.

La documentation peut être rédigée en français.

Les libellés affichés à l'utilisateur seront internationalisés à terme.

---

# 12. Conclusion

Toute nouvelle classe, tout nouveau fichier et toute nouvelle ressource doivent respecter cette convention.

Le respect de ces règles garantit une architecture cohérente et une maintenance facilitée tout au long de la vie de ForeverCare AI.
