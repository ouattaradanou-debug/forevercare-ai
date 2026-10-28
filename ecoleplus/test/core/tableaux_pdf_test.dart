import 'package:ecoleplus/core/pdf/tableaux_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valeurs courtes centrées : tirets, nombres, dates, rangs, codes', () {
    for (final v in [
      '',
      '—',
      '-',
      '…',
      '7',
      '66,67',
      '75 %',
      '12,5/20',
      '15/03/2026',
      '2026-03-15',
      '2025-2026',
      '7e/39',
      '1re',
      '2e ex/39',
      'M',
      'CM1',
    ]) {
      expect(valeurCourte(v), isTrue, reason: v);
    }
    for (final v in ['TEST Aïcha', 'Toute l’année', 'Classer le courrier']) {
      expect(valeurCourte(v), isFalse, reason: v);
    }
  });

  test('colonne centrée si toutes ses valeurs sont courtes ou des codes de '
      'même longueur ; texte libre à gauche', () {
    final lignes = [
      ['TEST Aïcha', '123456A', '12/01/2015', 'Bon travail', 'Cultivateur'],
      ['TEST Boukary Issa', '234567B', '—', 'À encourager', 'Commerçant'],
      ['TEST Clarisse', '345678C', '03/11/2014', '', 'Cultivateur'],
    ];
    expect(colonnesCentrees(lignes, 5), [false, true, true, false, false]);
  });
}
