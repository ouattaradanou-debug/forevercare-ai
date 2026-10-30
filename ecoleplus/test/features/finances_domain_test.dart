import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:flutter_test/flutter_test.dart';

const _t = '2026-10-01T00:00:00Z';

FeeItemRow ligne(
  String id,
  int montant, {
  String rubrique = 'scolarite',
  String libelle = 'Scolarité',
  String? niveau,
  String? classe,
}) => FeeItemRow(
  id: id,
  schoolId: 's',
  schoolYearId: 'a',
  rubric: rubrique,
  label: libelle,
  levelCode: niveau,
  classId: classe,
  billingPeriod: 'unique',
  amount: montant,
  updatedAt: _t,
);

FeeInstallmentRow tranche(String ligneId, int montant, String echeance) =>
    FeeInstallmentRow(
      id: '$ligneId-$echeance',
      schoolId: 's',
      feeItemId: ligneId,
      label: 'Tranche',
      dueOn: echeance,
      amount: montant,
      updatedAt: _t,
    );

PaymentRow paiement(
  String id,
  int montant, {
  String eleve = 'e1',
  String? ligneId = 'scol',
  String? annule,
  int numero = 1,
}) => PaymentRow(
  id: id,
  schoolId: 's',
  schoolYearId: 'a',
  studentId: eleve,
  rubric: 'scolarite',
  feeItemId: ligneId,
  amount: montant,
  method: 'especes',
  paidAt: '2026-10-1${numero % 10}T08:00:00Z',
  deviceId: 'd',
  deviceSeq: numero,
  receiptNumber: numeroRecu('2025-2026', 'A', numero),
  reversesPaymentId: annule,
  reversalReason: annule == null ? null : 'Erreur',
  updatedAt: _t,
);

(DiscountRow, StudentDiscountRow) remise(
  String kind,
  double valeur, {
  String eleve = 'e1',
  String? rubrique,
  String? ligneId,
}) => (
  DiscountRow(
    id: 'r-$kind-$valeur',
    schoolId: 's',
    label: 'Fratrie',
    kind: kind,
    value: valeur,
    rubric: rubrique,
    updatedAt: _t,
  ),
  StudentDiscountRow(
    id: 'sd-$kind-$valeur-$eleve',
    schoolId: 's',
    studentId: eleve,
    discountId: 'r-$kind-$valeur',
    schoolYearId: 'a',
    feeItemId: ligneId,
    updatedAt: _t,
  ),
);

