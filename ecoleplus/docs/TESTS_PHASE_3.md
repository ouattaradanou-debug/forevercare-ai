# Tests de la phase 3 — notes, moyennes, rangs, classement

Pour un testeur sans connaissances techniques. Durée : environ 1 h.
Téléphone Android avec la nouvelle version (voir `docs/GUIDE_TEST_TELEPHONE.md`),
connecté au serveur de test (jeu fictif « École Test »).

Comptes : `directeur@ecole-test.local`, `enseignant1@ecole-test.local`
(enseignante du CM1 A) — mot de passe `motdepasse-test`.
Toutes les données sont fictives. ✅ = ce que vous devez constater.

## 0. Accueil
1. Accueil du directeur. ✅ Un nouveau bouton « Notes et classement » (8 boutons).
2. Accueil de l'enseignante. ✅ « Mes élèves », « Ma classe », « Notes et
   classement ».

## 1. Cas calculé à la main (critère de GO)
Le jeu de test contient déjà la composition du **1er trimestre** du CM1 A
(école publique), notée sur 10 :

| Élève | Lecture (coef 1) | Calcul (coef 1) | Dictée (coef 1) | Dessin (coef 0) | Histoire (coef 1) |
|---|---|---|---|---|---|
| Aïcha | 8 | 7 | 6 | 10 | — |
| Boukary | 6 | 6 | 6 | 2 | — |
| Clarisse | 7 | 5 | 6 | — | — |
| Daouda | 5 | **absent** | 6 | — | — |

Calcul à la main (école publique : moyenne du trimestre = somme des notes ÷
nombre de matières notées ; tous les coefficients valent 1, Dessin 0 ;
résultat arrondi au centième) :
- Histoire n'a aucune note : elle ne compte pour personne.
- Dessin a le coefficient 0 : il ne change aucune moyenne.
- Aïcha : (8 + 7 + 6) / 3 = 21 / 3 = **7** ; total **21**.
- Boukary : (6 + 6 + 6) / 3 = **6** ; total **18**.
- Clarisse : (7 + 5 + 6) / 3 = **6** ; total **18**.
- Daouda : absent en Calcul, l'absence ne compte pas (règle par défaut, voir
  H41) : (5 + 6) / 2 = **5,5** ; total **11**.
- Rangs : Aïcha 1re ; Boukary et Clarisse **2e ex-aequo** ; Daouda **4e**
  (et non 3e).
- Moyenne de la classe : (7 + 6 + 6 + 5,5) / 4 = 6,125 → **6,13**.

1. Directeur → « Notes et classement » → « CM1 A » → « Classement » →
   pastille « 1er trimestre ».
   ✅ Aïcha « 1re/4 », Moyenne 7 · total 21 ; Boukary et Clarisse
   « 2e ex-aequo/4 », Moyenne 6 · total 18 ; Daouda « 4e/4 », Moyenne 5,5 ·
   total 11. Statistiques : meilleure 7, plus faible 5,5, moyenne de la
   classe 6,13.
2. Touchez un élève. ✅ Sa moyenne par matière (Histoire : « — »).

## 2. Matières, coefficients, compositions (directeur)
1. CM1 A → « Matières et coefficients ». ✅ Lecture, Calcul, Dictée, Dessin
   (0), Histoire. Changez le coefficient de Calcul : 2. ✅ Coche ✓.
2. Revenez au classement. ✅ Recalculé aussitôt (Aïcha : (8 + 14 + 6) / 4 = 7 ;
   Clarisse : (7 + 10 + 6) / 4 = 5,75). Remettez 1.
3. « Ajouter une matière » → « Écriture », coefficient 1. ✅ Elle s'ajoute.
4. CM1 A → « 2e trimestre ». ✅ L'écran de saisie s'ouvre (une case par
   élève en école publique ; aucune composition à créer à la main).

## 3. Saisie au clavier — chronométrée (critère de GO : 30 notes < 3 min)
Prenez une classe d'au moins 30 élèves (ou importez
`docs/exemples/eleves_exemple_40.csv` dans le CE1 A, voir phase 2), ouvrez
un trimestre et choisissez une matière.
1. Démarrez un chronomètre. Touchez la case du premier élève, tapez la note,
   touchez « Suivant » (➜) sur le clavier : ✅ le curseur passe directement à
   l'élève suivant (sans passer par « Abs. »).
2. Saisissez ainsi 30 notes. ✅ « 30/30 saisies » en haut ; **moins de
   3 minutes**. Notez le temps : ………
3. Tapez 12 (barème 10). ✅ « Hors barème : la note ne peut pas dépasser 10 » ;
   rien n'est enregistré.
4. « Abs. » sur un élève. ✅ La case affiche « Abs. ».
5. Corrigez une note, revenez au classement. ✅ Recalculé.

