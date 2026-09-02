# Atelier+

Application mobile de gestion de clientèle pour tailleurs et couturiers
d'Afrique de l'Ouest — fonctionnement intégralement hors-ligne au quotidien,
avec synchronisation automatique vers Supabase dès qu'une connexion est
disponible.

> **Emplacement dans le dépôt.** Ce projet Flutter vit dans le sous-dossier
> `atelier_plus/` du dépôt `forevercare-ai`, isolé du projet existant
> "ForeverCare AI" (racine du dépôt), sans rapport fonctionnel avec lui. Un
> dépôt GitHub dédié n'a pas pu être créé automatiquement (l'intégration
> GitHub utilisée par Claude Code n'a pas la permission "Administration"
> nécessaire) ; ce sous-dossier pourra être extrait vers son propre dépôt
> plus tard si besoin (`git subtree split` ou copie simple, l'historique
> Git de ce sous-dossier est autonome depuis sa création).

## Démarrage

```bash
cd atelier_plus
flutter pub get

# Génération du code Drift (tables locales) — à lancer après la Phase 2
dart run build_runner build --delete-conflicting-outputs

flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxxx
```

Sans variables Supabase configurées, l'application démarre quand même (mode
hors-ligne uniquement) — voir `lib/core/config/supabase_config.dart`.

## Architecture

```
lib/
  core/          Configuration, thème, router, constantes, utilitaires
                 (formatage FCFA / dates françaises), sans dépendance à une
                 fonctionnalité métier précise.
  data/          Sources de données transverses :
                   local/         base Drift (cache SQLite hors-ligne)
                   remote/        client Supabase
                   models/        modèles partagés local <-> distant
                   repositories/  API unique consommée par les features
                   sync/          file d'attente + résolution de conflit
  features/      Un dossier par fonctionnalité, chacun en
                 data/ (accès données spécifiques) + presentation/ (écrans,
                 widgets) + providers/ (état Riverpod) :
                   auth/          création de compte, connexion, apprentis
                   clients/       fiches clients, recherche, photos
                   mesures/       gabarits de tenues, prise de mesure
                   rendezvous/    rendez-vous et rappels
                   finances/      commandes, paiements (propriétaire only)
                   permissions/   droits fins des apprentis
                   abonnement/    essai gratuit / abonnement
                   branding/      personnalisation nom/logo, export PDF
  shared/        Widgets réutilisables sans logique métier propre.
```

`supabase/schema.sql` contient le schéma PostgreSQL complet (tables,
contraintes, index, déclencheurs, fonctions RLS) — voir `supabase/README.md`
pour son application et un résumé des garanties de sécurité.

## Décisions d'architecture (Phase 0)

Choix pris sans arbitrage préalable, conformément à la consigne "choisis
l'option la plus stable et documentée, signale ton choix" :

| Décision | Choix retenu | Raison |
|---|---|---|
| Identifiants d'enregistrement | `uuid` généré côté client (package `uuid`) | Indispensable en offline-first : un client/une mesure créé(e) hors-ligne doit avoir un identifiant définitif immédiatement, sans attendre une réponse serveur. |
| Stockage de la session/PIN | `flutter_secure_storage` | Package le plus stable et documenté pour du stockage chiffré multiplateforme (Keychain iOS / Keystore Android). |
| Compression photo avant upload | `flutter_image_compress` | Package le plus utilisé et maintenu pour cette tâche précise ; complète `image_picker` (capture) sans le remplacer. |
| Gestion d'état Riverpod | Providers écrits à la main, **sans** génération de code (`riverpod_generator`) | Réduit le nombre de générateurs actifs en parallèle avec `drift_dev` (simplicité de build), plus simple à lire pour une petite équipe. Réévaluable plus tard sans rupture d'API si besoin. |
| Modèles de données | Classes Dart manuelles (`fromJson`/`toJson`) plutôt que `freezed`/`json_serializable` | Évite d'ajouter deux générateurs de code supplémentaires dès la Phase 0 ; à reconsidérer si le volume de modèles le justifie en Phase 1-2. |
| Authentification propriétaire/apprenti | Compte Supabase Auth classique (email/mot de passe interne), le "numéro de téléphone provisoire" de l'apprenti servant d'identifiant métier | Supabase Auth n'a pas de mode "PIN" natif ; détaillé en Phase 1. |

## Où en est le projet

- **Phase 0 (ce commit) :** architecture, dépendances, schéma SQL + RLS. ✅
- Phases 1 à 5 : voir la conversation / les commits suivants.

## Note sur la génération de la plateforme native

Cet environnement de développement ne dispose pas du SDK Flutter installé
(build sandboxé), donc `flutter create .` n'a pas pu être exécuté pour
générer les dossiers `android/`, `ios/`, `web/`, etc. Avant le premier build
mobile, exécuter localement :

```bash
cd atelier_plus
flutter create . --platforms=android,ios --org com.atelierplus --project-name atelier_plus
```

Cette commande ne touche pas à `lib/`, `pubspec.yaml` ni `supabase/` déjà en
place ; elle ne fait que générer l'enrobage natif manquant.
