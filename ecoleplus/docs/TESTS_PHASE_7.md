# Tests de la phase 7 — Dossier médico-scolaire (module optionnel, sensible)

Pour un directeur testeur. Durée : environ 30 minutes. Téléphone **connecté à
Internet**, serveur de test « École Test », données **fictives** uniquement
(n'inscrivez jamais la santé d'un vrai enfant sur le serveur de test).
Comptes : `directeur@ecole-test.local`, `enseignant1@ecole-test.local` —
mot de passe `motdepasse-test`. ✅ = ce que vous devez constater.

## 1. Désactivé par défaut
1. « Élèves » → TEST Aïcha. ✅ Pas de bouton « Fiche médico-scolaire (B5) ».

## 2. Activation
1. « Mon école » → « Options de l'école » → « Activer : dossier
   médico-scolaire ». ✅ Avertissement « Données de santé » ; touchez
   « J'ai compris, activer ».
2. ✅ Sous l'interrupteur : « Information des parents » (texte proposé,
   imprimable) et « Journal d'accès ».

## 3. Saisir une fiche complète (critère du GO : sans aide)
1. « Élèves » → TEST Aïcha → « Fiche médico-scolaire (B5) ». ✅ Rappel
   « réservées au directeur », « Pas de micro sur cette fiche ».
2. Remplissez les antécédents familiaux et personnels, les vaccinations,
   les antécédents chirurgicaux (tous facultatifs).
3. « Ajouter l'examen de 2025-2026 » : urines, AV, AA, poids, taille,
   examen physique.
4. Observations : choisissez « À surveiller » ; cochez « Montrer cette
   mention à l'enseignant(e) ».
5. « Enregistrer ». ✅ « Fiche médico-scolaire enregistrée. » Quittez sans
   enregistrer après un changement : ✅ l'application prévient.
6. « Fiche médico-scolaire (PDF) ». ✅ En-tête, identité, A) antécédents,
   B) examen clinique (8 colonnes « 20… », 8 lignes d'examen physique),
   OBSERVATIONS avec la case cochée, « Document confidentiel » en bas.

## 4. Journal d'accès
1. « Options » → « Journal d'accès ». ✅ Chaque consultation, modification,
   impression, avec qui, quand et quel élève ; les tentatives refusées en
   rouge.

## 5. Enseignante
1. Connectez-vous comme `enseignant1@ecole-test.local` → « Mes élèves » →
   TEST Aïcha. ✅ Pas de fiche médicale ; seulement « Aptitude : À
   surveiller ».
2. Revenez en directeur, décochez « Montrer cette mention », enregistrez.
   ✅ L'enseignante ne voit plus rien.

## 6. Sans Internet
1. Mode avion → ouvrez la fiche. ✅ « Connexion à Internet nécessaire : la
   fiche médico-scolaire n'est jamais gardée sur le téléphone. »

## 7. Désactiver
1. Désactivez le module. ✅ Le bouton disparaît ; réactivé, la fiche
   revient (rien n'est effacé).

## Résultats automatiques (mesurés le 30/10/2026)
- Téléphone : 172 tests ✅ (dont la fiche, aucune donnée de santé sur le
  téléphone, PDF B5, refus, hors ligne, aptitude de l'enseignante, et le
  contrôle automatique : aucun code d'IA, de recherche, d'export, de
  synchronisation ou de journal ne peut lire le module).
- Serveur (pgTAP) : 294 tests ✅ (dont 22 pour la phase 7 : enseignant
  refusé au niveau des données et journalisé, module désactivé = rien,
  autre école refusée, aptitude seule exposable, rien dans le journal
  général).
- Intégration téléphone ↔ serveur local : 19 tests ✅.

Points juridiques à faire vérifier : `docs/MEDICO_POINTS_JURIDIQUES.md`.
