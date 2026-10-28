import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/forms/data/forms_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'documents_directeur_test.dart' show texteDuPdf;

Future<void> voir(WidgetTester tester, Finder f) => tester.scrollUntilVisible(
  f,
  250,
  scrollable: find.byType(Scrollable).first,
);

Future<void> tap(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await AppHarness.settle(tester);
}

Future<void> retour(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Retour').first);
  await AppHarness.settle(tester);
}

Future<void> saisir(WidgetTester tester, String label, String texte) async {
  final f = find.widgetWithText(AutoSaveField, label);
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.enterText(f, texte);
  await AppHarness.settle(tester);
  await tester.pump(const Duration(seconds: 1));
  await AppHarness.settle(tester);
}

Future<void> enHaut(WidgetTester tester) async {
  await tester.drag(find.byType(Scrollable).first, const Offset(0, 6000));
  await AppHarness.settle(tester);
}

Future<void> imprimer(WidgetTester tester) async {
  final f = find.text('Aperçu et impression');
  await voir(tester, f);
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.runAsync(() async {
    await tester.tap(f);
    await Future<void>.delayed(const Duration(seconds: 2));
  });
  await AppHarness.settle(tester);
}

const ts = '2026-10-21T07:00:00.000Z';

/// 13 objectifs déjà saisis (une activité chacun) ; le 14e est ajouté à
/// l'écran.
void seedProgramme(AppHarness h) {
  for (var i = 1; i <= 13; i++) {
    h.server
      ..seed('activity_objectives', {
        'id': 'o-$i',
        'school_id': ecoleId,
        'school_year_id': anneeId,
        'order_no': i,
        'label': 'Objectif $i',
        'updated_at': ts,
      })
      ..seed('activity_lines', {
        'id': 'l-$i',
        'school_id': ecoleId,
        'objective_id': 'o-$i',
        'sort_order': 1,
        'planned_activity': 'Activité $i',
        'expected_result': 'Attendu $i',
        'updated_at': ts,
      });
  }
}

