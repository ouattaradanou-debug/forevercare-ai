# PACKAGES.md

**Projet :** ForeverCare AI

**Version :** 1.0

**Statut :** Officiel

**Dernière mise à jour :** Sprint A.1.6.6

---

# 1. Objectif

Ce document référence l'ensemble des packages utilisés dans ForeverCare AI.

Chaque package présent dans le projet doit avoir une justification fonctionnelle ou technique.

Aucune dépendance ne doit être ajoutée sans validation conformément au `PROJECT_GOVERNANCE.md`.

---

# 2. Principes de sélection

Avant d'ajouter un package, vérifier les critères suivants :

* maintenance active ;
* documentation officielle de qualité ;
* communauté importante ;
* compatibilité avec la version de Flutter utilisée ;
* licence compatible avec le projet ;
* stabilité reconnue.

Les packages abandonnés ou peu maintenus sont interdits.

---

# 3. Packages officiels

## Gestion d'état

### flutter_riverpod

**Rôle**

Gestion de l'état de l'application.

**Utilisation**

* Providers
* State Notifiers
* Injection des dépendances métier

---

## Navigation

### go_router

**Rôle**

Navigation officielle de l'application.

Toutes les navigations passent par GoRouter.

Les appels directs à `Navigator.push()` sont à éviter, sauf cas exceptionnel documenté.

---

## Base de données

### drift

**Rôle**

ORM SQLite officiel.

Responsabilités :

* définition des tables ;
* requêtes ;
* migrations ;
* DAO.

---

### sqlite3_flutter_libs

**Rôle**

Bibliothèques SQLite natives nécessaires à Drift.

---

### path

**Rôle**

Gestion des chemins de fichiers.

---

### path_provider

**Rôle**

Accès aux répertoires système.

---

## Interface utilisateur

### google_fonts

**Rôle**

Gestion de la typographie.

Police officielle :

* Poppins

---

### flutter_svg

**Rôle**

Affichage des icônes SVG.

---

### cached_network_image

**Rôle**

Mise en cache des images distantes.

---

### lottie

**Rôle**

Animations de l'application.

---

### fl_chart

**Rôle**

Graphiques et tableaux de bord.

---

## Notifications

### flutter_local_notifications

**Rôle**

Notifications locales.

Utilisation :

* rappels de suivi ;
* renouvellements ;
* alertes.

---

## Utilitaires

### intl

**Rôle**

Internationalisation.

Gestion :

* dates ;
* nombres ;
* devises ;
* traductions.

---

### shared_preferences

**Rôle**

Stockage des préférences utilisateur.

---

### logger

**Rôle**

Journalisation des événements et erreurs.

---

# 4. Packages de développement

## build_runner

Utilisé pour la génération de code.

---

## drift_dev

Utilisé pour générer le code Drift.

---

## flutter_test

Tests unitaires et tests Flutter.

---

# 5. Règles d'ajout d'un package

Avant toute intégration, vérifier :

1. Le besoin fonctionnel.
2. Les alternatives existantes.
3. L'impact sur les performances.
4. La qualité de la documentation.
5. La fréquence des mises à jour.
6. Les éventuels problèmes de sécurité.
7. La compatibilité avec les autres dépendances.

Toute décision doit être documentée dans `docs/decisions/`.

---

# 6. Mise à jour des packages

Avant toute mise à jour majeure :

* consulter les notes de version ;
* identifier les changements incompatibles ;
* tester l'application ;
* mettre à jour la documentation si nécessaire.

---

# 7. Suppression d'un package

Avant de supprimer un package :

* vérifier qu'il n'est plus utilisé ;
* supprimer le code associé ;
* exécuter `flutter analyze` ;
* mettre à jour ce document.

---

# 8. Packages interdits

Les packages suivants ne doivent pas être ajoutés :

* packages non maintenus ;
* packages sans licence claire ;
* packages contournant l'architecture officielle ;
* packages créant une duplication fonctionnelle.

---

# 9. Évolution

La liste des packages évoluera avec le projet.

Chaque ajout, mise à jour ou suppression devra être documenté dans :

* `CHANGELOG.md`
* `PROJECT_STATUS.md`
* `docs/decisions/`
* `PACKAGES.md`

---

# Conclusion

Les packages constituent une partie essentielle de l'architecture.

Chaque dépendance doit être justifiée, documentée et maintenue afin de garantir la stabilité, la sécurité et la pérennité de ForeverCare AI.
