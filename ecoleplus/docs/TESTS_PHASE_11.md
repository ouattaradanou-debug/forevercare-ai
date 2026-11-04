# Tests de la phase 11 — Cantine scolaire (abonnement mensuel, A26)

Pour le directeur et, si possible, le responsable de la cantine. Durée :
environ 40 minutes. Deux téléphones si possible. Serveur de test « École
Test ». Comptes (mot de passe `motdepasse-test`) :
- `directeur@ecole-test.local` (directeur) ;
- `secretaire@ecole-test.local` (secrétaire : droit « finances » ; à
  l'étape 8, vous lui donnerez aussi le droit « Cantine »).

**Données fictives uniquement.** ✅ = ce que vous devez constater.

Principe : **le mois se paie avant les repas**. Un élève non abonné ne doit
rien. Un mois payé en partie (avance) ne donne pas droit aux repas.

## 1. Désactivée : invisible
1. ✅ L'accueil n'a pas de bouton « Cantine scolaire ».
2. « Mon école » → « Options de l'école » → « Activer la cantine ».
   ✅ Le bouton **« Cantine scolaire »** apparaît à l'accueil.

## 2. Réglages (une fois par année)
1. « Cantine scolaire » → en bas, « **Réglages (tarif, mois, exonérations)** ».
2. Tarif mensuel **5 000** ; mois de fonctionnement (octobre à juin cochés
   par défaut, modifiables) ; jour limite (facultatif) ; votre définition
   de la cantine endogène → « Enregistrer ».
3. Plus tard, changez le tarif à 6 000 « Applicable dès janvier ».
   ✅ Les mois déjà abonnés gardent 5 000.

## 3. Abonner et encaisser (le geste principal)
1. « **ABONNER ET ENCAISSER** » → tapez « aïc » → TEST Aïcha.
2. Cochez **octobre** et **décembre** (non consécutifs). ✅ Tarif de chaque
   mois, « 2 mois », total **10 000** calculé tout seul.
3. Nom du payeur, mode (Espèces, Orange Money…) → « ABONNER ET
   ENCAISSER » → ✅ récapitulatif → « **VALIDER LE PAIEMENT** ».
4. ✅ Un seul reçu R2526-… détaillant « Cantine — octobre 2025 » et
   « Cantine — décembre 2025 » ; « Partager par WhatsApp », « Imprimer »,
   « Télécharger en PDF ».
5. Rouvrez « Abonner et encaisser » pour TEST Aïcha. ✅ Octobre et décembre
   sont **ABONNÉ** et ne se cochent plus (pas de double paiement).
6. Cochez novembre, montant reçu **2 000** → ✅ « Paiement partiel… » ;
   validez. ✅ Novembre : **PAIEMENT PARTIEL** (pas de repas). Payez ensuite
   les 3 000 restants : ✅ novembre ABONNÉ.

## 4. Abonnements (statuts du mois, abonnement groupé)
1. « Abonnements » → mois **octobre**, classe **CM1 A**. ✅ Tableau Nom et
   prénom | Classe | Statut du mois (vert ABONNÉ, gris NON ABONNÉ).
2. « Tout cocher (non abonnés) » → « ABONNER ET ENCAISSER (n) » → mode →
   « VALIDER LE PAIEMENT ». ✅ Tous ABONNÉ ; un reçu par élève dans
   « Encaissements ».
3. « **Liste des élèves autorisés** » ✅ PDF par classe (à imprimer pour le
   contrôle quotidien).
4. Novembre : ne cochez personne. ✅ Ces élèves restent NON ABONNÉ, **sans
   dette**. Décembre : abonnez de nouveau un élève (reprise).

## 5. Tableau de bord
1. « Tableau de bord » → octobre, « Toute l'école ». ✅ Abonnés, non
   abonnés, attendu, encaissé, restant, taux. Vérifiez à la main :
   attendu = 5 000 × abonnés + avances engagées ; les non-abonnés ne
   comptent jamais.
2. ✅ Tableau des élèves : dû, payé, statut ; touchez un nom → sa situation.

## 6. Situation et historique
1. « Situation et historique » → TEST Aïcha. ✅ « SITUATION DE
   L'ABONNEMENT À LA CANTINE » : chaque mois avec dû, payé, statut ;
   totaux ; nombre de mois abonnés et non abonnés ; ses reçus.
2. « Réduction / exonération » : exonérez un autre élève. ✅ Ses mois
   s'abonnent sans paiement (« ABONNER (exonéré) »). Une réduction de
   1 000 donne 4 000 par mois pour les prochains abonnements.
3. Ouvrez un reçu → « Annuler ce reçu (erreur) » → motif. ✅ Les mois de
   ce reçu redeviennent NON ABONNÉ, sans dette ; le reçu reste visible.

## 7. Vivres et repas (phase 11)
« Vivres et repas » : pointage des repas (le nombre d'**abonnés du mois**
de chaque classe se recopie d'un geste), stock de vivres (sortie au-delà
du stock refusée, inventaire), menus, dépenses de cantine, bilan mensuel
PDF / Excel (repas, abonnés, coût moyen par repas, abonnements encaissés,
avances à compléter, stock).

## 8. Deux téléphones, responsable de cantine
1. Directeur : « Personnes et droits » → Secrétaire Test → cochez
   « **Cantine** ».
2. Deuxième téléphone (secrétaire), les deux **en mode avion** : chacun
   abonne un élève différent. Réseau rétabli, « Synchroniser » sur les
   deux (deux fois). ✅ Même tableau de bord sur les deux téléphones, chaque
   reçu une seule fois.

## 9. Désactivation
« Options de l'école » → désactivez la cantine. ✅ « Vos données sont
conservées » ; plus de bouton « Cantine scolaire ». Réactivez : ✅ tout est
revenu.

## Critère du GO
- Un parent paie plusieurs mois (consécutifs ou non) en une seule
  opération, avec un seul reçu, en moins d'une minute.
- La liste des élèves autorisés du mois est juste.
- Le stock calculé d'une semaine fictive est égal à l'inventaire papier.

## Tests automatiques
```
cd ecoleplus
flutter test test/features/cantine_abonnements_test.dart test/features/cantine_test.dart test/features/phase11_cantine_test.dart
supabase test db        # dont 23_phase11_cantine et 24_a26_abonnements
```
