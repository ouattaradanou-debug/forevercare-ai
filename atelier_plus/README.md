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

# Génération du code Drift (obligatoire dès maintenant : lib/data/local/database.dart
# définit déjà les tables de cache local de l'identité utilisateur/atelier)
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
| Création d'apprenti (Phase 1) | Fonction Edge Supabase `creer-apprenti` (clé `service_role`) plutôt qu'un appel client direct | `auth.signUp` côté client remplacerait la session du propriétaire par celle du nouvel apprenti (une seule session gérée à la fois par le SDK). Voir `supabase/functions/creer-apprenti/`. |
| Base locale Drift (Phase 1) | Introduite dès maintenant avec un socle minimal (identité : atelier, utilisateurs, permissions, session locale), étendue en Phase 2/3 avec clients/mesures/etc. | Évite une double mécanique locale temporaire (ex. `flutter_secure_storage` pour un cache JSON) qui serait de toute façon remplacée à la Phase 2 ; la session doit être connue hors-ligne dès la Phase 1 (contrainte transversale "fonctionne hors-ligne au quotidien"). |
| Écritures clients/mesures/photos (Phase 2) | Toujours locales d'abord (Drift), puis tentative best-effort vers Supabase ; échec silencieux si hors-ligne | Satisfait l'exigence "créer client / prendre mesure" utilisable hors-ligne au quotidien, sans anticiper la vraie file d'attente de synchronisation (retries, résolution de conflit) qui est le périmètre explicite de la Phase 3. |
| Écritures gabarits (types_tenue/champs_mesure, Phase 2) | Serveur d'abord (pas d'écriture locale immédiate) | Action administrative peu fréquente (absente de la liste "usage hors-ligne quotidien" du cahier des charges), dont la cohérence (contrainte d'unicité, RLS propriétaire) doit être garantie par Supabase avant tout reflet local. |
| Bucket Storage `photos-clients` (Phase 2) | Public (comme `logos-ateliers`), chemins non énumérables (UUID) | Évite la complexité des URLs signées à renouveler pour de simples photos de tissus/modèles, non classées "données sensibles" dans le cahier des charges (contrairement aux données financières). Voir `supabase/storage_photos_clients.sql`. |

## Où en est le projet

- **Phase 0 :** architecture, dépendances, schéma SQL + RLS. ✅
- **Phase 1 :** authentification (création de compte atelier, connexion
  téléphone + PIN, récupération du profil sur nouvel appareil), gestion des
  apprentis, panneau de permissions. ✅
- **Phase 2 (ce commit) :** clients (liste, recherche instantanée,
  création/édition), gabarits de mesure (12 gabarits par défaut, gestion
  des champs avec masquage et duplication), prise de mesure historisée avec
  pré-remplissage, photos de tissus/modèles. ✅
- Phases 3 à 5 : voir la conversation / les commits suivants.

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
