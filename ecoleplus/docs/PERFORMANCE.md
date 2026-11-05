# Poids et vitesse — phase 14

## Poids de l'application (APK)
Construit par GitHub (« EcolePlus — livraison téléphone ») : un APK par type
de téléphone, pour ne télécharger que le nécessaire.

| Fichier | Pour | Poids (05/11/2026, avant compactage) |
|---|---|---|
| `ecoleplus-test-recent.apk` | la plupart des téléphones (64 bits) | 31,5 Mo |
| `ecoleplus-test-ancien.apk` | téléphones anciens (32 bits) | 30,2 Mo |

Ce qui pèse : le moteur Flutter, la lecture/impression des PDF, la base
chiffrée, la dictée et le code de l'application (14 phases).

**Optimisation phase 14** : code Dart compacté (`--obfuscate
--split-debug-info`), icônes réduites aux seules utilisées (1,6 Mo → 23 Ko,
déjà en place). Le nouveau poids s'affiche dans le résumé de chaque
construction GitHub (tableau « Poids de l'APK »). Une fois installée, la
mise à jour suivante ne retélécharge que l'APK.

## Vitesse avec une grande école
Test `test/features/phase14_mesures_test.dart` : **1 000 élèves, 20
classes, 180 jours d'appel (180 000 présences)**, sur l'ordinateur
d'intégration. Un téléphone d'entrée de gamme est environ **5 à 10 fois
plus lent**.

| Opération | Avant | Après la phase 14 | Estimation téléphone d'entrée de gamme |
|---|---|---|---|
| Liste des 1 000 élèves | 80 ms | 80 ms | < 1 s |
| Accueil, notifications, « Ma journée » (présences du jour) | 1 200 à 1 600 ms (toutes les présences relues) | **8 à 11 ms** | < 0,1 s |
| Totaux d'absences de l'année (tableau de bord, rapports) | 1 400 à 1 850 ms | **145 à 155 ms** (calcul par la base) | ≈ 1 s |
| Recherche « aich » parmi 1 000 élèves | 11 à 21 ms | 11 à 21 ms | < 0,2 s |
| Ajout de 200 documents sans Internet (phase 9) | voir `bibliotheque_mesures_test` | — | — |

Ce qui a été changé : l'accueil et les notifications relisaient toutes les
présences de l'année à chaque appel. Ils lisent maintenant les présences du
jour (index école + jour, base du téléphone v19) et des totaux calculés par
la base.

## Test sur un téléphone d'entrée de gamme (à faire par vous)
Téléphone conseillé : Android 8 à 10, 2 Go de mémoire, 16 Go de stockage
(par exemple un Tecno ou Itel d'entrée de gamme).

| Étape | ✅ attendu | Mesuré |
|---|---|---|
| Installer l'APK « ancien » (32 bits) ou « récent » | installation sans erreur | |
| Première ouverture puis connexion du directeur | moins de 10 s | |
| Première synchronisation (École Test) | moins de 30 s en 3G | |
| Ouvrir l'accueil, le tableau de bord | moins de 2 s | |
| Faire l'appel d'une classe de 60 élèves | défilement fluide | |
| Imprimer le bulletin d'une classe (PDF) | moins de 20 s | |
| Mode avion : saisir des notes puis revenir en ligne | tout est envoyé | |
| Batterie après une journée d'usage normal | pas de chute anormale | |
| Espace pris par l'application après un mois | noter la valeur | |
