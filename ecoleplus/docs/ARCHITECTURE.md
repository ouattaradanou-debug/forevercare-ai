# Architecture — EcolePlus (nom provisoire)

> Phase 0 — document de cadrage technique. Toute évolution passe par docs/EVOLUTIONS.md.

## 1. Vue d'ensemble

```
 Téléphone Android (Flutter)                       Supabase
 ┌────────────────────────────────┐               ┌──────────────────────────────────┐
 │ Écrans (Riverpod, go_router)   │               │ Auth (identifiant / téléphone)   │
 │        │ lit / écrit           │               │ Postgres 17 + RLS sur TOUT       │
 │        ▼                       │   push (RPC)  │  ├ schéma public (école, notes…) │
 │ Base locale Drift (SQLite)     │──────────────▶│  ├ schéma medical (séparé)       │
 │  = source de vérité de l'UI    │               │  └ pgvector + texte intégral FR  │
 │ File d'envoi (outbox)          │◀──────────────│ Storage privé (photos, docs)     │
 │ Indicateur « N en attente »    │   pull        │ Edge Functions (IA, indexation)  │
 └────────────────────────────────┘  (curseur)    └──────────────────────────────────┘
```

* L'interface ne lit et n'écrit **que** dans la base locale. Le réseau sert à synchroniser, jamais à afficher.
* La sécurité est appliquée **dans Postgres** (RLS, triggers) : l'interface ne protège rien.
* Aucune clé `service_role` ni clé d'IA dans l'application (variables d'environnement côté serveur).

## 2. Outils et versions (installés dans l'environnement de développement)

| Outil | Version | Remarque |
|---|---|---|
| Flutter / Dart | 3.47.7 / 3.13.5 | canal stable |
| Supabase CLI | 2.121.0 | installée via npm |
| Postgres (Supabase local) | 17.11 | extensions `vector` 0.8.2, `pg_trgm`, `unaccent`, `pgtap` 1.3.3 |
| Tesseract (banc d'essai OCR) | 5.3.4 + `fra` | outil de mesure, pas une dépendance de l'application |
| Android SDK | **absent** | `dl.google.com` refusé par le réseau de l'environnement cloud : APK à construire sur un poste local ou après ouverture du domaine |

## 3. Paquets Flutter retenus

Critères : maintenu (publication récente), compatible Flutter 3.47 / Dart 3.13, léger. Les versions sont celles de pub.dev au 20/10/2026. **Seuls les paquets de la phase en cours sont ajoutés au `pubspec.yaml`** ; les autres sont présélectionnés ici et ajoutés dans leur phase.

| Besoin | Paquet | Version | Dernière publication | Phase | Justification |
|---|---|---|---|---|---|
| État | `flutter_riverpod` | 3.4.3 | 09/2026 | 0 | imposé (R2), testable sans widgets |
| Navigation | `go_router` | 18.1.x | 10/2026 | 0 | imposé (R2), prêt pour le web |
| Lints stricts | `very_good_analysis` | 11.0.0 | 09/2026 | 0 | règles strictes + `strict-casts/inference/raw-types` |
| Base locale | `drift`, `drift_flutter`, `drift_dev` | 2.35.x / 0.3.1 | 10/2026 | 1 | SQL typé, migrations, flux réactifs, fonctionne aussi sur le web (WASM) |
| Backend | `supabase_flutter` | 2.18.3 | 10/2026 | 1 | client officiel (auth, RPC, storage) |
| Identifiants | `uuid` | 4.6.0 | 07/2026 | 1 | UUID v4/v7 générés hors ligne |
| Formats FR | `intl` | 0.20.3 | 06/2026 | 1 | dates, nombres « 14,5 », FCFA |
| PDF | `pdf` + `printing` | 3.13.1 / 5.15.1 | 09/2026 | 2 | dessin vectoriel A4 paysage, tableaux, **QR code intégré** (pas besoin de `qr_flutter`, non publié depuis 2023), impression et partage |
| Excel | `excel` | 4.0.6 | 08/2024 | 2 | ⚠️ peu actif mais pur Dart, sans licence commerciale ; alternative `syncfusion_flutter_xlsio` écartée (licence Syncfusion). Repli prévu : import CSV |
| Choix de fichiers | `file_picker` | 13.1.0 | 09/2026 | 2 | import Excel, ajout de documents en lot |
| Partage | `share_plus` | 13.3.1 | 10/2026 | 2 | partage PDF (WhatsApp) |
| Dictée | `speech_to_text` | 7.5.0 | 09/2026 | 2 | reconnaissance native Android (voir §11) |
| Caméra / photo | `image_picker` | 1.2.4 | 10/2026 | 8 | caméra système, pas de dépendance lourde |
| Recadrage | `image_cropper` | 13.0.0 | 10/2026 | 8 | recadrage guidé du visage (exige Flutter ≥ 3.47) |
| Compression | `flutter_image_compress` | 2.5.1 | 07/2026 | 8 | compression native (WebP/JPEG) ciblant ≤ 40 Ko |
| Scan QR (si 12.4 accepté) | `mobile_scanner` | 7.4.2 | 09/2026 | 8 | ⚠️ ajout proposé, voir EVOLUTIONS |
| Empreinte de fichier | `crypto` | 3.0.7 | 11/2025 | 9 | SHA-256 pour les doublons |
| Connectivité | `connectivity_plus` | 7.3.2 | 10/2026 | 1 | déclenche la synchronisation au retour du réseau (jamais bloquant) |

Écartés : `sqflite` (pas de typage ni de flux réactifs), `hive`/`isar` (pas de SQL ni de jointures pour les calculs de classement), Firebase (hors stack).

## 4. Structure du code

```
ecoleplus/
├── lib/
│   ├── main.dart
│   ├── app/                  # application, thème, routeur
│   ├── core/                 # widgets communs, (phase 1) base locale, sync, auth
│   └── features/<module>/    # une fonctionnalité = un dossier
│        ├── data/            # tables Drift, dépôts, synchro du module
│        ├── domain/          # logique métier pure Dart (calculs testés)
│        └── presentation/    # écrans et widgets
├── test/                     # tests unitaires et widgets
├── supabase/
│   ├── migrations/           # schéma versionné (une migration par domaine)
│   ├── tests/                # tests pgTAP (RLS, intégrité, calculs)
│   └── seed.sql              # « École Test » (fictif)
├── tools/ocr_bench/          # banc d'essai OCR et mesure de l'index
└── docs/
```

La logique métier (moyennes, rang, soldes, numérotation, normalisation des nombres dictés) vit dans `domain/` en Dart pur : elle tourne hors ligne et se teste sans téléphone.

## 5. Schéma de données

71 tables (67 dans `public`, 4 dans `medical`), une migration par domaine :

| Migration | Contenu |
|---|---|
| `…0100_socle` | `levels` (référentiel), `schools`, `school_years`, `admin_headers` (en-têtes **par année**), `school_modules`, `memberships`, `delegate_permissions`, `devices`, `school_counters`, `audit_log`, `sync_conflicts` |
| `…0200_personnel` | `teachers`, `teacher_postings`, `teacher_interruptions`, `teacher_awards`, `teacher_diplomas` (historiques B3 en listes) |
| `…0300_classes_eleves` | `classes`, `teacher_year_assignments`, `students`, `guardians`, `enrollments`, `annual_results`, `scolarity_followups`, `scolarity_followup_courses`, `attendance` |
| `…0400_notes_bulletins` | `subjects`, `class_subjects` (coefficients), `assessments` (compositions, barème), `grades`, `mention_scales`, `report_templates`, `report_cards`, `timetable_slots` |
| `…0500_maternelle` | `learning_domains`, `qualitative_levels` (couleur + pictogramme), `preschool_periods`, `preschool_evaluations`, `preschool_booklets` |
| `…0600_finances_cantine` | `fee_items`, `fee_installments`, `discounts`, `student_discounts`, `payments`, `payment_allocations`, `expenses`, `cash_closings`, `canteen_settings`, `canteen_beneficiaries`, `meal_services`, `meal_checks`, `stock_products`, `stock_movements`, `canteen_menus` |
| `…0700_medico_scolaire` | schéma `medical` : `records`, `yearly_exams`, `fitness`, `access_log` |
| `…0800_formulaires_cartes` | `official_forms` (état, « Fait à … le … », date de référence B1), `form_versions` (version finale verrouillée), `activity_objectives`, `activity_lines` (B6 + B7), `scolarity_copy_log`, `card_templates`, `student_cards` (jeton QR opaque) |
| `…0900_bibliotheque_ia` | `documents`, `document_levels`, `document_classes`, `document_chunks` (texte intégral FR + vecteur), `lesson_preps`, `ai_requests`, `ai_quotas` |
| `…1000_rls_et_integrite` | RLS sur toutes les tables, triggers génériques (synced_at, interdiction de suppression, ajout seul) |

### 5.1 Conventions communes
* `id uuid` généré **par l'appareil** ; `school_id` sur chaque ligne (cloisonnement et RLS simples).
* `updated_at` : horloge de l'appareil (règle « dernière modification gagne ») ; `synced_at` : horloge serveur (curseur de téléchargement).
* `deleted_at` : suppression logique. Un trigger **refuse toute suppression physique** des tables scolaires et financières (seuls les documents en corbeille seront purgés, phase 9).
* Énumérations en texte + `CHECK` (reproductibles telles quelles dans Drift).
* Montants en FCFA entiers (`bigint`), notes `numeric(5,2)`, moyennes arrondies à 2 décimales.

### 5.2 Ce que le schéma garantit (prouvé par les tests pgTAP)
* **Moyenne, total des points, rang, effectif** : calculables à partir de `grades` + `class_subjects.coefficient` + `enrollments` ; résultat annuel figé dans `annual_results` (moyenne, rang, ex-aequo, effectif → « 7e/39 »).
* **Note hors barème refusée** (trigger sur `assessments.max_score`).
* **Reçus inaltérables** : `payments`, `payment_allocations`, `expenses`, `cash_closings`, `stock_movements` sont en ajout seul ; une annulation est une contre-passation négative, motivée, liée à l'écriture d'origine (une seule annulation possible).
* **Registre matricule** : numéro d'ordre attribué par le serveur, continu, jamais réutilisé ni modifié.
* **Évaluations de maternelle** sans note chiffrée (niveau qualitatif).
* **Archives jamais indexées pour l'IA** (`CHECK` + trigger sur les vecteurs).
* **Version finale de formulaire verrouillée**.

### 5.3 Ce que le schéma ne fait pas encore (phases suivantes)
Politiques RLS par profil (phase 1 pour le socle, puis chaque module), refus d'écriture des modules désactivés (phase 1), buckets de stockage (phases 8-9), fonctions d'accès au dossier médical (phase 7).

## 6. Synchronisation hors ligne (conçue en phase 0, construite en phase 1)

**Écriture** : écran → transaction Drift (ligne + entrée dans `outbox`) → retour immédiat. L'indicateur affiche « Tout est synchronisé » ou « N éléments en attente » (= taille de l'outbox).

**Envoi (push)** : dès que le réseau revient (et toutes les X minutes), l'outbox est envoyée par lots à une fonction Postgres `sync_push` exécutée **avec les droits de l'utilisateur** (RLS appliquée). Chaque table suit une règle :

| Règle | Tables | Comportement serveur |
|---|---|---|
| Dernière modification gagne, avec trace | élèves, fiches, notes, bulletins, formulaires, paramètres… | si `updated_at` entrant ≥ serveur : écrase et copie la version perdante dans `sync_conflicts` ; sinon : ignore et trace |
| Fusion par clé métier | `attendance` (élève + date), `meal_checks` (élève + jour), `meal_services` (jour + classe), `grades` (composition + élève + matière) | `insert … on conflict (clé métier)` puis règle précédente sur la ligne |
| Ajout seul | `payments`, `payment_allocations`, `expenses`, `stock_movements`, journaux | `insert … on conflict (id) do nothing` : un renvoi ne crée jamais de doublon, rien n'est écrasé |

**Téléchargement (pull)** : par table, lignes dont `synced_at` > dernier curseur (horloge serveur ; fenêtre de recouvrement de quelques minutes, application idempotente). Les valeurs attribuées par le serveur (numéro d'ordre du registre) reviennent ainsi sur l'appareil.

**Horloges** : un téléphone à l'heure fausse fausserait « dernière modification gagne ». À chaque synchronisation, l'écart avec l'heure du serveur est mesuré et corrige `updated_at` des écritures en attente (à tester en phase 1).

**Fichiers** (photos, documents) : file séparée, envoi reprenable par morceaux ; jamais de téléchargement automatique des documents (catalogue seulement).

## 7. Numérotation hors ligne

| Objet | Mécanisme | Exemple | Pourquoi |
|---|---|---|---|
| Reçus (et pièces de dépense, mouvements de stock) | **Série par appareil** attribuée en ligne à l'inscription du téléphone (`devices.series_code`), compteur local par série et par année, incrémenté dans la même transaction que l'encaissement ; le serveur vérifie la cohérence | `R2526-A-00012` | Deux appareils hors ligne ne peuvent jamais produire le même numéro ; le numéro est imprimable tout de suite et ne change jamais |
| Numéro d'ordre du registre matricule (B2) | **Attribué par le serveur** à la synchronisation (compteur continu) ; hors ligne, l'appareil affiche un numéro provisoire (`P-A-0003`) | `152` | Le registre exige une suite continue sans trou et dans l'ordre d'admission : seule une autorité centrale le garantit |

Limites (à valider) : la numérotation des reçus est continue **par série**, pas pour toute l'école ; si un téléphone est perdu avant synchronisation, sa série peut présenter un trou (les reçus papier remis existent). Réinstallation : l'appareil récupère son dernier numéro depuis le serveur avant tout nouveau reçu (sinon il reçoit une nouvelle série). Reprise d'un registre papier : un numéro saisi est accepté et le compteur repart après le plus grand.

## 8. Sécurité et RLS (plan)

* Phase 0 : RLS activée **partout**, aucune politique → refus total pour `anon` et `authenticated` (testé). Seul le référentiel `levels` est lisible.
* Phase 1 : fonctions `app.my_role(school)`, `app.my_class_ids()`, `app.has_permission(school, clé)`, `app.module_enabled(school, module)` (`security definer`, `stable`), puis politiques par famille :
  * données d'école (directeur) ; données de classe (enseignant : uniquement ses classes via `classes.main_teacher_id` / affectations) ;
  * finances : directeur + délégué `finances` ; jamais enseignant ;
  * personnel et registres : directeur + délégué `registres` ;
  * modules optionnels : `module_enabled(...)` dans `using` **et** `with check` → lectures vides, écritures refusées, données conservées ;
  * `medical` : aucune politique directe ; accès par fonctions dédiées journalisées (phase 7).
* Stockage : buckets privés, chemins `{school_id}/…`, politiques sur `storage.objects` identiques aux tables, URL signées courtes.
* Index IA : `document_chunks` hérite des droits du document (même fonction d'accès).
* Secrets : `.env` ignoré par Git, modèle `.env.example` fourni.

## 9. Modules optionnels (R11)

Table `school_modules` (clé, activé, date, auteur), tout désactivé par défaut. P6 étant reporté, Finances, Cartes et Bibliothèque IA restent toujours actifs en version 1. Dépendance unique : la Cantine exige les Finances (toujours vraies en V1 tant que P6 est reporté). Aucune table du noyau ne référence une table optionnelle.

## 10. IA

Appels uniquement depuis une Edge Function (fournisseur et modèle par variables d'environnement `AI_PROVIDER`, `AI_MODEL`, `AI_API_KEY`), quotas par école (`ai_quotas`), demandes conservées hors ligne (`ai_requests`). Aucune donnée nominative ni médicale envoyée ; documents traités comme données non fiables. Détails et coûts : docs/BIBLIOTHEQUE_ET_IA.md.

## 11. Dictée vocale (module 13.4)

| Critère | Reconnaissance native Android (`speech_to_text`) | Service en ligne (ex. API cloud de transcription) | Modèle d'IA de transcription (type Whisper) |
|---|---|---|---|
| Hors ligne | Oui si le pack français est installé sur le téléphone (variable selon appareil) | Non | Non (en ligne) ; sur l'appareil : trop lourd pour 2 Go de RAM |
| Accents d'Afrique de l'Ouest | Correct pour phrases courtes (à mesurer) | Bon | Généralement le meilleur |
| Bruit de classe | Moyen | Moyen à bon | Bon |
| Coût | Gratuit | Payant à la minute | Payant à la minute |
| Confidentialité | Traitement par le service vocal du téléphone (Google) | Audio envoyé à un tiers | Audio envoyé à un tiers |
| Poids APK | Quasi nul | Faible | Faible (en ligne) |

**Recommandation** : reconnaissance native (gratuite, sans poids, souvent hors ligne), avec confirmation visuelle systématique et clavier toujours disponible. Les nombres dictés (« quatorze virgule cinq ») sont normalisés par notre propre code Dart testé. Qualité réelle à mesurer sur un vrai téléphone en phase 2.

## 12. Tests et pipeline

* `flutter analyze` (lints stricts) + `flutter test` (unitaires et widgets).
* `supabase test db` : pgTAP (RLS partout, intégrité, calculs sur « École Test »).
* `.github/workflows/ecoleplus.yml` : exécute les deux à chaque push touchant `ecoleplus/`.
* Script local : `tools/check.sh`.
