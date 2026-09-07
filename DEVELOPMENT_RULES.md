# Atelier+ Development Standard

## Règle 1

Toujours partir des fichiers existants ; remplacer un fichier complet plutôt que coller des fragments.

## Règle 2

Ne jamais modifier un module validé (phase déjà validée par l'utilisateur) sans nécessité.

## Règle 3

Architecture unique pour tous les modules : `lib/core`, `lib/data`, `lib/features/<fonctionnalite>`, `lib/shared`.

## Règle 4

Aucune donnée financière (commandes, paiements, montants) ne doit être accessible, ni même visible dans le code ou les logs, pour un rôle apprenti.

## Règle 5

Aucune suppression définitive d'une donnée métier créée par l'utilisateur (client, mesure, champ de mesure déjà utilisé). On masque, on annule, on corrige.

## Règle 6

Validation obligatoire avant de clore une phase :

- `flutter analyze`
- `flutter test`
- `flutter run` sur téléphone (procédure de test fournie en fin de phase)

## Règle 7

Un module n'est terminé que lorsque :

- Logique métier complète
- UI complète en français
- Fonctionnement hors-ligne validé
- Navigation validée
