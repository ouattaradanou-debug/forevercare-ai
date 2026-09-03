import 'package:atelier_plus/data/models/abonnement.dart';
import 'package:atelier_plus/features/abonnement/data/etat_abonnement.dart';
import 'package:flutter_test/flutter_test.dart';

Abonnement _abonnement({required String statut, required DateTime dateFinEssai}) {
  return Abonnement(id: 'a1', atelierId: 't1', statut: statut, dateFinEssai: dateFinEssai);
}

void main() {
  final maintenant = DateTime.utc(2026, 1, 15);

  group('joursRestantsEssai', () {
    test('compte les jours restants avant la fin de l\'essai', () {
      final abonnement = _abonnement(statut: 'essai', dateFinEssai: DateTime.utc(2026, 1, 20));
      expect(joursRestantsEssai(abonnement, maintenant: maintenant), 5);
    });

    test('est négatif quand la date est dépassée', () {
      final abonnement = _abonnement(statut: 'essai', dateFinEssai: DateTime.utc(2026, 1, 10));
      expect(joursRestantsEssai(abonnement, maintenant: maintenant), -5);
    });
  });

  group('estEnModeConsultationSeule', () {
    test('un abonnement actif n\'est jamais en lecture seule, même après la date d\'essai', () {
      final abonnement = _abonnement(statut: 'actif', dateFinEssai: DateTime.utc(2020, 1, 1));
      expect(estEnModeConsultationSeule(abonnement, maintenant: maintenant), isFalse);
    });

    test('un abonnement expiré est toujours en lecture seule', () {
      final abonnement = _abonnement(statut: 'expire', dateFinEssai: DateTime.utc(2030, 1, 1));
      expect(estEnModeConsultationSeule(abonnement, maintenant: maintenant), isTrue);
    });

    test('un abonnement suspendu est toujours en lecture seule', () {
      final abonnement = _abonnement(statut: 'suspendu', dateFinEssai: DateTime.utc(2030, 1, 1));
      expect(estEnModeConsultationSeule(abonnement, maintenant: maintenant), isTrue);
    });

    test('un essai encore valide n\'est pas en lecture seule', () {
      final abonnement = _abonnement(statut: 'essai', dateFinEssai: DateTime.utc(2026, 1, 20));
      expect(estEnModeConsultationSeule(abonnement, maintenant: maintenant), isFalse);
    });

    test(
        'un essai dont la date est dépassée bascule en lecture seule même si '
        'statut est resté "essai" en base (aucune tâche planifiée ne le change)',
        () {
      final abonnement = _abonnement(statut: 'essai', dateFinEssai: DateTime.utc(2026, 1, 10));
      expect(estEnModeConsultationSeule(abonnement, maintenant: maintenant), isTrue);
    });
  });

  group('doitAfficherRappelEssai', () {
    test('vrai à J-7', () {
      final abonnement = _abonnement(statut: 'essai', dateFinEssai: DateTime.utc(2026, 1, 22));
      expect(doitAfficherRappelEssai(abonnement, maintenant: maintenant), isTrue);
    });

    test('vrai à J-1', () {
      final abonnement = _abonnement(statut: 'essai', dateFinEssai: DateTime.utc(2026, 1, 16));
      expect(doitAfficherRappelEssai(abonnement, maintenant: maintenant), isTrue);
    });

    test('faux à J-8 (trop tôt)', () {
      final abonnement = _abonnement(statut: 'essai', dateFinEssai: DateTime.utc(2026, 1, 23));
      expect(doitAfficherRappelEssai(abonnement, maintenant: maintenant), isFalse);
    });

    test('faux une fois l\'essai déjà terminé (autre message affiché)', () {
      final abonnement = _abonnement(statut: 'essai', dateFinEssai: DateTime.utc(2026, 1, 10));
      expect(doitAfficherRappelEssai(abonnement, maintenant: maintenant), isFalse);
    });

    test('faux pour un abonnement déjà actif', () {
      final abonnement = _abonnement(statut: 'actif', dateFinEssai: DateTime.utc(2026, 1, 16));
      expect(doitAfficherRappelEssai(abonnement, maintenant: maintenant), isFalse);
    });
  });
}
