# CODING_RULES.md

**Projet :** ForeverCare AI

**Version :** 1.0

**Statut :** Officiel

**Dernière mise à jour :** Sprint A.1.6.4

---

# 1. Objectif

Ce document définit les règles de développement applicables à l'ensemble du projet ForeverCare AI.

Toutes les personnes intervenant sur le projet doivent respecter ces règles afin de garantir un code homogène, maintenable et évolutif.

---

# 2. Principes fondamentaux

Chaque développement doit respecter les principes suivants :

* Lisibilité avant complexité.
* Simplicité avant optimisation prématurée.
* Réutilisation avant duplication.
* Documentation avant livraison.
* Zéro régression.
* Code testable.
* Responsabilité unique.

---

# 3. Structure des fichiers

Un fichier Dart ne doit contenir qu'une seule responsabilité principale.

Ordre recommandé :

1. Imports Dart
2. Imports Flutter
3. Imports des packages
4. Imports du projet
5. Constantes privées
6. Classe principale
7. Classes secondaires si elles sont réellement liées

---

# 4. Conventions de nommage

## Fichiers

Toujours en snake_case.

Exemple :

* client_repository.dart
* dashboard_page.dart
* followup_service.dart

## Classes

Toujours en PascalCase.

Exemple :

* ClientRepository
* DashboardPage
* FollowupService

## Variables

Toujours en camelCase.

Exemple :

* clientName
* totalSales

## Constantes

camelCase précédées de "k" si elles sont publiques.

Exemple :

* kDefaultPadding
* kPrimaryColor

---

# 5. Widgets

Les Widgets :

* n'effectuent jamais de calcul métier ;
* ne manipulent jamais directement la base de données ;
* ne contiennent jamais de logique commerciale.

Ils affichent uniquement les données.

---

# 6. Providers

Les Providers :

* exposent les données à l'interface ;
* orchestrent les appels aux Use Cases ;
* restent indépendants de l'interface graphique.

---

# 7. Services

Les Services :

* réalisent des opérations techniques ;
* ne connaissent jamais les Widgets.

---

# 8. Repositories

Les Repositories :

* constituent la seule porte d'entrée vers les données ;
* masquent totalement l'implémentation de la base de données.

---

# 9. Base de données

Aucun Widget ne doit communiquer directement avec Drift.

Le chemin officiel est :

Widget → Provider → Use Case → Repository → Data Source → Drift

---

# 10. Gestion des erreurs

Les exceptions ne doivent jamais être ignorées.

Toute erreur doit :

* être capturée ;
* être journalisée ;
* être transformée en erreur métier lorsque nécessaire.

---

# 11. Documentation

Chaque classe publique doit posséder une documentation lorsqu'elle expose un comportement important.

Les commentaires doivent expliquer **pourquoi** un choix est fait, et non simplement décrire ce que le code fait.

---

# 12. TODO

Les TODO sont interdits dans le code de production.

Toute tâche reportée doit être :

* documentée ;
* planifiée dans la Roadmap ou le Sprint concerné.

---

# 13. Duplication

Toute duplication doit être évitée.

Avant d'écrire un composant, vérifier s'il existe déjà dans :

* shared/
* design_system/
* core/

---

# 14. Imports

Les imports inutilisés sont interdits.

Les imports doivent être organisés et nettoyés avant chaque validation.

---

# 15. Formatage

Le code doit être formaté avant chaque validation.

Commande officielle :

```cmd
dart format .
```

---

# 16. Analyse

Avant chaque validation :

```cmd
flutter analyze
```

Aucune erreur ne doit être ignorée.

Les avertissements doivent être traités dès que possible.

---

# 17. Tests

Toute fonctionnalité critique devra pouvoir être testée.

L'architecture doit favoriser les tests unitaires et les tests d'intégration.

---

# 18. Réutilisation

Avant de créer :

* un Widget ;
* un Service ;
* un Repository ;
* un Provider ;

vérifier qu'un composant similaire n'existe pas déjà.

---

# 19. Politique de modification

Avant toute modification d'un fichier existant :

1. analyser son contenu ;
2. analyser les impacts ;
3. proposer la modification ;
4. valider ;
5. développer ;
6. tester.

---

# 20. Validation

Aucun Sprint n'est considéré comme terminé tant que :

* le projet compile ;
* les règles sont respectées ;
* la documentation est à jour ;
* les tests prévus sont validés ;
* le CHANGELOG et le PROJECT_STATUS sont mis à jour.

---

# Conclusion

Ces règles constituent le standard officiel de développement de ForeverCare AI.

Toute évolution du projet devra rester conforme à ce document, sauf décision d'architecture validée conformément au PROJECT_GOVERNANCE.md.
