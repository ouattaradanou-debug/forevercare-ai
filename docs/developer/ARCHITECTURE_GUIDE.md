# ARCHITECTURE_GUIDE.md

**Projet :** ForeverCare AI

**Version :** 1.0

**Statut :** Officiel

**Dernière mise à jour :** Sprint A.1.6.7

---

# 1. Objectif

Ce guide explique comment appliquer l'architecture officielle de ForeverCare AI lors du développement de nouvelles fonctionnalités.

Il complète les documents :

* PROJECT_GOVERNANCE.md
* ARCHITECTURE.md
* CODING_RULES.md
* NAMING.md
* PACKAGES.md

---

# 2. Philosophie

ForeverCare AI est construit selon les principes suivants :

* Feature First
* Clean Architecture
* Séparation des responsabilités
* Réutilisation maximale
* Documentation permanente
* Zéro régression

Chaque nouvelle fonctionnalité doit respecter ces principes.

---

# 3. Cycle officiel de développement

Chaque fonctionnalité suit obligatoirement les étapes suivantes :

1. Analyse du besoin métier.
2. Validation d'architecture.
3. Création de la structure du module.
4. Développement du domaine.
5. Développement des sources de données.
6. Développement des Providers et Controllers.
7. Développement de l'interface.
8. Tests.
9. Documentation.
10. Validation.

Aucune étape ne doit être ignorée.

---

# 4. Structure d'un module

Chaque module suit obligatoirement cette organisation :

```text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── pages/
    ├── widgets/
    ├── providers/
    └── controllers/
```

Cette structure est identique pour tous les modules.

---

# 5. Responsabilités des couches

## Domain

Le domaine contient les règles métier.

Il ne dépend jamais de Flutter ni de la base de données.

---

## Data

La couche Data implémente l'accès aux données.

Elle communique avec :

* Drift
* APIs
* Stockage local

---

## Presentation

La couche Presentation gère :

* l'interface utilisateur ;
* les interactions ;
* les Providers ;
* les Controllers.

Aucune logique métier complexe n'y est autorisée.

---

# 6. Flux officiel

Le flux de données est le suivant :

```text
Utilisateur
        ↓
Widget
        ↓
Provider / Controller
        ↓
Use Case
        ↓
Repository
        ↓
Data Source
        ↓
SQLite / Cloud
```

Le flux inverse est utilisé pour l'affichage.

---

# 7. Création d'un nouveau module

Avant de créer un module :

* vérifier qu'il n'existe pas déjà ;
* utiliser le template officiel du projet ;
* respecter la structure imposée ;
* documenter le module.

---

# 8. Création d'un Widget

Avant de créer un Widget :

* rechercher un composant existant dans `shared/` ;
* rechercher un composant dans `design_system/`.

Si un composant réutilisable existe, il doit être privilégié.

---

# 9. Gestion des Services

Les Services :

* sont indépendants de l'interface ;
* peuvent être utilisés par plusieurs modules ;
* sont placés dans `core/services`.

---

# 10. Gestion des Repositories

Les Repositories :

* masquent la source des données ;
* exposent une API métier claire ;
* ne sont jamais utilisés directement par les Widgets.

---

# 11. Documentation

Chaque nouvelle fonctionnalité doit mettre à jour :

* PROJECT_STATUS.md
* CHANGELOG.md
* le document correspondant dans `docs/features/`
* la documentation technique si l'architecture évolue.

---

# 12. Validation d'un Sprint

Un sprint est terminé uniquement si :

* le code compile ;
* `flutter analyze` ne retourne aucune erreur ;
* les tests prévus sont validés ;
* la documentation est à jour ;
* les règles du projet sont respectées.

---

# 13. Gestion des évolutions

Toute évolution d'architecture doit suivre la procédure définie dans PROJECT_GOVERNANCE.md.

Aucune exception n'est autorisée.

---

# 14. Objectif à long terme

L'architecture doit permettre :

* l'ajout de nouveaux modules ;
* la synchronisation Cloud ;
* le fonctionnement hors connexion ;
* l'intégration de nouvelles fonctionnalités IA ;
* le développement de versions Android, iOS et Web.

Chaque décision doit être prise en gardant cette vision.

---

# Conclusion

Ce guide constitue la référence pratique pour tous les développements de ForeverCare AI.

Avant de créer ou modifier une fonctionnalité, le développeur doit vérifier que son implémentation respecte les principes décrits dans ce document.