void main() {
  testWidgets('programme de 14 objectifs → bilan sans retaper ; version '
      'finale verrouillée, « Modifier » crée une nouvelle version et garde '
      'l’ancienne', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    seedProgramme(h);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');

    await AppHarness.toucher(tester, 'Documents');
    await AppHarness.settle(tester);
    await tap(tester, find.text('Programme d’activités (B6)'));
    expect(find.text('1. Objectif 1'), findsOneWidget);

    // 14e objectif : une proposition du modèle, modifiable.
    await tap(tester, find.text('Ajouter un objectif'));
    await tester.tap(
      find.widgetWithText(ActionChip, 'Gérer rationnellement les ressources'),
    );
    await AppHarness.settle(tester);
    await tester.tap(find.text('Enregistrer'));
    await AppHarness.settle(tester);
    await voir(tester, find.text('14. Gérer rationnellement les ressources'));

    await tap(tester, find.byKey(const Key('ajouter-activite-14')));
    await tester.tap(
      find.widgetWithText(ActionChip, 'Distribution des fournitures'),
    );
    await AppHarness.settle(tester);
    await tester.tap(find.text('Enregistrer'));
    await AppHarness.settle(tester);
    expect(find.text('Activité du programme'), findsOneWidget);
    await saisir(tester, 'ou échéance en toutes lettres', 'Octobre');
    await saisir(tester, 'Résultats attendus', 'Fournitures distribuées');
    await retour(tester);
    expect(
      find.text('Échéance : Octobre\nAttendu : Fournitures distribuées'),
      findsOneWidget,
    );

    // Version finale 1 : verrou.
    await tap(tester, find.text('Valider la version finale'));
    await tester.tap(find.widgetWithText(FilledButton, 'Valider'));
    await AppHarness.settle(tester);
    await enHaut(tester);
    expect(find.text('Version finale 1 verrouillée'), findsOneWidget);
    expect(find.text('Ajouter un objectif'), findsNothing);
    expect(find.byKey(const Key('ajouter-activite-14')), findsNothing);
    var forms = await h.db.select(h.db.officialForms).get();
    expect(forms.single.lockedVersion, 1);
    await imprimer(tester);
    expect(h.pdfSortis.keys, contains('B6_2025-2026.pdf'));
    final b6 = texteDuPdf(h.pdfSortis['B6_2025-2026.pdf']!);
    if (b6 != null) {
      expect(b6, contains('Distribution des fournitures'));
      expect(b6, contains('Octobre'));
    }

    // Une activité verrouillée se lit sans se modifier.
    await tap(tester, find.text('Distribution des fournitures'));
    expect(find.byType(AutoSaveField), findsNothing);
    await retour(tester);

    // « Modifier » : nouvelle version, l'ancienne reste.
    await enHaut(tester);
    await tap(tester, find.widgetWithText(OutlinedButton, 'Modifier'));
    await tester.tap(find.widgetWithText(FilledButton, 'Modifier'));
    await AppHarness.settle(tester);
    forms = await h.db.select(h.db.officialForms).get();
    expect(forms.single.lockedVersion, isNull);
    await tap(tester, find.text('Distribution des fournitures'));
    await saisir(tester, 'Résultats attendus', 'Toutes les fournitures');
    await retour(tester);
    await tap(tester, find.text('Valider la version finale'));
    await tester.tap(find.widgetWithText(FilledButton, 'Valider'));
    await AppHarness.settle(tester);
    await enHaut(tester);
    expect(find.text('Version finale 2 verrouillée'), findsOneWidget);
    final versions = await h.db.select(h.db.formVersions).get();
    expect(versions.map((v) => v.versionNo), unorderedEquals([1, 2]));
    final v1 = versions.firstWhere((v) => v.versionNo == 1).snapshot;
    expect(v1, contains('Fournitures distribuées'));
    expect(v1, isNot(contains('Toutes les fournitures')));
    await voir(tester, find.byKey(const Key('version-1')));
    expect(find.byKey(const Key('version-1')), findsOneWidget);
    await retour(tester);

    // Bilan (B7) : les mêmes lignes, rien à retaper.
    await tap(tester, find.text('Bilan annuel des activités (B7)'));
    await voir(tester, find.text('14. Gérer rationnellement les ressources'));
    await tap(tester, find.text('Distribution des fournitures'));
    expect(find.text('Toutes les fournitures'), findsOneWidget);
    await saisir(tester, 'Résultats atteints', 'Distribuées en novembre');
    await saisir(tester, 'Taux de réussite (%)', '150');
    expect(find.text('Un nombre entre 0 et 100.'), findsOneWidget);
    await saisir(tester, 'Taux de réussite (%)', '75');
    await retour(tester);
    await voir(tester, find.text('Moyenne de l’objectif : 75 %'));
    expect(find.text('Moyenne de l’objectif : 75 %'), findsOneWidget);
    await tap(tester, find.byKey(const Key('moyenne-objectif')));
    await imprimer(tester);
    final b7 = texteDuPdf(h.pdfSortis['B7_2025-2026.pdf']!);
    if (b7 != null) {
      for (final t in [
        'BILAN DE PROGRAMME ANNUEL D’ACTIVITÉS',
        'Objectif 13',
        'Attendu 13',
        'Toutes les fournitures',
        'Distribuées en novembre',
        'Moyenne de l’objectif',
        '75',
      ]) {
        expect(b7, contains(t));
      }
    }

    await h.synchroniser(tester);
    expect(h.server.tables['activity_objectives'], hasLength(14));
    expect(h.server.tables['activity_lines'], hasLength(14));
    expect(h.server.tables['form_versions'], hasLength(2));
    final ligne = h.server.tables['activity_lines']!.values.firstWhere(
      (l) => l['planned_activity'] == 'Distribution des fournitures',
    );
    expect(ligne['success_rate'], 75);
    final snapshot = h.server.tables['form_versions']!.values.first['snapshot'];
    expect(
      snapshot,
      isA<Map<String, dynamic>>(),
      reason: 'l’instantané part comme un objet JSON',
    );
    await h.dispose(tester);
  });

  testWidgets('« Mes formulaires de l’année » : état de chaque formulaire', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    seedProgramme(h);
    h.server.seed('official_forms', {
      'id': FormsRepository.idFormulaire(anneeId, 'B6'),
      'school_id': ecoleId,
      'school_year_id': anneeId,
      'form_code': 'B6',
      'status': 'complet',
      'locked_version': 3,
      'updated_at': ts,
    });
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await AppHarness.toucher(tester, 'Documents');
    await AppHarness.settle(tester);
    await tap(tester, find.text('Mes formulaires de l’année'));
    for (final c in ['B1', 'B2', 'B3', 'B6', 'B7']) {
      expect(find.byKey(Key('formulaire-$c')), findsOneWidget);
    }
    expect(find.text('Complet • version finale 3 verrouillée'), findsOneWidget);
    expect(find.text('À compléter'), findsNWidgets(4));
    await h.dispose(tester);
  });
}
