import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/finances/data/finances_repository.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'phase10_finances_test.dart' show idFrais, ouvrirFinances, saisir, texte;
import 'phase8_cartes_test.dart' show accueil, retour, tap;
import 'phase9_bibliotheque_test.dart' show calme;

ProviderContainer conteneur(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

Future<void> basculerCantine(
  WidgetTester tester, {
  required bool activer,
}) async {
  await accueil(tester);
  await AppHarness.ouvrirDansMonEcole(tester, 'Options de l’école');
  await tester.tap(find.byKey(const Key('module-cantine')));
  await AppHarness.settle(tester);
  if (!activer) {
    expect(find.textContaining('les cotisations de cantine'), findsOneWidget);
    expect(find.textContaining('Vos données sont conservées'), findsOneWidget);
    await tester.tap(find.text('Désactiver'));
    await AppHarness.settle(tester);
  }
  await accueil(tester);
}

void main() {
  testWidgets('cantine OFF → ON → OFF → ON : invisible tant qu’elle est '
      'désactivée, données conservées ; réglages, bénéficiaires, pointage, '
      'stock (sortie au-delà du stock refusée), cotisation partielle avec '
      'reçu, impayés distincts ; élève sorti : historique conservé', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');

    // ------------------------------ OFF --------------------------------
    await ouvrirFinances(tester);
    expect(find.text('Cantine'), findsNothing);
    await accueil(tester);
    expect(find.text('Cantine'), findsNothing);

    // ------------------------------ ON ---------------------------------
    await basculerCantine(tester, activer: true);
    await ouvrirFinances(tester);
    await tap(tester, find.text('Cantine'));
    expect(find.textContaining('Commencez par « Réglages'), findsOne);

    // Réglages : mode mixte et définition locale.
    await tap(tester, find.text('Réglages de la cantine'));
    await tap(tester, find.byKey(const Key('mode-mixte')));
    await saisir(
      tester,
      'definition-cantine',
      'Vivres apportés par les parents et la communauté',
    );
    await tap(tester, find.byKey(const Key('enregistrer-reglages')));
    await calme(tester);
    final reglages = await h.db.select(h.db.canteenSettings).getSingle();
    expect(reglages.mode, 'mixte');
    expect(reglages.localDefinition, contains('communauté'));
    expect(
      (await h.db.select(h.db.feeRubrics).get()).map((r) => r.code),
      contains(rubriqueCantine),
      reason: 'rubrique « Cantine » ajoutée à la grille',
    );
    await retour(tester);

    // Bénéficiaires : Aïcha et Boukary ; la famille de Boukary ne paie pas.
    await tap(tester, find.text('Élèves bénéficiaires'));
    await tap(tester, find.byKey(const Key('benef-e-0')));
    await tap(tester, find.byKey(const Key('benef-e-1')));
    await tap(tester, find.byKey(const Key('participe-e-1')));
    await calme(tester);
    expect(
      texte(
        tester.widget<Text>(find.byKey(const Key('total-beneficiaires'))).data,
      ),
      'Total : 2 bénéficiaire(s) sur 4 élève(s)',
    );
    final b = await h.db.select(h.db.canteenBeneficiaries).get();
    expect(
      {for (final x in b) (x.studentId, x.contributes)},
      {('e-0', true), ('e-1', false)},
    );
    await retour(tester);

    // Pointage : le nombre de bénéficiaires se recopie d'un geste.
    await tap(tester, find.text('Pointage des repas'));
    await tap(tester, find.byKey(const Key('remplir-c-cm1')));
    await saisir(tester, 'repas-c-ce1', '1');
    await saisir(tester, 'repas--', '3');
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('total-pointage'))).data),
      '6',
    );
    await tap(tester, find.byKey(const Key('enregistrer-pointage')));
    await calme(tester);
    final p = await h.db.select(h.db.mealServices).get();
    expect(totalRepas(p), 6);
    expect(p, hasLength(3));
    // Nouvelle saisie du même jour : remplace, n'additionne pas.
    await saisir(tester, 'repas-c-cm1', '1');
    await tap(tester, find.byKey(const Key('enregistrer-pointage')));
    await calme(tester);
    expect(totalRepas(await h.db.select(h.db.mealServices).get()), 5);
    await retour(tester);

    // Stock : produit, entrée, sortie refusée au-delà du stock, sortie.
    await tap(tester, find.text('Stock de vivres'));
    await tap(tester, find.byKey(const Key('nouveau-produit')));
    await tester.enterText(find.byKey(const Key('nom-produit')), 'Riz');
    await tester.enterText(find.byKey(const Key('seuil-produit')), '5');
    await tap(tester, find.byKey(const Key('valider-produit')));
    await calme(tester);
    final riz = (await h.db.select(h.db.stockProducts).getSingle()).id;
    Future<void> mouvement(String bouton, String q, {String? motif}) async {
      await tap(tester, find.byKey(Key(bouton)));
      await tester.enterText(find.byKey(const Key('quantite-mouvement')), q);
      if (motif != null) await tap(tester, find.byKey(Key('motif-$motif')));
      await tester.tap(find.byKey(const Key('valider-mouvement')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    await mouvement('bouton-entree', '20', motif: 'produits_locaux');
    await calme(tester);
    await mouvement('bouton-sortie', '30');
    expect(find.textContaining('Il ne reste que 20 kg'), findsOne);
    await calme(tester);
    await mouvement('bouton-sortie', '16');
    await calme(tester);
    expect(texte(tester.widget<Text>(find.byKey(Key('stock-$riz'))).data), '4');
    final m = await h.db.select(h.db.stockMovements).get();
    expect(m.map((x) => (x.kind, x.quantityDelta)), [
      ('entree', 20.0),
      ('sortie', -16.0),
    ]);
    expect(m.first.provenance, 'produits_locaux');
    await retour(tester);
    expect(find.byKey(const Key('alerte-stock')), findsOne, reason: '4 ≤ 5');

    // Cotisation : tarif de la cantine pour le CM1 A, 3 trimestres.
    await calme(tester);
    final c = conteneur(tester);
    await c
        .read(financesRepositoryProvider)
        .enregistrerFrais(
          {
            'id': idFrais('c-cm1', rubriqueCantine),
            'school_id': ecoleId,
            'school_year_id': anneeId,
            'rubric': rubriqueCantine,
            'label': 'Cantine',
            'class_id': 'c-cm1',
          },
          const [
            Versement('1er trimestre', 2000),
            Versement('2e trimestre', 2000, fin: '2099-01-15'),
            Versement('3e trimestre', 2000, fin: '2099-04-15'),
          ],
        );
    final suivi = c.listen(
      situationsCantineProvider((ecoleId, anneeId)),
      (_, _) {},
    );
    final suiviHors = c.listen(
      situationsHorsCantineProvider((ecoleId, anneeId)),
      (_, _) {},
    );
    await AppHarness.settle(tester);
    var cantine = suivi.read()!;
    expect(cantine.map((l) => l.eleve.eleve.id), [
      'e-0',
    ], reason: 'seule la famille d’Aïcha participe');
    final versement = cantine.single.situation.versements.first;
    final recu = await c
        .read(financesRepositoryProvider)
        .encaisserRubriques(
          schoolId: ecoleId,
          yearId: anneeId,
          studentId: 'e-0',
          choix: [(versement, 1500)],
          mode: 'especes',
        );
    expect(recu.receiptNumber, startsWith('R2526-'));
    expect(recu.rubric, rubriqueCantine);
    await AppHarness.settle(tester);
    cantine = suivi.read()!;
    expect(
      (cantine.single.situation.encaisse, cantine.single.situation.reste),
      (1500, 4500),
      reason: 'cotisation partielle',
    );
    // Impayés distincts : la cantine n'entre pas dans les impayés de
    // scolarité.
    final horsCantine = suiviHors.read()!;
    expect(
      horsCantine
          .firstWhere((l) => l.eleve.eleve.id == 'e-0')
          .situation
          .lignes
          .any((x) => x.ligne.rubric == rubriqueCantine),
      isFalse,
    );
    await tap(tester, find.text('Cotisations et impayés de cantine'));
    expect(find.byKey(const Key('reste-cantine-e-0')), findsOne);
    expect(find.byKey(const Key('reste-cantine-e-1')), findsNothing);
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('impayes-cantine'))).data),
      contains('500'),
      reason: '1er trimestre : 2 000 − 1 500',
    );
    await retour(tester);

    // Élève sorti : historique de cantine conservé.
    await c.read(localStoreProvider).save('students', {
      'id': 'e-0',
      'archived_at': '2026-11-04T08:00:00Z',
    });
    await AppHarness.settle(tester);
    await tap(tester, find.text('Élèves bénéficiaires'));
    expect(find.text('Élèves sortis (historique conservé)'), findsOne);
    expect(find.text('TEST Aïcha'), findsOne);
    await accueil(tester);

    // ------------------------ OFF : données intactes ---------------------
    final avant = (
      (await h.db.select(h.db.stockMovements).get()).length,
      (await h.db.select(h.db.mealServices).get()).length,
      (await h.db.select(h.db.canteenBeneficiaries).get()).length,
    );
    await basculerCantine(tester, activer: false);
    await ouvrirFinances(tester);
    expect(find.text('Cantine'), findsNothing);
    final c2 = conteneur(tester);
    final toutes = c2.read(situationsProvider((ecoleId, anneeId)))!;
    expect(
      toutes.every(
        (l) => l.situation.lignes.every((x) => x.ligne.rubric != 'cantine'),
      ),
      isTrue,
      reason: 'module désactivé : plus de cotisation de cantine due',
    );
    expect(
      c2.read(rubriquesProvider(ecoleId)).value!.map((r) => r.code),
      isNot(contains(rubriqueCantine)),
    );
    expect(
      (
        (await h.db.select(h.db.stockMovements).get()).length,
        (await h.db.select(h.db.mealServices).get()).length,
        (await h.db.select(h.db.canteenBeneficiaries).get()).length,
      ),
      avant,
      reason: 'désactiver ne supprime rien',
    );

    // ------------------------ ON : tout revient --------------------------
    await basculerCantine(tester, activer: true);
    await ouvrirFinances(tester);
    await tap(tester, find.text('Cantine'));
    await tap(tester, find.text('Stock de vivres'));
    expect(texte(tester.widget<Text>(find.byKey(Key('stock-$riz'))).data), '4');
    await h.dispose(tester);
  });

  testWidgets('responsable de cantine : bouton « Cantine » à l’accueil, '
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
    await AppHarness.toucher(tester, 'Cantine');
    await AppHarness.settle(tester);
    expect(find.text('Cotisations et impayés de cantine'), findsNothing);

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
