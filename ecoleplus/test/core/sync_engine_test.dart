import 'dart:convert';

import 'package:ecoleplus/core/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/device.dart';
import '../helpers/fake_server.dart';

const ecole = '10000000-0000-4000-8000-000000000001';

Map<String, Object?> annee(String id, String label) => {
  'id': id,
  'school_id': ecole,
  'label': label,
};

void main() {
  late FakeServer server;
  late TestDevice a;
  late TestDevice b;

  setUp(() async {
    server = FakeServer();
    a = TestDevice(server);
    b = TestDevice(server);
    await a.initSession();
    await b.initSession();
  });

  tearDown(() async {
    await a.close();
    await b.close();
  });

  test(
    'mode avion : les écritures restent sur le téléphone, en attente',
    () async {
      a.online = false;
      await a.store.save('school_years', annee('y1', '2026-2027'));
      await a.store.save('school_years', annee('y2', '2027-2028'));

      final state = await a.engine.syncNow();

      expect(state.phase, SyncPhase.offline);
      expect(await a.store.pendingCount(), 2);
      expect(await a.db.select(a.db.schoolYears).get(), hasLength(2));
      expect(server.table('school_years'), isEmpty);
    },
  );

  test('retour du réseau : tout est envoyé, sans perte ni doublon', () async {
    a.online = false;
    for (var i = 0; i < 120; i++) {
      await a.store.save('school_years', annee('y$i', '20${10 + i}-x'));
    }
    await a.engine.syncNow();
    a.online = true;

    final state = await a.engine.syncNow();
    await a.engine.syncNow(); // une seconde synchronisation ne renvoie rien

    expect(state.phase, SyncPhase.idle);
    expect(await a.store.pendingCount(), 0);
    expect(server.table('school_years'), hasLength(120));
    expect(await a.db.select(a.db.schoolYears).get(), hasLength(120));
  });

  test(
    'modifications successives d’une ligne : une seule entrée fusionnée',
    () async {
      a.online = false;
      await a.store.save('schools', {'id': ecole, 'name': 'École A'});
      await a.store.save('schools', {'id': ecole, 'phone': '70 00 00 00'});
      await a.store.save('schools', {'id': ecole, 'name': 'École B'});

      final entries = await a.db.select(a.db.outbox).get();
      expect(entries, hasLength(1));
      expect(entries.single.revision, 3);
      final payload =
          jsonDecode(entries.single.payload) as Map<String, dynamic>;
      expect(payload['name'], 'École B');
      expect(payload['phone'], '70 00 00 00');
    },
  );

  test('deux téléphones hors ligne : la dernière modification gagne, '
      'l’autre est tracée, les deux finissent identiques', () async {
    server.seed('admin_headers', {
      'id': 'h1',
      'school_id': ecole,
      'school_year_id': 'y',
      'country': 'BURKINA FASO',
      'ceb': 'CEB initiale',
      'ministry': 'MINISTÈRE',
      'updated_at': '2026-10-21T07:00:00.000Z',
    });
    await a.engine.syncNow();
    await b.engine.syncNow();
    a.online = false;
    b.online = false;

    await a.store.save('admin_headers', {'id': 'h1', 'ceb': 'CEB de A'});
    b.advance(const Duration(minutes: 5));
    await b.store.save('admin_headers', {'id': 'h1', 'ceb': 'CEB de B'});

    b.online = true;
    await b.engine.syncNow(); // B (plus récent) arrive en premier
    a.online = true;
    await a.engine.syncNow(); // A (plus ancien) arrive ensuite : ignoré
    await b.engine.syncNow();

    final serveur = server.table('admin_headers').values.single;
    expect(serveur['ceb'], 'CEB de B');
    expect(serveur['ministry'], 'MINISTÈRE', reason: 'colonnes non touchées');
    expect(
      server.conflicts.where((c) => (c['loser'] as Map)['ceb'] == 'CEB de A'),
      hasLength(1),
    );
    final surA = await a.store.read('admin_headers', {'id': 'h1'});
    final surB = await b.store.read('admin_headers', {'id': 'h1'});
    expect(surA!['ceb'], 'CEB de B');
    expect(surB!['ceb'], 'CEB de B');
    expect(await a.store.pendingCount(), 0);
  });

  test(
    'changement refusé : message clair et retour à la version du serveur',
    () async {
      server.seed('schools', {
        'id': ecole,
        'name': 'École Test',
        'school_type': 'publique',
        'manages_primary': true,
        'grading_scale': 10,
        'show_race_religion': false,
        'absent_rule': 'non_compte',
        'updated_at': '2026-10-21T07:00:00.000Z',
      });
      await a.engine.syncNow();
      server.rejectWith = (table, row) => table == 'schools' ? '42501' : null;

      await a.store.save('schools', {'id': ecole, 'name': 'Piratée'});
      await a.engine.syncNow();

      final entry = (await a.db.select(a.db.outbox).get()).single;
      expect(entry.status, 'refuse');
      expect(entry.message, contains('pas le droit'));
      expect(
        (await a.store.read('schools', {'id': ecole}))!['name'],
        'École Test',
      );
      expect(await a.store.pendingCount(), 0);
    },
  );

  test('une ligne créée puis refusée disparaît du téléphone', () async {
    server.rejectWith = (table, row) => '42501';
    await a.store.save('school_years', annee('y-refus', '2030-2031'));
    await a.engine.syncNow();
    expect(await a.store.read('school_years', {'id': 'y-refus'}), isNull);
  });

  test(
    'téléchargement : une modification locale non envoyée reste prioritaire',
    () async {
      server.seed('school_years', {
        ...annee('y1', '2025-2026'),
        'updated_at': '2026-10-21T07:00:00.000Z',
      });
      await a.engine.syncNow();
      await a.store.save('school_years', {
        'id': 'y1',
        'starts_on': '2025-10-01',
      });
      // Pendant ce temps, une autre version arrive sur le serveur…
      server.seed('school_years', {
        ...annee('y1', '2025-2026 (serveur)'),
        'updated_at': '2026-10-21T07:30:00.000Z',
      });
      // … et la réponse à notre envoi se perd : l'entrée reste en attente.
      a.remote.dropPushResults = true;
      await a.engine.syncNow();
      final local = await a.store.read('school_years', {'id': 'y1'});
      expect(local!['starts_on'], '2025-10-01');
      expect(local['label'], '2025-2026', reason: 'pas écrasée par le serveur');
      expect(await a.store.pendingCount(), 1);

      a.remote.dropPushResults = false;
      await a.engine.syncNow();
      expect(await a.store.pendingCount(), 0);
      expect(
        server.table('school_years').values.single['starts_on'],
        '2025-10-01',
      );
    },
  );

  test(
    'pagination : 130 lignes au même instant serveur sont toutes reçues',
    () async {
      final fixed = server.now;
      for (var i = 0; i < 130; i++) {
        server
          ..now = fixed
          ..seed('school_years', {
            ...annee('y${i.toString().padLeft(3, '0')}', 'L$i'),
            'updated_at': '2026-10-21T07:00:00.000Z',
          });
      }
      await a.engine.syncNow();
      expect(await a.db.select(a.db.schoolYears).get(), hasLength(130));
    },
  );

  test(
    'horloge du téléphone fausse : l’heure enregistrée est corrigée',
    () async {
      a.time = DateTime.utc(2026); // téléphone réglé 10 mois trop tôt
      await a.engine.syncNow(); // mesure de l'écart avec le serveur
      final row = await a.store.save('school_years', annee('y1', '2026-2027'));
      expect(
        DateTime.parse(row['updated_at'] as String)
            .difference(server.now)
            .abs(),
        lessThan(const Duration(seconds: 1)),
      );
    },
  );

  test('téléphone déconnecté par le directeur : rien n’est envoyé, '
      'l’application est prévenue', () async {
    await a.store.save('school_years', annee('y1', '2026-2027'));
    server.revokedDevices.add('d'); // identité du téléphone de test
    final state = await a.engine.syncNow();
    expect(state.phase, SyncPhase.revoked);
    expect(server.table('school_years'), isEmpty);
  });

  test(
    'le serveur connaît le nombre d’éléments en attente du téléphone',
    () async {
      a.online = true;
      server.rejectWith = (t, r) => null;
      a.remote.dropPushResults = true;
      await a.store.save('school_years', annee('y1', '2026-2027'));
      await a.engine.syncNow();
      expect(server.reportedPending['d'], 1);
    },
  );
}
