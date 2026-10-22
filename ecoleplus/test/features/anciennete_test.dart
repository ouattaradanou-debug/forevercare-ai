import 'package:ecoleplus/features/staff/domain/anciennete.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Trois cas vérifiés à la main (R7, phase 2).
  test('cas 1 : 01/10/2008 → 31/12/2025 = 17 ans 2 mois 30 jours', () {
    // 01/10/2008 → 01/10/2025 : 17 ans ; → 01/12/2025 : 2 mois ;
    // → 31/12/2025 : 30 jours.
    final a = Anciennete.entre(DateTime(2008, 10), DateTime(2025, 12, 31));
    expect(a, const Anciennete(17, 2, 30));
    expect(a!.texte, '17 ans 2 mois 30 j');
  });

  test('cas 2 : 15/03/2019 → 10/03/2026 = 6 ans 11 mois 23 jours '
      '(jour de référence avant le jour de départ)', () {
    // 15/03/2019 → 15/02/2026 : 6 ans 11 mois ; 15/02 → 10/03/2026 :
    // 13 jours restants de février (28 j) + 10 = 23 jours.
    expect(
      Anciennete.entre(DateTime(2019, 3, 15), DateTime(2026, 3, 10)),
      const Anciennete(6, 11, 23),
    );
  });

  test('cas 3 : départ le jour même → 0 j ; départ après la référence → '
      'rien (pas de durée négative)', () {
    expect(
      Anciennete.entre(DateTime(2024, 10, 5), DateTime(2024, 10, 5))!.texte,
      '0 j',
    );
    expect(Anciennete.entre(DateTime(2027), DateTime(2026)), isNull);
    expect(Anciennete.entre(null, DateTime(2026)), isNull);
  });

  test('29 février et fin de mois (jour ramené au dernier jour du mois)', () {
    expect(
      Anciennete.entre(DateTime(2020, 2, 29), DateTime(2021, 2, 28)),
      const Anciennete(1, 0, 0),
    );
    expect(
      Anciennete.entre(DateTime(2024, 1, 31), DateTime(2024, 3, 2)),
      const Anciennete(0, 1, 2),
    );
    expect(const Anciennete(1, 0, 0).texte, '1 an');
  });

  test('référence par défaut : 31 décembre de l’année', () {
    expect(referenceParDefaut(DateTime(2026, 10, 22)), DateTime(2026, 12, 31));
  });
}
