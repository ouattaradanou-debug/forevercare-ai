# Atelier+

Atelier+ est une application Flutter de gestion de clientèle pour les tailleurs et couturiers d'Afrique de l'Ouest : fiches clients, mesures corporelles par type de tenue, rendez-vous, suivi financier, gestion d'apprentis avec permissions, personnalisation de marque par atelier.

L'application fonctionne intégralement hors-ligne au quotidien et se synchronise automatiquement avec Supabase dès qu'une connexion est détectée.

## Stack technique

- **Frontend** : Flutter (Dart), Riverpod
- **Backend** : Supabase (PostgreSQL, Auth, Storage, Row Level Security)
- **Base locale hors-ligne** : Drift (SQLite), synchronisation bidirectionnelle
- **Photos** : image_picker (caméra + galerie), compression avant upload
- **Notifications locales** : flutter_local_notifications
- **Navigation** : go_router

## Architecture

```
lib/
  core/       configuration, thème, routeur, utilitaires
  data/       modèles, repositories, sources locale (Drift) et distante (Supabase)
  features/   un dossier par fonctionnalité (auth, clients, mesures, rendezvous,
              finances, permissions, abonnement, branding, home)
  shared/     widgets réutilisables
supabase/
  schema.sql  schéma PostgreSQL complet + politiques Row Level Security
```

## Méthode de développement

Le projet est construit par phases successives, chacune validée sur téléphone avant de passer à la suivante. Voir `PROJECT_STATUS.md` pour l'état d'avancement.
