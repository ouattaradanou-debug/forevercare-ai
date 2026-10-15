# Atelier +

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
| Stockage de la session/PIN | `flutter_secure_storage` retenu en Phase 0, **retiré en Phase 5** | Supabase gère déjà lui-même la persistance sécurisée de sa session ; aucun usage concret ne s'est présenté sur 4 phases (pas d'app-lock local implémenté). Dépendance non utilisée retirée à la vérification finale plutôt que laissée en poids mort. |
| Compression photo avant upload | `flutter_image_compress` | Package le plus utilisé et maintenu pour cette tâche précise ; complète `image_picker` (capture) sans le remplacer. |
| Gestion d'état Riverpod | Providers écrits à la main, **sans** génération de code (`riverpod_generator`) | Réduit le nombre de générateurs actifs en parallèle avec `drift_dev` (simplicité de build), plus simple à lire pour une petite équipe. Réévaluable plus tard sans rupture d'API si besoin. |
| Modèles de données | Classes Dart manuelles (`fromJson`/`toJson`) plutôt que `freezed`/`json_serializable` | Évite d'ajouter deux générateurs de code supplémentaires dès la Phase 0 ; à reconsidérer si le volume de modèles le justifie en Phase 1-2. |
| Authentification propriétaire/apprenti | Compte Supabase Auth classique (email/mot de passe interne), le "numéro de téléphone provisoire" de l'apprenti servant d'identifiant métier | Supabase Auth n'a pas de mode "PIN" natif ; détaillé en Phase 1. |
| Création d'apprenti (Phase 1) | Fonction Edge Supabase `creer-apprenti` (clé `service_role`) plutôt qu'un appel client direct | `auth.signUp` côté client remplacerait la session du propriétaire par celle du nouvel apprenti (une seule session gérée à la fois par le SDK). Voir `supabase/functions/creer-apprenti/`. |
| Base locale Drift (Phase 1) | Introduite dès maintenant avec un socle minimal (identité : atelier, utilisateurs, permissions, session locale), étendue en Phase 2/3 avec clients/mesures/etc. | Évite une double mécanique locale temporaire (ex. `flutter_secure_storage` pour un cache JSON) qui serait de toute façon remplacée à la Phase 2 ; la session doit être connue hors-ligne dès la Phase 1 (contrainte transversale "fonctionne hors-ligne au quotidien"). |
| Écritures clients/mesures/photos (Phase 2) | Toujours locales d'abord (Drift), puis tentative best-effort vers Supabase ; échec silencieux si hors-ligne | Satisfait l'exigence "créer client / prendre mesure" utilisable hors-ligne au quotidien, sans anticiper la vraie file d'attente de synchronisation (retries, résolution de conflit) qui est le périmètre explicite de la Phase 3. |
| Écritures gabarits (types_tenue/champs_mesure, Phase 2) | Serveur d'abord (pas d'écriture locale immédiate) | Action administrative peu fréquente (absente de la liste "usage hors-ligne quotidien" du cahier des charges), dont la cohérence (contrainte d'unicité, RLS propriétaire) doit être garantie par Supabase avant tout reflet local. |
| Bucket Storage `photos-clients` (Phase 2) | Public (comme `logos-ateliers`), chemins non énumérables (UUID) | Évite la complexité des URLs signées à renouveler pour de simples photos de tissus/modèles, non classées "données sensibles" dans le cahier des charges (contrairement aux données financières). Voir `supabase/storage_photos_clients.sql`. |
| Écritures rendez-vous/commandes/paiements (Phase 3) | Locales d'abord, via la même file d'attente de synchronisation que clients/mesures (`data/sync/`) | Un rendez-vous fait partie de l'usage quotidien hors-ligne ("noter RDV"). Pour les finances, la file d'attente désormais réelle (retries + résolution de conflit) rend le local-first sûr — contrairement au choix "serveur d'abord" retenu pour les gabarits en Phase 2, qui reste inchangé (action rare, hors du périmètre synchronisé). |
| Rappel de rendez-vous (Phase 3) | Un seul rappel, 1 heure avant, via `flutter_local_notifications` + `timezone`/`flutter_timezone` | Simple et suffisant pour le besoin exprimé ; `timezone`/`flutter_timezone` sont les packages recommandés par la documentation officielle de `flutter_local_notifications` pour la planification exacte (`zonedSchedule`). |
| Modèle "commande" (Phase 3) | Une seule commande par client (montant total + avance ajustables), pas une liste de commandes distinctes | Correspond à l'écran "finances par client" du cahier des charges ; extensible plus tard si plusieurs commandes simultanées par client sont nécessaires. |
| Cache financier local (Phase 3) | Effacé à la déconnexion (si rien n'est en attente d'envoi) | Un appareil peut être partagé entre le propriétaire et un apprenti : les données financières ne doivent jamais rester lisibles sur le disque après le départ du propriétaire, en plus du filtrage déjà fait par l'écran et par la RLS. |
| Export PDF (Phase 4) | `pdf` + `printing` (nouvelles dépendances), logo téléchargé via `http` (nouvelle dépendance) | Choix les plus stables/documentés de l'écosystème Flutter pour la génération et le partage/impression de PDF ; `printing` fournit l'aperçu système sans gérer soi-même les permissions de stockage. |
| Statut réel de l'essai (Phase 4) | Calculé côté application (`estEnModeConsultationSeule`) plutôt que de faire confiance à `abonnements.statut` seul | Aucune tâche planifiée côté serveur ne fait passer `statut` de 'essai' à 'expire' quand `date_fin_essai` est dépassée (non demandé au cahier des charges) : l'échéance réelle est donc déterminée en comparant la date actuelle à `date_fin_essai`, en plus de `statut`. |
| Mode consultation seule (Phase 4) | Vérifié en tête de chaque méthode d'écriture des repositories "métier" (clients, mesures, photos, rendez-vous, finances, gabarits), pas dans chaque écran | Point de contrôle unique et systématique plutôt que de désactiver un bouton dans une quinzaine d'écrans séparément ; échoue "ouvert" (n'écrase jamais) si l'abonnement n'est pas encore en cache, pour ne jamais bloquer un nouvel utilisateur légitime par un simple délai de synchronisation. Les actions de compte (connexion, apprentis) restent volontairement exclues de ce blocage. |
| Renouvellement d'abonnement (Phase 4) | Écran d'information + contact, pas de paiement réel | Aucun prestataire de paiement n'était spécifié au cahier des charges ; simuler un paiement fonctionnel aurait été trompeur. Point d'extension explicitement laissé pour une intégration future (Mobile Money ou autre). |

## Où en est le projet

- **Phase 0 :** architecture, dépendances, schéma SQL + RLS. ✅
- **Phase 1 :** authentification (création de compte atelier, connexion
  téléphone + PIN, récupération du profil sur nouvel appareil), gestion des
  apprentis, panneau de permissions. ✅
- **Phase 2 :** clients (liste, recherche instantanée, création/édition),
  gabarits de mesure (12 gabarits par défaut, gestion des champs avec
  masquage et duplication), prise de mesure historisée avec
  pré-remplissage, photos de tissus/modèles. ✅
- **Phase 3 :** rendez-vous (création, liste triée, rappel local
  programmé), finances par client (reste à payer calculé automatiquement,
  historique des paiements, réservé au propriétaire), couche de
  synchronisation Drift ↔ Supabase (file d'attente, déclenchement
  automatique via `connectivity_plus`, résolution de conflit par
  horodatage avec journalisation). ✅
- **Phase 4 :** nom/logo de l'atelier appliqués dynamiquement (écran
  d'accueil + export PDF de fiche client avec dernières mesures par type
  de tenue), essai gratuit de 30 jours avec bandeau de rappel (J-7 à J-1),
  mode consultation seule appliqué au niveau des repositories (jamais de
  perte de données, aucune écriture bloquée n'est jamais silencieuse). ✅
- **Phase 5 (ce commit) — vérification finale :** voir le détail complet
  ci-dessous. ✅

## Phase 5 — Vérification finale

Relecture explicite des quatre garanties demandées, par lecture directe du
code (RLS + Dart), pas par simple rappel de ce qui avait été annoncé aux
phases précédentes :

1. **Un apprenti ne peut jamais accéder à `commandes`/`paiements`,
   même indirectement.** Vérifié à trois niveaux : RLS (`commandes_all`/
   `paiements_all` exigent `est_proprietaire()`, sans aucune exception liée
   à une permission) ; `permissions_apprenti` ne contient aucune colonne
   financière ; côté application, `financesRepositoryProvider` et les
   providers qui en dépendent ne sont référencés QUE dans
   `EcranFinancesClient`, lui-même gardé par un contrôle de rôle avant
   affichage. Cas limite vérifié aussi : sur un appareil partagé où une
   tâche de synchronisation financière resterait en attente après le
   départ du propriétaire, la relecture côté serveur (RLS) renvoie un
   résultat vide sous session apprenti — aucune valeur financière n'est
   donc jamais lue localement, et aucune entrée `journal_actions` n'est
   créée dans ce cas (la journalisation de conflit ne se déclenche que si
   la ligne serveur a pu être lue).
2. **La suppression d'un champ de mesure utilisé est bien bloquée.**
   Aucune politique RLS `DELETE` n'existe sur `champs_mesure` (vérifié dans
   `schema.sql`) et aucune méthode de suppression n'existe côté client
   (grep confirmé) : seul le masquage (`statut = 'masque'`) est possible,
   inconditionnellement — la protection est donc plus forte que "bloquée
   si utilisée", elle est bloquée en toute circonstance.
3. **L'application reste utilisable hors-ligne pour créer un client,
   prendre une mesure, noter un rendez-vous.** Confirmé pour les trois
   écritures (locales d'abord, `verifierEcritureAutorisee` n'accède qu'au
   cache local). **Un bug réel a été trouvé et corrigé pendant cette
   vérification** : `EcranSelectionTypeTenue` (l'étape "quel type de
   tenue ?" avant la prise de mesure) ne rapatriait jamais les gabarits
   depuis le serveur — seul l'écran de gestion des gabarits (réservé au
   propriétaire) le faisait. Un tailleur ou un apprenti passant directement
   par "Prendre une mesure" sans jamais avoir ouvert "Mes types de tenue"
   voyait donc une liste vide, même en ligne. Corrigé : cet écran rapatrie
   désormais aussi les gabarits par défaut à son ouverture.
4. **Le logo/nom d'atelier n'est modifiable que par le compte
   propriétaire.** La RLS (`ateliers_update`) l'impose correctement. Constat
   honnête cependant : **aucun écran ne permet actuellement de modifier le
   nom/logo après la création du compte**, pour le propriétaire comme pour
   quiconque — seule la création initiale (Phase 1) écrit dans `ateliers`.
   La garantie demandée est donc vraie mais non démontrée par un vrai flux
   "le propriétaire modifie, l'apprenti ne peut pas" ; ajouter cet écran
   d'édition serait une extension naturelle d'une phase future.

**Nettoyage effectué en cours de vérification** : `flutter_secure_storage`,
retenu en Phase 0, n'a jamais été utilisé dans le code sur les 4 phases
suivantes (Supabase gère déjà sa propre persistance de session) — retiré du
`pubspec.yaml` plutôt que laissé en dépendance morte.

### Tests à écrire en priorité

Déjà écrits dans `test/` (fonctions pures, aucune dépendance à mocker) :
- `test/features/finances/data/calcul_solde_test.dart` — `resteAPayer`
  (cas normal, trop-perçu négatif, soldé, sans aucun paiement).
- `test/features/abonnement/data/etat_abonnement_test.dart` —
  `estEnModeConsultationSeule`, `joursRestantsEssai`,
  `doitAfficherRappelEssai` (essai en cours, dépassé, actif, expiré,
  suspendu).

Restent à écrire (nécessitent de mocker `SupabaseClient`/`AppDatabase`,
non tentés ici pour ne pas ajouter une dépendance de mock — ex. `mocktail`
— sans validation du besoin par l'équipe) :
- **`SyncEngine.traiterFileAttente`** : la tâche la plus critique à
  couvrir. Cas à tester : reprise après échec réseau (la tâche reste en
  file avec `tentatives` incrémenté) ; résolution de conflit "serveur plus
  récent gagne" sur `clients`/`rendez_vous`/`commandes` (vérifier que le
  cache local est bien réaligné et qu'une entrée `journal_actions` est
  créée) ; non-régression sur `mesures`/`paiements` (jamais de vérification
  de conflit, toujours un simple insert) ; traitement idempotent d'une
  violation de contrainte d'unicité sur un insert déjà appliqué (code
  Postgres `23505` → tâche retirée sans erreur, pas de boucle infinie).
- **Permissions** (`permissions_apprenti` + gardes d'écran) : pour chacun
  des 5 droits, vérifier qu'un apprenti sans la permission voit l'action
  désactivée/masquée ET que l'appel repository correspondant échoue côté
  RLS s'il est forcé directement (défense en profondeur, pas seulement
  l'UI) ; vérifier spécifiquement qu'aucune combinaison de permissions
  n'accorde jamais d'accès à `commandes`/`paiements`.
- **`ClientsRepository`/`MesuresRepository`/`RendezVousRepository`** :
  vérifier qu'un échec réseau simulé sur l'envoi immédiat aboutit bien à
  une entrée dans `SyncQueueEntries` avec le bon `payloadJson`, et que
  l'écriture locale a quand même réussi (le cœur de la promesse
  offline-first).
- **`verifierEcritureAutorisee`** : vérifie qu'elle bloque bien en mode
  consultation seule, qu'elle laisse toujours passer un abonnement actif,
  et — cas volontairement permissif à documenter dans le test — qu'elle
  ne bloque jamais quand aucun abonnement n'est encore en cache.

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
