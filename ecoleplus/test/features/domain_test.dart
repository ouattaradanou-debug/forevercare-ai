import 'dart:convert';
import 'dart:io';

import 'package:ecoleplus/features/auth/domain/identifiant.dart';
import 'package:ecoleplus/features/options/domain/module_rules.dart';
import 'package:ecoleplus/features/school/domain/school_year.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('identifiant de connexion (mêmes exemples que le serveur)', () {
    final cas = jsonDecode(
      File('test/fixtures/identifiants.json').readAsStringSync(),
    ) as List<dynamic>;
    for (final c in cas) {
      final (saisie, attendu) = ((c as List)[0] as String, c[1] as String?);
      test('« $saisie » → $attendu', () {
        expect(identifiantVersEmail(saisie), attendu);
      });
    }
    test('type et affichage', () {
      expect(typeIdentifiant('70112233'), TypeIdentifiant.telephone);
      expect(typeIdentifiant('aminata'), TypeIdentifiant.identifiant);
      expect(typeIdentifiant('a@b.bf'), TypeIdentifiant.email);
      expect(
        identifiantAffichable('22670112233@tel.ecoleplus.invalid'),
        '70 11 22 33',
      );
      expect(identifiantAffichable('aminata@id.ecoleplus.invalid'), 'aminata');
    });
  });

  group('année scolaire', () {
    test('proposition selon la date', () {
      expect(anneeScolaireProposee(DateTime(2026, 10, 21)), '2026-2027');
      expect(anneeScolaireProposee(DateTime(2026, 3)), '2025-2026');
    });
    test('année suivante et validation', () {
      expect(anneeSuivante('2025-2026'), '2026-2027');
      expect(anneeScolaireValide('2025-2026'), isTrue);
      expect(anneeScolaireValide('2025-2027'), isFalse);
      expect(anneeScolaireValide('25-26'), isFalse);
      expect(() => anneeSuivante('x'), throwsFormatException);
    });
  });

  group('options de l’école', () {
    test('au moins un niveau', () {
      expect(niveauxValides(primaire: false, maternelle: false), isFalse);
      expect(niveauxValides(primaire: false, maternelle: true), isTrue);
    });
    test('module dépendant', () {
      const deps = {'cantine': 'finances', 'finances': null};
      expect(moduleActif('cantine', {'cantine': true}, deps), isFalse);
      expect(
        moduleActif('cantine', {'cantine': true, 'finances': true}, deps),
        isTrue,
      );
    });
    test('le droit « cantine » n’apparaît que si la cantine est active', () {
      expect(droitsVisibles(cantineActive: false), isNot(contains('cantine')));
      expect(droitsVisibles(cantineActive: true), contains('cantine'));
    });
  });
}
