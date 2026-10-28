# Tests de la phase 5 — programme d'activités (B6) et bilan annuel (B7)

Pour un directeur testeur. Durée : environ 45 minutes. Téléphone avec la
nouvelle version (`docs/GUIDE_TEST_TELEPHONE.md`), serveur de test « École
Test ».

Comptes : `directeur@ecole-test.local`, `enseignant1@ecole-test.local` —
mot de passe `motdepasse-test`. Données fictives uniquement.
✅ = ce que vous devez constater.

## 1. Où les trouver
1. Accueil → « Documents » → section « École ». ✅ « Programme d'activités
   (B6) », « Bilan annuel des activités (B7) », « Mes formulaires de
   l'année », chacun avec son état (« À compléter », « Complet •
   version finale 1 verrouillée »…).
2. « Mes formulaires de l'année ». ✅ B1, B2, B3, B6, B7 avec leur état ;
   un cadenas pour une version finale verrouillée.

## 2. Saisir le programme (B6) — critère du GO : 14 objectifs
1. « Programme d'activités (B6) ». ✅ L'objectif du jeu de test
   (« Gérer rationnellement les ressources ») et ses deux activités.
2. « Ajouter un objectif ». ✅ Des propositions tirées du modèle (« Gérer
   le courrier », « Rédiger les différents rapports »…) : touchez-en une,
   modifiez le texte si besoin, « Enregistrer ». Vous pouvez aussi écrire
   un objectif libre.
3. Sous l'objectif : « Ajouter une activité ». ✅ Pour les deux premiers
   objectifs du modèle, des activités proposées (« Visites de classes »…).
   Après « Enregistrer », la fiche de l'activité s'ouvre : échéance (une
   date, ou un texte comme « Toute l'année » qui l'emporte), contrainte de
   réalisation, résultats attendus. Chaque champ s'enregistre seul (✓) ; le
   micro 🎤 permet de dicter.
4. Recommencez jusqu'à **14 objectifs**. Menu « ⋮ » d'un objectif :
   « Modifier », « Monter », « Descendre », « Supprimer ». ✅ Le numéro
   imprimé suit l'ordre affiché.
5. « Avant d'imprimer » : « Fait à », « Le », « Nom du directeur ».
6. « Aperçu et impression ». ✅ A4 **paysage** : en-tête (ministère,
   directions, circonscription, école ; « BURKINA FASO » et devise), titre
   « PROGRAMME D'ACTIVITÉS AU TITRE DE L'ANNÉE SCOLAIRE 2025-2026 »,
   colonnes N° d'ordre | Objectifs | Activités prévues | Échéances |
   Contrainte de réalisation | Résultats attendus ; la case d'un objectif
   couvre toutes ses activités ; l'en-tête du tableau se répète sur chaque
   page ; en bas « Fait à … le … », le directeur (nom, signature, cachet) et
   « L'Inspecteur, chef de la circonscription » (espace vide).
   Comparez avec votre modèle papier.

## 3. Version finale et verrou
1. « Valider la version finale » → « Valider ». ✅ Cadre « Version finale 1
   verrouillée » ; plus de boutons d'ajout ; une activité s'ouvre en lecture
   seule.
2. « Modifier » → « Modifier ». ✅ Le programme redevient modifiable ; en
   bas, « Versions finales conservées » garde la **version 1** : touchez-la,
   elle s'imprime telle qu'elle était.
3. Changez un résultat attendu, puis « Valider la version finale ». ✅
   « Version finale 2 verrouillée » ; les versions 1 et 2 sont listées.

## 4. Bilan (B7) sans rien retaper
1. « Documents » → « Bilan annuel des activités (B7) ». ✅ Les 14 objectifs
   et toutes les activités du programme, avec leurs résultats attendus.
2. Touchez une activité : « Résultats atteints » et « Taux de réussite
   (%) » (ex. 75 ou 66,67). ✅ « 150 » est refusé (« Un nombre entre 0 et
   100. »).
3. ✅ Sous l'objectif : « Moyenne de l'objectif : … % » (moyenne des taux
   saisis). Cochez « Imprimer la moyenne de chaque objectif » si vous la
   voulez sur le papier.
4. « Aperçu et impression ». ✅ Titre « BILAN DE PROGRAMME ANNUEL
   D'ACTIVITÉS », colonnes N° | Objectifs | Activités prévues | Résultats
   attendus | Résultats atteints | Taux de réussite (%).
5. Le programme (B6) verrouillé n'empêche pas de remplir le bilan ; le bilan
   a son propre « Valider la version finale ».

## 5. Droits
1. Connectez-vous comme `enseignant1@ecole-test.local`. ✅ Pas de bouton
   « Documents » ; le serveur refuse toute modification du programme.

## 6. Deux téléphones
1. Synchronisez ; sur un second téléphone du directeur. ✅ Même programme,
   mêmes versions, même verrou.
2. Programme verrouillé sur un téléphone pendant qu'un autre, hors ligne,
   change une activité : ✅ à la synchronisation, le changement est refusé
   avec « Programme verrouillé (version finale) : touchez « Modifier » pour
   créer une nouvelle version. »

## Résultats automatiques (mesurés le 28/10/2026)
- Téléphone : 158 tests ✅ (dont 14 objectifs → bilan sans retaper ; verrou,
  nouvelle version, ancienne conservée ; PDF B6/B7 ; taux en %).
- Serveur (pgTAP) : 252 tests ✅ (dont 18 pour la phase 5 : droits, verrou
  B6/B7, versions en ajout seul, journal).
- Intégration téléphone ↔ serveur local : 17 tests ✅ (dont la phase 5).
