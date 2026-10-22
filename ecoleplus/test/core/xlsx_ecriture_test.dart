import 'dart:io';

import 'package:ecoleplus/core/export/xlsx_ecriture.dart';
import 'package:ecoleplus/core/import/tableur.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le classeur écrit se relit à l’identique (accents, & et <)', () {
    final octets = ecrireXlsx('Classement', [
      ['Rang', 'Nom', 'Moyenne'],
      ['1re', 'TEST Aïcha & co <x>', 7.8],
      ['2e ex-aequo', 'TEST Boukary', 7.2],
      ['Non classé', 'TEST Clarisse', null],
      [null, null, 10.0],
    ]);
    final chemin = Platform.environment['XLSX_SORTIE'];
    if (chemin != null) File(chemin).writeAsBytesSync(octets);
    expect(lireTableur(octets), [
      ['Rang', 'Nom', 'Moyenne'],
      ['1re', 'TEST Aïcha & co <x>', '7.8'],
      ['2e ex-aequo', 'TEST Boukary', '7.2'],
      ['Non classé', 'TEST Clarisse'],
      [null, null, '10'],
    ]);
  });
}
