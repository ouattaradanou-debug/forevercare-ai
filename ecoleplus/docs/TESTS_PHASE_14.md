# Tests de la phase 14 — Durcissement et préparation du lancement

Serveur de test « École Test » (mot de passe `motdepasse-test`). ✅ = ce que
vous devez constater.

**Critère du GO** : audit sans faille critique ouverte (`AUDIT_SECURITE.md`),
sauvegarde restaurée avec succès sur un autre appareil, et votre accord pour
l'essai pilote.

## 1. Sauvegarde puis restauration sur un AUTRE téléphone (≈ 15 min)
Il faut deux téléphones (A et B).
1. Téléphone A, directeur : **mode avion**. Mon école → changez la
   « Commune ». ✅ « 1 élément en attente ».
2. Mon école → Sauvegarde → « Créer une sauvegarde ». Mot de passe trop
   court (« court ») : ✅ « Au moins 8 caractères. » Choisissez un mot de
   passe de 8 caractères ou plus, deux fois. Envoyez le fichier (WhatsApp à
   vous-même, ou clé USB).
3. ✅ Essayez d'ouvrir le fichier avec une autre application : illisible.
4. Téléphone B : installez l'application, connectez-vous avec le **même
   compte directeur**. ✅ Les élèves, classes, notes reviennent du serveur ;
   la commune modifiée sur A n'est pas là (pas encore envoyée).
5. Téléphone B : Mon école → Sauvegarde → « Restaurer une sauvegarde » →
   le fichier → un **mauvais** mot de passe : ✅ « Mot de passe incorrect… ».
6. Recommencez avec le bon mot de passe. ✅ « 1 élément(s) n'avaient pas
   encore été envoyés… » → « Reprendre ». ✅ « 1 élément(s) repris ».
7. ✅ Quelques secondes après : « Tout est synchronisé », et la commune
   modifiée sur A apparaît sur B et sur le serveur.
8. Une sauvegarde d'une **autre école** : ✅ refusée (« Autre école »).

## 2. Téléphone d'entrée de gamme
Suivez le tableau de `PERFORMANCE.md` (installation, première
synchronisation, appel d'une classe de 60 élèves, PDF d'une classe).

## 3. Contrôles de sécurité à refaire vous-même
- Sur un navigateur, sans être connecté, ouvrez
  `https://<projet>.supabase.co/rest/v1/students` : ✅ refus (aucune
  donnée).
- Téléphone perdu : Mon école → Sécurité → Téléphones → déconnecter le
  téléphone B. ✅ À sa reconnexion, B est vidé et revient à l'écran
  d'accueil.

## 4. Guide d'utilisation
Lisez `GUIDE_UTILISATION.md` avec un directeur qui ne connaît pas
l'application : ✅ il trouve chaque écran avec le guide.

## Tests automatiques
```
cd ecoleplus
flutter test test/features/phase14_durcissement_test.dart test/features/phase14_mesures_test.dart test/core/chiffrement_base_test.dart
supabase test db        # dont 27_phase14_audit (audit automatique)
tools/test_restauration.sh   # sauvegarde du serveur, base vidée, restauration
flutter test test/guide --update-goldens --run-skipped --tags captures   # images du guide
```
