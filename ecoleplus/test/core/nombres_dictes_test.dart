import 'package:ecoleplus/core/dictee/nombres_dictes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nombres en lettres', () {
    int? n(String s) => nombreEnLettres(s.split(' '));
    expect(n('vingt deux'), 22);
    expect(n('soixante dix'), 70);
    expect(n('soixante quinze'), 75);
    expect(n('quatre vingt'), 80);
    expect(n('quatre vingt dix sept'), 97);
    expect(n('deux mille onze'), 2011);
    expect(n('mille neuf cent quatre vingt cinq'), 1985);
    expect(n('cinquante bonjour'), isNull);
  });

  test('numéros de téléphone dictés', () {
    expect(
      numeroDicte('soixante-dix cinquante-six dix-sept quarante'),
      '70561740',
    );
    expect(numeroDicte('70 56 17 40'), '70561740');
    expect(
      numeroDicte('soixante-seize zéro un quatre-vingt-dix-neuf douze'),
      '76019912',
    );
    expect(numeroDicte('mat zéro douze'), 'mat012');
  });

  test('dates dictées', () {
    expect(dateDictee('vingt-deux octobre deux mille onze'), '22/10/2011');
    expect(dateDictee('le 1er mars 2017'), '01/03/2017');
    expect(dateDictee('premier janvier deux mille dix-huit'), '01/01/2018');
    expect(dateDictee('22 10 2011'), '22/10/2011');
    expect(dateDictee('22/10/11'), '22/10/2011');
    expect(dateDictee('31 février 2017'), isNull);
    expect(dateDictee('demain'), isNull);
  });
}
