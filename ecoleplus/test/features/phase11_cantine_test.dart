import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'phase10_finances_test.dart' show ouvrirFinances, saisir, texte;
import 'phase8_cartes_test.dart' show accueil, retour, tap, tapLong, voir;
import 'phase9_bibliotheque_test.dart' show calme;

ProviderContainer conteneur(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

Future<void> basculerCantine(
  WidgetTester tester, {
  required bool activer,
}) async {
  await accueil(tester);
  await voir(tester, find.text('Mon école'));
  await AppHarness.ouvrirDansMonEcole(tester, 'Options de l’école');
  await tester.tap(find.byKey(const Key('module-cantine')));
  await AppHarness.settle(tester);
  if (!activer) {
    expect(
      find.textContaining('les abonnements et reçus de cantine'),
      findsOneWidget,
    );
    expect(find.textContaining('Vos données sont conservées'), findsOneWidget);
    await tester.tap(find.text('Désactiver'));
    await AppHarness.settle(tester);
  }
  await accueil(tester);
}

void main() {
  testWidgets('cantine OFF → ON → OFF → ON ; tarif mensuel ; abonner et '
      'encaisser plusieurs mois non consécutifs en un reçu ; mois payé non '
      'recochable ; avance = paiement partiel ; tableau de bord ; abonnement '
      'groupé ; stock (sortie au-delà refusée) ; élève sorti : historique', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');

    // ------------------------------ OFF --------------------------------
    expect(find.text('Cantine scolaire'), findsNothing);
    await ouvrirFinances(tester);
    expect(find.text('Cantine'), findsNothing);

    // ------------------------------ ON ---------------------------------
    await basculerCantine(tester, activer: true);
    await AppHarness.toucher(tester, 'Cantine scolaire');
    await AppHarness.settle(tester);
    expect(find.textContaining('fixer le tarif mensuel'), findsOne);

    // Réglages : 5 000 par mois.
    await tap(tester, find.byKey(const Key('reglages-cantine')));
    await saisir(tester, 'tarif-mensuel', '5000');
    await saisir(tester, 'definition-cantine', 'Vivres de la communauté');
    await tap(tester, find.byKey(const Key('enregistrer-reglages')));
    await calme(tester);
    expect((await h.db.select(h.db.canteenRates).getSingle()).amount, 5000);
    final annee = await h.db.select(h.db.canteenYears).getSingle();
    expect(annee.months, contains('2025-10-01'));
    await retour(tester);

    // Abonner et encaisser : TEST Aïcha, octobre + décembre (non
    // consécutifs) = 10 000, un seul reçu.
    await tap(tester, find.byKey(const Key('abonner-encaisser')));
    await tester.enterText(find.byKey(const Key('recherche-eleve')), 'aïc');
    await AppHarness.settle(tester);
    await tap(tester, find.byKey(const Key('choisir-e-0')));
    await tap(tester, find.byKey(const Key('mois-2025-10')));
    await tap(tester, find.byKey(const Key('mois-2025-12')));
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('total-a-payer'))).data),
      '10 000',
    );
    await saisir(tester, 'payeur', 'TEST Mariam');
    await tap(tester, find.byKey(const Key('valider-abonnement')));
    expect(find.text('Vérifiez avant de valider'), findsOne);
    await tap(tester, find.byKey(const Key('valider-paiement')));
    await calme(tester);
    final recu = (await h.db.select(h.db.payments).get()).single;
    expect(
      (recu.rubric, recu.amount, recu.payerName),
      ('cantine', 10000, 'TEST Mariam'),
    );
    expect(find.byKey(const Key('numero-recu')), findsOne, reason: 'reçu');
    expect(find.textContaining('Cantine — octobre 2025 : 5'), findsOne);
    await retour(tester);

    // Situation de l'élève : octobre et décembre ABONNÉ, novembre NON
    // ABONNÉ (aucune dette).
    await tap(tester, find.text('Situation et historique'));
    await tap(tester, find.text('TEST Aïcha'));
    Text pastille(String k) => tester.widget<Text>(
      find.descendant(of: find.byKey(Key(k)), matching: find.byType(Text)),
    );
    expect(pastille('statut-mois-2025-10').data, 'ABONNÉ');
    expect(pastille('statut-mois-2025-11').data, 'NON ABONNÉ');
    expect(pastille('statut-mois-2025-12').data, 'ABONNÉ');
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('resume-eleve'))).data),
      contains('2 mois abonné(s)'),
    );

    // Encore : octobre payé ne se recoche pas ; avance de 2 000 sur
    // novembre → PAIEMENT PARTIEL.
    await tap(tester, find.text('ABONNER ET ENCAISSER'));
    expect(
      tester.widget<Checkbox>(find.byKey(const Key('mois-2025-10'))).onChanged,
      isNull,
      reason: 'déjà payé : pas de double paiement',
    );
    await tap(tester, find.byKey(const Key('mois-2025-11')));
    await saisir(tester, 'montant-recu', '2000');
    await tap(tester, find.byKey(const Key('valider-abonnement')));
    expect(find.textContaining('Paiement partiel'), findsOne);
    await tap(tester, find.byKey(const Key('valider-paiement')));
    await calme(tester);
    await retour(tester);
    expect(pastille('statut-mois-2025-11').data, 'PAIEMENT PARTIEL');
    await accueil(tester);

    // Tableau de bord d'octobre : 1 abonné sur 4 ; attendu 5 000 (les
    // non-abonnés ne doivent rien) ; taux 100 %.
    await AppHarness.toucher(tester, 'Cantine scolaire');
    await AppHarness.settle(tester);
    await tap(tester, find.text('Tableau de bord'));
    await tap(tester, find.byKey(const Key('choix-mois')));
    await tap(tester, find.text('octobre 2025').last);
    String val(String k) => texte(tester.widget<Text>(find.byKey(Key(k))).data);
    expect(
      (val('nb-abonnes'), val('nb-non-abonnes'), val('attendu'), val('taux')),
      ('1', '3', '5 000', '100 %'),
    );
    await retour(tester);

    // Abonnement groupé d'octobre : toute la classe de CM1 A d'un coup.
    await tap(tester, find.text('Abonnements'));
    await tap(tester, find.byKey(const Key('choix-mois')));
    await tap(tester, find.text('octobre 2025').last);
    await tap(tester, find.byKey(const Key('choix-classe')));
    await tap(tester, find.text('CM1 A').last);
    await tap(tester, find.byKey(const Key('tout-cocher')));
    await tap(tester, find.byKey(const Key('abonner-selection')));
    await tap(tester, find.byKey(const Key('valider-groupe')));
    await calme(tester);
    final p = await h.db.select(h.db.payments).get();
    expect(p, hasLength(4), reason: '2 reçus d’Aïcha + 2 élèves du CM1 A');
    await tapLong(tester, find.byKey(const Key('liste-autorises')));
    final pdf = h.pdfSortis.keys.firstWhere(
      (k) => k.contains('Cantine_autorises_2025-10'),
    );
    expect(pdf, isNotNull);
    await retour(tester);

    // Vivres et repas : stock, sortie au-delà du stock refusée.
    await tap(tester, find.text('Vivres et repas'));
    await tap(tester, find.text('Stock de vivres'));
    await tap(tester, find.byKey(const Key('nouveau-produit')));
    await tester.enterText(find.byKey(const Key('nom-produit')), 'Riz');
    await tap(tester, find.byKey(const Key('valider-produit')));
    await calme(tester);
    Future<void> mouvement(String bouton, String q) async {
      await tap(tester, find.byKey(Key(bouton)));
      await tester.enterText(find.byKey(const Key('quantite-mouvement')), q);
      await tester.tap(find.byKey(const Key('valider-mouvement')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    await mouvement('bouton-entree', '20');
    await calme(tester);
    await mouvement('bouton-sortie', '30');
    expect(find.textContaining('Il ne reste que 20 kg'), findsOne);
    await calme(tester);
    await accueil(tester);

    // Élève sorti : historique de cantine conservé.
    final c = conteneur(tester);
    await c.read(localStoreProvider).save('students', {
      'id': 'e-0',
      'archived_at': '2026-11-04T08:00:00Z',
    });
    await AppHarness.settle(tester);
    expect(
      (await h.db.select(h.db.canteenSubscriptions).get()).where(
        (s) => s.studentId == 'e-0',
      ),
      hasLength(3),
    );

    // ------------------------ OFF : données intactes ---------------------
    final avant = (await h.db.select(h.db.canteenSubscriptions).get()).length;
    await basculerCantine(tester, activer: false);
    await tester.tap(find.text('Finances'));
    await AppHarness.settle(tester);
    expect(find.text('Cantine scolaire'), findsNothing);
    await tester.tap(find.byTooltip('Retour').first);
    await AppHarness.settle(tester);
    expect(
      (await h.db.select(h.db.canteenSubscriptions).get()).length,
      avant,
      reason: 'désactiver ne supprime rien',
    );
    // Les frais scolaires ne contiennent jamais la cantine.
    final toutes = conteneur(tester)
        .read(situationsProvider((ecoleId, anneeId)));
    expect(
      (toutes ?? const []).every(
        (l) => l.situation.lignes.every((x) => x.ligne.rubric != 'cantine'),
      ),
      isTrue,
    );
    await basculerCantine(tester, activer: true);
    await tester.tap(find.text('Finances'));
    await AppHarness.settle(tester);
    expect(find.text('Cantine scolaire'), findsOne);
    await h.dispose(tester);
  });

  testWidgets('responsable de cantine : « Cantine scolaire » à l’accueil, '
      'pas de Finances ; dépense de cantine dans la caisse commune ; menu', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    h.server.tables['school_modules']!['$ecoleId|cantine']!['enabled'] = true;
    // Responsable de cantine : délégué avec le seul droit « cantine ».
    h.server
      ..seed('memberships', {
        'id': 'm-can',
        'school_id': ecoleId,
        'user_id': 'u-can',
        'role': 'delegue',
        'display_name': 'Cantine Test',
        'active': true,
        'updated_at': '2026-10-21T07:00:00.000Z',
      })
      ..seed('delegate_permissions', {
        'id': 'p-can',
        'school_id': ecoleId,
        'membership_id': 'm-can',
        'permission_key': 'cantine',
        'updated_at': '2026-10-21T07:00:00.000Z',
      });
    h.auth.addUser('cantine@ecole-test.local', 'motdepasse-test', 'u-can');
    await h.pump(tester);
    await h.login(tester, 'cantine@ecole-test.local');
    expect(find.text('Finances'), findsNothing);
    await AppHarness.toucher(tester, 'Cantine scolaire');
    await AppHarness.settle(tester);
    expect(find.byKey(const Key('abonner-encaisser')), findsOne);

    await tap(tester, find.text('Vivres et repas'));
    await tap(tester, find.text('Dépenses de cantine'));
    await tap(tester, find.byKey(const Key('nouvelle-depense-cantine')));
    expect(find.text('Dépense de cantine'), findsOne);
    await tap(tester, find.text('Condiments'));
    await saisir(tester, 'montant-depense', '2500');
    await tap(tester, find.text('Enregistrer la dépense'));
    await calme(tester);
    final d = await h.db.select(h.db.expenses).getSingle();
    expect((d.category, d.label, d.amount), ('cantine', 'Condiments', 2500));
    await retour(tester);

    await tap(tester, find.text('Menus de la semaine'));
    await saisir(tester, 'texte-menu', 'Lundi : riz sauce arachide');
    await tap(tester, find.byKey(const Key('enregistrer-menu')));
    await calme(tester);
    final menu = await h.db.select(h.db.canteenMenus).getSingle();
    expect(menu.content, 'Lundi : riz sauce arachide');
    expect(DateTime.parse(menu.weekStart).weekday, DateTime.monday);
    await h.dispose(tester);
  });
}
