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
| A2 | ➕ Ajout demandé (21/10/2026) | Carte créée automatiquement depuis la fiche élève et sa photo ; photo **prise par la caméra OU importée** (galerie, fichier, photo scannée, photo d'identité papier photographiée puis recadrée) — fiche ci-dessous | **Acceptée** (22/10/2026) — à construire | 8 |
| A3 | ⚠️ Ajout proposé (phase 1) | Récupération du mot de passe par SMS — fiche ci-dessous | Remplacée par A5 (décision du 21/10/2026) | — |
| A5 | ➕ Ajout demandé (21/10/2026) | Mot de passe oublié par **question secrète** — fiche ci-dessous | **Acceptée** avec protections (21/10/2026) — construite | 1 |
| A6 | ➕ Ajout demandé (21/10/2026) | Toutes les données de l'école enregistrées et **récupérables en cas de perte ou de changement de téléphone** (directeur et enseignant) — fiche ci-dessous | **Acceptée** : images sur nouveau téléphone, déconnexion d'un téléphone perdu, alerte (rendue **conditionnelle** à la demande du porteur), sauvegarde du serveur — construite | 1 |
| A7 | ➕ Ajout demandé (21/10/2026) | **Tester sur un vrai téléphone après chaque phase** (APK installable) — fiche ci-dessous | **Acceptée** : Supabase gratuit + GitHub — construite ; reste à saisir les secrets (porteur) | 1, puis chaque phase |
| A8 | ➕ Ajout demandé (21/10/2026, réponse A6) | **Verrouillage par code PIN ou empreinte** à l'ouverture — fiche ci-dessous | **Confirmée** (22/10/2026) — construite ; au choix code OU empreinte | 1 |
| A9 | ➕ Ajout demandé (21/10/2026, réponse A6) | **Journal d'activité** : connexions et actions, qui a fait quoi — fiche ci-dessous | **Confirmée** (22/10/2026) — construite | 1 |
| A10 | ⚠️ Ajout proposé (phase 1) | Chiffrement de la base locale du téléphone (SQLCipher) — fiche ci-dessous | **Acceptée** (22/10/2026) — construite (phase 2) | 2 |
| A11 | ➕ Ajout demandé (22/10/2026, test sur téléphone) | Le directeur peut **aussi se connecter avec son numéro de téléphone** (son e-mail reste valable) — fiche ci-dessous | **Acceptée** (22/10/2026) — construite | 1 |
| A12 | ⚠️ Ajout proposé (phase 2) | **Modèle Excel à télécharger** depuis l'écran d'import (colonnes déjà titrées, une ligne d'exemple) — fiche ci-dessous | En attente — recommandation : maintenant (phase 2) | 2 |
| A13 | ➕ Ajout demandé (22/10/2026, test sur téléphone) | **Micro sur tous les champs de saisie** (et pas seulement les observations), pour le directeur et l'enseignant — fiche ci-dessous | **Acceptée** (22/10/2026), tous les champs — construite ; jamais sur les mots de passe, codes et réponses secrètes | 2 |
| A14 | ➕ Ajout demandé (22/10/2026, test sur téléphone) | **Dates saisies en chiffres « jj/mm/aaaa »** au lieu du calendrier — fiche ci-dessous | **Acceptée** (22/10/2026), avec un petit bouton calendrier — construite | 2 |
| A15 | ➕ Ajout demandé (23/10/2026) | **Calcul des moyennes selon le type d'école** (publique / privée, choisi dans « Mon école ») : 3 trimestres ; publique = 1 composition par matière ; privée = évaluation + composition par matière ; moyenne annuelle = moyenne des 3 trimestres — fiche ci-dessous | **Acceptée** (23/10/2026) : coefficients gardés (1 par défaut) ; en privé, si une seule des deux notes existe, **elle constitue la moyenne de la matière** et la moyenne du trimestre est calculée ; construite (23/10/2026) | 3 |
| A16 | ➕ Ajout demandé (27/10/2026) | **Version ordinateur (Windows)** de l'application, mêmes données et même serveur que le téléphone — fiche ci-dessous | **Acceptée** (27/10/2026) — à construire à la fin ; dès maintenant, pas de choix réservé au téléphone | Fin |
| A17 | ➕ Ajout demandé (27/10/2026) | **Documents du directeur réunis sous un seul bouton « Documents »**, rangés « Enseignants » / « Élèves » ; **4 nouveaux modèles** fournis par le porteur : attestation de prise de service (enseignant), certificat de scolarité, attestation de niveau, certificat de non redevance (élèves) — fiche ci-dessous | **Acceptée** (27/10/2026) : certificat de scolarité en **page entière ou demi-page au choix** ; **pas de numéro** ; non redevance : **avertissement** si impayés (quand les Finances existeront), le directeur décide ; 3e rubrique **« École »** (programme et bilan, phase 5) | 4 |
| A18 | ➕ Ajout demandé (28/10/2026, test sur téléphone) | Documents : « **Camarade** » à la place de « Madame » / « Monsieur » ; grade du directeur plus visible dans « Mon école » (avec propositions) ; **aperçu des PDF qu'on peut agrandir** (deux doigts, boutons + et −) avant d'imprimer ou de partager | **Acceptée** (28/10/2026) — construite | 4 |
| A20 | ➕ Ajout demandé (30/10/2026, test sur téléphone) | **« Archives » devient une commande à part** sur l'accueil (directeur et délégués « archives »), au lieu d'une ligne dans « Documents » — fiche ci-dessous | **Acceptée** (30/10/2026) — construite | 9 |
| A4 | ⚠️ Ajout proposé (phase 1) | Chiffrement du fichier de sauvegarde par un code choisi par le directeur — fiche ci-dessous | Reportée (V2), décision du 22/10/2026 | 2 |

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
* **Ajustement demandé au test sur téléphone (21/10/2026)** : **l'empreinte OU le code, jamais les deux**. Sur un téléphone avec capteur, la 1re connexion propose « Avec mon empreinte » ou « Avec un code de 4 à 6 chiffres ». Avec l'empreinte, aucun code EcolePlus n'est créé ; si l'empreinte échoue, le téléphone propose son propre code ou schéma (hors ligne). En dernier recours : « Empreinte refusée ? » → mot de passe du compte (en ligne). Changement possible dans « Mon compte ». Aucun changement de base de données (`pin_hash` vide = empreinte). Touche de validation du clavier : « OK » remplacé par une coche ✓ pleine couleur, active seulement à partir de 4 chiffres, avec la consigne « Appuyez sur ✓ pour valider ».

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

## Fiche d'impact A11 — Connexion du directeur par son numéro de téléphone
* **Constat (test du 21-22/10/2026)** : le directeur a créé son école avec son e-mail, puis a tenté de se connecter avec un numéro de téléphone : refus. Au Burkina Faso, le numéro est l'identifiant naturel ; l'e-mail est moins utilisé au quotidien.
* **Description** : à la création de l'école (et dans « Mon compte »), un champ facultatif « Votre numéro de téléphone (pour vous connecter) ». Ensuite, à l'écran de connexion, le directeur tape **son numéro OU son e-mail**, avec le même mot de passe. L'e-mail reste obligatoire à la création : il sert à récupérer le mot de passe par code.
* **Valeur** : connexion plus simple ; même geste que les enseignants, qui se connectent déjà avec leur numéro. **Profils** : directeur (et tout compte qui a un e-mail : délégué, enseignant).
* **Fonctionnement prévu** — sans SMS, sans révéler d'informations à un inconnu :
  1. table serveur `app.login_phones` (numéro normalisé 226XXXXXXXX → compte), **un numéro = un seul compte** dans toute l'application ; refus si le numéro sert déjà d'identifiant à un autre compte (y compris un enseignant) ;
  2. à la connexion avec un numéro, l'application essaie d'abord le compte « numéro » habituel (enseignants) ; en cas de refus, elle demande à une fonction serveur `connexion-telephone` si ce numéro **et ce mot de passe** correspondent à un compte ; seulement dans ce cas, le serveur répond par l'e-mail du compte et l'application se connecte avec. **Un inconnu qui n'a pas le mot de passe n'apprend rien**, pas même si le numéro existe ;
  3. 5 essais ratés en une heure sur un numéro → blocage temporaire (comme la question secrète) ; chaque connexion par numéro est notée dans le journal d'activité du directeur.
* **Impact** — tables : `app.login_phones` (hors API, accès service uniquement), réutilisation de `app.recovery_attempts` pour les essais ; fonctions SQL `set_login_phone` (par le titulaire du compte) et `login_lookup` (service uniquement) ; serveur : une fonction `connexion-telephone` (en ligne) ; écrans : un champ dans « Créer mon école » et dans « Mon compte » ; hors ligne : aucun changement (la 1re connexion sur un téléphone demande déjà Internet ; ensuite, code ou empreinte) ; tests : pgTAP (numéro unique, mot de passe faux, blocage), Flutter (connexion par numéro), intégration (serveur local).
* **Effort** : S à M (environ une demi-journée).
* **Risques** : (a) le numéro n'est pas vérifié par SMS : quelqu'un pourrait enregistrer le numéro d'un autre, qui ne pourrait alors plus l'utiliser comme identifiant → message clair « numéro déjà utilisé : contactez le directeur » et possibilité pour le directeur de le libérer ; (b) changement de numéro → modifiable dans « Mon compte » ; (c) un essai de plus côté serveur uniquement quand le premier échoue (aucun ralentissement pour les enseignants).
* **Alternative écartée** : remplacer l'e-mail du directeur par son numéro → on perdrait la récupération du mot de passe par e-mail.
* **Recommandation** : **maintenant** (dans la phase 1, avant le rapport), car c'est le premier obstacle rencontré au test sur téléphone.
* **Décision** : acceptée le 22/10/2026, construite : migration `20261022000100_a11_connexion_telephone.sql`, fonction `connexion-telephone`, champ à la création de l'école, « Mon compte » → « Mon numéro pour me connecter ». Tests : 17 pgTAP, 2 Flutter, 1 intégration.

## Fiche d'impact A12 — Modèle Excel à télécharger
* **Description** : sur l'écran « Importer un fichier Excel », un bouton « Recevoir un modèle à remplir » crée un fichier .xlsx avec les titres de colonnes reconnus (et la liste des classes de l'année pour les élèves), à partager par WhatsApp ou e-mail vers un ordinateur.
* **Valeur** : évite les erreurs de titres de colonnes ; le secrétariat remplit le modèle sur ordinateur. **Profils** : directeur, délégués « élèves » ou « registres ».
* **Impact** : aucune table ; écriture d'un .xlsx minimal (même technique que la lecture) ; partage par `share_plus` (déjà présent) ; hors ligne : oui.
* **Effort** : S. **Risques** : aucun sur les données.
* **Recommandation** : maintenant (phase 2), si vous le souhaitez ; sinon la liste des colonnes affichée à l'écran et les fichiers d'exemple suffisent pour le test.

## Fiche d'impact A13 — Micro sur tous les champs de saisie
* **Description** : le bouton micro (déjà présent sur « Observations ») est ajouté à **tous les champs de texte** des fiches : élève, parents, enseignant, historiques, classe, école, en-têtes, formulaires, recherche. Même fonctionnement : le texte reconnu s'affiche, reste modifiable, puis remplace ou complète le champ ; aucun son conservé ; clavier toujours disponible.
* **Champs particuliers** : *nombres et numéros* (téléphone, matricule, identifiant) : les chiffres dictés (« soixante-dix, cinquante-six… ») sont convertis en chiffres ; *dates* : une date dictée (« vingt-deux octobre deux mille onze ») est convertie en 22/10/2011 ; *noms propres* : la reconnaissance se trompe souvent sur les noms burkinabè (ex. « Savadogo », « Ouédraogo ») — on corrige au clavier dans la petite fenêtre avant de valider.
* **Valeur** : saisie plus rapide pour qui écrit peu sur téléphone. **Profils** : directeur, délégués, enseignant (sur les champs qu'il a le droit de modifier).
* **Impact** : aucune table ; un réglage du champ de saisie commun ; conversion des nombres et dates dictés en français (code testé) ; permission micro déjà demandée ; hors ligne : selon le pack de langue française du téléphone.
* **Effort** : S à M. **Risques** : qualité de reconnaissance variable (bruit, accents) → texte toujours vérifié avant validation ; écran un peu plus chargé (une petite icône par champ).
* **Recommandation** : maintenant.

## Fiche d'impact A14 — Dates en chiffres « jj/mm/aaaa »
* **Description** : toutes les dates (naissance, entrée, sortie, nominations, anciennetés, « Fait le »…) se tapent au **clavier numérique**, les barres « / » se placent toutes seules (`22102011` → `22/10/2011`). Le calendrier n'est plus ouvert d'office (un petit bouton calendrier reste disponible). Date impossible (31/02, 2099…) refusée avec un message clair.
* **Valeur** : bien plus rapide pour une date de naissance ancienne (le calendrier oblige à remonter les années). **Profils** : tous.
* **Impact** : aucune table (stockage inchangé) ; un seul composant de date à modifier ; tests de saisie.
* **Effort** : S. **Risques** : aucun sur les données.
* **Recommandation** : maintenant.

## Fiche d'impact A15 — Moyennes selon le type d'école (publique / privée)
* **Description** : le type d'école choisi dans « Mon école » décide seul de la méthode, sans réglage à refaire à chaque trimestre.
  * **Publique** : 3 trimestres ; une **composition** par trimestre. Moyenne du trimestre = somme des notes ÷ nombre de matières notées (exemple : (8 + 7 + 9 + 6) ÷ 4 = 7,5).
  * **Privée** : 3 trimestres ; pour chaque matière une **évaluation** et une **composition**, saisies séparément. Moyenne de la matière = (évaluation + composition) ÷ 2 ; moyenne du trimestre = somme des moyennes des matières ÷ nombre de matières (exemple : 7, 8 et 9 → 8). Si l'une des deux notes manque, **la note présente constitue la moyenne de la matière** (décision du 23/10/2026) ; la note manquante n'est jamais comptée comme un 0 et la matière est signalée « une seule note ».
  * **Les deux** : moyenne annuelle = (T1 + T2 + T3) ÷ 3, calculée seulement quand les 3 moyennes de trimestre existent (exemple : (7,5 + 8 + 9) ÷ 3 = 8,17). Une note non saisie n'est jamais un zéro ; un 0 saisi est un vrai 0. Calcul exact, arrondi à 2 décimales seulement à l'affichage.
  * Changer le type d'école ne supprime aucune note : on passe de publique à privée → les compositions déjà saisies restent, les évaluations manquantes sont signalées ; de privée à publique → les évaluations restent enregistrées mais ne comptent plus.
* **Ce qui existe déjà et sera réutilisé** (aucun doublon) :
  * `schools.school_type` (« publique » / « privee »), déjà modifiable dans « Mon école » ;
  * `assessments.kind` (« composition » / « evaluation ») et `assessments.sequence`, qui servira de **numéro de trimestre** (1, 2, 3) ;
  * les tables `grades`, `class_subjects`, `annual_results`, `report_cards` (bulletins), le moteur de calcul `calculs.dart`, les écrans de saisie (clavier, voix), le classement et ses exports PDF / Excel.
* **Impact** :
  * base : **aucune nouvelle table** ; une petite migration qui empêche deux « Composition du 2e trimestre » pour la même classe (index unique classe + trimestre + type) ; aucune donnée existante modifiée ;
  * calcul : moyennes de trimestre et annuelle selon le type d'école, matière « incomplète » (privé), calcul exact et arrondi à l'affichage — **remplace l'hypothèse H40** (arrondi à chaque étape) ;
  * écrans : « Nouvelle composition » devient le choix du **trimestre** (privé : l'évaluation et la composition sont créées ensemble) ; en privé, chaque élève a deux cases (Éval. / Compo.) ; le classement propose T1, T2, T3 et « Année » à la place du « Cumul » ; les résultats annuels et les exports suivent ; la saisie vocale demande la note d'évaluation puis celle de composition ;
  * bulletins (phase 4) : ils liront directement ces moyennes ;
  * tests : les deux exemples ci-dessus, notes manquantes, notes à 0, note modifiée, trimestre manquant, changement de type d'école.
* **Valeur** : élevée — c'est la méthode réellement appliquée dans les écoles ; sans elle, les moyennes affichées seraient fausses pour les écoles privées. **Profils** : directeur, enseignant.
* **Effort** : M (environ une journée de travail, tests compris). **Risques** : faibles sur les données (rien n'est supprimé) ; les résultats annuels déjà « gardés » devront être regardés à nouveau.
* **Recommandation** : maintenant, avant le GO de la phase 3, puisque cela change les calculs de cette phase.

## Fiche d'impact A16 — Version ordinateur (Windows)
* **Description** : EcolePlus installable sur un PC Windows, construite à partir du **même code** (Flutter) que l'application du téléphone : mêmes écrans, même serveur, même synchronisation hors ligne. Un installateur est construit par GitHub, comme l'APK.
* **Valeur** : saisie plus confortable au bureau (grand écran, clavier), impression directe des PDF, imports Excel depuis le PC. **Profils** : surtout le directeur et le secrétariat.
* **Impact** :
  * code : aucun doublon ; quelques adaptations d'écran pour un grand écran (largeur limitée, navigation au clavier) ;
  * à vérifier sous Windows : la dictée vocale (le module actuel n'est peut-être pas disponible sur PC ; le clavier reste toujours possible), l'empreinte (Windows Hello s'il existe, sinon le code), le chiffrement de la base locale, le stockage sûr de la clé ;
  * construction : une tâche GitHub de plus, sur une machine Windows ;
  * dès maintenant : chaque nouvelle fonction évite les choix réservés au téléphone.
* **Effort** : M (à la fin), plus une petite attention à chaque phase. **Risques** : faibles ; la dictée peut être absente sur PC.
* **Recommandation** : acceptée le 27/10/2026, construite après la dernière phase.

Rythme de travail confirmé le 27/10/2026 : **GO phase par phase** (règle R1 inchangée).

**Règle du porteur (27/10/2026)** : avant de construire une fonction qui ne pourrait marcher **que sur le téléphone** (caméra, capteur, micro, NFC, SMS…), je demande l'avis du porteur, avec ce qui se passerait sur l'ordinateur. Fonctions déjà construites concernées, à revoir lors de la construction d'A16 : dictée vocale (micro), ouverture par empreinte.

## Fiche d'impact A17 — Un seul bouton « Documents » (enseignants / élèves) et 4 nouveaux modèles
* **Description** : l'accueil du directeur a un seul bouton **« Documents »**, qui remplace « Registres et formulaires ». Il ouvre deux rubriques :
  * **Enseignants** : fiche de renseignement du personnel (B1), registre du personnel (B3), **attestation de prise de service** (nouveau, par enseignant) ;
  * **Élèves** : registre matricule (B2), fiche de scolarité (B4), **certificat de scolarité**, **attestation de niveau**, **certificat de non redevance** (nouveaux, par élève), et un accès aux bulletins.
  Les documents d'un seul élève ou d'un seul enseignant se choisissent dans une liste (recherche par nom), puis s'impriment ou se partagent en PDF.
* **Les 4 modèles** (scans du porteur, école de Barkouitenga, reproduits avec leur contenu et leur mise en forme) :
  * en-tête à gauche : ministère, direction régionale, direction provinciale, circonscription (CEB), école, séparés par des étoiles ; à droite : « BURKINA FASO », étoiles, devise de l'année (déjà réglable : « La Patrie ou la Mort, nous Vaincrons ») ;
  * titre souligné ; texte « Je soussigné(e) … Directeur/Directrice de l'école … » ; pointillés remplacés par les données de l'élève ou de l'enseignant ; « En foi de quoi … pour servir et valoir ce que de droit » ; « Fait à …, le … » ; « Le Directeur / La Directrice », nom, grade ;
  * attestation de prise de service : enseignant, matricule, emploi (« Instituteur Certifié »…), affectation suivant décision n° … du …, prise de service le … ;
  * certificat de scolarité : élève, parents et professions, né(e) le … à …, numéro du registre matricule, fréquente régulièrement depuis le …, classe ;
  * attestation de niveau : élève, né(e) le …, fils/fille de … et de …, « a le niveau de la classe de … » ;
  * certificat de non redevance : élève, né(e) le … à …, parents, classe, « ne doit rien à l'établissement … libre de tout engagement », année scolaire.
* **Données réutilisées** (aucun doublon) : en-têtes administratifs de l'année, nom de l'école, commune (« Fait à »), fiche élève, parents, registre matricule (B2), classe de l'année, fiche enseignant (matricule, emploi), journal des copies (comme la fiche de scolarité).
* **Données à ajouter** :
  * « Mon école » : civilité et grade du directeur (« Madame », « Directrice », « Professeur Certifié des Écoles ») ;
  * fiche enseignant : n° et date de la décision d'affectation, date de prise de service à l'école ;
  * chaque document délivré est journalisé (qui, quand, pour qui), **sans numéro** (décision du 27/10/2026).
* **Droits** : directeur ; délégué « registres » pour les élèves et le personnel ; jamais l'enseignant.
* **Fonctionne sur ordinateur** : oui (aucune fonction réservée au téléphone).
* **Effort** : M. **Risques** : faibles ; textes à vérifier mot pour mot sur les scans.
* **Recommandation** : maintenant, avec la phase 4 (documents d'élèves, comme la fiche de scolarité).


## Fiche d'impact A19 — Présentation soignée de tous les tableaux imprimés
* **Demande du porteur (28/10/2026)** : texte aligné à gauche ; tirets, nombres et dates centrés ; colonnes centrées quand leurs cases ont la même taille ; des tableaux « joliment présentés et très attrayants ».
* **Ce qui change** (B1, B2, B3, B4, B6, B7, bulletins, classement) — une seule règle commune (`lib/core/pdf/tableaux_pdf.dart`) :
  * texte (noms, activités, observations…) **à gauche** ;
  * valeurs courtes **centrées** : tirets, nombres, %, notes « 12,5/20 », dates, années scolaires, rangs (« 7e/39 », « 1re »), codes de 3 caractères au plus (« M », « T », « CM1 ») ;
  * colonne entière centrée si toutes ses cases sont courtes, ou si ce sont des codes de même longueur avec des chiffres (matricules) ;
  * en-tête en gras, centré, sur fond gris bleuté, répété à chaque page ; une ligne sur deux très légèrement teintée (un objectif sur deux pour B6/B7) ; contenu centré en hauteur ; traits fins gris foncé ;
  * B6/B7 : échéances et taux toujours centrés ; ligne « Moyenne de l'objectif » teintée.
* **Données** : aucune. **Écrans** : aucun (les écrans n'ont pas de tableau).
* **Fonctionne sur ordinateur** : oui.
* **Effort** : S. **Risques** : très faibles ; les teintes restent lisibles en photocopie noir et blanc.
* **Décision** : demandée par le porteur le 28/10/2026, construite le jour même.

## Fiche d'impact A20 — « Archives », commande à part entière
* **Demande du porteur (30/10/2026)** : dissocier les archives administratives du bouton « Documents ».
* **Ce qui change** : un bouton **« Archives »** sur l'accueil, visible par le directeur et par les délégués ayant le droit « archives » ; la ligne « Archives administratives » disparaît de « Documents ». Un délégué qui n'a que le droit « archives » n'a plus de bouton « Documents » (il n'en avait pas l'usage).
* **Inchangé** : contenu, droits (jamais visibles par un enseignant, jamais utilisées par l'IA), « Archiver la copie signée » sur les pages des formulaires B1, B3, B6, B7.
* **Données** : aucune. **Serveur** : aucun changement.
* **Fonctionne sur ordinateur** : oui.
* **Effort** : XS. **Risques** : aucun.
* **Décision** : demandée par le porteur le 30/10/2026, construite le jour même.
