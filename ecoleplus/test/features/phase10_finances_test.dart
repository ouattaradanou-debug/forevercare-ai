import 'package:ecoleplus/features/finances/data/finances_repository.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../helpers/app_harness.dart';
import 'cartes_domain_test.dart' show photoDeTest;
import 'documents_directeur_test.dart' show texteDuPdf;
import 'phase8_cartes_test.dart' show accueil, retour, tap, tapLong, voir;
import 'phase9_bibliotheque_test.dart' show calme;

Future<void> ouvrirFinances(WidgetTester tester) async {
  await AppHarness.toucher(tester, 'Finances');
  await AppHarness.settle(tester);
}

String texte(String? t) => (t ?? '').replaceAll(RegExp(r'[  \s]+'), ' ');

/// Identifiants des frais et versements écrits par la grille (A23).
String idFrais(String classe, String code) =>
    FinancesRepository.idFraisClasse(anneeId, classe, code);
String idVersement(String classe, String code, int i) => const Uuid().v5(
  Namespace.url.value,
  'ecoleplus:versement:${idFrais(classe, code)}:$i',
);

Future<void> saisir(WidgetTester tester, String cle, String valeur) async {
  final f = find.byKey(Key(cle));
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.ensureVisible(f);
  await tester.enterText(f, valeur);
  await tester.pump();
}

/// Grille standard du CM1 A : scolarité en 3 versements (le 1er à
/// l'inscription), assurance « en une fois », carte scolaire.
Future<void> grilleCm1(AppHarness h, WidgetTester tester) async {
  // La synchronisation lancée à la connexion doit être finie (sinon
  // l'écriture attend la base indéfiniment).
  await calme(tester);
  final repo = ProviderScope.containerOf(
    tester.element(find.byType(Scaffold).first),
  ).read(financesRepositoryProvider);
  {
    await repo.enregistrerFrais(
      {
        'id': idFrais('c-cm1', 'scolarite'),
        'school_id': ecoleId,
        'school_year_id': anneeId,
        'rubric': 'scolarite',
        'label': 'Scolarité',
        'class_id': 'c-cm1',
      },
      const [
        Versement('1er versement', 10000),
        Versement('2e versement', 8000, fin: '2099-01-15'),
        Versement('3e versement', 7000, fin: '2099-04-15'),
      ],
    );
    await repo.enregistrerFrais(
      {
        'id': idFrais('c-cm1', 'assurance'),
        'school_id': ecoleId,
        'school_year_id': anneeId,
        'rubric': 'assurance',
        'label': 'Assurance',
        'class_id': 'c-cm1',
        'payment_terms': 'integral',
      },
      const [Versement('Assurance', 1500)],
    );
  }
  await AppHarness.settle(tester);
}

