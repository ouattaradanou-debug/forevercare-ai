import 'dart:io';

import 'package:ecoleplus/core/import/analyse_import.dart';
import 'package:ecoleplus/core/import/tableur.dart';
import 'package:ecoleplus/features/staff/domain/import_enseignants.dart';
import 'package:ecoleplus/features/students/domain/import_eleves.dart';
import 'package:flutter_test/flutter_test.dart';

/// Les fichiers d'exemple de docs/TESTS_PHASE_2.md donnent bien le résultat
/// annoncé dans la procédure.
void main() {
  test(
    'eleves_exemple_40.csv : 40 prêts, 1 doublon, 1 ligne vide, 1 erreur',
    () {
      final a = analyserImport(
        lireTableur(
          File('docs/exemples/eleves_exemple_40.csv').readAsBytesSync(),
        ),
        colonnes: colonnesEleves,
        valider: validerEleve({'ce1a'}),
        cleDoublon: cleDoublonEleve,
      );
      expect(a.valides.length, 40);
      expect(a.doublons.length, 1);
      expect(a.vides, 1);
      expect(a.erreurs.single.message, contains('CM3 B'));
      expect(a.valides.where((l) => l['sexe'] == 'F').length, 20);
    },
  );

  test('enseignants_exemple.csv : 2 prêts, 1 doublon de matricule', () {
    final a = analyserImport(
      lireTableur(
        File('docs/exemples/enseignants_exemple.csv').readAsBytesSync(),
      ),
      colonnes: colonnesEnseignants,
      valider: validerEnseignant({'ce1a'}),
      cleDoublon: cleDoublonEnseignant,
    );
    expect(a.valides.length, 2);
    expect(a.doublons.length, 1);
    expect(a.erreurs, isEmpty);
  });
}
