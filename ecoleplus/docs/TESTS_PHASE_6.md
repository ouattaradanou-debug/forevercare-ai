# Tests de la phase 6 — Maternelle (module optionnel)

Pour un directeur testeur. Durée : environ 40 minutes. Téléphone avec la
nouvelle version (`docs/GUIDE_TEST_TELEPHONE.md`), serveur de test « École
Test ». Comptes : `directeur@ecole-test.local`,
`enseignant2@ecole-test.local` — mot de passe `motdepasse-test`. Données
fictives uniquement. ✅ = ce que vous devez constater.

## 1. Désactivée par défaut
1. « Notes et classement ». ✅ Seules les classes du primaire ; pas de
   « Réglages de la maternelle ».
2. « Classes » → ajouter une classe. ✅ Aucune section de maternelle
   proposée.

## 2. Activer
1. « Mon école » → « Options de l'école » → « Activer la maternelle ». ✅
   Les domaines proposés (Langage, Éveil mathématique, Éveil à
   l'environnement, Graphisme et préécriture, Motricité et activités
   physiques, Expression artistique) et 3 niveaux sont créés.
2. « Notes et classement » → « Réglages de la maternelle ».
   ✅ Domaines : renommer, monter, descendre, retirer, ajouter.
   ✅ Niveaux « Acquis » (vert, rond plein), « En cours d'acquisition »
   (orange, demi-rond), « Non acquis » (rouge, rond vide) : libellé, couleur
   et pictogramme modifiables.
   ✅ « Classer les enfants (déconseillé) » : désactivé, avec ses avantages
   et inconvénients.
3. « Classes » → ajoutez « GS A » (Grande section), enseignant :
   ENSEIGNANT Deux ; inscrivez-y 2 ou 3 élèves fictifs.

## 3. Évaluer (sans note)
1. « Notes et classement » → « GS A » (« Maternelle : évaluation sans
   note »). ✅ Pastilles « 1er / 2e / 3e trimestre », la liste des enfants
   avec « 0/6 domaines évalués ».
2. Touchez un enfant : pour chaque domaine, touchez le niveau atteint
   (pictogramme en couleur) ; touchez-le encore pour l'enlever.
3. « Appréciation de l'enseignant(e) » : dictez-la au micro 🎤 ou tapez-la.
   « Observations du directeur » (directeur seulement).
4. « Livret de l'enfant (PDF) ». ✅ A4 : en-tête, enfant, classe,
   enseignant(e), tableau domaines × niveaux avec le pictogramme coloré dans
   la bonne colonne (lisible en noir et blanc), « Évaluation sans note
   chiffrée », présences, appréciation, observation, signatures
   (enseignant(e), directeur/directrice, parents). **Aucune note, aucune
   moyenne, aucun rang.**
5. « Enfant suivant » passe au suivant. « Livrets de toute la classe
   (PDF) » : une page par enfant.

## 4. Présences
1. « GS A » → « Présences ». ✅ Le jour ; pour chaque enfant : Présent /
   Absent / Retard ; « Tous les autres sont présents » ; le résumé du jour.
2. « Autre jour » : rattrapez un jour passé.
3. ✅ Le livret indique le nombre d'absences et de retards.

## 5. Classement facultatif
1. « Réglages de la maternelle » → activez le classement. ✅ Le rang
   apparaît dans la liste de la classe et sur le livret. Désactivez-le :
   ✅ il disparaît.

## 6. Enseignante de la grande section
1. Connectez-vous comme `enseignant2@ecole-test.local`. ✅ « Notes et
   classement » → « GS A » : elle évalue, écrit l'appréciation et fait
   l'appel ; l'observation du directeur est seulement affichée.
2. `enseignant1@ecole-test.local` : ✅ ne voit pas la grande section.

## 7. Désactiver puis réactiver
1. Désactivez la maternelle. ✅ Message « Seront masqués : les classes de
   maternelle, les domaines d'apprentissage, les livrets d'évaluation…
   Vos données sont conservées. » ; « GS A » disparaît partout.
2. Réactivez. ✅ Tout revient (évaluations, appréciations, présences), sans
   doublon de domaines.

## 8. École « maternelle seule »
(Option de test : dans « Options », activez la maternelle puis décochez
« Primaire ».) ✅ Le bouton devient « Évaluations (maternelle) » ; aucune
classe du primaire, ni « Mentions », ni « Modèle de bulletin » ; dans
« Documents », plus de registre matricule (B2), de fiche de scolarité (B4)
ni de bulletins. Recochez « Primaire » à la fin.

## Résultats automatiques (mesurés le 29/10/2026)
- Téléphone : 165 tests ✅ (dont OFF → ON → OFF → ON, école maternelle
  seule, livret sans note, présences, classement facultatif).
- Serveur (pgTAP) : 272 tests ✅ (dont 20 pour la phase 6 : module
  désactivé = rien, droits de l'enseignante de la classe, observation
  réservée au directeur, données conservées).
- Intégration téléphone ↔ serveur local : 18 tests ✅ (dont : une école
  active la maternelle, l'autre garde exactement les mêmes effectifs).
