# PROJECT_GOVERNANCE.md

**Projet :** Atelier+

**Version :** 1.0

**Statut :** Officiel

---

# 1. Vision du projet

Atelier+ est une application mobile de gestion de clientèle destinée aux tailleurs et couturiers d'Afrique de l'Ouest : fiches clients, mesures corporelles par type de tenue, rendez-vous, suivi financier, gestion d'apprentis avec permissions, personnalisation de marque par atelier.

L'application doit fonctionner intégralement hors-ligne au quotidien (connexion internet instable chez les utilisateurs cibles) et se synchroniser automatiquement avec Supabase dès qu'une connexion est disponible.

Le projet est développé avec une vision long terme et doit rester maintenable pendant de nombreuses années.

---

# 2. Valeurs du projet

* Simplicité
* Robustesse
* Fonctionnement hors-ligne fiable
* Lisibilité
* Documentation permanente
* Zéro régression
* Zéro perte de données

---

# 3. Cycle de développement

Le projet est construit par **phases séparées** (voir la demande initiale de spécification). Chaque phase se termine par : un résumé des fichiers créés, une procédure de test sur téléphone, et l'attente de validation avant de passer à la phase suivante.

---

# 4. Règles officielles

1. L'architecture est pilotée de manière centralisée (`lib/core`, `lib/data`, `lib/features`, `lib/shared`).
2. Le chemin exact de chaque fichier est toujours indiqué.
3. Aucune régression n'est acceptée.
4. Aucune donnée financière n'apparaît dans le code, les logs ou les widgets accessibles à un rôle apprenti.
5. Aucune suppression définitive de données métier (client, mesure, champ de mesure utilisé) : on masque, on annule, on corrige.
6. La documentation est maintenue en continu (`PROJECT_STATUS.md`, `CHANGELOG.md`).
7. Toute décision d'architecture non précisée est prise en choisissant l'option la plus stable et documentée, puis signalée dans le résumé de phase.
8. L'interface est entièrement en français, libellés simples, icônes explicites.
9. Le code est commenté en français, uniquement lorsque le "pourquoi" n'est pas évident.

---

# 5. Documentation

* `README.md`
* `PROJECT_STATUS.md`
* `CHANGELOG.md`
* `supabase/schema.sql` (schéma de base de données + RLS)

---

# 6. Engagement

Ce document constitue la référence officielle de gouvernance d'Atelier+. Toute évolution majeure devra être analysée, validée et documentée avant son intégration.
