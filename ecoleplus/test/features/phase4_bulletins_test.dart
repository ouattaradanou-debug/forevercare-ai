import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/forms/data/fiche_scolarite_repository.dart';
import 'package:ecoleplus/features/grades/data/grades_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';

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

/// Saisit une note au clavier puis « Suivant ».
Future<void> note(WidgetTester tester, String eleve, String valeur) async {
  final f = find.byKey(Key('note-$eleve'));
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.enterText(f, valeur);
  await tester.testTextInput.receiveAction(TextInputAction.next);
  await AppHarness.settle(tester);
}

const ts = '2026-10-21T07:00:00.000Z';

/// CM1 A : Calcul (coef 1), trois trimestres notés sur 10 :
/// Aïcha 8, Boukary 6, Clarisse 7 à chaque trimestre.
void seedNotes(AppHarness h) {
  h.server
    ..seed('subjects', {
      'id': 's-cal',
      'school_id': ecoleId,
      'name': 'Calcul',
      'sort_order': 1,
      'updated_at': ts,
    })
    ..seed('class_subjects', {
      'id': 'cs-cal',
      'school_id': ecoleId,
      'class_id': 'c-cm1',
      'subject_id': 's-cal',
      'coefficient': 1,
      'updated_at': ts,
    });
  for (final t in const [1, 2, 3]) {
    h.server.seed('assessments', {
      'id': 'a-$t',
      'school_id': ecoleId,
      'class_id': 'c-cm1',
      'school_year_id': anneeId,
      'label': 'Composition — trimestre $t',
      'kind': 'composition',
      'sequence': t,
      'max_score': 10,
      'updated_at': ts,
    });
    for (final (e, v) in const [('e-0', 8), ('e-1', 6), ('e-2', 7)]) {
      h.server.seed('grades', {
        'id': 'g-$t-$e',
        'school_id': ecoleId,
        'assessment_id': 'a-$t',
        'student_id': e,
        'subject_id': 's-cal',
        'score': v,
        'status': 'note',
        'updated_at': ts,
      });
    }
  }
}

FicheScolariteRepository fiches(AppHarness h) {
  final store = LocalStore(h.db, Clock());
  return FicheScolariteRepository(store, GradesRepository(store));
}

