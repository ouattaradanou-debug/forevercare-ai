import 'package:atelier_plus/features/finances/data/calcul_solde.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resteAPayer', () {
    test('soustrait avance et paiements du montant total', () {
      final resultat = resteAPayer(montantTotal: 50000, avance: 10000, sommePaiements: 15000);
      expect(resultat, 25000);
    });

    test('vaut zéro quand le montant total est intégralement couvert', () {
      final resultat = resteAPayer(montantTotal: 30000, avance: 10000, sommePaiements: 20000);
      expect(resultat, 0);
    });

    test('devient négatif en cas de trop-perçu, sans être masqué', () {
      final resultat = resteAPayer(montantTotal: 30000, avance: 10000, sommePaiements: 25000);
      expect(resultat, -5000);
    });

    test('gère une commande sans aucun paiement ni avance', () {
      final resultat = resteAPayer(montantTotal: 20000, avance: 0, sommePaiements: 0);
      expect(resultat, 20000);
    });
  });
}
