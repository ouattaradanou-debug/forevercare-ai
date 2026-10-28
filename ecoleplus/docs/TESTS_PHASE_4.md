# Tests de la phase 4 — bulletins et fiche de scolarité

Pour un directeur testeur. Durée : environ 1 h. Téléphone avec la nouvelle
version (`docs/GUIDE_TEST_TELEPHONE.md`), serveur de test « École Test ».

Comptes : `directeur@ecole-test.local`, `enseignant1@ecole-test.local`
(CM1 A) — mot de passe `motdepasse-test`. Données fictives uniquement.
✅ = ce que vous devez constater.

## 0. Préparer une année complète (10 minutes)
Le jeu de test n'a que le 1er trimestre du CM1 A. Directeur → « Notes et
classement » → « CM1 A » → « 2e trimestre » : saisissez une note de Lecture
pour chaque élève (par exemple 7, 6, 8, 5) ; faites de même au « 3e
trimestre ».

## 1. Modèle de bulletin (directeur)
1. « Notes et classement » → « Modèle de bulletin ». ✅ Titre, coefficients
   et points, total, rang, mention, statistiques de la classe, signature des
   parents, libellés des signatures, texte en bas.
2. Changez le titre (« BULLETIN TRIMESTRIEL ») et décochez « Signature des
   parents ». ✅ Les bulletins suivants en tiennent compte.

## 2. Bulletins d'un trimestre
1. « CM1 A » → « Bulletins » → pastille « 1er trimestre ». ✅ Chaque élève :
   moyenne et rang (« 1re/4 », « 2e ex-aequo/4 »).
2. Touchez un élève → « Appréciation de l'enseignant(e) » : dictez-la au
   micro 🎤 ou tapez-la. ✅ Coche ✓ : enregistrée.
3. « Observations du directeur » (directeur seulement).
4. « Bulletin de l'élève (PDF) ». ✅ A4 : en-tête de l'école, élève, classe,
   matricule, tableau des matières (école publique : « Compo. » ; école
   privée : « Éval. » et « Compo. »), moyenne de chaque matière, coefficient,
   points, total des points, moyenne « / 10 », rang « 1re/4 », statistiques,
   appréciation, observations, signatures.
5. « Bulletins de toute la classe (PDF) ». ✅ Un seul fichier, une page par
   élève.

## 3. Bulletin de l'année et décision
1. Pastille « Année ». ✅ Colonnes « 1er trim. », « 2e trim. », « 3e trim. »
   par matière, moyennes des trimestres, moyenne annuelle et rang de
   l'année.
2. Touchez un élève → « Décision » : touchez « Passe en classe supérieure »
   (ou écrivez autre chose). ✅ Elle s'imprime sur le bulletin annuel.

## 4. Une note corrigée change le rang PARTOUT (critère clé)
1. Notez le rang d'un élève sur le bulletin de l'année et sur sa fiche de
   scolarité (section 6).
2. Corrigez une de ses notes du 3e trimestre.
3. ✅ Le bulletin de l'année ET la fiche de scolarité montrent aussitôt la
   nouvelle moyenne et le nouveau rang (sans rien « garder » à la main).

## 5. Droits de l'enseignante
1. Connectez-vous comme `enseignant1@ecole-test.local` → « Notes et
   classement » → « CM1 A » → « Bulletins ». ✅ Elle écrit l'appréciation ;
   l'observation du directeur et la décision sont visibles mais grisées.
2. Sur la fiche d'un élève : ✅ pas de bouton « Fiche de scolarité (B4) ».

## 6. Fiche de scolarité (B4)
1. Directeur → « Élèves » → **TEST Fatou** (CM2 cette année) → « Fiche de
   scolarité (B4) ». ✅ « C.M.1 : moyenne 7,25 · classement 7e/39 »
   (résultat de l'an passé dans le jeu de test).
2. « Aperçu et impression ». ✅ A4 paysage : en-tête, identité (parents,
   professions, domicile, N° Mle, école, logeur, entrée, « venant de »),
   tableau « Cours suivis » (C.P.1 à C.M.2, deux colonnes par cours), lignes
   Date / Moyenne générale / Classement, diplômes, observations, signature,
   observations générales ; page 2 : deux blocs de suite pour les
   établissements suivants.
3. **Copie conforme** : activez « Copie conforme » → imprimez. ✅ Mention
   « COPIE CONFORME » et « délivrée le … ». « Sécurité » → « Journal
   d'activité » : ✅ « … a généré une fiche de scolarité (copie conforme) ».
4. **Redoublant** : fiche d'un élève du CM1 → « Redouble cette classe ».
   Quand les trois trimestres sont notés, ✅ sa fiche montre le résultat de
   cette année dans la **seconde** colonne du C.M.1.
5. **Élève muté en cours d'année** : « Sortie définitive de l'école » (date,
   « Allant à », motif). ✅ Il disparaît des bulletins et du classement de la
   classe ; sa fiche montre « Sorti le », « allant à », « Motif du départ ».
6. **Comparaison avec le scan** : posez le scan de la fiche à côté du PDF et
   notez chaque écart (intitulés, ordre, place des cases, texte des
   observations générales — à reprendre mot pour mot, H51).

## 7. Un seul bouton « Documents » et les 4 nouveaux modèles (A17)
1. Accueil du directeur. ✅ « Documents » remplace « Registres et
   formulaires ».
2. « Mon école » → section « Signature des documents » : « Les documents
   sont signés par » → **La Directrice** (ou Le Directeur), puis le grade
   (touchez une proposition ou écrivez le vôtre). Vérifiez aussi le nom.
   ✅ Les documents impriment « Je soussignée Camarade …, Directrice ».
3. « Documents ». ✅ Trois rubriques : **Enseignants** (B1, B3, attestation
   de prise de service), **Élèves** (B2, fiche de scolarité, certificat de
   scolarité, attestation de niveau, certificat de non redevance,
   bulletins), **École** (programme et bilan : phase 5).
4. **Certificat de scolarité** → tapez « aich » → TEST Aïcha. ✅ « À
   compléter » liste ce qui manque. Essayez « Page entière » puis
   « Demi-page » → « Aperçu et impression ». ✅ L'aperçu s'ouvre dans
   l'application : écartez deux doigts (ou touchez + et −) pour agrandir,
   puis « Imprimer » ou « Partager ».
5. **Attestation de niveau** et **Certificat de non redevance** pour le même
   élève. ✅ « Fille de », « née le », « elle » s'accordent ; « Fait à »
   (commune de l'école) et la date se changent avant d'imprimer.
6. **Attestation de prise de service** → ENSEIGNANT Un. Complétez d'abord sur
   sa fiche (« Enseignants ») : n° et date de la décision d'affectation, date
   de prise de service. ✅ Elles s'impriment.
7. **Comparaison avec vos scans** : en-tête (ministère, directions, CEB,
   école, étoiles ; « BURKINA FASO », devise), titre souligné, texte, « Fait
   à … le … », « La Directrice », nom, grade. Notez chaque écart.
8. « Sécurité » → « Journal d'activité ». ✅ « … a délivré un certificat de
   scolarité », etc.
9. Comme enseignante : ✅ pas de bouton « Documents ».

## Tests automatiques (pour information)
```
flutter test                        # application (148 tests)
supabase test db                    # base de données, droits (234 vérifications)
SUPABASE_URL=… SUPABASE_ANON_KEY=… flutter test test/integration   # 16 tests
```
