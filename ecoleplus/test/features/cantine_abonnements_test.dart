import 'dart:io';

import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/cantine/data/cantine_repository.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/finances/data/finances_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/device.dart';
import '../helpers/fake_server.dart';

const _t = '2026-10-01T00:00:00Z';
const _mois = [
  '2025-10-01',
  '2025-11-01',
  '2025-12-01',
  '2026-01-01',
  '2026-02-01',
];

CanteenRateRow tarif(String depuis, int montant) => CanteenRateRow(
  id: depuis,
  schoolId: 's',
  schoolYearId: 'a',
  fromMonth: depuis,
  amount: montant,
  updatedAt: _t,
);

/// Un téléphone avec l'année et la session (série de reçus « A »).
Future<(TestDevice, CantineRepository, FinancesRepository)> telephone(
  FakeServer server,
  String deviceId,
) async {
  final t = TestDevice(server);
  await t.initSession(deviceId: deviceId, serie: deviceId);
  await t.db
      .into(t.db.schoolYears)
      .insertOnConflictUpdate(
        SchoolYearsCompanion.insert(
          id: 'a',
          schoolId: 's',
          label: '2025-2026',
          updatedAt: _t,
        ),
      );
  return (
    t,
    CantineRepository(t.store),
    FinancesRepository(
      t.store,
      remote: t.remote,
      mediaDir: Directory.systemTemp,
    ),
  );
}

Future<SituationCantine> lire(TestDevice t, String eleve) async =>
    situationCantine(
      studentId: eleve,
      mois: _mois,
      tarifs: await t.db.select(t.db.canteenRates).get(),
      abonnements: await t.db.select(t.db.canteenSubscriptions).get(),
      payes: payeParAbonnement(
        await t.db.select(t.db.paymentAllocations).get(),
      ),
      fiche: (await t.db.select(t.db.canteenBeneficiaries).get())
          .where((b) => b.studentId == eleve)
          .firstOrNull,
    );

