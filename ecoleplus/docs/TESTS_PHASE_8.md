# Tests de la phase 8 — Photos et cartes scolaires

Pour un directeur testeur. Durée : environ 40 minutes. Téléphone avec la
nouvelle version, serveur de test « École Test », imprimante A4.
Comptes : `directeur@ecole-test.local`, `enseignant1@ecole-test.local`,
`enseignant2@ecole-test.local` — mot de passe `motdepasse-test`.
**Photos de test uniquement** (un objet, un dessin, un adulte d'accord) : pas
de vrais enfants sur le serveur de test. ✅ = ce que vous devez constater.

## 1. Photo d'un élève
1. « Élèves » → TEST Aïcha. ✅ En haut : cadre photo vide, « Prendre la
   photo » et « Choisir dans la galerie ».
2. « Prendre la photo » → photographiez → l'écran « Cadrer la photo »
   s'ouvre : déplacez et agrandissez avec deux doigts (visage au centre,
   épaules en bas) → « Garder ce cadre ». ✅ La photo apparaît.
3. « Reprendre la photo » la remplace ; « Retirer la photo » l'enlève
   (la photo est facultative).

## 2. Hors ligne
1. Mode avion → photo d'un autre élève. ✅ Elle s'affiche tout de suite ;
   « 1 élément en attente ».
2. Réseau rétabli → « Synchroniser ». ✅ Plus rien en attente ; sur un
   second téléphone du directeur, la photo arrive.

## 3. Droits
1. `enseignant1` (CM1 A) → « Mes élèves » → TEST Aïcha. ✅ La photo est
   visible, sans bouton pour la changer.
2. `enseignant2` (CM2 A). ✅ Ne voit pas les élèves ni les photos du CM1.

## 4. Logo (facultatif)
1. « Mon école » → « Logo de l'école » → « Photographier » le logo (à plat,
   fond clair) → cadrer → garder. ✅ Il s'affiche ; il apparaîtra sur les
   cartes.

## 5. Cartes scolaires (critère du GO)
1. « Documents » → « Cartes scolaires ». ✅ Choix « Toute l'école », un
   niveau ou une classe ; couleur du bandeau ; « n élèves sans photo »
   (touchez un nom pour aller prendre sa photo).
2. « Générer les cartes (PDF) ». ✅ Avertissement si des élèves n'ont pas
   de photo (cadre vide « PHOTO »).
3. Imprimez la première feuille **à 100 % (taille réelle, sans « ajuster à
   la page »)**, en recto-verso retourné sur le grand côté.
   ✅ Avec une règle : chaque carte mesure **85,6 × 54 mm** (format carte
   bancaire) ; 10 cartes par feuille.
   ✅ Recto : bandeau (logo, école, commune, « CARTE SCOLAIRE », année),
   photo, nom, prénom(s), classe, identifiant, QR code.
   ✅ Verso (au dos de la bonne carte) : école, téléphone, « Si cette carte
   est trouvée, merci de contacter l'école… », cadre « Cachet et signature
   du directeur » (à la main).
4. Scannez un QR code avec l'appareil photo du téléphone. ✅ Il se lit et
   affiche seulement « EP1- » suivi de 32 caractères (aucun nom).
5. Régénérez les cartes. ✅ Les QR codes restent les mêmes (les cartes déjà
   distribuées restent valables).
6. Fiche d'un élève → « Carte scolaire (PDF) » : sa carte seule.
7. « Information des parents (photos) » : texte proposé, imprimable.

## Résultats automatiques (mesurés le 31/10/2026)
- Téléphone : 178 tests ✅ (photo hors ligne puis envoyée ; lot avec 3
  élèves sans photo ; QR gardé d'une impression à l'autre ; planche :
  10 cartes au format carte bancaire, verso en miroir).
- Poids moyen d'une photo : **17,2 Ko** (300 × 400, JPEG) sur les images
  de test ; plafond 50 Ko.
- Planche rendue à 300 ppp : carte mesurée 85,5 × 54,1 mm ; **les 10 QR
  codes de la planche ont été lus et décodés correctement** par un lecteur
  de QR code (zxing).
- Serveur (pgTAP) : 310 tests ✅ (dont 16 pour la phase 8 : compartiment
  privé, enseignant d'une autre classe refusé, autre école et visiteur non
  connecté : rien).
- Intégration : 20 tests ✅ (photo reçue par l'enseignante de la classe,
  refusée à l'autre, lien public refusé).
