# Tests de la phase 0 — procédure pour un testeur non technique

Durée : 20 minutes. Il faut un ordinateur où le projet est installé (voir README.md) et, pour l'étape 1, Android Studio avec un émulateur.

## 1. L'application démarre
1. Ouvrez Android Studio, lancez un téléphone virtuel (émulateur).
2. Dans un terminal, dans le dossier `ecoleplus`, tapez : `flutter run`
3. ✅ Attendu : un écran vert et blanc avec une icône d'école, le titre « EcolePlus » et le mot « Bienvenue ».
4. Activez le mode avion de l'émulateur, fermez et rouvrez l'application. ✅ Attendu : le même écran s'affiche (rien ne dépend d'Internet).

## 2. La base de données de test existe
1. Tapez : `npx supabase start` puis `npx supabase db reset`
2. ✅ Attendu : le message se termine par « Finished supabase db reset » sans erreur rouge.

## 3. Les règles de sécurité et d'intégrité sont vérifiées automatiquement
1. Tapez : `npx supabase test db`
2. ✅ Attendu : « All tests successful » et « Result: PASS » (35 vérifications), notamment :
   * aucun enseignant ni visiteur ne lit d'élève, de note ou de paiement tant que les droits ne sont pas définis ;
   * un reçu ne peut être ni modifié ni supprimé ; une annulation sans motif est refusée ;
   * une note de 11 sur 10 est refusée ;
   * le numéro d'ordre du registre matricule ne peut pas être changé ;
   * dans « École Test », CM1, Composition 1 : Aïcha 1re (7,00), Boukary et Clarisse 2e ex-aequo (6,00), Daouda **4e** (5,50).

## 4. Vérification à la main du classement (à faire avec un enseignant)
Notes de la Composition 1 du CM1 (sur 10). Le Dessin a le coefficient 0, l'Histoire n'a aucune note.

| Élève | Lecture | Calcul | Dictée | Dessin (coef 0) |
|---|---|---|---|---|
| Aïcha | 8 | 7 | 6 | 10 |
| Boukary | 6 | 6 | 6 | 2 |
| Clarisse | 7 | 5 | 6 | — |
| Daouda | 5 | absent | 6 | — |

Calculez total et moyenne. ✅ Attendu (avec l'hypothèse « absent = matière non comptée ») : 21 / 7,00 ; 18 / 6,00 ; 18 / 6,00 ; 11 / 5,50. Si votre école compte l'absence comme 0, Daouda aurait 3,67 : **dites-nous quelle règle vous appliquez.**

## 5. Le tableau de correspondance des formulaires
Ouvrez `docs/CORRESPONDANCE_FORMULAIRES.md` à côté des sept formulaires papier. Pour chaque colonne du papier, vérifiez qu'une ligne du tableau lui correspond. ✅ Attendu : aucune colonne oubliée. Notez les libellés marqués « à confirmer » que vous pouvez trancher.
