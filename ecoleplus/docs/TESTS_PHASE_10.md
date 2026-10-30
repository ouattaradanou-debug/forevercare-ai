# Tests de la phase 10 — Finances (hors cantine)

Pour un directeur (ou un comptable) testeur. Durée : environ 45 minutes.
Deux téléphones si possible. Serveur de test « École Test ».
Comptes (mot de passe `motdepasse-test`) :
- `directeur@ecole-test.local` (directeur) ;
- `secretaire@ecole-test.local` (secrétaire : droit « finances » seulement) ;
- `enseignant1@ecole-test.local` (enseignante du CM1 A).

**Données fictives uniquement.** Montants en FCFA. ✅ = ce que vous devez
constater.

## 1. Grille des frais (directeur)
1. Accueil → **« Finances »** → « Grille des frais » → « Ajouter un frais » :
   rubrique « Scolarité », 25 000, niveau **CM1** → « Enregistrer ».
2. Touchez la ligne → « Ajouter une tranche » : 10 000 avant le
   01/10/2025 ; puis 15 000 avant le 15/01/2026. ✅ « Total des tranches :
   25 000 FCFA ».
3. Ajoutez « Inscription », 5 000, « Tous les niveaux ».
4. (Facultatif) Tarif ajusté : « Scolarité », 30 000, **classe CM1 B**. ✅ Les
   élèves de CM1 B doivent 30 000, ceux de CM1 A 25 000.
5. « Remises » → « Nouvelle remise » : « Fratrie », 10 %, sur
   « Scolarité ». Puis « Situation des élèves » → un élève → touchez
   « Fratrie ». ✅ Son dû baisse de 2 500.

## 2. Encaisser sans Internet (critère du GO)
1. Mode avion. « Encaisser » → TEST Aïcha → « Scolarité (reste …) » →
   10 000 → Espèces → « Encaisser et faire le reçu ».
   ✅ Numéro **définitif** affiché tout de suite (ex. « R2526-C-00001 » :
   la lettre est celle de votre téléphone) ; « Pas encore envoyé ».
2. « Partager le reçu (WhatsApp…) ». ✅ Reçu PDF A5 : école, numéro, date,
   élève et classe, objet, montant en chiffres **et en lettres**, mode,
   « Reste à payer », cadre « Cachet et signature ».
3. Mobile Money : sans référence. ✅ Refusé : « Indiquez la référence du
   paiement (Orange Money) ».
4. **Deuxième téléphone** (secrétaire), aussi en mode avion : encaissez
   deux paiements. ✅ Ses numéros ont une autre lettre.
5. Réseau rétabli sur les deux, « Synchroniser » sur chacun.
   ✅ « Reçus » : tous les reçus des deux téléphones, chacun une seule fois,
   aucun numéro en double.

## 3. Un reçu ne se modifie jamais (critère du GO)
1. Ouvrez un reçu. ✅ Aucun champ modifiable, aucun bouton « Supprimer ».
2. « Annuler ce reçu (erreur) » → motif obligatoire → « Annuler
   l'écriture ». ✅ Une **annulation** est créée avec son propre numéro et
   le montant opposé ; le reçu d'origine reste, marqué « Annulé par … ».
   ✅ Une annulation ne peut pas être annulée.
3. Directeur → « Sécurité » → « Journal d'activité ». ✅ « … a encaissé
   10 000 FCFA (reçu …) », « … a annulé 10 000 FCFA (reçu … : motif) ».

## 4. Soldes et impayés
1. « Situation des élèves » : par classe ou toute l'école. ✅ Dû, payé,
   reste, taux de recouvrement ; « Retard » en rouge pour une échéance
   passée et non réglée.
2. « Impayés et relances ». ✅ Seules les échéances **passées** comptent.
3. Icône message → texte de relance prêt (modifiable) avec le numéro des
   parents → « Partager ». ✅ Rien ne part tout seul : vous choisissez
   WhatsApp ou SMS et le destinataire.

## 5. Dépenses avec justificatif
1. « Dépenses » → « Nouvelle dépense » : Fournitures, « Craies », 1 500,
   espèces → « Photographier » le ticket (ou « Galerie », « Fichier PDF »).
   ✅ Numéro de pièce « D2526-… ».
