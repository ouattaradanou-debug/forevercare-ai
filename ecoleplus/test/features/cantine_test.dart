import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/cantine/data/cantine_repository.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/device.dart';
import '../helpers/fake_server.dart';

const _t = '2026-11-01T00:00:00Z';

MealServiceRow repas(String jour, int n, {String? classe}) => MealServiceRow(
  id: '$jour-$classe',
  schoolId: 's',
  day: jour,
  classId: classe,
  mealsCount: n,
  updatedAt: _t,
);

ExpenseRow depense(int montant, String jour, {String cat = 'cantine'}) =>
    ExpenseRow(
      id: 'x$montant$jour',
      schoolId: 's',
      schoolYearId: 'a',
      category: cat,
      label: 'Bois',
      amount: montant,
      spentOn: jour,
      deviceId: 'd',
      deviceSeq: 1,
      updatedAt: _t,
    );

CanteenBeneficiaryRow benef({bool oui = true, bool paie = true}) =>
    CanteenBeneficiaryRow(
      id: 'b',
      schoolId: 's',
      studentId: 'e1',
      schoolYearId: 'a',
      isBeneficiary: oui,
      contributes: paie,
      updatedAt: _t,
    );

Future<CantineRepository> telephone(TestDevice t, String deviceId) async {
  await t.initSession(deviceId: deviceId, serie: deviceId);
  return CantineRepository(t.store);
}

