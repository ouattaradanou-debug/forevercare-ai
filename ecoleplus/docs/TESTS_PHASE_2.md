# Tests de la phase 2 — élèves, classes, enseignants, registres, import, micro

Pour un testeur sans connaissances techniques. Durée : environ 1 h 30.
Téléphone Android avec l'application installée (voir `docs/GUIDE_TEST_TELEPHONE.md`),
connecté au serveur de test (jeu fictif « École Test »).

Comptes : `directeur@ecole-test.local`, `enseignant1@ecole-test.local`,
`secretaire@ecole-test.local` — mot de passe `motdepasse-test`.
Toutes les données sont fictives. ✅ = ce que vous devez constater.

## 0. Mise à jour et protection des données
1. Installez la nouvelle version (`git pull` puis le script, comme d'habitude).
2. Ouvrez l'application. ✅ Vos données d'avant sont toujours là (la base du
   téléphone est maintenant chiffrée, sans rien perdre).
3. Accueil du directeur. ✅ 7 gros boutons : Élèves, Classes, Enseignants,
   Registres et formulaires, Mon école, Personnes et droits, Sécurité.
   « Années scolaires », « Options » et « Sauvegarde » sont dans « Mon école ».

## 1. Classes
1. « Classes ». ✅ En haut : nombre de classes, nombre d'élèves, filles et
   garçons. Chaque classe : effectif (F, G) et enseignant responsable.
2. « Ajouter une classe » → niveau CP1 → nom « CP1 A » → « Créer la classe ».
   ✅ La classe apparaît. Si la maternelle n'est pas activée (Options),
   « Petite section » n'est pas proposée.
3. Ouvrez « CP1 A » → choisissez un enseignant responsable. ✅ Il apparaît sur
   la liste des classes.

## 2. Élèves
1. « Élèves » → « Ajouter un élève » : nom, prénoms, fille, classe CP1 A →
   « Créer la fiche ». ✅ La fiche s'ouvre ; seuls nom, prénoms et classe
   étaient demandés.
2. **Mode avion** : créez un autre élève. ✅ « N° provisoire P-A-0001 ».
   Coupez le mode avion et attendez « Tout est synchronisé ». ✅ Le numéro
   d'ordre définitif apparaît (« N° 13 », par exemple).
3. Remplissez la fiche (date et lieu de naissance, domicile, parent avec
   profession). ✅ Pas de bouton « Enregistrer » : tout est enregistré.
4. Section « Scolarité » (directeur) : « Venant de », « Date du C.E.P. »,
   observations du registre. ✅ Rappel « N'indiquez pas d'informations
   médicales ». Les champs « Race » et « Religion » n'apparaissent pas.
5. **Modifier une fiche déjà enregistrée** : revenez à la liste, rouvrez la
   fiche, changez ou complétez un champ (ex. lieu de naissance). ✅ Une coche
   ✓ apparaît : c'est enregistré. Le crayon ✏️ à côté d'un parent (ou d'une
   ligne d'historique sur la fiche enseignant) permet de le corriger.
6. « Classe cette année » → changez de classe → « Changer ». ✅ L'ancienne
   classe reste écrite dans l'historique (« du … au … (changement de classe) »).
7. Recherche : tapez une partie du nom, sans accent (ex. « aicha »). ✅ L'élève
   est trouvé. Filtrez par classe avec les pastilles.
8. « Sortie définitive de l'école » → date, « Allant à », motif → « Confirmer ».
   ✅ L'élève disparaît des listes ; « Afficher aussi les élèves sortis » le
   montre. Rien n'est supprimé.

## 3. Deux téléphones hors ligne (numéros d'ordre)
Avec deux téléphones connectés comme directeur :
1. Mettez les deux en mode avion ; créez un élève sur chacun.
2. Rallumez le réseau sur les deux, attendez « Tout est synchronisé ».
   ✅ Les deux élèves ont des numéros d'ordre différents, qui se suivent.
   Aucun numéro n'est jamais réutilisé, même après une sortie de l'école.

## 4. Enseignants
1. « Enseignants » → ouvrez « ENSEIGNANT Un ». ✅ Fiche défilante : identité,
   emploi, catégorie, échelon, T/S, classe tenue cette année, fonction.
2. Anciennetés : la date de départ de l'ancienneté générale est remplie.
   ✅ Sous le champ : « Au 31/12/2026 : 18 ans 2 mois 30 j » (années, mois et
   jours révolus).
3. Vérification à la main (3 cas) : saisissez ces dates de départ et comparez
   (date de référence modifiable dans le formulaire B1) :
   | Départ | Référence | Résultat attendu |
   |---|---|---|
   | 01/10/2008 | 31/12/2025 | 17 ans 2 mois 30 j |
   | 15/03/2019 | 10/03/2026 | 6 ans 11 mois 23 j |
   | 31/01/2024 | 02/03/2024 | 1 mois 2 j |
4. « Titres de capacité » → « Ajouter une ligne » → « CAP », une date → cochez
   « Diplôme académique » ou non. ✅ Plusieurs lignes possibles (de même pour
   les communes, interruptions et récompenses).
5. « Cet enseignant a quitté l'école » → confirmer. ✅ Il disparaît de la liste
   habituelle mais reste dans le registre du personnel (B3).

## 5. Import Excel (critère de GO : 40 élèves en moins d'une minute)
Fichiers d'exemple (fictifs) : `docs/exemples/eleves_exemple_40.csv` et
`docs/exemples/enseignants_exemple.csv`. Envoyez-les sur le téléphone (WhatsApp
à vous-même, e-mail ou câble USB dans « Téléchargements »). Ils s'ouvrent aussi
dans Excel ; un fichier .xlsx fonctionne de la même façon.
1. « Élèves » → « Importer un fichier Excel » → « Choisir le fichier » →
   `eleves_exemple_40.csv`. Démarrez un chronomètre.
   ✅ Rapport : « 40 élèves prêts à importer », 1 ligne à corriger (classe
   « CM3 B » inconnue, avec son numéro de ligne), 1 doublon écarté, 1 ligne
   vide ignorée.
2. « Importer 40 élèves ». ✅ « 40 fiches créées » ; **moins d'une minute**
   depuis le choix du fichier.
3. « Classes » → CE1 A. ✅ Effectif augmenté de 40 exactement : 20 filles,
   20 garçons de plus.
4. Réimportez le même fichier. ✅ « Rien à importer » : tout est reconnu comme
   déjà enregistré (pas de doublon créé).
5. « Enseignants » → « Importer un fichier Excel » → `enseignants_exemple.csv`.
   ✅ 2 prêts, 1 doublon (même matricule) ; après import, EXEMPLE Awa tient le
   CE1 A.

## 6. Registres et formulaires (PDF) — comparaison avec le papier
1. « Registres et formulaires ». ✅ B1, B2, B3 avec leur état.
2. Ouvrez chaque formulaire. ✅ « À compléter dans les fiches » liste ce qui
   manque (ex. enseignants sans matricule, élèves en attente de numéro).
3. Remplissez « Fait à », « Le », le nom du directeur (et pour B1 la date de
   référence, pour B2 la période). « Aperçu et impression ». ✅ Le PDF
   s'affiche ; l'état passe à « Imprimé ». « Partager le PDF » l'envoie par
   WhatsApp ou e-mail.
4. **Comparaison visuelle** — posez le scan (ou le papier) à côté du PDF et
   cochez pour chaque formulaire :
   - [ ] orientation A4 paysage ;
   - [ ] mêmes intitulés de colonnes, **dans le même ordre**, mot pour mot ;
   - [ ] B1 : en-tête « CEB de … / Année scolaire … / École de … », groupe
     « Ancienneté » au-dessus de ses 4 colonnes, place de « Dernier diplôme
     académique » (à confirmer) ;
   - [ ] B2 : couverture (Mod. 557, province, département, commune, école,
     période), 9 colonnes numérotées, texte sous « Observations » **identique
     au scan** (sinon recopiez-le exactement) ;
   - [ ] B3 : page de gauche colonnes 1 à 7, page de droite 8 à 13, chaque
     enseignant à la même hauteur des deux côtés ; listes (communes, titres)
     sur plusieurs lignes ;
   - [ ] « Fait à … le … », « Le Directeur », nom, cadre signature et cachet ;
   - [ ] en-têtes de l'année (pas ceux d'une autre année).
   Notez **chaque écart** (intitulé, ordre, largeur, place) : ils seront
   corrigés avant le GO.

## 7. Dictée vocale (micro) — sur un vrai téléphone
1. Fiche d'un élève → « Observations » → bouton micro. ✅ La première fois, une
   explication : rien n'est enregistré, le texte reste modifiable. Puis Android
   demande l'autorisation du micro.
2. Dites « très bon élève, attentif en classe ». ✅ Le texte s'affiche pendant
   que vous parlez ; vous pouvez le corriger ; « Ajouter au texte » le place
   dans les observations (enregistré automatiquement).
3. Essayez en classe (bruit) et hors connexion. ✅ En cas d'échec, un message
   clair (« Rien n'a été compris… », « … a besoin d'Internet ou du pack de
   langue française hors ligne ») ; le clavier reste toujours disponible.
4. Notez la qualité de la reconnaissance (accents, bruit) : elle sera reportée
   dans le rapport.

## 8. Droits
1. Connectez-vous comme **enseignant** (`enseignant1@ecole-test.local`).
   ✅ « Mes élèves » et « Ma classe » : seulement les élèves de sa classe,
   en lecture seule ; aucune section « Scolarité/registre », aucun bouton
   « Enseignants » ni « Registres et formulaires ».
2. Comme **secrétaire** (droit « finances » seulement) : ✅ ni élèves, ni
   registres. Le directeur lui donne le droit « Élèves » (Personnes et droits) :
   ✅ « Élèves » et « Classes » apparaissent, sans les registres.

## Tests automatiques (pour information)
```
flutter test                        # application (93 tests)
supabase test db                    # base de données, droits (197 vérifications)
SUPABASE_URL=… SUPABASE_ANON_KEY=… flutter test test/integration   # 12 tests
```
