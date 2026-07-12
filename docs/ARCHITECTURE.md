# ForeverCare AI
# Architecture Logicielle

Version : 1.0
Statut : Officiel

---

# 1. Objectif

ForeverCare AI est une application Flutter destinée à la gestion complète
des activités Forever Living Products.

L'application est conçue pour fonctionner :

- hors connexion (SQLite)
- avec une architecture évolutive
- avec une interface homogène
- avec une maintenance simplifiée

---

# 2. Architecture générale

L'application suit une Clean Architecture.

```
Présentation
        │
        ▼
Domain
        │
        ▼
Data
        │
        ▼
SQLite
```

Aucune couche ne doit contourner cette architecture.

---

# 3. Organisation des modules

Chaque module possède exactement la même structure.

```
feature/

    clients/

        data/

        domain/

        presentation/

            controllers/

            forms/

            pages/

            providers/

            widgets/
```

Cette structure est obligatoire.

---

# 4. Base de données

Une seule base SQLite est utilisée.

AppDatabase est l'unique point d'accès à SQLite.

Les DataSources sont les seules autorisées
à exécuter des requêtes SQL.

---

# 5. Riverpod

Les Providers sont utilisés uniquement
pour exposer les données aux écrans.

Les Widgets ne doivent jamais accéder directement
aux DataSources.

---

# 6. Navigation

Toute la navigation est centralisée.

GoRouter est utilisé pour les routes principales.

Les pages de détail peuvent utiliser
MaterialPageRoute lorsque cela simplifie
la navigation.

---

# 7. Design System

Toute l'interface repose sur le ForeverCare Design Language (FDL).

Les composants réutilisables doivent être privilégiés.

Exemples :

- FCButton

- FCCard

- FCTextField

- FCDateField

- FCDropdownField

Aucun écran ne doit recréer ces composants.

---

# 8. Règles de développement

Toujours partir des fichiers existants.

Toujours remplacer un fichier complet.

Ne jamais modifier un module validé sans raison.

Toujours exécuter :

flutter analyze

flutter test

flutter run

avant validation.

---

# 9. Cycle de développement

Chaque module suit exactement les étapes suivantes.

Architecture

↓

Domain

↓

Data

↓

SQLite

↓

Providers

↓

Controllers

↓

Forms

↓

Widgets

↓

Pages

↓

Navigation

↓

Dashboard

↓

Validation

---

# 10. Modules prévus

- Dashboard

- Clients

- Produits

- Commandes

- Ventes

- Protocoles

- Rendez-vous

- Inventaire

- Fournisseurs

- Paiements

- Rapports

- Paramètres

---

# 11. Documentation

Chaque évolution importante doit être documentée.

Les documents officiels sont :

README.md

CHANGELOG.md

PROJECT_STATUS.md

docs/ARCHITECTURE.md

docs/DATABASE.md

docs/DESIGN_SYSTEM.md

docs/ROADMAP.md

docs/RELEASE_PROCESS.md

---

# 12. Validation

Un module est considéré terminé uniquement si :

- Architecture validée

- CRUD complet

- Interface complète

- SQLite validée

- Navigation validée

- Dashboard connecté

- flutter analyze OK

- flutter test OK

- flutter run OK

---

Fin du document.