void main() {
  test('tarif applicable : le dernier « à partir de » ce mois', () {
    final t = [tarif('2025-10-01', 5000), tarif('2026-01-01', 6000)];
    expect(tarifDuMois(t, '2025-12-01'), 5000);
    expect(tarifDuMois(t, '2026-01-01'), 6000);
    expect(tarifDuMois(t, '2026-02-01'), 6000);
    expect(tarifDuMois(const [], '2026-02-01'), isNull);
    expect(tarifDuMois(t, '2025-09-01'), isNull);
    expect(libelleMoisCantine('2026-11-01'), 'novembre 2026');
    expect(moisParDefaut('2025-2026').first, '2025-10-01');
    expect(moisParDefaut('2025-2026').last, '2026-06-01');
  });

  test('statuts : non abonné ne doit rien ; partiel ≠ abonné ; '
      'répartition dans l’ordre des mois', () {
    const non = MoisEleve(
      mois: '2025-10-01',
      tarif: 5000,
      abonnement: null,
      paye: 0,
    );
    expect(
      (non.statut, non.du, non.reste, non.payable),
      (StatutMois.nonAbonne, 0, 0, true),
    );
    CanteenSubscriptionRow ab(int du, {bool exempt = false}) =>
        CanteenSubscriptionRow(
          id: 'x',
          schoolId: 's',
          schoolYearId: 'a',
          studentId: 'e',
          month: '2025-10-01',
          amountDue: du,
          exempt: exempt,
          updatedAt: _t,
        );
    final partiel = MoisEleve(
      mois: '2025-10-01',
      tarif: 6000,
      abonnement: ab(5000),
      paye: 2000,
    );
    expect(
      (partiel.statut, partiel.du, partiel.reste, partiel.aVerser),
      (StatutMois.partiel, 5000, 3000, 3000),
      reason: 'montant figé (5 000) malgré le nouveau tarif',
    );
    final paye = MoisEleve(
      mois: '2025-10-01',
      tarif: 5000,
      abonnement: ab(5000),
      paye: 5000,
    );
    expect((paye.statut, paye.payable), (StatutMois.abonne, false));
    final exo = MoisEleve(
      mois: '2025-10-01',
      tarif: 0,
      abonnement: ab(0, exempt: true),
      paye: 0,
    );
    expect((exo.statut, exo.du), (StatutMois.abonne, 0));
    // Paiement annulé : plus abonné, aucune dette.
    final annule = MoisEleve(
      mois: '2025-10-01',
      tarif: 5000,
      abonnement: ab(5000),
      paye: 0,
    );
    expect((annule.statut, annule.du), (StatutMois.nonAbonne, 0));

    const nov = MoisEleve(
      mois: '2025-11-01',
      tarif: 5000,
      abonnement: null,
      paye: 0,
    );
    const jan = MoisEleve(
      mois: '2026-01-01',
      tarif: 5000,
      abonnement: null,
      paye: 0,
    );
    expect(
      [
        for (final (m, p) in repartir(7000, [jan, nov])) (m.mois, p),
      ],
      [('2025-11-01', 5000), ('2026-01-01', 2000)],
    );
    final bord = TableauBordCantine.depuis([non, partiel, paye, exo]);
    expect((bord.abonnes, bord.partiels, bord.nonAbonnes), (2, 1, 1));
    expect((bord.attendu, bord.encaisse, bord.restant), (10000, 7000, 3000));
    expect(TableauBordCantine.depuis([non]).taux, isNull);
  });

  test('abonner et encaisser : un mois, plusieurs mois (consécutifs ou '
      'non), interruption et reprise, avance, double paiement refusé, '
      'annulation, tarif modifié, exonération', () async {
    final server = FakeServer();
    final (t, repo, fin) = await telephone(server, 'A');
    await repo.fixerTarif(
      schoolId: 's',
      yearId: 'a',
      aPartirDe: '2025-10-15',
      montant: 5000,
    );
    var s = await lire(t, 'e1');
    expect(s.mois.every((m) => m.statut == StatutMois.nonAbonne), isTrue);
    expect(s.du, 0, reason: 'non abonné : aucune dette');

    Future<PaymentRow?> payer(
      List<String> mois,
      int recu, {
      String e = 'e1',
    }) async {
      final sit = await lire(t, e);
      return await repo.abonnerEtEncaisser(
        finances: fin,
        schoolId: 's',
        yearId: 'a',
        studentId: e,
        classId: 'c1',
        mois: [for (final m in mois) sit.duMois(m)!],
        recu: recu,
        mode: 'especes',
        payeur: 'M. TEST',
      );
    }

    // Octobre seul.
    final r1 = await payer(['2025-10-01'], 5000);
    expect(r1!.receiptNumber, 'R2526-A-00001');
    expect(r1.rubric, rubriqueCantine);
    // Novembre + janvier (non consécutifs) en un seul reçu ; décembre :
    // interruption.
    final r2 = await payer(['2026-01-01', '2025-11-01'], 10000);
    final detail = await (t.db.select(
      t.db.paymentAllocations,
    )..where((a) => a.paymentId.equals(r2!.id))).get();
    expect(
      detail.map((a) => (a.label, a.amount)),
      unorderedEquals([
        ('Cantine — novembre 2025', 5000),
        ('Cantine — janvier 2026', 5000),
      ]),
    );
    s = await lire(t, 'e1');
    expect(
      [for (final m in s.mois) m.statut],
      [
        StatutMois.abonne,
        StatutMois.abonne,
        StatutMois.nonAbonne,
        StatutMois.abonne,
        StatutMois.nonAbonne,
      ],
    );
    expect((s.moisAbonnes, s.du, s.encaisse, s.reste), (3, 15000, 15000, 0));

    // Double paiement : refusé.
    await expectLater(
      payer(['2025-10-01'], 5000),
      throwsA(
        isA<UserMessage>().having((e) => e.message, 'm', contains('déjà payé')),
      ),
    );
    // Plus que le total : refusé.
    await expectLater(payer(['2025-12-01'], 6000), throwsA(isA<UserMessage>()));

    // Nouveau tarif dès janvier : 6 000 ; les mois déjà abonnés gardent 5 000.
    await repo.fixerTarif(
      schoolId: 's',
      yearId: 'a',
      aPartirDe: '2026-01-01',
      montant: 6000,
    );
    s = await lire(t, 'e1');
    expect(s.duMois('2026-01-01')!.montant, 5000, reason: 'déjà abonné');
    expect(s.duMois('2026-02-01')!.montant, 6000);

    // Reprise en décembre et février, avance de 8 000 sur 11 000 :
    // décembre payé, février en paiement partiel (pas de repas).
    final r3 = await payer(['2025-12-01', '2026-02-01'], 8000);
    expect(r3!.amount, 8000);
    s = await lire(t, 'e1');
    expect(s.duMois('2025-12-01')!.statut, StatutMois.abonne);
    expect(
      (s.duMois('2026-02-01')!.statut, s.duMois('2026-02-01')!.aVerser),
      (StatutMois.partiel, 3000),
    );
    expect(s.reste, 3000);
    // Le complément termine février.
    await payer(['2026-02-01'], 3000);
    s = await lire(t, 'e1');
    expect(s.duMois('2026-02-01')!.statut, StatutMois.abonne);
    expect((s.moisAbonnes, s.encaisse), (5, 26000));

    // Annulation motivée d'un reçu : les mois redeviennent non abonnés,
    // sans dette ; l'historique reste.
    await fin.annuler(r2!, 'Erreur d’élève');
    s = await lire(t, 'e1');
    expect(s.duMois('2025-11-01')!.statut, StatutMois.nonAbonne);
    expect(s.duMois('2025-11-01')!.du, 0);
    expect(await t.db.select(t.db.canteenSubscriptions).get(), hasLength(5));

    // Exonéré : abonné sans reçu ; réduction : montant diminué.
    await repo.definirFiche(
      schoolId: 's',
      yearId: 'a',
      studentId: 'e2',
      exonere: true,
    );
    expect(await payer(['2025-10-01'], 0, e: 'e2'), isNull);
    expect(
      (await lire(t, 'e2')).duMois('2025-10-01')!.statut,
      StatutMois.abonne,
    );
    await repo.definirFiche(
      schoolId: 's',
      yearId: 'a',
      studentId: 'e3',
      exonere: false,
      reduction: 1000,
    );
    expect((await lire(t, 'e3')).duMois('2025-10-01')!.aVerser, 4000);

    // Un mois coché sans aucun versement (avance trop petite) ne crée pas
    // d'abonnement : pas de dette.
    await payer(['2025-10-01', '2025-11-01'], 1000, e: 'e4');
    final e4 = await lire(t, 'e4');
    expect(e4.duMois('2025-10-01')!.statut, StatutMois.partiel);
    expect(e4.duMois('2025-11-01')!.abonnement, isNull);
    await t.close();
  });

  test(
    'deux téléphones : même abonnement (aucun doublon) ; reçus distincts',
    () async {
      final server = FakeServer();
      final (a, ra, fa) = await telephone(server, 'A');
      final (b, rb, fb) = await telephone(server, 'B');
      await ra.fixerTarif(
        schoolId: 's',
        yearId: 'a',
        aPartirDe: '2025-10-01',
        montant: 5000,
      );
      await a.engine.syncNow();
      await b.engine.syncNow();
      a.online = false;
      b.online = false;
      Future<void> payer(
        TestDevice t,
        CantineRepository r,
        FinancesRepository f,
        String e,
      ) async {
        final sit = await lire(t, e);
        await r.abonnerEtEncaisser(
          finances: f,
          schoolId: 's',
          yearId: 'a',
          studentId: e,
          classId: null,
          mois: [sit.duMois('2025-10-01')!],
          recu: 5000,
          mode: 'especes',
        );
      }

      await payer(a, ra, fa, 'e1');
      await payer(b, rb, fb, 'e2');
      a.online = true;
      b.online = true;
      await a.engine.syncNow();
      await b.engine.syncNow();
      await a.engine.syncNow();
      expect(server.tables['canteen_subscriptions'], hasLength(2));
      expect(server.tables['payments'], hasLength(2));
      for (final t in [a, b]) {
        expect(
          (await lire(t, 'e1')).duMois('2025-10-01')!.statut,
          StatutMois.abonne,
        );
        expect(
          (await lire(t, 'e2')).duMois('2025-10-01')!.statut,
          StatutMois.abonne,
        );
      }
      await a.close();
      await b.close();
    },
  );
}
