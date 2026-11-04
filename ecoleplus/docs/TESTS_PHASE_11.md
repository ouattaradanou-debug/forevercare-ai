# Tests de la phase 11 — Cantine (module optionnel)

Pour le directeur et, si possible, le responsable de la cantine. Durée :
environ 40 minutes. Deux téléphones si possible. Serveur de test « École
Test ». Comptes (mot de passe `motdepasse-test`) :
- `directeur@ecole-test.local` (directeur) ;
- `secretaire@ecole-test.local` (secrétaire : droit « finances » ; vous lui
  donnerez aussi le droit « Cantine » à l'étape 7).

**Données fictives uniquement.** Montants en FCFA, quantités avec une
virgule (« 12,5 »). ✅ = ce que vous devez constater.

Choix du directeur pilote (04/11/2026) : la « cantine endogène » fonctionne
surtout avec des **vivres apportés par la communauté** ; pointage **en
nombre par classe** ; une sortie de stock **plus grande que le stock est
refusée** ; la cotisation se paie **par trimestre**.

## 1. Désactivée : invisible (règle R11)
1. Accueil → « Finances ». ✅ Aucun bouton « Cantine ».
2. « Mon école » → « Options de l'école » → « Activer la cantine ».
   ✅ « Finances » affiche maintenant le bouton **« Cantine »**.

## 2. Réglages
1. « Finances » → « Cantine » → « Réglages de la cantine ».
2. Choisissez **Mixte** ; dans « Ce que l'école appelle cantine
   endogène », écrivez votre définition → « Enregistrer ».
3. « Finances » → « Grille des frais », cochez CM1 A. ✅ Une rubrique
   **« Cantine »** est apparue. Mettez 3 versements de 2 000 (un par
   trimestre, avec leurs périodes) → « Enregistrer ».

## 3. Élèves bénéficiaires
1. « Cantine » → « Élèves bénéficiaires ». Cochez 3 élèves du CM1 A ;
   pour l'un d'eux, décochez **« Participe »** (sa famille ne paie pas).
   ✅ « Total : 3 bénéficiaire(s) sur … élève(s) » et « CM1 A — 3 / … ».
2. « Toute la classe » coche d'un coup les élèves d'une classe.

## 4. Pointage des repas (mode avion possible)
1. « Pointage des repas ». ✅ Le jour affiché est aujourd'hui ; flèches
   pour changer de jour.
2. Touchez le nombre de bénéficiaires du CM1 A (✅ recopié dans « Repas
   servis »), tapez un nombre pour le CE1 A et 2 dans « Autres
   (personnel…) » → « Enregistrer le pointage ». ✅ « Total du jour ».
3. Retapez un autre nombre pour le CM1 A → « Enregistrer ». ✅ Le total
   est **remplacé**, pas additionné.

## 5. Stock de vivres
1. « Stock de vivres » → « Nouveau produit » : Riz, kg, seuil d'alerte 10.
   Ajoutez aussi Huile (litre) et Haricot (kg).
2. « Entrée » : Riz 50 kg, provenance **Contribution des parents** ;
   Haricot 20 kg, **Produits locaux** ; Huile 5 litres, **Don**.
3. « Sortie » : Riz **60** kg. ✅ Refusé : « Il ne reste que 50 kg… ».
   Sortie Riz 42 kg (repas). ✅ Riz **8**, en rouge avec ⚠ (sous le seuil) ;
   l'accueil de la cantine affiche « Stock bas : Riz (8 kg) ».
4. Touchez **Riz** : historique. Sur la sortie de 42 kg, « ↶ » → motif →
   ✅ « Annulation — … » ajoutée, la sortie est barrée « annulé », stock
   50 ; aucun mouvement n'a disparu.
5. « Inventaire » : comptez vos sacs « papier » et tapez les quantités ;
   motif « Inventaire du vendredi » → « Enregistrer l'inventaire ».
   ✅ Le stock calculé devient égal à votre inventaire ; l'écart apparaît
   dans l'historique (« Inventaire — … »).

## 6. Menus, dépenses, cotisations
1. « Menus de la semaine » : écrivez le menu (une ligne par jour proposée)
   → « Enregistrer le menu » → « Imprimer ou partager le menu ». ✅ PDF.
2. « Dépenses de cantine » → « Nouvelle dépense de cantine » → touchez
   « Condiments », 2 500, photo du justificatif → « Enregistrer la
   dépense ». ✅ Numéro D2526-… ; elle apparaît aussi dans « Finances » →
   « Caisse et clôture » (caisse commune), catégorie « Cantine ».
3. « Finances » → « Encaisser » → un élève bénéficiaire qui participe.
   ✅ La ligne « Cantine » (3 trimestres) est proposée ; encaissez 1 500 sur
   le 1er trimestre (**cotisation partielle**) → reçu **R2526-…** comme pour
   la scolarité. ✅ L'élève dont la famille ne participe pas n'a pas de
   ligne « Cantine ».
4. « Cantine » → « Cotisations et impayés de cantine ». ✅ Synthèse (dû,
   encaissé, restant, taux) ; l'élève : reste 4 500 ; « Impayés de
   cantine » distincts. « Finances » → « Impayés et relances » ✅ ne compte
   **pas** la cantine. Relance : ✅ « … pour la cantine de … ».

## 7. Responsable de cantine (deuxième téléphone)
1. Directeur : « Personnes et droits » → Secrétaire Test → cochez
   **« Cantine »**.
2. Sur le deuxième téléphone, connectez-vous en secrétaire. ✅ Elle voit
   la cantine dans « Finances » (elle a les deux droits).
3. **Les deux téléphones en mode avion** : pointez le même jour, chacun
   une classe différente ; faites chacun une entrée ou une sortie de Riz.
   Réseau rétabli, « Synchroniser » sur les deux (deux fois). ✅ Les deux
   téléphones affichent le **même stock** et les **mêmes repas**, chaque
   mouvement une seule fois.

## 8. Rapports et bilan mensuel
1. « Rapports et bilan mensuel » → le mois en cours. ✅ Repas servis,
   jours de service, bénéficiaires, dépenses de cantine, **coût moyen par
   repas** avec sa formule (« dépenses ÷ repas = … ») : vérifiez-le à la
   calculatrice. Cotisations encaissées et impayés de cantine.
2. « Bilan mensuel (PDF) » ✅ synthèse, repas par jour, bénéficiaires par
   classe, stock (début, entrées, sorties, inventaire, fin), signatures.
   « Bilan (Excel) » ✅ s'ouvre dans le tableur.

## 9. Élève sorti, puis désactivation
1. Sortez (archivez) un élève bénéficiaire. ✅ « Élèves bénéficiaires » le
   garde dans « Élèves sortis (historique conservé) ».
2. « Options de l'école » → désactivez la cantine. ✅ Liste de ce qui sera
   masqué et « **Vos données sont conservées** ». ✅ Plus de bouton
   « Cantine », plus de rubrique « Cantine » dans la grille ni à
   l'encaissement ; les reçus de cantine déjà faits restent dans les
   reçus et la caisse (c'est de l'argent réellement encaissé).
3. Réactivez. ✅ Stock, pointages, bénéficiaires et menus sont revenus.

## Critère du GO
Le responsable de cantine saisit une **semaine fictive** (5 jours de
repas, des entrées, des sorties) en **moins de 10 minutes**, et le stock
calculé est **égal à l'inventaire papier**.

## Tests automatiques
```
cd ecoleplus
flutter test test/features/cantine_test.dart test/features/phase11_cantine_test.dart
supabase test db        # dont supabase/tests/23_phase11_cantine.test.sql
```