## 4. Saisie vocale guidée (sur un vrai téléphone)
1. Écran de saisie → « Saisie vocale guidée ». ✅ Le nom du premier élève sans
   note, en grand.
2. « Dire la note » → dites « sept virgule cinq ». ✅ La note comprise s'affiche **en
   grand** ; **rien n'est enregistré** avant « Confirmer ».
3. Dites « quinze » : si le téléphone comprend « cinq », vous le voyez avant
   de confirmer → « Ce n'est pas ça : recommencer ». ✅ Rien n'a été gardé.
4. Dites une note trop grande (« quinze » sur 10). ✅ « Hors barème : 15
   refusé ». (En école privée, l'application demande pour chaque élève la
   note d'évaluation, puis celle de composition.)
5. Dites « absent ». ✅ « Absent » → « Confirmer ».
6. La case « Ou tapez la note » reste toujours disponible.
7. Notez combien de notes ont été mal comprises sur 10 essais : ………

## 5. Exports
1. Classement → « PDF ». ✅ A4 paysage : école, année, classe, période ;
   colonnes Rang, Nom, une colonne par matière (avec coefficient), Total,
   Moyenne, Mention ; statistiques dessous.
2. « Excel ». ✅ Le fichier s'ouvre dans Excel / Google Sheets / WPS ; les
   moyennes sont des nombres (on peut les additionner).

## 6. Mentions et résultats de l'année (directeur)
1. « Notes et classement » → « Mentions » → « Ajouter une mention » :
   de 7 à 8,99 → « Bien ». ✅ Classement, pastille « 1er trimestre » :
   Aïcha a « Bien ».
2. Classement → pastille « Année ». ✅ Tant que les trois trimestres ne sont
   pas notés : « Il manque la moyenne d'un trimestre » (pas de moyenne
   annuelle, pas de zéro inventé).
3. Quand les trois trimestres sont notés : « Garder les résultats de
   l'année ». ✅ « Résultats de l'année gardés (… élèves) ». La moyenne
   annuelle, le rang et l'effectif (« 1re/4 ») serviront à la fiche de
   scolarité.

## 6 bis. Écoles publique et privée (évolution A15) — vos exemples
Dans le **CE1 A** : « Matières et coefficients » → ajoutez Français,
Mathématiques, Sciences, Histoire-Géographie (coefficient 1).
1. **École publique** (« Mon école » → type « Publique »). « 1er trimestre »,
   pour un élève : Français 8, Mathématiques 7, Sciences 9,
   Histoire-Géographie 6. ✅ Classement, 1er trimestre : **7,5**.
2. « 2e trimestre » : 8 partout ; « 3e trimestre » : 9 partout.
   ✅ Pastille « Année » : (7,5 + 8 + 9) ÷ 3 = **8,17**.
3. Une matière laissée vide n'est pas un zéro : effacez la note de
   Histoire-Géographie au 1er trimestre. ✅ (8 + 7 + 9) ÷ 3 = **8**. Tapez 0.
   ✅ (8 + 7 + 9 + 0) ÷ 4 = **6**.
4. **École privée** (« Mon école » → type « Privée »). ✅ Les notes déjà
   saisies sont toujours là ; chaque élève a maintenant **deux cases** :
   « Éval. » et « Compo. ».
5. 1er trimestre : effacez d'abord la note de Histoire-Géographie, puis
   Français éval. 8 / compo. 6 ; Mathématiques 7 / 9 ; Sciences 8 / 10.
   ✅ Sous l'élève : « Moyenne de la matière : 7 », puis 8 et 9 ;
   classement : (7 + 8 + 9) ÷ 3 = **8**.
6. Laissez une seule des deux notes dans une matière. ✅ Elle fait la moyenne
   de la matière, avec « (une seule note) » ; jamais un zéro.
7. Remettez le type « Publique ». ✅ Les évaluations restent enregistrées
   mais ne comptent plus ; les moyennes reviennent à la méthode publique.

## 7. Droits
1. Comme **enseignante** : « Notes et classement » → seulement « CM1 A ».
   ✅ Elle saisit les notes de sa classe, voit le classement ; pas de
   « Matières et coefficients », pas de « Garder les résultats ».
2. Le serveur refuse une note de l'enseignante sur une autre classe (vérifié
   par les tests automatiques).

## 8. Mode avion
1. Mode avion → saisissez des notes. ✅ Enregistrées sur le téléphone.
2. Après 1 jour sans réseau avec des notes non envoyées, l'accueil affiche
   l'alerte (1 jour au lieu de 3 en période de composition).
3. Rallumez le réseau. ✅ « Tout est synchronisé » ; le directeur voit les
   notes.

## Tests automatiques (pour information)
```
flutter test                        # application (121 tests)
supabase test db                    # base de données, droits (211 vérifications)
SUPABASE_URL=… SUPABASE_ANON_KEY=… flutter test test/integration   # 14 tests
```
