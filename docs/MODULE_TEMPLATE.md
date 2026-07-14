# ForeverCare AI
# Modèle Officiel de Développement d'un Module

Version : 1.0

---

# Objectif

Tous les modules de ForeverCare AI doivent suivre exactement la même architecture afin de garantir :

- une maintenance simplifiée ;
- une cohérence du code ;
- une évolution rapide ;
- une qualité constante.

---

# Arborescence

```
features/

└── nom_du_module/

    ├── data/
    │
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    │
    ├── domain/
    │
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    │
    └── presentation/
        │
        ├── controllers/
        ├── forms/
        ├── pages/
        ├── providers/
        └── widgets/
```

---

# Ordre de développement

Toujours respecter cet ordre.

1. Entity

2. Repository (interface)

3. UseCases

4. Model

5. DataSource

6. RepositoryImpl

7. Providers

8. Controller

9. Form

10. Widgets

11. Pages

12. Navigation

13. Dashboard

14. Validation

---

# Fichiers minimum

## Domain

- entity.dart
- repository.dart

UseCases :

- create
- update
- delete
- get_all
- get_by_id
- search (si nécessaire)

---

## Data

- model.dart
- local_datasource.dart
- repository_impl.dart

---

## Presentation

- controller.dart
- form.dart
- page_list.dart
- page_add.dart
- page_details.dart
- providers.dart

Widgets :

- header
- identity_card
- quick_actions

---

# Validation

Chaque module doit valider :

- création
- lecture
- modification
- suppression
- recherche (si prévue)
- navigation
- SQLite
- Dashboard

---

# Validation technique

Avant toute livraison :

flutter analyze

flutter test

flutter run

---

# Git

À la fin du module :

git add .

git commit -m "feat(module): complete module"

git tag vx.y.z

---

# Critères de fin

Un module est terminé uniquement si :

- Architecture validée
- CRUD validé
- Interface validée
- SQLite validée
- Dashboard connecté
- Tests validés
- Documentation mise à jour

---

Fin du document.