void main() {
  test('quantités : affichage et saisie à la française', () {
    expect(qte(12.5), '12,5');
    expect(qte(3), '3');
    expect(qte(1250.25), '1 250,25');
    expect(qte(-0.5), '−0,5');
    expect(lireQte('12,5'), 12.5);
    expect(lireQte(' 3 '), 3);
    expect(lireQte('abc'), isNull);
    expect(lireQte(''), isNull);
  });

  test('sortie supérieure au stock : refusée avec un message clair', () {
    expect(
      controleSortie(stock: 10, quantite: 12, unite: 'kg'),
      contains('Il ne reste que 10 kg'),
    );
    expect(
      controleSortie(stock: 0, quantite: 1, unite: 'kg'),
      contains('épuisé'),
    );
    expect(controleSortie(stock: 10, quantite: 10, unite: 'kg'), isNull);
    expect(controleSortie(stock: 10, quantite: 0, unite: 'kg'), isNotNull);
  });

  test('coût moyen par repas vérifié à la main (formule affichée)', () {
    // Novembre : 45 000 de dépenses de cantine (dont une annulation de
    // 5 000), 300 repas ; les autres dépenses ne comptent pas.
    final depenses = [
      depense(30000, '2026-11-03'),
      depense(20000, '2026-11-10'),
      depense(-5000, '2026-11-11'),
      depense(9999, '2026-11-12', cat: 'fournitures'),
      depense(7000, '2026-10-30'),
    ];
    final pointages = [
      repas('2026-11-03', 100, classe: 'c1'),
      repas('2026-11-03', 50, classe: 'c2'),
      repas('2026-11-04', 140, classe: 'c1'),
      repas('2026-11-04', 10),
      repas('2026-10-30', 999, classe: 'c1'),
    ];
    final c = CoutMoyen(
      depensesCantine(depenses, mois: '2026-11'),
      totalRepas(pointages, mois: '2026-11'),
    );
    expect((c.depenses, c.repas, c.arrondi), (45000, 300, 150));
    expect(c.formule, contains('45 000 ÷ 300 = 150'));
    expect(repasParJour(pointages, mois: '2026-11'), {
      '2026-11-03': 150,
      '2026-11-04': 150,
    });
    // Aucun repas : pas de coût (jamais de division par zéro).
    const vide = CoutMoyen(1000, 0);
    expect((vide.valeur, vide.arrondi), (null, null));
    expect(vide.formule, contains('aucun repas'));
  });

  test('participation des familles selon le mode', () {
    expect(participe('avec_participation', benef()), isTrue);
    expect(participe('sans_participation', benef()), isFalse);
    expect(participe('mixte', benef(paie: false)), isFalse);
    expect(participe('mixte', benef()), isTrue);
    expect(participe('avec_participation', benef(oui: false)), isFalse);
    expect(participe('avec_participation', null), isFalse);
    final lignes = [
      const FeeItemRow(
        id: 'scol',
        schoolId: 's',
        schoolYearId: 'a',
        rubric: 'scolarite',
        label: 'Scolarité',
        billingPeriod: 'unique',
        amount: 30000,
        paymentTerms: 'partiel',
        updatedAt: _t,
      ),
      const FeeItemRow(
        id: 'cant',
        schoolId: 's',
        schoolYearId: 'a',
        rubric: rubriqueCantine,
        label: 'Cantine',
        billingPeriod: 'unique',
        amount: 6000,
        paymentTerms: 'partiel',
        updatedAt: _t,
      ),
    ];
    expect(avecCantine(lignes, actif: true, participeAuxFrais: true).length, 2);
    expect(
      avecCantine(lignes, actif: true, participeAuxFrais: false).single.id,
      'scol',
    );
    expect(
      avecCantine(lignes, actif: false, participeAuxFrais: true).single.id,
      'scol',
      reason: 'module désactivé : les totaux de scolarité ne changent pas',
    );
    // Impayés de cantine distincts des impayés de scolarité.
    final s = situation(
      studentId: 'e1',
      lignes: lignes,
      tranches: const [],
      remises: const [],
      paiements: const [],
      aujourdhui: '2026-11-04',
    );
    final cantine = filtrerRubrique(s, rubriqueCantine, garder: true);
    final scolarite = filtrerRubrique(s, rubriqueCantine, garder: false);
    expect((cantine.impaye, scolarite.impaye), (6000, 30000));
    expect(cantine.impaye + scolarite.impaye, s.impaye);
  });

  test('semaines et jours', () {
    expect(lundi('2026-11-05'), '2026-11-02');
    expect(lundi('2026-11-02'), '2026-11-02');
    expect(lundi('2026-11-08'), '2026-11-02', reason: 'dimanche');
    expect(joursSemaine('2026-11-02').last, '2026-11-06');
    expect(jourCourt('2026-11-05'), 'jeu. 05/11');
  });

  test('deux téléphones hors ligne : pointages et mouvements fusionnés sans '
      'doublon ; stock calculé = inventaire papier', () async {
    final server = FakeServer();
    final a = TestDevice(server);
    final b = TestDevice(server);
    final ra = await telephone(a, 'dA');
    final rb = await telephone(b, 'dB');
    a.online = false;
    b.online = false;

    // Même produit créé sur les deux téléphones : un seul produit.
    final riz = await ra.ajouterProduit(
      schoolId: 's',
      nom: 'Riz',
      unite: 'kg',
      seuil: 10,
    );
    final riz2 = await rb.ajouterProduit(
      schoolId: 's',
      nom: ' riz ',
      unite: 'kg',
    );
    expect(riz2, riz);
    await expectLater(
      ra.ajouterProduit(schoolId: 's', nom: 'RIZ', unite: 'kg'),
      throwsA(isA<UserMessage>()),
      reason: 'nom déjà pris sur ce téléphone',
    );

    await ra.entree(
      produitId: riz,
      quantite: 50,
      provenance: 'parents',
      date: '2026-11-02',
    );
    await rb.entree(
      produitId: riz,
      quantite: 25,
      provenance: 'produits_locaux',
      date: '2026-11-02',
    );
    await ra.sortie(
      produitId: riz,
      quantite: 12.5,
      motif: 'repas',
      date: '2026-11-03',
    );
    // Sur B : seulement 25 kg connus, sortie de 30 refusée.
    await expectLater(
      rb.sortie(
        produitId: riz,
        quantite: 30,
        motif: 'repas',
        date: '2026-11-03',
      ),
      throwsA(
        isA<UserMessage>().having(
          (e) => e.message,
          'message',
          contains('Il ne reste que 25 kg'),
        ),
      ),
    );
    await rb.sortie(
      produitId: riz,
      quantite: 10,
      motif: 'repas',
      date: '2026-11-03',
    );

    // Pointage de la même classe le même jour sur les deux téléphones :
    // la dernière saisie remplace (jamais d'addition).
    await ra.pointer(
      schoolId: 's',
      jour: '2026-11-03',
      classId: 'c1',
      repas: 30,
    );
    await rb.pointer(
      schoolId: 's',
      jour: '2026-11-03',
      classId: 'c1',
      repas: 32,
    );
    await rb.pointer(
      schoolId: 's',
      jour: '2026-11-03',
      classId: 'c2',
      repas: 20,
    );

    a.online = true;
    b.online = true;
    await a.engine.syncNow();
    await b.engine.syncNow();
    await a.engine.syncNow();
    await a.engine.syncNow();

    expect(server.tables['stock_products'], hasLength(1));
    expect(server.tables['stock_movements'], hasLength(4));
    expect(server.tables['meal_services'], hasLength(2));
    for (final t in [a, b]) {
      final m = await t.db.select(t.db.stockMovements).get();
      expect(m, hasLength(4));
      expect(stockCourant(m, riz), 52.5, reason: '50 + 25 − 12,5 − 10');
      final p = await t.db.select(t.db.mealServices).get();
      expect(totalRepas(p), 52, reason: '32 (dernière saisie) + 20');
    }
    // Numéros des mouvements : série de chaque téléphone.
    final seqA = [
      for (final m in await a.db.select(a.db.stockMovements).get())
        if (m.deviceId == 'dA') m.deviceSeq,
    ]..sort();
    expect(seqA, [1, 2]);

    // Inventaire papier : 50 kg comptés → ajustement de −2,5 motivé.
    await expectLater(
      ra.inventaire(produitId: riz, compte: 50, motif: '', date: '2026-11-05'),
      throwsA(isA<UserMessage>()),
      reason: 'écart sans motif',
    );
    final aj = await ra.inventaire(
      produitId: riz,
      compte: 50,
      motif: 'Sac entamé par les rongeurs',
      date: '2026-11-05',
    );
    expect(aj!.quantityDelta, -2.5);
    expect(
      await ra.inventaire(
        produitId: riz,
        compte: 50,
        motif: '',
        date: '2026-11-05',
      ),
      isNull,
      reason: 'aucun écart',
    );
    final tous = await a.db.select(a.db.stockMovements).get();
    expect(stockCourant(tous, riz), 50);

    // Annulation motivée d'une sortie (jamais de suppression).
    final sortieA = tous.firstWhere(
      (m) => m.kind == 'sortie' && m.deviceId == 'dA',
    );
    final annul = await ra.annuler(sortieA, 'Saisie en double');
    expect(annul.quantityDelta, 12.5);
    await expectLater(
      ra.annuler(sortieA, 'Encore'),
      throwsA(isA<UserMessage>()),
    );
    await expectLater(ra.annuler(annul, 'x'), throwsA(isA<UserMessage>()));
    expect(
      stockCourant(await a.db.select(a.db.stockMovements).get(), riz),
      62.5,
    );
    // Après une grosse sortie, annuler l'entrée de 50 kg rendrait le stock
    // négatif : refusé.
    await ra.sortie(
      produitId: riz,
      quantite: 60,
      motif: 'repas',
      date: '2026-11-06',
    );
    final entreeA = tous.firstWhere(
      (m) => m.kind == 'entree' && m.deviceId == 'dA',
    );
    await expectLater(
      ra.annuler(entreeA, 'Erreur'),
      throwsA(isA<UserMessage>()),
    );
    expect(
      stockCourant(await a.db.select(a.db.stockMovements).get(), riz),
      2.5,
    );

    // Un produit avec du stock ne peut pas être retiré.
    final produit = await a.db.select(a.db.stockProducts).getSingle();
    await expectLater(ra.retirerProduit(produit), throwsA(isA<UserMessage>()));
    await a.close();
    await b.close();
  });

  test(
    'bénéficiaires : même ligne sur deux téléphones ; retrait gardé',
    () async {
      final server = FakeServer();
      final a = TestDevice(server);
      final b = TestDevice(server);
      final ra = await telephone(a, 'dA');
      final rb = await telephone(b, 'dB');
      await ra.definirBeneficiaire(
        schoolId: 's',
        yearId: 'a',
        studentId: 'e1',
        beneficiaire: true,
      );
      await rb.definirBeneficiaire(
        schoolId: 's',
        yearId: 'a',
        studentId: 'e1',
        beneficiaire: true,
        participe: false,
      );
      await a.engine.syncNow();
      await b.engine.syncNow();
      await a.engine.syncNow();
      expect(server.tables['canteen_beneficiaries'], hasLength(1));
      final l = await a.db.select(a.db.canteenBeneficiaries).getSingle();
      expect((l.isBeneficiary, l.contributes), (true, false));
      expect(l.since, isNotNull);
      await ra.definirBeneficiaire(
        schoolId: 's',
        yearId: 'a',
        studentId: 'e1',
        beneficiaire: false,
      );
      final apres = await a.db.select(a.db.canteenBeneficiaries).getSingle();
      expect(apres.isBeneficiary, isFalse);
      expect(apres.since, l.since, reason: 'historique conservé');
      await expectLater(
        ra.pointer(schoolId: 's', jour: '2026-11-03', classId: null, repas: -1),
        throwsA(isA<UserMessage>()),
      );
      // Réglages : avec participation, la rubrique « Cantine » apparaît.
      await ra.enregistrerReglages(
        schoolId: 's',
        mode: 'mixte',
        definition: 'Vivres apportés par la communauté',
      );
      final r = await a.db.select(a.db.feeRubrics).get();
      expect(r.where((x) => x.code == rubriqueCantine), hasLength(1));
      await ra.enregistrerReglages(schoolId: 's', mode: 'avec_participation');
      expect(
        (await a.db.select(a.db.feeRubrics).get()).where(
          (x) => x.code == rubriqueCantine,
        ),
        hasLength(1),
        reason: 'pas de doublon',
      );
      await ra.enregistrerMenu(
        schoolId: 's',
        jour: '2026-11-05',
        texte: 'Riz gras',
      );
      await rb.enregistrerMenu(
        schoolId: 's',
        jour: '2026-11-03',
        texte: 'Haricots',
      );
      await a.engine.syncNow();
      await b.engine.syncNow();
      expect(
        server.tables['canteen_menus'],
        hasLength(1),
        reason: 'même semaine',
      );
      await a.close();
      await b.close();
    },
  );

  test('bilan du mois : stock début / entrées / sorties / fin', () {
    const p = StockProductRow(
      id: 'riz',
      schoolId: 's',
      name: 'Riz',
      unit: 'kg',
      updatedAt: _t,
    );
    StockMovementRow m(String kind, double q, String jour) => StockMovementRow(
      id: '$kind$q$jour',
      schoolId: 's',
      productId: 'riz',
      kind: kind,
      quantityDelta: q,
      occurredOn: jour,
      deviceId: 'd',
      deviceSeq: 1,
      updatedAt: '',
    );
    final mm = mouvementsDuMois(
      [p],
      [
        m('entree', 100, '2026-10-05'),
        m('sortie', -30, '2026-10-20'),
        m('entree', 50, '2026-11-02'),
        m('sortie', -40, '2026-11-10'),
        m('ajustement', -2, '2026-11-30'),
        m('entree', 999, '2026-12-01'),
      ],
      '2026-11',
    ).single;
    expect(
      (mm.stockDebut, mm.entrees, mm.sorties, mm.ajustements, mm.stockFin),
      (70.0, 50.0, 40.0, -2.0, 78.0),
    );
    // Cotisations de cantine : détail des reçus, annulations déduites.
    PaymentRow pay(String id, String rubric, int montant) => PaymentRow(
      id: id,
      schoolId: 's',
      schoolYearId: 'a',
      studentId: 'e1',
      rubric: rubric,
      amount: montant,
      method: 'especes',
      paidAt: '2026-11-03T08:00:00Z',
      deviceId: 'd',
      deviceSeq: 1,
      receiptNumber: 'R',
      updatedAt: '',
    );
    PaymentAllocationRow det(String pid, String rubric, int montant) =>
        PaymentAllocationRow(
          id: '$pid$rubric',
          schoolId: 's',
          paymentId: pid,
          rubric: rubric,
          amount: montant,
          updatedAt: '',
        );
    expect(
      cotisationsCantine(
        [
          pay('p1', 'plusieurs', 12000),
          pay('p2', rubriqueCantine, 2000),
          pay('p3', 'scolarite', 9000),
        ],
        [det('p1', 'scolarite', 10000), det('p1', rubriqueCantine, 2000)],
        mois: '2026-11',
      ),
      4000,
    );
  });
}
