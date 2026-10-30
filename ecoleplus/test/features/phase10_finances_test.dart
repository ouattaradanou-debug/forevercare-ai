import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'cartes_domain_test.dart' show photoDeTest;
import 'documents_directeur_test.dart' show texteDuPdf;
import 'phase8_cartes_test.dart' show accueil, retour, tap, tapLong, voir;
import 'phase9_bibliotheque_test.dart' show calme;

Future<void> ouvrirFinances(WidgetTester tester) async {
  await AppHarness.toucher(tester, 'Finances');
  await AppHarness.settle(tester);
}

void main() {
  testWidgets('directeur hors ligne : grille, encaissement, reçu PDF '
      'numéroté, annulation motivée, situation exacte, relance préparée ; '
      'puis envoi', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    h.online = false;

    // Grille : scolarité du CM1, une tranche déjà échue.
    await ouvrirFinances(tester);
    await tap(tester, find.text('Grille des frais'));
    await tap(tester, find.text('Ajouter un frais'));
    await tester.enterText(find.byKey(const Key('montant-frais')), '25000');
    await tap(tester, find.widgetWithText(ChoiceChip, 'CM1'));
    await tap(tester, find.text('Enregistrer'));
    expect(find.text('Scolarité • ${fcfa(25000)}'), findsOneWidget);
    await tap(tester, find.text('Scolarité • ${fcfa(25000)}'));
    await tap(tester, find.byKey(const Key('ajouter-tranche')));
    await tester.enterText(find.byKey(const Key('montant-tranche')), '10000');
    await tester.enterText(find.byKey(const Key('date-tranche')), '01/10/2025');
    await tap(tester, find.widgetWithText(FilledButton, 'Ajouter'));
    expect(find.textContaining('Tranche 1 • ${fcfa(10000)}'), findsOneWidget);
    await accueil(tester);

    // Encaissement : 10 000 pour TEST Aïcha (CM1 A).
    await ouvrirFinances(tester);
    await tap(tester, find.text('Encaisser'));
    await tap(tester, find.byKey(const Key('choisir-e-0')));
    await tap(tester, find.textContaining('Scolarité (reste'));
    await tester.enterText(find.byKey(const Key('montant')), '10000');
    await tapLong(tester, find.text('Encaisser et faire le reçu'));
    expect(find.text('R2526-A-00001'), findsOneWidget);
    expect(find.textContaining('Pas encore envoyé'), findsOneWidget);

    // Reçu PDF partagé.
    await tapLong(tester, find.text('Partager le reçu (WhatsApp…)'));
    final pdf = h.pdfSortis['partage:Recu_R2526-A-00001.pdf']!;
    final texte = texteDuPdf(pdf);
    expect(texte, contains('REÇU N° R2526-A-00001'));
    expect(texte, contains('Dix-mille francs CFA'));
    expect(texte, contains('TEST Aïcha'));
    expect(
      texte!.replaceAll(RegExp(r'[\u00a0\u202f\s]+'), ' '),
      contains('Reste à payer 15 000 FCFA'),
    );

    // Annulation motivée : nouveau numéro, reçu d'origine intact.
    await tap(tester, find.byKey(const Key('annuler-recu')));
    await tester.enterText(find.byKey(const Key('motif')), 'Mauvais élève');
    await tap(tester, find.widgetWithText(FilledButton, 'Annuler l’écriture'));
    await calme(tester);
    expect(find.byKey(const Key('recu-annule')), findsOneWidget);
    expect(find.text('Annulé par R2526-A-00002'), findsOneWidget);
    final paiements = await h.db.select(h.db.payments).get();
    expect(paiements.map((x) => (x.receiptNumber, x.amount)), [
      ('R2526-A-00001', 10000),
      ('R2526-A-00002', -10000),
    ]);
    await accueil(tester);

    // Situation : 25 000 dû, rien payé net, 10 000 en retard.
    await ouvrirFinances(tester);
    await tap(tester, find.text('Situation des élèves'));
    await tap(tester, find.byKey(const Key('situation-e-0')));
    expect(find.text('Reste à payer : ${fcfa(25000)}'), findsOneWidget);
    expect(
      find.text('En retard (échéances passées) : ${fcfa(10000)}'),
      findsOneWidget,
    );
    await tap(tester, find.text('Préparer une relance'));
    await tap(tester, find.widgetWithText(FilledButton, 'Partager'));
    expect(h.textesPartages.single, contains(fcfa(10000)));
    expect(h.textesPartages.single, contains('TEST Aïcha (CM1 A)'));
    await accueil(tester);

    // Réseau rétabli : les deux écritures partent, une seule fois.
    h.online = true;
    await h.synchroniser(tester);
    await calme(tester);
    expect(h.server.tables['payments'], hasLength(2));
    expect(h.server.tables['fee_items'], hasLength(1));
    await h.dispose(tester);
  });

  testWidgets('dépense avec photo du justificatif ; caisse du mois, '
      'clôture une seule fois', (tester) async {
    final h = AppHarness()
      ..seedEcoleTest()
      ..imageChoisie = photoDeTest(2);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    // Fonds de caisse du matin : recette sans élève.
    await ouvrirFinances(tester);
    await tap(tester, find.text('Encaisser'));
    await tap(tester, find.textContaining('Recette sans élève'));
    await tester.enterText(find.byKey(const Key('montant')), '2000');
    await tapLong(tester, find.text('Encaisser et faire le reçu'));
    expect(find.text('R2526-A-00001'), findsOneWidget);
    await accueil(tester);
    final fonds = (await h.db.select(h.db.payments).get()).single;
    expect((fonds.studentId, fonds.rubric), (null, 'autre'));

    await ouvrirFinances(tester);
    await tap(tester, find.text('Encaisser'));
    await tap(tester, find.byKey(const Key('choisir-e-1')));
    await tester.enterText(find.byKey(const Key('montant')), '5000');
    await tapLong(tester, find.text('Encaisser et faire le reçu'));
    await accueil(tester);

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
    expect(d.justificationPath, isNotNull);
    // En ligne : justificatif déjà envoyé dans le compartiment privé.
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
    expect(
      (await h.db.select(h.db.cashClosings).get()).single.closingBalance,
      5500,
    );
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
}