void main() {
  testWidgets('A23 grille unique : deux classes cochées, scolarité = '
      '1er + 2e + 3e versement, totaux, une copie par classe modifiable '
      'ensuite, récapitulatif PDF', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await ouvrirFinances(tester);
    await tap(tester, find.text('Grille des frais'));
    expect(find.textContaining('Cochez une ou plusieurs classes'), findsOne);
    await tap(tester, find.byKey(const Key('toutes-classes')));

    await saisir(tester, 'montant-scolarite-1', '10000');
    await saisir(tester, 'montant-scolarite-2', '8000');
    await saisir(tester, 'au-scolarite-2', '15/01/2099');
    await saisir(tester, 'montant-scolarite-3', '7000');
    await saisir(tester, 'montant-assurance-1', '1500');
    await saisir(tester, 'montant-carte_scolaire-1', '500');
    await AppHarness.settle(tester);
    // Total calculé, jamais saisi.
    expect(
      texte(
        tester
            .widget<Text>(find.byKey(const Key('total-ligne-scolarite')))
            .data,
      ),
      '25 000 FCFA',
    );
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('total-eleve'))).data),
      '27 000 FCFA',
    );
    // 3e versement sans date limite : refusé avec un message clair.
    await tap(tester, find.text('Enregistrer pour les 2 classes'));
    expect(find.textContaining('3e versement : indiquez la date'), findsOne);
    await AppHarness.settle(tester);
    await saisir(tester, 'au-scolarite-3', '15/04/2099');
    await voir(tester, find.byKey(const Key('modalite-assurance')));
    await tap(tester, find.byKey(const Key('modalite-assurance')));
    await tap(tester, find.text('En une fois').last);
    await saisir(tester, 'observations-frais', 'Tenue obligatoire.');
    await tap(tester, find.text('Enregistrer pour les 2 classes'));
    await calme(tester);

    final frais = await h.db.select(h.db.feeItems).get();
    expect(
      {for (final f in frais) (f.classId, f.rubric, f.amount)},
      {
        ('c-cm1', 'scolarite', 25000),
        ('c-ce1', 'scolarite', 25000),
        ('c-cm1', 'assurance', 1500),
        ('c-ce1', 'assurance', 1500),
        ('c-cm1', 'carte_scolaire', 500),
        ('c-ce1', 'carte_scolaire', 500),
      },
    );
    expect(
      frais.firstWhere((f) => f.rubric == 'assurance').paymentTerms,
      'integral',
    );
    // 3 versements de scolarité + 1 paiement pour chaque autre rubrique.
    expect(await h.db.select(h.db.feeInstallments).get(), hasLength(10));

    // Le CE1 A seul : assurance à 2 000 ; le CM1 A ne change pas.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await AppHarness.settle(tester);
    await tap(tester, find.byKey(const Key('toutes-classes')));
    await tap(tester, find.byKey(const Key('classe-c-ce1')));
    await saisir(tester, 'montant-assurance-1', '2000');
    await tap(tester, find.text('Enregistrer'));
    await calme(tester);
    final apres = await h.db.select(h.db.feeItems).get();
    expect(
      apres
          .firstWhere((f) => f.classId == 'c-ce1' && f.rubric == 'assurance')
          .amount,
      2000,
    );
    expect(
      apres
          .firstWhere((f) => f.classId == 'c-cm1' && f.rubric == 'assurance')
          .amount,
      1500,
    );

    // Récapitulatif des deux classes, en un document.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await AppHarness.settle(tester);
    await tap(tester, find.byKey(const Key('toutes-classes')));
    await tapLong(tester, find.byKey(const Key('imprimer-recap')));
    await tapLong(tester, find.textContaining('Un document regroupant'));
    final pdf = h.pdfSortis['Frais_scolaires_2025-2026.pdf']!;
    final t = texte(texteDuPdf(pdf));
    expect(t, contains('FRAIS SCOLAIRES — CM1 A'));
    expect(t, contains('FRAIS SCOLAIRES — CE1 A'));
    expect(t, contains('1er versement'));
    expect(t, contains('À l’inscription'));
    expect(t, contains('Avant le 15/01/2099'));
    expect(t, contains('MONTANT TOTAL À PAYER PAR ÉLÈVE 27 000 FCFA'));
    expect(t, contains('Tenue obligatoire.'));
    await h.dispose(tester);
  });

  testWidgets('A23 encaissement en un tableau : plusieurs rubriques '
      'cochées, plafond au reste dû, « en une fois », récapitulatif, reçu '
      'détaillé ; annulation qui rétablit les soldes', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await grilleCm1(h, tester);
    h.online = false;

    await ouvrirFinances(tester);
    await tap(tester, find.text('Encaisser'));
    await tap(tester, find.byKey(const Key('encaisser-classe-c-cm1')));
    await tester.enterText(find.byKey(const Key('recherche-eleve')), 'aïc');
    await AppHarness.settle(tester);
    await tap(tester, find.byKey(const Key('choisir-e-0')));
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('frais-eleve'))).data),
      '26 500 FCFA',
    );

    final v1 = idVersement('c-cm1', 'scolarite', 0);
    final v2 = idVersement('c-cm1', 'scolarite', 1);
    final ass = idVersement('c-cm1', 'assurance', 0);
    await tap(tester, find.byKey(Key('cocher-$v1')));
    await tap(tester, find.byKey(Key('cocher-$v2')));
    await tap(tester, find.byKey(Key('cocher-$ass')));
    // Montant proposé = reste dû ; plus que le reste : refusé.
    expect(
      tester
          .widget<TextField>(find.byKey(Key('a-encaisser-$v1')))
          .controller!
          .text,
      '10000',
    );
    await saisir(tester, 'a-encaisser-$v2', '9000');
    expect(find.text('Max ${fcfa(8000)}'), findsOne);
    await saisir(tester, 'a-encaisser-$v2', '3000');
    // Assurance « en une fois » : montant non modifiable.
    expect(
      tester.widget<TextField>(find.byKey(Key('a-encaisser-$ass'))).enabled,
      isFalse,
    );
    await tap(tester, find.byKey(const Key('mode-autre')));
    await saisir(tester, 'mode-libre', 'Wave');
    await saisir(tester, 'payeur', 'TEST Mariam');
    await saisir(tester, 'telephone-payeur', '70 00 00 00');
    await tap(tester, find.textContaining('Encaisser 14'));
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('recap-total'))).data),
      '14 500 FCFA',
    );
    expect(find.text('Mode : Wave'), findsOneWidget);
    await tapLong(tester, find.byKey(const Key('valider-encaissement')));
    expect(find.text('R2526-A-00001'), findsOneWidget);
    final detail = await h.db.select(h.db.paymentAllocations).get();
    expect(detail.map((a) => (a.label, a.amount)), [
      ('Scolarité — 1er versement', 10000),
      ('Scolarité — 2e versement', 3000),
      ('Assurance', 1500),
    ]);

    // Reçu PDF détaillé.
    await tapLong(tester, find.text('Partager par WhatsApp'));
    final t = texte(texteDuPdf(h.pdfSortis['partage:Recu_R2526-A-00001.pdf']!));
    expect(t, contains('Rubrique réglée'));
    expect(t, contains('Scolarité — 2e versement 3 000 FCFA'));
    expect(t, contains('Total reçu 14 500 FCFA'));
    expect(t, contains('Wave'));
    expect(t, contains('TEST Mariam (70 00 00 00)'));
    expect(t, contains('Reste à payer 12 000 FCFA'));
    await tapLong(tester, find.byKey(const Key('telecharger-recu')));
    expect(h.fichiersSortis.keys, contains('Recu_R2526-A-00001.pdf'));

    // Nouvel encaissement : assurance « Payé », non cochable.
    await accueil(tester);
    await ouvrirFinances(tester);
    await tap(tester, find.text('Encaisser'));
    await tap(tester, find.byKey(const Key('choisir-e-0')));
    expect(
      tester.widget<Checkbox>(find.byKey(Key('cocher-$ass'))).onChanged,
      isNull,
    );
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('reste-encaisser'))).data),
      '12 000 FCFA',
    );
    await accueil(tester);

    // Annulation du reçu : soldes rétablis, détail opposé.
    await ouvrirFinances(tester);
    await tap(tester, find.text('Reçus'));
    await tap(tester, find.byKey(const Key('recu-R2526-A-00001')));
    await tap(tester, find.byKey(const Key('annuler-recu')));
    await tester.enterText(find.byKey(const Key('motif')), 'Mauvais élève');
    await tap(tester, find.widgetWithText(FilledButton, 'Annuler l’écriture'));
    await calme(tester);
    final tout = await h.db.select(h.db.paymentAllocations).get();
    expect(tout.fold<int>(0, (s, a) => s + a.amount), 0);
    expect((await h.db.select(h.db.payments).get()).last.methodLabel, 'Wave');
    await accueil(tester);

    h.online = true;
    await h.synchroniser(tester);
    await calme(tester);
    expect(h.server.tables['payment_allocations'], hasLength(6));
    await h.dispose(tester);
  });

  testWidgets('recettes sans élève, dépense avec photo du justificatif ; '
      'caisse du mois, clôture une seule fois', (tester) async {
    final h = AppHarness()
      ..seedEcoleTest()
      ..imageChoisie = photoDeTest(2);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    for (final m in ['2000', '5000']) {
      await ouvrirFinances(tester);
      await tap(tester, find.text('Encaisser'));
      await tap(tester, find.textContaining('Recette sans élève'));
      await tester.enterText(find.byKey(const Key('montant')), m);
      await tapLong(tester, find.text('Encaisser et faire le reçu'));
      await accueil(tester);
    }
    final p = await h.db.select(h.db.payments).get();
    expect(p.map((x) => (x.studentId, x.rubric)).toSet(), {(null, 'autre')});

    await ouvrirFinances(tester);
    await tap(tester, find.text('Dépenses'));
    await tap(tester, find.text('Nouvelle dépense'));
    await tester.enterText(find.byKey(const Key('objet-depense')), 'Craies');
    await tester.enterText(find.byKey(const Key('montant-depense')), '1500');
    await tapLong(tester, find.byKey(const Key('galerie-justificatif')));
    expect(find.textContaining('Photo jointe'), findsOneWidget);
    await tapLong(tester, find.text('Enregistrer la dépense'));
    final d = (await h.db.select(h.db.expenses).get()).single;
    expect(d.voucherNumber, 'D2526-A-00001');
    await calme(tester);
    expect(h.server.files.keys, contains('finances/${d.justificationPath}'));
    await retour(tester);

    await tap(tester, find.text('Caisse et clôture'));
    expect(
      find.text('Caisse (espèces) en fin de mois : ${fcfa(5500)}'),
      findsOneWidget,
    );
    await tap(tester, find.byKey(const Key('cloturer')));
    await tap(tester, find.widgetWithText(FilledButton, 'Clôturer'));
    await calme(tester);
    expect(find.byKey(const Key('mois-cloture')), findsOneWidget);
    expect(find.byKey(const Key('cloturer')), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('enseignant : aucun accès aux finances', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, '70 11 22 33');
    expect(find.text('Finances'), findsNothing);
    await voir(tester, find.text('Bibliothèque'));
    expect(find.text('Finances'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('A23 rubriques dans la grille : « + Ajouter une rubrique » '
      '(elle apparaît aussi à l’encaissement), « Supprimer une rubrique » '
      'pour toute l’école', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await ouvrirFinances(tester);
    await tap(tester, find.text('Grille des frais'));
    await tap(tester, find.byKey(const Key('classe-c-cm1')));
    for (final code in [
      'scolarite',
      'cotisation',
      'assurance',
      'carte_scolaire',
      'fournitures',
    ]) {
      await voir(tester, find.byKey(Key('ligne-grille-$code')));
      expect(find.byKey(Key('ligne-grille-$code')), findsOneWidget);
    }
    await tap(tester, find.byKey(const Key('ajouter-rubrique')));
    await tester.enterText(
      find.byKey(const Key('nom-rubrique')),
      'Frais d’examen',
    );
    await tap(tester, find.widgetWithText(FilledButton, 'Valider'));
    await saisir(tester, 'montant-frais_d_examen-1', '2000');
    await tap(tester, find.text('Enregistrer'));
    await calme(tester);
    expect(
      (await h.db.select(h.db.feeItems).get()).map((f) => f.rubric),
      contains('frais_d_examen'),
    );

    // Supprimer « Assurance » pour toute l'école.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await AppHarness.settle(tester);
    await tap(tester, find.byKey(const Key('supprimer-rubrique')));
    await tap(tester, find.byKey(const Key('choix-supprimer-assurance')));
    await tap(tester, find.byKey(const Key('supprimer-toute-ecole')));
    await tap(tester, find.widgetWithText(FilledButton, 'Continuer'));
    await tap(tester, find.widgetWithText(FilledButton, 'Supprimer'));
    await calme(tester);
    expect(find.byKey(const Key('ligne-grille-assurance')), findsNothing);
    await accueil(tester);

    // La nouvelle rubrique est dans le tableau d'encaissement.
    await ouvrirFinances(tester);
    await tap(tester, find.text('Encaisser'));
    await tap(tester, find.byKey(const Key('choisir-e-0')));
    expect(find.text('Frais d’examen'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('A24 : synthèse de l’école et d’une classe, SOLDÉ en vert, '
      'élèves groupés par classe, page élève (FRAIS DE L’ANNÉE et total)', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await grilleCm1(h, tester);
    // TEST Aïcha solde tout (page Finances ouverte : soldes chargés).
    await ouvrirFinances(tester);
    final conteneur = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final aicha = conteneur
        .read(situationsProvider((ecoleId, anneeId)))!
        .firstWhere((l) => l.eleve.eleve.id == 'e-0');
    await conteneur
        .read(financesRepositoryProvider)
        .encaisserRubriques(
          schoolId: ecoleId,
          yearId: anneeId,
          studentId: 'e-0',
          choix: [for (final v in aicha.situation.versements) (v, v.reste)],
          mode: 'especes',
        );
    await calme(tester);
    await tap(tester, find.text('Situation des élèves'));
    String val(String k) => texte(tester.widget<Text>(find.byKey(Key(k))).data);
    // 3 élèves au CM1 A (26 500 chacun), 1 au CE1 A (aucun frais).
    expect(val('synthese-du'), '79 500 FCFA');
    expect(val('synthese-encaisse'), '26 500 FCFA');
    expect(val('synthese-restant'), '53 000 FCFA');
    expect(val('synthese-impayes'), '2 élèves');
    expect(val('synthese-taux'), '33,3 %');
    expect(find.text('CM1 A'), findsWidgets);
    expect(find.text('CE1 A'), findsWidgets);
    expect(find.text('SOLDÉ'), findsOneWidget);
    expect(find.text('Aucun frais'), findsOneWidget);

    // Une classe : mêmes indicateurs, limités au CE1 A.
    await tap(tester, find.byKey(const Key('situation-classe-c-ce1')));
    expect(val('synthese-du'), '0 FCFA');
    expect(val('synthese-taux'), '—');
    await tap(tester, find.byKey(const Key('situation-ecole')));
    await tester.enterText(
      find.byKey(const Key('recherche-situation')),
      'bouk',
    );
    await AppHarness.settle(tester);
    expect(find.byKey(const Key('situation-e-0')), findsNothing);

    // Page élève : synthèse et FRAIS DE L'ANNÉE.
    await tap(tester, find.byKey(const Key('situation-e-1')));
    expect(find.text('FRAIS DE L’ANNÉE'), findsOneWidget);
    expect(val('eleve-du'), '26 500 FCFA');
    expect(val('eleve-encaisse'), '0 FCFA');
    // Échus : 1er versement (à l'inscription) + assurance.
    expect(val('retard-eleve'), '11 500 FCFA');
    expect(val('a-venir-eleve'), '15 000 FCFA');
    expect(find.text('Scolarité – 2e versement'), findsOneWidget);
    expect(find.text('TOTAL'), findsOneWidget);
    await accueil(tester);

    // Encaisser : tableau par classe, reste et statut.
    await ouvrirFinances(tester);
    await tap(tester, find.text('Encaisser'));
    expect(find.text('Nom et prénom de l’élève'), findsWidgets);
    expect(find.text('SOLDÉ'), findsOneWidget);
    expect(find.text('Impayé'), findsNWidgets(2));
    await h.dispose(tester);
  });
}
