import 'package:test/test.dart';
import 'package:cave_manager/core/utils/paiement_calculator.dart';

void main() {
  group('calculerResteAPayer', () {
    test('paiement exact en espèces -> reste à payer = 0, soldé', () {
      final resultat =
          calculerResteAPayer(totalACharger: 15000, montantEspeces: 15000);

      expect(resultat.montantPaye, 15000);
      expect(resultat.resteAPayer, 0);
      expect(resultat.estSolde, isTrue);
    });

    test(
        'paiement partiel en Mobile Money -> reste à payer calculé automatiquement',
        () {
      final resultat =
          calculerResteAPayer(totalACharger: 20000, montantMobileMoney: 12000);

      expect(resultat.montantPaye, 12000);
      expect(resultat.resteAPayer, 8000);
      expect(resultat.estSolde, isFalse);
    });

    test('paiement mixte espèces + Mobile Money exact -> soldé', () {
      final resultat = calculerResteAPayer(
        totalACharger: 30000,
        montantEspeces: 10000,
        montantMobileMoney: 20000,
      );

      expect(resultat.montantPaye, 30000);
      expect(resultat.resteAPayer, 0);
      expect(resultat.estSolde, isTrue);
    });

    test('paiement mixte partiel -> reste à payer > 0', () {
      final resultat = calculerResteAPayer(
        totalACharger: 30000,
        montantEspeces: 5000,
        montantMobileMoney: 10000,
      );

      expect(resultat.montantPaye, 15000);
      expect(resultat.resteAPayer, 15000);
      expect(resultat.estSolde, isFalse);
    });

    test('aucun paiement saisi -> reste à payer = total', () {
      final resultat = calculerResteAPayer(totalACharger: 5000);

      expect(resultat.montantPaye, 0);
      expect(resultat.resteAPayer, 5000);
    });

    test('trop-perçu -> reste à payer plafonné à 0 (pas de valeur négative)',
        () {
      final resultat =
          calculerResteAPayer(totalACharger: 10000, montantEspeces: 12000);

      expect(resultat.resteAPayer, 0);
      expect(resultat.estSolde, isTrue);
    });

    test('total négatif -> erreur explicite', () {
      expect(
          () => calculerResteAPayer(totalACharger: -100), throwsArgumentError);
    });

    test('montant espèces négatif -> erreur explicite', () {
      expect(
        () => calculerResteAPayer(totalACharger: 1000, montantEspeces: -50),
        throwsArgumentError,
      );
    });
  });
}