void main() {
  testWidgets('bulletins de l’année : appréciation, décision, PDF de la '
      'classe ; une note corrigée change le rang sur le bulletin ET sur la '
      'fiche de scolarité ; copie conforme journalisée', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    seedNotes(h);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await AppHarness.toucher(tester, 'Notes et classement');
    await AppHarness.settle(tester);
    await tap(tester, find.text('CM1 A'));
    await tap(tester, find.text('Bulletins'));
    await tap(tester, find.byKey(const Key('bulletin-periode-4')));
    // Année : Aïcha 8, Clarisse 7, Boukary 6.
    expect(find.text('Moyenne 8 · 1re/3'), findsOneWidget);
    expect(find.text('Moyenne 6 · 3e/3'), findsOneWidget);

    await tap(tester, find.byKey(const Key('eleve-bulletin-e-0')));
    await tester.enterText(
      find.byKey(const ValueKey('appreciation-e-0-4')),
      'Très bonne année',
    );
    await AppHarness.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    await AppHarness.settle(tester);
    await tap(
      tester,
      find.widgetWithText(ActionChip, 'Passe en classe supérieure'),
    );
    final cartes = await h.db.select(h.db.reportCards).get();
    expect(
      (cartes.single.teacherAppreciation, cartes.single.decision),
      ('Très bonne année', 'Passe en classe supérieure'),
    );
    expect(cartes.single.assessmentId, isNull, reason: 'bulletin annuel');

    await voir(tester, find.byKey(const Key('bulletins-classe')));
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('bulletins-classe')));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await AppHarness.settle(tester);
    expect(h.pdfSortis.keys, contains('Bulletin_CM1_A_Année.pdf'));
    expect((await h.db.select(h.db.reportCards).get()).single.status, 'genere');

    // Correction au 3e trimestre : Boukary 6 → 10, (6 + 6 + 10) ÷ 3 = 7,33.
    await retour(tester);
    await tap(tester, find.byKey(const Key('trimestre-3')));
    await note(tester, 'e-1', '10');
    await retour(tester);
    await tap(tester, find.text('Bulletins'));
    await tap(tester, find.byKey(const Key('bulletin-periode-4')));
    expect(find.text('Moyenne 7,33 · 2e/3'), findsOneWidget);
    expect(find.text('Moyenne 7 · 3e/3'), findsOneWidget);

    // Même rang sur la fiche de scolarité.
    final f = (await tester.runAsync(() => fiches(h).fiche('e-1')))!;
    expect(f.cours[('CM1', 1)]!.classement, '2e/3');
    expect(f.cours[('CM1', 1)]!.moyenneTexte, '7,33');

    // Fiche de scolarité depuis la fiche élève : copie conforme.
    await retour(tester);
    await retour(tester);
    await retour(tester);
    await tap(tester, find.text('Élèves'));
    await tap(tester, find.text('TEST Boukary'));
    await tap(tester, find.byKey(const Key('ouvrir-b4')));
    expect(find.text('Moyenne 7,33 · classement 2e/3'), findsOneWidget);
    await tap(tester, find.byKey(const Key('copie-conforme')));
    await voir(tester, find.byKey(const Key('b4-imprimer')));
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('b4-imprimer')));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await AppHarness.settle(tester);
    expect(
      h.pdfSortis.keys,
      contains('Fiche_scolarite_TEST_Boukary_copie_conforme.pdf'),
    );
    final copies = await h.db.select(h.db.scolarityCopyLog).get();
    expect(copies.single.studentId, 'e-1');
    expect(copies.single.isCertifiedCopy, isTrue);
    await h.synchroniser(tester);
    expect(h.server.tables['scolarity_copy_log'], hasLength(1));
    expect(h.server.tables['report_cards'], hasLength(1));
    await h.dispose(tester);
  });

  testWidgets('fiche de scolarité : élève redoublant (même niveau deux fois) '
      'et élève muté en cours d’année', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    seedNotes(h);
    // Aïcha a déjà fait un CM1 l'an passé (5,2 ; 5e/30) : elle redouble.
    h.server
      ..seed('annual_results', {
        'id': 'ar-prec',
        'school_id': ecoleId,
        'student_id': 'e-0',
        'school_year_id': 'annee-prec',
        'level_code': 'CM1',
        'attempt': 1,
        'result_date': '2025-06-30',
        'general_average': 5.2,
        'rank': 5,
        'rank_ex_aequo': false,
        'class_size': 30,
        'updated_at': ts,
      })
      // Daouda (CE1) est parti en cours d'année.
      ..tables['students']!['e-3']!['exit_date'] = '2026-01-15'
      ..tables['enrollments']!['i-3']!['ends_on'] = '2026-01-15'
      ..seed('student_registry', {
        'id': 'e-3',
        'school_id': ecoleId,
        'destination': 'École B de Koudougou',
        'exit_reason': 'Mutation des parents',
        'updated_at': ts,
      });
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    // Le directeur indique sur la fiche d'Aïcha qu'elle redouble le CM1.
    await tap(tester, find.text('Élèves'));
    await tap(tester, find.text('TEST Aïcha'));
    await tap(tester, find.byKey(const Key('redouble')));
    await retour(tester);
    await retour(tester);

    final aicha = (await tester.runAsync(() => fiches(h).fiche('e-0')))!;
    expect(aicha.cours[('CM1', 1)]!.classement, '5e/30');
    expect(aicha.cours[('CM1', 1)]!.moyenneTexte, '5,2');
    expect(aicha.cours[('CM1', 2)]!.classement, '1re/3', reason: 'redouble');
    expect(aicha.cours[('CM1', 2)]!.moyenneTexte, '8');

    final daouda = (await tester.runAsync(() => fiches(h).fiche('e-3')))!;
    expect(daouda.sortiLe, '15/01/2026');
    expect(daouda.allantA, 'École B de Koudougou');
    expect(daouda.motifDepart, 'Mutation des parents');
    expect(daouda.cours, isEmpty, reason: 'pas de résultat cette année');

    // Les résultats gardés de l'année marquent le redoublement.
    await AppHarness.toucher(tester, 'Notes et classement');
    await AppHarness.settle(tester);
    await tap(tester, find.text('CM1 A'));
    await tap(tester, find.text('Classement'));
    await tap(tester, find.byKey(const Key('periode-4')));
    await tap(tester, find.byKey(const Key('garder-annuel')));
    await tester.tap(find.widgetWithText(FilledButton, 'Garder'));
    await AppHarness.settle(tester);
    final gardes = await (h.db.select(
      h.db.annualResults,
    )..where((a) => a.schoolYearId.equals(anneeId))).get();
    expect(
      {for (final a in gardes) a.studentId: a.attempt},
      {'e-0': 2, 'e-1': 1, 'e-2': 1},
    );
    await h.dispose(tester);
  });
}
