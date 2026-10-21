import 'package:ecoleplus/features/lock/domain/pin.dart';
import 'package:ecoleplus/features/security/domain/journal.dart';
import 'package:ecoleplus/features/sync/domain/sync_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 21, 12);

  group('alerte de synchronisation conditionnelle', () {
    test('rien en attente, synchronisé il y a 10 jours : pas d’alerte', () {
      expect(
        alerteSynchronisation(
          enAttente: 0,
          maintenant: now,
          derniereSynchro: now.subtract(const Duration(days: 10)),
        ),
        isNull,
      );
    });
    test('rien en attente, aucune nouvelle depuis 30 jours : alerte', () {
      expect(
        alerteSynchronisation(
          enAttente: 0,
          maintenant: now,
          derniereSynchro: now.subtract(const Duration(days: 31)),
        ),
        contains('depuis 31 jours'),
      );
    });
    test('données en attente depuis 2 jours : pas encore d’alerte', () {
      expect(
        alerteSynchronisation(
          enAttente: 4,
          maintenant: now,
          plusAncienneAttente: now.subtract(const Duration(days: 2)),
        ),
        isNull,
      );
    });
    test('données en attente depuis 3 jours : alerte', () {
      expect(
        alerteSynchronisation(
          enAttente: 4,
          maintenant: now,
          plusAncienneAttente: now.subtract(const Duration(days: 3)),
        ),
        startsWith('4 éléments saisis depuis 3 jours'),
      );
    });
    test('période de composition : alerte dès 1 jour', () {
      expect(
        alerteSynchronisation(
          enAttente: 1,
          maintenant: now,
          plusAncienneAttente: now.subtract(const Duration(hours: 25)),
          periodeComposition: true,
        ),
        startsWith('1 élément saisi depuis 1 jour'),
      );
    });
  });

  group('code PIN', () {
    test('règles', () {
      expect(validerPin('12a4'), isNotNull);
      expect(validerPin('123'), isNotNull);
      expect(validerPin('1111'), contains('trop facile'));
      expect(validerPin('1234'), contains('trop facile'));
      expect(validerPin('4071'), isNull);
      expect(validerPin('907315'), isNull);
    });
    test('empreinte : stable, dépend du sel, ne contient pas le code', () {
      const sel = 'AAECAwQFBgcICQoLDA0ODw==';
      final e = empreintePin('4071', sel, 1000);
      expect(empreintePin('4071', sel, 1000), e);
      expect(empreintePin('4072', sel, 1000), isNot(e));
      expect(empreintePin('4071', nouveauSel(), 1000), isNot(e));
      expect(e, isNot(contains('4071')));
    });
    test('PBKDF2 conforme au vecteur de référence (RFC 7914 §11)', () {
      // P="passwd", S="salt", c=1, dkLen=32 (premier bloc).
      expect(
        empreintePin('passwd', 'c2FsdA==', 1),
        'VawEblbjCJ/sFpHCJUS2BflBhSFt3gRl5oudV8INrLw=',
      );
    });
    test('PBKDF2 : 20 000 itérations identiques à la référence Python', () {
      // Python : hashlib.pbkdf2_hmac('sha256', b'4071', sel, 20000)
      expect(
        empreintePin('4071', 'AAECAwQFBgcICQoLDA0ODw==', 20000),
        _ref20000,
      );
    });
    test('attente après erreurs', () {
      expect(attenteApresErreurs(4), Duration.zero);
      expect(attenteApresErreurs(5), const Duration(seconds: 30));
      expect(attenteApresErreurs(7), const Duration(minutes: 2));
      expect(attenteApresErreurs(9), const Duration(minutes: 8));
      expect(attenteApresErreurs(10), isNull);
    });
  });

  group('journal d’activité en phrases simples', () {
    test('modification de l’école', () {
      final e = decrireEvenement(
        action: 'modification',
        table: 'schools',
        detailsJson: '{"colonnes":["phone","commune"]}',
        acteur: 'Directeur Test',
      );
      expect(
        e.phrase,
        'Directeur Test a modifié les informations de l’école '
        '(téléphone, commune)',
      );
      expect(e.securite, isFalse);
    });
    test('événements de sécurité', () {
      expect(
        decrireEvenement(
          action: 'recuperation_mot_de_passe',
          table: 'memberships',
          detailsJson: '{"personne":"Enseignant Un"}',
          acteur: 'x',
        ),
        isA<EvenementJournal>()
            .having((e) => e.securite, 'sécurité', isTrue)
            .having((e) => e.phrase, 'phrase', startsWith('Enseignant Un')),
      );
      final connexion = decrireEvenement(
        action: 'connexion',
        table: 'devices',
        detailsJson: '{"telephone":"Tecno","nouveau":true}',
        acteur: 'Enseignant Un',
      );
      expect(connexion.phrase, contains('(nouveau téléphone)'));
      expect(connexion.securite, isTrue);
    });
    test('activation d’un module', () {
      expect(
        decrireEvenement(
          action: 'modification',
          table: 'school_modules',
          detailsJson: '{"module":"cantine","valeurs":{"enabled":true}}',
          acteur: 'Directeur Test',
        ).phrase,
        'Directeur Test a activé le module « cantine »',
      );
    });
  });
}

const _ref20000 = 'M15RwXxxUms1K9ZAd6I8h8jjaHUF5u5+clPmycXTpCA=';
