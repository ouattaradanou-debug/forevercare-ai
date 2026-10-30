import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/finances/data/finances_repository.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/device.dart';
import '../helpers/fake_server.dart';

Future<FinancesRepository> telephone(
  TestDevice t,
  String deviceId,
  String? serie,
  Directory media,
) async {
  await t.initSession(deviceId: deviceId, serie: serie);
  await t.db
      .into(t.db.schoolYears)
      .insertOnConflictUpdate(
        SchoolYearsCompanion.insert(
          id: 'a',
          schoolId: 's',
          label: '2025-2026',
          updatedAt: '2026-10-01T00:00:00Z',
        ),
      );
  return FinancesRepository(t.store, remote: t.remote, mediaDir: media);
}

void main() {
  test(
    'encaissements hors ligne sur DEUX téléphones puis synchronisation : '
    'numéros uniques, aucun doublon, annulation sur l’autre téléphone',
    () async {
      final server = FakeServer();
      final tmp = Directory.systemTemp.createTempSync('finances');
      final a = TestDevice(server);
      final b = TestDevice(server);
      final ra = await telephone(a, 'dA', 'A', tmp);
      final rb = await telephone(b, 'dB', 'B', tmp);
      a.online = false;
      b.online = false;

      Future<PaymentRow> payer(FinancesRepository r, int montant) =>
          r.encaisser(
            schoolId: 's',
            yearId: 'a',
            studentId: 'e1',
            rubric: 'scolarite',
            feeItemId: null,
            montant: montant,
            mode: 'especes',
          );
      final a1 = await payer(ra, 10000);
      final a2 = await payer(ra, 5000);
      final b1 = await payer(rb, 7000);
      final b2 = await payer(rb, 3000);
      expect([a1, a2, b1, b2].map((p) => p.receiptNumber), [
        'R2526-A-00001',
        'R2526-A-00002',
        'R2526-B-00001',
        'R2526-B-00002',
      ]);

      // Réseau rétabli : chacun envoie, puis reçoit les reçus de l'autre.
      a.online = true;
      b.online = true;
      await a.engine.syncNow();
      await b.engine.syncNow();
      await a.engine.syncNow();
      // Envoi répété (réseau coupé après l'envoi) : toujours 4 reçus.
      await a.engine.syncNow();
      expect(server.tables['payments'], hasLength(4));
      for (final t in [a, b]) {
        final tous = await t.db.select(t.db.payments).get();
        expect(tous, hasLength(4));
        expect(tous.map((p) => p.receiptNumber).toSet(), hasLength(4));
      }

      // Le téléphone B annule un reçu du téléphone A : numéro de la série B.
      final recuA = (await b.db.select(b.db.payments).get()).firstWhere(
        (p) => p.id == a2.id,
      );
      final annul = await rb.annuler(recuA, 'Montant saisi deux fois');
      expect(annul.receiptNumber, 'R2526-B-00003');
      expect(annul.amount, -5000);
      await expectLater(
        rb.annuler(recuA, 'Encore'),
        throwsA(isA<UserMessage>()),
        reason: 'déjà annulé',
      );
      await expectLater(
        rb.annuler(annul, 'x'),
        throwsA(isA<UserMessage>()),
        reason: 'une annulation ne s’annule pas',
      );
      await b.engine.syncNow();
      await a.engine.syncNow();
      final net = (await a.db.select(a.db.payments).get()).fold<int>(
        0,
        (s, p) => s + p.amount,
      );
      expect(net, 20000, reason: '10 000 + 5 000 + 7 000 + 3 000 − 5 000');

      // Le reçu d'origine est intact.
      final origine = await (a.db.select(
        a.db.payments,
      )..where((p) => p.id.equals(a2.id))).getSingle();
      expect((origine.amount, origine.receiptNumber), (5000, 'R2526-A-00002'));

      // Mobile Money sans référence : refusé ; montant nul : refusé.
      await expectLater(
        ra.encaisser(
          schoolId: 's',
          yearId: 'a',
          studentId: 'e1',
          rubric: 'scolarite',
          feeItemId: null,
          montant: 1000,
          mode: 'orange_money',
        ),
        throwsA(isA<UserMessage>()),
      );
      await expectLater(payer(ra, 0), throwsA(isA<UserMessage>()));
      await a.close();
      await b.close();
      tmp.deleteSync(recursive: true);
    },
  );

  test('sans série de reçus (jamais connecté) : message clair', () async {
    final server = FakeServer();
    final tmp = Directory.systemTemp.createTempSync('finances2');
    final t = TestDevice(server);
    final r = await telephone(t, 'dX', null, tmp);
    await expectLater(
      r.encaisser(
        schoolId: 's',
        yearId: 'a',
        studentId: null,
        rubric: 'autre',
        feeItemId: null,
        montant: 100,
        mode: 'especes',
      ),
      throwsA(
        isA<UserMessage>().having(
          (e) => e.message,
          'message',
          contains('série de reçus'),
        ),
      ),
    );
    await t.close();
    tmp.deleteSync(recursive: true);
  });

  test('dépense avec justificatif : copie locale, envoi programmé, pièce '
      'numérotée ; annulation ; clôture une seule fois par mois', () async {
    final server = FakeServer();
    final tmp = Directory.systemTemp.createTempSync('finances3');
    final t = TestDevice(server);
    final r = await telephone(t, 'dA', 'A', tmp);
    final d = await r.depenser(
      schoolId: 's',
      yearId: 'a',
      categorie: 'fournitures',
      libelle: 'Craies',
      montant: 3000,
      date: '2026-10-12',
      mode: 'especes',
      justificatif: (Uint8List.fromList([1, 2, 3]), 'image/jpeg'),
    );
    expect(d.voucherNumber, 'D2526-A-00001');
    expect(d.justificationPath, 's/depenses/${d.id}.jpg');
    expect(File('${tmp.path}/${d.justificationPath}').existsSync(), isTrue);
    final envois = await t.db.select(t.db.fileUploads).get();
    expect(envois.single.bucket, 'finances');
    expect(await r.justificatif(d), [1, 2, 3]);
    final ann = await r.annulerDepense(d, 'Doublon');
    expect((ann.amount, ann.voucherNumber), (-3000, 'D2526-A-00002'));

    await r.cloturer(schoolId: 's', mois: '2026-10', solde: 12000);
    await expectLater(
      r.cloturer(schoolId: 's', mois: '2026-10', solde: 12000),
      throwsA(isA<UserMessage>()),
    );
    await t.engine.syncNow();
    expect(server.files.keys, ['finances/s/depenses/${d.id}.jpg']);
    expect(server.tables['cash_closings'], hasLength(1));
    expect(
      fcfa(
        server.tables['expenses']!.values.fold<int>(
          0,
          (s, e) => s + (e['amount'] as int),
        ),
      ),
      '0 FCFA',
    );
    await t.close();
    tmp.deleteSync(recursive: true);
  });

  test('rapprochement de la journée fictive du guide de test : 33 500 FCFA '
      'en espèces', () async {
    final server = FakeServer();
    final tmp = Directory.systemTemp.createTempSync('finances4');
    final t = TestDevice(server);
    final r = await telephone(t, 'dA', 'A', tmp);
    Future<PaymentRow> payer(
      int m, {
      String? eleve = 'e1',
      String mode = 'especes',
      String? ref,
    }) => r.encaisser(
      schoolId: 's',
      yearId: 'a',
      studentId: eleve,
      rubric: eleve == null ? 'autre' : 'scolarite',
      feeItemId: null,
      montant: m,
      mode: mode,
      reference: ref,
    );
    await payer(20000, eleve: null);
    await payer(10000);
    await payer(5000, eleve: 'e2', mode: 'orange_money', ref: 'OM-1');
    final clarisse = await payer(7500, eleve: 'e3');
    await r.depenser(
      schoolId: 's',
      yearId: 'a',
      categorie: 'fournitures',
      libelle: 'Craies',
      montant: 1500,
      date: t.time.toIso8601String().substring(0, 10),
      mode: 'especes',
    );
    await r.annuler(clarisse, 'Erreur de montant');
    await payer(5000, eleve: 'e3');
    final j = journalCaisse(
      paiements: await t.db.select(t.db.payments).get(),
      depenses: await t.db.select(t.db.expenses).get(),
      nomEleve: (_) => '',
    );
    expect(j, hasLength(7));
    expect(solde(j, mode: 'especes'), 33500);
    expect(solde(j), 38500, reason: 'avec le Mobile Money');
    await t.close();
    tmp.deleteSync(recursive: true);
  });
}
