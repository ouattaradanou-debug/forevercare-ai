# Registre des évolutions (R6)

| N° | Origine | Description | Décision | Phase |
|---|---|---|---|---|
| E0 | Décision de démarrage | Application construite dans le sous-dossier `ecoleplus/` du dépôt `forevercare-ai` (le dépôt contient une autre application, non modifiée) ; déplaçable dans un dépôt dédié | Acceptée (20/10/2026) | 0 |
| E1 | Décision de démarrage | Nom provisoire « EcolePlus », paquet Android `bf.sedatech.ecoleplus` (à remplacer) | Défaut accepté | 0 |
| E2 | Décision de démarrage | Supabase local (CLI) ; IA configurable par variables d'environnement via Edge Function ; barème sur 10 par matière ; émulateur seulement ; aucun module optionnel actif ; quota bibliothèque 5 Go | Défauts acceptés | 0 |
| E3 | Décision du porteur (21/10/2026) | Règle de l'élève absent **paramétrable par école** (`schools.absent_rule`). Valeur de départ : l'élève absent n'a pas de note (affiché « Abs. ») et la composition manquante n'est pas comptée à zéro | Acceptée — à confirmer avec un directeur avant la phase 3 | 1 (paramètre), 3 (calcul) |
| E4 | Choix technique (phase 1) | Connexion par numéro de téléphone **sans SMS** : le numéro sert d'identifiant avec un mot de passe ; mot de passe oublié par e-mail (code à 6 chiffres) ou réinitialisé par le directeur | Appliqué — à valider | 1 |
| P1 | Annexe C | Reprise du programme d'activités de l'année précédente + bibliothèque d'objectifs | Reportée (V2) | — |
| P2 | Annexe C | Rappels d'échéances du programme d'activités | Reportée (V2) | — |
| P3 | Annexe C | Numérisation de documents par la caméra | Reportée (V2) | — |
| P4 | Annexe C | Budget prévisionnel, bilans AGR / COGES | Reportée (V2) | — |
| P5 | Annexe C | Aide IA à la rédaction du bilan annuel | Reportée (V2) | — |
| P6 | Annexe C | Finances, Cartes, Bibliothèque IA activables par école | Reportée (V2) | — |
| P7 | Annexe C | Transfert sécurisé du dossier d'un élève muté | Reportée (V2) — recommandation initiale : V3 | — |
| A1 | ⚠️ Ajout proposé (phase 0) | Vérification de la carte scolaire par scan du QR code (12.4) — ne remplace pas la création des cartes | Reportée (V2), décision du 21/10/2026 | — |
| A2 | ➕ Ajout demandé (21/10/2026) | Carte créée automatiquement depuis la fiche élève et sa photo ; photo **prise par la caméra OU importée** (galerie, fichier, photo scannée, photo d'identité papier photographiée puis recadrée) — fiche ci-dessous | En attente de validation (rapport phase 1) — recommandation : maintenant | 8 |
| A3 | ⚠️ Ajout proposé (phase 1) | Récupération du mot de passe par SMS — fiche ci-dessous | Remplacée par A5 (décision du 21/10/2026) | — |
| A5 | ➕ Ajout demandé (21/10/2026) | Mot de passe oublié par **question secrète** — fiche ci-dessous | **Acceptée** avec protections (21/10/2026) — construite | 1 |
| A6 | ➕ Ajout demandé (21/10/2026) | Toutes les données de l'école enregistrées et **récupérables en cas de perte ou de changement de téléphone** (directeur et enseignant) — fiche ci-dessous | **Acceptée** : images sur nouveau téléphone, déconnexion d'un téléphone perdu, alerte (rendue **conditionnelle** à la demande du porteur), sauvegarde du serveur — construite | 1 |
| A7 | ➕ Ajout demandé (21/10/2026) | **Tester sur un vrai téléphone après chaque phase** (APK installable) — fiche ci-dessous | **Acceptée** : Supabase gratuit + GitHub — construite ; reste à saisir les secrets (porteur) | 1, puis chaque phase |
| A8 | ➕ Ajout demandé (21/10/2026, réponse A6) | **Verrouillage par code PIN ou empreinte** à l'ouverture — fiche ci-dessous | Construite — à confirmer dans le rapport | 1 |
| A9 | ➕ Ajout demandé (21/10/2026, réponse A6) | **Journal d'activité** : connexions et actions, qui a fait quoi — fiche ci-dessous | Construite — à confirmer dans le rapport | 1 |
| A10 | ⚠️ Ajout proposé (phase 1) | Chiffrement de la base locale du téléphone (SQLCipher) — fiche ci-dessous | En attente — recommandation : avant la phase 2 | 2 |
| A4 | ⚠️ Ajout proposé (phase 1) | Chiffrement du fichier de sauvegarde par un code choisi par le directeur — fiche ci-dessous | En attente — recommandation : maintenant (début de phase 2) ; la sauvegarde du **serveur**, elle, est déjà chiffrée | 2 |

## Fiche d'impact A2 — Photo de la carte : caméra ou import
* **Description** : depuis la fiche élève, deux boutons : « Prendre une photo » (caméra) et « Importer une photo » (galerie du téléphone ou fichier : photo envoyée par un parent, photo scannée, photo d'identité papier photographiée). Dans les deux cas, le même cadre de recadrage du visage, puis la même compression. La carte est ensuite générée automatiquement à partir de la fiche élève (nom, prénom, classe, année, identifiant, école) et de cette photo — ce qui était déjà prévu en 12.2-12.3 ; l'ajout porte sur l'import.
* **Valeur** : beaucoup d'écoles ont déjà des photos d'identité papier ou des photos envoyées par les parents ; inutile de refaire toutes les photos en classe.
* **Profils** : directeur, délégué ayant le droit « Cartes scolaires ».
* **Impact** — tables : aucune nouvelle (`students.photo_path`, `student_cards` existent) ; écrans : un bouton de plus sur la fiche élève et sur la liste « élèves sans photo » ; hors ligne : identique à la caméra (copie locale, envoi différé) ; sécurité : même stockage privé ; **suppression des métadonnées de la photo** (dont la localisation GPS) à la compression ; contrôle du format (JPEG, PNG ; HEIC converti) et d'une taille minimale ; paquets : `image_picker` (caméra et galerie), `file_picker`, `image_cropper`, `flutter_image_compress` (déjà présélectionnés).
* **Effort** : S.
* **Risques** : photo importée floue ou trop petite (scan de mauvaise qualité) → avertissement « photo trop petite pour une carte nette » ; photo qui n'est pas celle de l'enfant (vérification visuelle par le directeur) ; droit à l'image (texte d'information des parents déjà prévu).
* **Recommandation** : **maintenant** (phase 8, sans changer le reste du plan).

## Fiche d'impact A3 — Mot de passe oublié par SMS
* **Description** : recevoir un code par SMS pour les comptes « numéro de téléphone ».
* **Valeur** : autonomie des enseignants sans e-mail. **Profils** : enseignants, délégués.
* **Impact** : configuration d'un fournisseur SMS dans Supabase (Twilio, MessageBird, Vonage…) ; aucun changement de tables ; un écran existant adapté ; coût par SMS (couverture et tarifs au Burkina Faso à vérifier).
* **Effort** : S (technique) + contrat fournisseur. **Risques** : coût, délivrabilité, fraude aux SMS.
* **Recommandation** : V2 (en V1, le directeur réinitialise le mot de passe en un geste).

## Fiche d'impact A4 — Sauvegarde chiffrée
* **Description** : le fichier de sauvegarde créé sur le téléphone est protégé par un code choisi par le directeur (AES-256 ; sans le code, le fichier est illisible).
* **Valeur** : la sauvegarde contiendra bientôt des données d'élèves (phase 2) ; un fichier perdu ou partagé par erreur ne les expose pas.
* **Profils** : directeur. **Impact** : aucun changement de tables ; un champ « code de la sauvegarde » ; paquet `cryptography` (pur Dart) ; restauration (phase 14) demandera le code.
* **Effort** : S. **Risques** : code oublié = sauvegarde inutilisable (le serveur reste la sauvegarde principale).
* **Recommandation** : maintenant, au début de la phase 2, avant l'arrivée des données d'élèves.

## Fiche d'impact A5 — Mot de passe oublié par question secrète
* **Description** : à la première connexion, chaque personne choisit une question (liste ou question libre) et tape sa réponse. En cas d'oubli : identifiant → question → réponse → nouveau mot de passe, sans e-mail ni SMS, sans attendre le directeur.
* **Valeur** : autonomie des enseignants qui n'ont pas d'e-mail ; gratuit. **Profils** : tous (directeur compris, en plus de l'e-mail).
* **Impact** — tables : `app.recovery_secrets` (réponse **jamais stockée en clair** : empreinte bcrypt, réponse normalisée sans accents ni majuscules) et `app.recovery_attempts`, hors de l'API, aucune RLS d'accès direct ; serveur : une fonction `recuperer-mot-de-passe` (en ligne) ; écrans : choix de la question (après la 1re connexion, modifiable) et une étape de plus dans « Mot de passe oublié » ; hors ligne : la récupération exige Internet (comme toute connexion sur un nouveau téléphone).
* **Effort** : S à M.
* **Risques** (importants, à connaître) : dans une petite communauté, les réponses aux questions classiques (« nom de votre mère », « village natal ») sont **faciles à deviner** ; c'est la méthode de récupération la plus faible. Parades prévues : questions classiques déconseillées à l'écran, question libre encouragée, réponse de 4 caractères minimum, **5 essais puis blocage d'1 heure**, chaque récupération réussie notée dans le journal et **signalée au directeur**, la réinitialisation par le directeur reste possible.
* **Recommandation** : maintenant, avec ces parades.

## Fiche d'impact A6 — Données récupérables en cas de perte ou de changement de téléphone
* **Déjà en place** : tout ce qui est synchronisé est sur le serveur ; en se connectant sur un nouveau téléphone, le directeur ou l'enseignant retrouve toutes les données de l'école auxquelles il a droit (prouvé par les tests d'intégration). Ce qui manque :
  1. **Images** (en-tête, plus tard photos et documents) : téléchargées automatiquement sur le nouveau téléphone (aujourd'hui elles ne restent que sur le téléphone qui les a ajoutées).
  2. **Téléphone perdu ou volé** : le directeur voit la liste des téléphones de l'école et touche « Déconnecter ce téléphone » ; l'ancien téléphone ne peut plus rien lire ni envoyer, et efface ses données à sa prochaine connexion au réseau.
  3. **Rien d'important ne reste seulement sur un téléphone** : alerte « Ce téléphone n'a pas été synchronisé depuis 3 jours » sur l'accueil, et pour le directeur la liste des téléphones avec leur dernière synchronisation.
  4. **Sauvegarde du serveur lui-même** (sinon une panne du serveur ferait tout perdre) : copie automatique quotidienne de la base, chiffrée, conservée 30 jours, et procédure de restauration testée.
* **Limite honnête** : ce qui a été saisi sur un téléphone perdu **sans jamais avoir été synchronisé** ne peut pas être récupéré ; l'alerte du point 3 réduit ce risque.
* **Profils** : directeur (liste et déconnexion des téléphones), tous (alerte). **Impact** : `devices` (déjà présente : ajout `revoked_at`), règles RLS refusant un appareil révoqué, file de téléchargement des fichiers, une tâche planifiée de sauvegarde. **Effort** : M. **Risques** : coût de stockage des copies (faible), clé de chiffrement des copies à garder hors du serveur.
* **Recommandation** : maintenant (points 1 à 3 en phase 1 ; point 4 dès qu'un serveur hébergé existe, voir A7).

## Fiche d'impact A7 — Test sur un vrai téléphone après chaque phase
* **Description** : à la fin de chaque phase, un fichier APK installable sur un téléphone Android + un serveur de test en ligne (« École Test ») + la procédure `docs/TESTS_PHASE_N.md`.
* **Contraintes actuelles** : (1) l'environnement cloud bloque le SDK Android (`dl.google.com`) ; (2) le serveur actuel tourne **dans mon environnement** : un téléphone ne peut pas l'atteindre. Il faut donc un **projet Supabase hébergé de test** (offre gratuite suffisante pour les essais) et une construction de l'APK **par GitHub Actions** (qui dispose du SDK Android), téléchargeable depuis GitHub.
* **Impact** : un fichier de workflow « Livraison téléphone » (migrations + fonctions déployées sur le serveur de test, APK construit et publié) ; secrets à enregistrer **par vous** dans GitHub (jamais dans la conversation ni dans le dépôt). **Effort** : S. **Risques** : le serveur de test ne doit contenir que des données fictives.
* **Recommandation** : maintenant.

## Fiche d'impact A8 — Verrouillage par code PIN ou empreinte
* **Description** : après la première connexion, chacun choisit un code de 4 à 6 chiffres (codes trop faciles refusés : 1234, 0000…), demandé à chaque ouverture et après 2 minutes en arrière-plan ; empreinte digitale en option si le téléphone en a une. 5 erreurs : attente croissante (30 s → 15 min) ; 10 erreurs ou code oublié : reconnexion avec le mot de passe (en ligne), **sans perdre les données du téléphone**.
* **Valeur** : téléphone prêté ou volé avant d'être déconnecté par le directeur. **Profils** : tous.
* **Impact** : table locale `app_lock` (empreinte PBKDF2-SHA256 du code, 20 000 itérations, jamais le code) ; écrans : choix du code, écran verrouillé, code oublié, « Mon compte » ; paquet `local_auth` 3.0.2 (empreinte) ; Android : `FlutterFragmentActivity`, thème AppCompat, permission `USE_BIOMETRIC`.
* **Effort** : S. **Risques** : le code protège l'**écran**, pas le fichier de la base sur le téléphone (voir A10) ; empreinte non testable dans mon environnement (à vérifier sur téléphone).
* **Décision** : construit (code obligatoire), à confirmer.

## Fiche d'impact A9 — Journal d'activité
* **Description** : chaque création, modification ou suppression (école, années, en-têtes, options, comptes, droits), chaque connexion d'un téléphone, chaque téléphone déconnecté et chaque mot de passe récupéré est enregistré par le **serveur** : qui, quand, quoi, quelles valeurs. Le directeur le lit en phrases simples, **même hors ligne** ; l'accueil signale les événements de sécurité non lus.
* **Profils** : directeur (lecture). Personne ne peut le modifier ni l'effacer, pas même l'administrateur de la base (testé).
* **Impact** : `audit_log` (existait) rempli par des déclencheurs ; synchronisé en lecture seule vers le téléphone du directeur. Les modules suivants (notes, finances…) ajouteront leurs tables au même mécanisme. **Jamais de données médicales dans le journal.**
* **Effort** : S. **Risques** : volume croissant (à surveiller en phase 13 ; filtre « 90 derniers jours » possible).
* **Décision** : construit, à confirmer.

## Fiche d'impact A10 — Base du téléphone chiffrée
* **Description** : chiffrer le fichier SQLite du téléphone (SQLCipher) avec une clé gardée par le système Android (Keystore).
* **Valeur** : un voleur qui extrait la mémoire du téléphone (manipulation technique) ne lit rien ; complète le code PIN (A8), qui ne protège que l'écran.
* **Impact** : paquet `sqlcipher_flutter_libs` à la place de `sqlite3` ; + ~3 à 4 Mo d'APK (à mesurer) ; migration de la base existante ; aucune table nouvelle. **Effort** : M. **Risques** : poids, légère lenteur sur téléphone d'entrée de gamme, clé perdue si le téléphone est réinitialisé (les données restent sur le serveur).
* **Recommandation** : avant la phase 2 (arrivée des données d'élèves).
