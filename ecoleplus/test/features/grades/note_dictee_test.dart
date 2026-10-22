import 'package:ecoleplus/features/grades/domain/note_dictee.dart';
import 'package:flutter_test/flutter_test.dart';

int? v(String t) => switch (noteDictee(t)) {
  ValeurEntendue(:final centiemes) => centiemes,
  _ => null,
};

void main() {
  test('notes en lettres', () {
    expect(v('quatorze virgule cinq'), 1450);
    expect(v('Quatorze virgule cinq'), 1450);
    expect(v('dix-sept'), 1700);
    expect(v('dix sept sur vingt'), 1700);
    expect(v('douze et demi'), 1250);
    expect(v('douze virgule vingt-cinq'), 1225);
    expect(v('huit virgule zéro cinq'), 805);
    expect(v('zéro'), 0);
    expect(v('vingt'), 2000);
    expect(v('quinze'), 1500);
    expect(v('cinq'), 500);
  });

  test('notes en chiffres (souvent renvoyées par le téléphone)', () {
    expect(v('14,5'), 1450);
    expect(v('14.5'), 1450);
    expect(v('7'), 700);
    expect(v('14,5 sur 20'), 1450);
    expect(v('9,75'), 975);
  });

  test('absent et incompréhensible', () {
    expect(noteDictee('absent'), isA<AbsenceEntendue>());
    expect(noteDictee('Absente'), isA<AbsenceEntendue>());
    expect(noteDictee(''), isNull);
    expect(noteDictee('bonjour'), isNull);
    expect(noteDictee('quatorze virgule'), isNull);
  });
}
