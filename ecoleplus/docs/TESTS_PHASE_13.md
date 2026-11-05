# Tests de la phase 13 — Pilotage de l'école

Pour le directeur et un enseignant. Durée : environ 30 minutes.
Serveur de test « École Test ». Comptes (mot de passe `motdepasse-test`) :
`directeur@ecole-test.local`, `enseignant1@ecole-test.local` (CM1 A),
`enseignant2@ecole-test.local` (CM2 A). ✅ = ce que vous devez constater.

**Critère du GO** : le directeur trouve l'essentiel en 2 ou 3 touches.

## 1. Accueil par thèmes (directeur)
1. Ouvrez l'application. ✅ En haut « Tableau de bord » et « Rechercher »,
   puis 7 gros boutons : Élèves et classes, Pédagogie, Administration,
   Finances, Rapports, Bibliothèque et IA, Mon école.
2. « Élèves et classes » : ✅ Élèves, Classes, Absences, Faire l'appel,
   Cartes scolaires, Enseignants.
3. « Mon école » : ✅ Personnes et droits, Sécurité, Sauvegarde, Options.
4. Cantine désactivée (Mon école → Options) : ✅ « Cantine scolaire »
   n'apparaît ni dans Finances, ni au tableau de bord, ni dans les rapports.

## 2. Tableau de bord (1 touche)
« Tableau de bord ». ✅ Effectifs (filles, garçons, par classe), enseignants,
absences du jour et appel fait « X classes sur Y », résultats du dernier
trimestre (moyenne, réussite), finances (encaissé, reste, retards), mes
formulaires de l'année, espace de stockage, cantine (si active), alertes.
Chaque carte ouvre l'écran détaillé.

## 3. Emploi du temps
1. Pédagogie → Emploi du temps → CM1 A → « Ajouter un créneau » : lundi,
   `7h30`, `8h30`, Lecture → Enregistrer. ✅ « 07:30 – 08:30 Lecture ».
2. Ajoutez lundi `8h`–`9h`. ✅ « Ce créneau chevauche 07:30 – 08:30 le
   Lundi. »
3. « Copier vers une autre classe » → CM2 A. ✅ Le CM2 A a les mêmes
   créneaux.
4. « Imprimer (PDF) ». ✅ Une page paysage : heures en lignes, jours en
   colonnes.
5. Enseignante du CM1 : ✅ elle modifie l'emploi du temps du CM1 ; celui du
   CM2 ne lui est pas proposé.

## 4. Appel du jour (enseignant)
1. Enseignante du CM1 → accueil. ✅ Carte « Ma journée » : cours du jour,
   bouton « Faire l'appel — CM1 A ».
2. Touchez-le. ✅ Tous les élèves sont « Présent ». Touchez « Absent » pour
   un élève, « En retard » pour un autre → « Valider l'appel ».
3. ✅ « Ma journée » affiche « Appel fait (CM1 A) : 1 absent(s). »
4. Mode avion : refaites l'appel d'un autre jour (« Autre jour »). ✅ Il est
   gardé puis envoyé au retour du réseau.
5. Directeur → Élèves et classes → Faire l'appel → CM1 A. ✅ Il voit l'appel
   et peut le corriger.

## 5. Absences et statistiques
Élèves et classes → Absences. ✅ Par classe : jours d'appel, absences,
retards, présence (%) ; les élèves les plus absents d'abord ; PDF et Excel.
Changez la période (aujourd'hui, semaine, mois, depuis la rentrée).

## 6. Notifications (cloche en haut de l'accueil)
✅ Un chiffre rouge : appels à faire, absents du jour, élèves absents
3 fois ou plus dans le mois, paiements en retard, stock bas (cantine
active). « Tout marquer comme lu » : ✅ le chiffre disparaît. Rien n'arrive
quand l'application est fermée (choix retenu).

## 7. Recherche rapide
« Rechercher » → tapez `aich` (ou dictez). ✅ L'élève, ses résultats, et
les écrans dont le nom correspond (tapez `appel`, `reçus`). Les enseignants,
classes et vos fiches de l'assistant sont aussi trouvés. Jamais de donnée
de santé.

## 8. Rapports (PDF et Excel)
Rapports. Choisissez le trimestre, le seuil « élève en difficulté »
(ex. 5), la période des absences. ✅ Pour chacun, PDF et Excel :
effectifs par classe et par sexe, listes, résultats par classe et par
matière, classements, absences, élèves en difficulté, finances, synthèse.
Les motifs d'absence ne figurent dans aucun rapport.

## Tests automatiques
```
cd ecoleplus
flutter test test/features/phase13_pilotage_test.dart
supabase test db        # dont 26_phase13_pilotage (emploi du temps, appel)
```