2. Ouvrez la dépense → « Voir le justificatif ». ✅ La photo s'affiche.
   « Annuler cette dépense » : même principe que les reçus.

## 6. Rapprochement de caisse d'une journée fictive (critère du GO)
Préparez une enveloppe avec de vrais billets **ou** une feuille de calcul,
puis, sur une journée :

| Opération | Montant | Caisse espèces |
|---|---|---|
| Fonds de caisse du matin (Encaisser → « Recette sans élève ») | 20 000 | 20 000 |
| Scolarité Aïcha, espèces | 10 000 | 30 000 |
| Inscription Boukary, Orange Money (réf. OM-1) | 5 000 | 30 000 (pas d'espèces) |
| Scolarité Clarisse, espèces | 7 500 | 37 500 |
| Dépense : craies, espèces | 1 500 | 36 000 |
| Annulation du reçu de Clarisse (erreur) | −7 500 | 28 500 |
| Scolarité Clarisse (bon montant), espèces | 5 000 | 33 500 |

« Caisse et clôture » → mois en cours.
✅ « Caisse (espèces) en fin de mois » = **33 500 FCFA**, égal à l'argent
compté. ✅ Le journal liste les 7 mouvements avec leurs numéros.
« Clôturer » : ✅ le solde est figé ; « Clôturer » ne peut pas être refait.

## 7. Rapports
« Rapports (PDF, Excel) » : « Rapport PDF » (synthèse, recettes par
rubrique, dépenses, recouvrement par classe, impayés) et « Journal de
caisse (Excel) ». ✅ Les totaux correspondent à l'écran « Caisse ».

## 8. Droits (critère du GO)
1. `enseignant1` : ✅ pas de bouton « Finances » ; aucune donnée financière
   sur son téléphone.
2. `secretaire` : ✅ bouton « Finances », tout le module ; pas d'accès aux
   notes, élèves ou formulaires.

## Résultats automatiques (mesurés le 30/10/2026)
- Téléphone : **199 tests ✅**, dont pour la phase 10 :
  - calculs : numéro de reçu identique au contrôle du serveur, montants en
    lettres (vingt-et-un, quatre-vingts, deux-cents, mille, millions…),
    tarif de classe qui remplace celui du niveau, remises, échéancier,
    annulation déduite, trop-perçu : **soldes exacts** sur un cas calculé
    à la main ;
  - **deux téléphones hors ligne** (séries A et B) : 4 reçus, numéros
    uniques, aucun doublon après synchronisation et renvoi ; annulation
    faite sur l'autre téléphone ; reçu d'origine intact ;
  - **journée fictive du § 6** : 7 mouvements, caisse espèces **33 500 FCFA**
    (38 500 avec le Mobile Money) ;
  - écrans : grille, tranche, encaissement hors ligne, reçu PDF (montant en
    lettres, reste à payer), annulation motivée, situation (retard
    10 000), relance partagée, recette sans élève, dépense avec photo,
    clôture unique ; enseignant sans bouton « Finances ».
- Serveur (pgTAP) : **372 tests ✅**, dont 29 pour les finances : grille,
  numéro incohérent refusé, **série du téléphone d'une autre personne
  refusée**, doublon refusé, **modification et suppression d'un reçu sans
  effet ou refusées (même pour l'administrateur de la base)**, annulation
  au montant exact et motivée seulement, une seule annulation par reçu,
  économe (droit « finances ») : tout le module ; **enseignant : aucune
  donnée financière, aucune écriture, aucun justificatif** ; autre école :
  rien.
- Intégration (vrai serveur local) : **23 tests ✅**, dont deux téléphones
  hors ligne → 4 reçus uniques, renvoi sans doublon ; reçu inchangé après
  tentative de modification et de suppression par l'API ; numéro falsifié
  refusé ; justificatif privé lu par le directeur ; enseignante : rien
  (téléphone, API, fichiers).
- Défaut trouvé par le test sur le vrai serveur et corrigé : les reçus déjà
  présents sur le serveur empêchaient la synchronisation d'un téléphone
  (colonne absente côté serveur).
