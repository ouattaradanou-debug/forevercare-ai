# cave_manager

Application de gestion de cave à vin / cave à boissons diverses (Burkina
Faso) — Flutter + Supabase + Drift, offline-first.

Voir **[PHASE1.md](./PHASE1.md)** pour le détail complet de la Phase 1
(périmètre, modèle de données, matrice de permissions, critères
d'acceptation, auto-évaluation).

## Mise en route (première fois)

Ce module a été écrit dans un environnement sans Flutter/Dart installé ;
les commandes ci-dessous n'ont donc pas encore été exécutées. À faire côté
développeur avant le premier lancement :

```bash
cd cave_manager

# 1. Génère les dossiers de plateforme (android/, ios/, ...), absents de ce
#    commit — ils sont exclus du dépôt comme dans tout projet Flutter.
flutter create . --project-name cave_manager --org com.votrecave

# 2. Récupère les dépendances déclarées dans pubspec.yaml
flutter pub get

# 3. Génère le code Drift (app_database.g.dart, sync_queue_dao.g.dart)
dart run build_runner build --delete-conflicting-outputs

# 4. Configure le backend (voir supabase/README.md pour la migration SQL)
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxxx

# 5. Tests
dart test test/unit
```

## Structure

```
lib/
  app/            # App root, thème, routeur
  core/
    auth/         # Service d'authentification, providers Riverpod
    config/       # Configuration Supabase (dart-define)
    constants/    # Enums métier (rôles, type de cave)
    database/     # Schéma Drift (cache local offline)
    sync/         # File de synchronisation + moteur
    utils/        # Fonctions pures (FCFA, calcul de paiement)
  features/
    auth/         # Écran de connexion
    cave_setup/   # Configuration initiale de la cave
    home/         # Accueil minimal post-connexion
    splash/       # Démarrage
supabase/
  migrations/     # Schéma SQL + policies RLS
  functions/      # Edge Function de création de comptes équipe
test/
  unit/           # Tests purs (aucune dépendance Flutter/réseau)
  integration/    # Test RLS contre un vrai projet Supabase (optionnel)
```