void main() {
  test('numéro de reçu identique au contrôle du serveur', () {
    expect(numeroRecu('2025-2026', 'A', 12), 'R2526-A-00012');
    expect(numeroRecu('2026-2027', 'AB', 1), 'R2627-AB-00001');
    expect(numeroPiece('2025-2026', 'C', 3), 'D2526-C-00003');
    expect(prochainNumero(const []), 1);
    expect(prochainNumero(const [1, 2, 5]), 6, reason: 'jamais en arrière');
  });

  test('montants : FCFA et toutes lettres', () {
    expect(fcfa(25000), '25 000 FCFA');
    expect(fcfa(1250500), '1 250 500 FCFA');
    expect(fcfa(-3000), '−3 000 FCFA');
    for (final (n, txt) in const [
      (1, 'un franc CFA'),
      (21, 'vingt-et-un francs CFA'),
      (71, 'soixante-et-onze francs CFA'),
      (80, 'quatre-vingts francs CFA'),
      (81, 'quatre-vingt-un francs CFA'),
      (99, 'quatre-vingt-dix-neuf francs CFA'),
      (200, 'deux-cents francs CFA'),
      (250, 'deux-cent-cinquante francs CFA'),
      (1000, 'mille francs CFA'),
      (2500, 'deux-mille-cinq-cents francs CFA'),
      (25000, 'vingt-cinq-mille francs CFA'),
      (80000, 'quatre-vingt-mille francs CFA'),
      (200000, 'deux-cent-mille francs CFA'),
      (1500000, 'un-million-cinq-cent-mille francs CFA'),
      (2000000, 'deux-millions francs CFA'),
    ]) {
      expect(enLettres(n), txt, reason: '$n');
    }
  });

  test('grille par niveau, ajustée pour une classe', () {
    final grille = [
      ligne('niv', 25000, niveau: 'CM1'),
      ligne('classe', 30000, classe: 'cm1b'),
      ligne('ins', 5000, rubrique: 'inscription', libelle: 'Inscription'),
      ligne('ce1', 20000, niveau: 'CE1'),
    ];
    final a = fraisApplicables(grille, niveau: 'CM1', classe: 'cm1a');
    expect(a.map((f) => f.id), ['niv', 'ins']);
    final b = fraisApplicables(grille, niveau: 'CM1', classe: 'cm1b');
    expect(b.map((f) => f.id), ['classe', 'ins'], reason: 'tarif de classe');
  });

  test('soldes exacts : remises, échéancier, encaissements et annulation', () {
    final scol = ligne('scol', 30000);
    final ins = ligne(
      'ins',
      5000,
      rubrique: 'inscription',
      libelle: 'Inscription',
    );
    final tranches = [
      tranche('scol', 10000, '2026-10-15'),
      tranche('scol', 10000, '2027-01-15'),
      tranche('scol', 10000, '2027-04-15'),
    ];
    final remises = [
      remise('pourcentage', 10, rubrique: 'scolarite'),
      remise('montant', 500, ligneId: 'ins'),
      remise('pourcentage', 50, eleve: 'e2'),
    ];
    final paiements = [
      paiement('p1', 10000),
      paiement('p2', 4500, ligneId: 'ins', numero: 2),
      paiement('p3', 8000, numero: 3),
      paiement('p4', -8000, annule: 'p3', numero: 4),
      paiement('p5', 2000, ligneId: null, numero: 5),
      paiement('p6', 9999, eleve: 'e2', numero: 6),
    ];
    final s = situation(
      studentId: 'e1',
      lignes: [scol, ins],
      tranches: tranches,
      remises: remises,
      paiements: paiements,
      aujourdhui: '2026-11-02',
    );
    final sc = s.lignes.firstWhere((l) => l.ligne.id == 'scol');
    expect(sc.reduction, 3000, reason: '10 % de 30 000');
    expect(sc.du, 27000);
    expect(sc.paye, 10000, reason: '10 000 + 8 000 − 8 000 (annulé)');
    expect(sc.echu, 9000, reason: '1re tranche, remise au prorata');
    expect(sc.impaye, 0, reason: '10 000 payés ≥ 9 000 échus');
    expect(sc.reste, 17000);
    final i = s.lignes.firstWhere((l) => l.ligne.id == 'ins');
    expect((i.du, i.paye, i.reste, i.impaye), (4500, 4500, 0, 0));
    expect(s.autresRecettes, 2000);
    expect((s.du, s.paye, s.reste, s.impaye), (31500, 14500, 17000, 0));

    // Au 20/01/2027 : 2 tranches échues (18 000 après remise), 10 000 payés.
    final plusTard = situation(
      studentId: 'e1',
      lignes: [scol],
      tranches: tranches,
      remises: remises,
      paiements: paiements,
      aujourdhui: '2027-01-20',
    );
    expect(plusTard.impaye, 8000);
    expect(plusTard.aJour, isFalse);
  });

  test('sans échéancier : tout est dû ; remise plafonnée au montant', () {
    final l = ligne('scol', 1000);
    final s = situation(
      studentId: 'e1',
      lignes: [l],
      tranches: const [],
      remises: [remise('montant', 5000)],
      paiements: const [],
      aujourdhui: '2026-10-01',
    );
    expect((s.du, s.impaye), (0, 0));
    final s2 = situation(
      studentId: 'e1',
      lignes: [l],
      tranches: const [],
      remises: const [],
      paiements: [paiement('p', 1500)],
      aujourdhui: '2026-10-01',
    );
    expect(s2.lignes.single.tropPercu, 500);
    expect(s2.reste, 0);
  });

  test('journal de caisse : entrées, sorties, annulations, solde espèces', () {
    final j = journalCaisse(
      paiements: [
        paiement('p1', 10000),
        paiement('p2', -10000, annule: 'p1', numero: 2),
        paiement('p3', 5000, numero: 3),
      ],
      depenses: [
        const ExpenseRow(
          id: 'x',
          schoolId: 's',
          schoolYearId: 'a',
          category: 'fournitures',
          label: 'Craies',
          amount: 1500,
          spentOn: '2026-10-12',
          method: 'especes',
          deviceId: 'd',
          deviceSeq: 1,
          voucherNumber: 'D2526-A-00001',
          updatedAt: _t,
        ),
      ],
      nomEleve: (_) => 'TEST Aïcha',
      mois: '2026-10',
    );
    expect(j.map((m) => m.montant), [10000, -10000, -1500, 5000]);
    expect(solde(j), 3500);
    expect(solde(j, mode: 'especes'), 3500);
    expect(j[1].annulation, isTrue);
  });

  test('message de relance préparé', () {
    final m = messageRelance(
      ecole: 'École Test',
      eleve: 'TEST Aïcha',
      classe: 'CM1 A',
      impaye: 8000,
      telephoneEcole: '70 11 22 33',
    );
    expect(m, contains('8 000 FCFA'));
    expect(m, contains('TEST Aïcha (CM1 A)'));
    expect(m, contains('70 11 22 33'));
  });
}
