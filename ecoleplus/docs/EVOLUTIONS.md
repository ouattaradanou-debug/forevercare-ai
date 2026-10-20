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
| A3 | ⚠️ Ajout proposé (phase 1) | Récupération du mot de passe par SMS — fiche ci-dessous | En attente — recommandation : V2 | — |
| A4 | ⚠️ Ajout proposé (phase 1) | Chiffrement du fichier de sauvegarde par un code choisi par le directeur — fiche ci-dessous | En attente — recommandation : maintenant (début de phase 2) | 2 |

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
