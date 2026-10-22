import 'dart:io';

import 'package:ecoleplus/core/import/tableur.dart';
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

/// Matières → ajoute une matière avec son coefficient.
Future<void> ajouterMatiere(
  WidgetTester tester,
  String nom,
  String coef,
) async {
  await tap(tester, find.text('Ajouter une matière'));
  await tester.enterText(find.byKey(const Key('matiere-nom')), nom);
  await tester.enterText(find.byKey(const Key('matiere-coef')), coef);
  await tester.tap(find.widgetWithText(FilledButton, 'Ajouter'));
  await AppHarness.settle(tester);
}

/// Saisit une note au clavier puis « Suivant » (comme sur le téléphone).
Future<void> note(WidgetTester tester, String eleve, String valeur) async {
  final f = find.byKey(Key('note-$eleve'));
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.enterText(f, valeur);
  await tester.testTextInput.receiveAction(TextInputAction.next);
  await AppHarness.settle(tester);
}

/// Directeur : classe CM1 A avec Calcul (coef 3), Français (coef 2) et
/// Dessin (coef 0), puis une composition sur [bareme].
Future<void> preparerClasse(
  WidgetTester tester,
  AppHarness h, {
  String bareme = '10',
}) async {
  await h.pump(tester);
  await h.login(tester, 'directeur@ecole-test.local');
  await AppHarness.toucher(tester, 'Notes et classement');
  await AppHarness.settle(tester);
  await tap(tester, find.text('CM1 A'));
  await tap(tester, find.text('Matières et coefficients'));
  await ajouterMatiere(tester, 'Calcul', '3');
  await ajouterMatiere(tester, 'Français', '2');
  await ajouterMatiere(tester, 'Dessin', '0');
  expect(find.text('Calcul'), findsOneWidget);
  await retour(tester);
  await tap(tester, find.text('Nouvelle composition'));
  await tester.enterText(find.byKey(const Key('composition-bareme')), bareme);
  await tester.tap(find.widgetWithText(FilledButton, 'Créer'));
  await AppHarness.settle(tester);
  expect(find.byKey(const Key('saisie-notes')), findsOneWidget);
}

void main() {
  testWidgets('cas calculé à la main : moyennes, total, rang ex-aequo, '
      'coefficient 0, hors barème, recalcul après correction, exports et '
      'résultats annuels', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await preparerClasse(tester, h);

    // Calcul (coef 3) — sur 10.
    await note(tester, 'e-0', '9');
    await note(tester, 'e-1', '7');
    await note(tester, 'e-2', '7');
    // Hors barème : refusé, rien n'est enregistré.
    await note(tester, 'e-2', '12');
    expect(
      find.text('Hors barème : la note ne peut pas dépasser 10'),
      findsOneWidget,
    );
    await note(tester, 'e-2', '7');
    expect(find.textContaining('Hors barème'), findsNothing);

    // Français (coef 2).
    await tap(tester, find.widgetWithText(ChoiceChip, 'Français'));
    await note(tester, 'e-0', '6');
    await note(tester, 'e-1', '7,5');
    await note(tester, 'e-2', '7.5');
    // Dessin (coef 0) : noté, mais sans effet sur la moyenne.
    await tap(tester, find.widgetWithText(ChoiceChip, 'Dessin'));
    await note(tester, 'e-0', '1');
    expect(find.textContaining('3/3 saisies'), findsNothing);
    expect(find.textContaining('1/3 saisies'), findsOneWidget);

    await retour(tester);
    await tap(tester, find.text('Classement'));
    // Aïcha : (9×3 + 6×2) / 5 = 39 / 5 = 7,8.
    // Boukary et Clarisse : (7×3 + 7,5×2) / 5 = 36 / 5 = 7,2 → ex-aequo.
    expect(find.text('1re/3'), findsOneWidget);
    expect(find.text('2e ex-aequo/3'), findsNWidgets(2));
    expect(find.text('Moyenne 7,8 · total 39'), findsOneWidget);
    expect(find.text('Moyenne 7,2 · total 36'), findsNWidgets(2));
    expect(find.text('Meilleure moyenne : 7,8'), findsOneWidget);
    expect(find.text('Plus faible moyenne : 7,2'), findsOneWidget);
    // (7,8 + 7,2 + 7,2) / 3 = 7,4.
    expect(find.text('Moyenne de la classe : 7,4'), findsOneWidget);

    // Exports.
    await voir(tester, find.byKey(const Key('export-pdf')));
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('export-pdf')));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await AppHarness.settle(tester);
    expect(h.pdfSortis.keys, contains('Classement_CM1_A_Cumul_de_l_année.pdf'));
    final sortie = Platform.environment['PDF_SORTIE'];
    if (sortie != null) {
      File(sortie).writeAsBytesSync(h.pdfSortis.values.first);
    }
    await tap(tester, find.byKey(const Key('export-excel')));
    final xlsx = h.fichiersSortis['Classement_CM1_A_Cumul_de_l_année.xlsx']!;
    final lignes = lireTableur(xlsx);
    expect(lignes.first, [
      'Rang',
      'Nom et prénom(s)',
      'Calcul (coef. 3)',
      'Dessin (coef. 0)',
      'Français (coef. 2)',
      'Total',
      'Moyenne',
      'Mention',
    ]);
    expect(lignes[1], ['1re', 'TEST Aïcha', '9', '1', '6', '39', '7.8']);

    // Résultats de l'année gardés pour la fiche de scolarité.
    await tap(tester, find.byKey(const Key('garder-annuel')));
    await tester.tap(find.widgetWithText(FilledButton, 'Garder'));
    await AppHarness.settle(tester);
    final annuels = await h.db.select(h.db.annualResults).get();
    expect(annuels, hasLength(3));
    final aicha = annuels.firstWhere((a) => a.studentId == 'e-0');
    expect(aicha.generalAverage, 7.8);
    expect(aicha.rank, 1);
    expect(aicha.classSize, 3);
    final clarisse = annuels.firstWhere((a) => a.studentId == 'e-2');
    expect(clarisse.rank, 2);
    expect(clarisse.rankExAequo, isTrue);

    // Correction d'une note : le classement est recalculé aussitôt.
    await retour(tester);
    await tap(tester, find.text('Composition 1'));
    await note(tester, 'e-2', '8');
    await retour(tester);
    await tap(tester, find.text('Classement'));
    // Clarisse : (8×3 + 7,5×2) / 5 = 7,8 → 1re ex-aequo avec Aïcha ;
    // Boukary passe 3e (et non 2e).
    expect(find.text('1re ex-aequo/3'), findsNWidgets(2));
    expect(find.text('3e/3'), findsOneWidget);

    // Le serveur reçoit les notes.
    await h.synchroniser(tester);
    expect(
      (h.server.tables['grades'] ?? {}).values.where(
        (g) => g['deleted_at'] == null,
      ),
      hasLength(7),
    );
    await h.dispose(tester);
  });

  testWidgets('saisie vocale guidée : « quinze » compris « cinq » est vu '
      'avant d’être gardé ; hors barème refusé ; absent', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await preparerClasse(tester, h, bareme: '20');
    await tap(tester, find.text('Saisie vocale guidée'));
    expect(find.text('TEST Aïcha'), findsOneWidget);

    // Le maître dit « quinze », le téléphone comprend « cinq ».
    h.dictee.texte = 'cinq';
    await tap(tester, find.byKey(const Key('vocal-parler')));
    expect(
      tester.widget<Text>(find.byKey(const Key('vocal-proposee'))).data,
      '5',
    );
    expect(await h.db.select(h.db.grades).get(), isEmpty);
    await tap(tester, find.byKey(const Key('vocal-recommencer')));

    h.dictee.texte = 'quinze';
    await tap(tester, find.byKey(const Key('vocal-parler')));
    expect(
      tester.widget<Text>(find.byKey(const Key('vocal-proposee'))).data,
      '15',
    );
    await tap(tester, find.byKey(const Key('vocal-confirmer')));
    var notes = await h.db.select(h.db.grades).get();
    expect(notes.single.score, 15);
    expect(notes.single.studentId, 'e-0');

    // Élève suivant ; note hors barème refusée.
    expect(find.text('TEST Boukary'), findsOneWidget);
    h.dictee.texte = 'vingt-cinq';
    await tap(tester, find.byKey(const Key('vocal-parler')));
    expect(
      find.text('Hors barème : 25 refusé (la note ne peut pas dépasser 20).'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('vocal-confirmer')), findsNothing);
    h.dictee.texte = 'quatorze virgule cinq';
    await tap(tester, find.byKey(const Key('vocal-parler')));
    await tap(tester, find.byKey(const Key('vocal-confirmer')));

    // Clavier toujours disponible ; puis « absent ».
    expect(find.text('TEST Clarisse'), findsOneWidget);
    h.dictee.texte = 'absente';
    await tap(tester, find.byKey(const Key('vocal-parler')));
    expect(
      tester.widget<Text>(find.byKey(const Key('vocal-proposee'))).data,
      'Absent',
    );
    await tap(tester, find.byKey(const Key('vocal-confirmer')));
    expect(find.text('Tous les élèves ont été vus.'), findsOneWidget);
    notes = await h.db.select(h.db.grades).get();
    expect(
      {for (final n in notes) n.studentId: (n.score, n.status)},
      {'e-0': (15.0, 'note'), 'e-1': (14.5, 'note'), 'e-2': (null, 'absent')},
    );
    await h.dispose(tester);
  });

  testWidgets('30 notes au seul clavier : « Suivant » passe à l’élève '
      'suivant sans toucher l’écran', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    const ts = '2026-10-21T07:00:00.000Z';
    for (var i = 0; i < 27; i++) {
      h.server
        ..seed('students', {
          'id': 'x-$i',
          'school_id': ecoleId,
          'last_name': 'ZÉLÈVE',
          'first_names': 'N${i + 10}',
          'sex': i.isEven ? 'F' : 'M',
          'registry_number': 10 + i,
          'student_code': 'EL-X$i',
          'updated_at': ts,
        })
        ..seed('enrollments', {
          'id': 'ix-$i',
          'school_id': ecoleId,
          'student_id': 'x-$i',
          'class_id': 'c-cm1',
          'school_year_id': anneeId,
          'level_code': 'CM1',
          'starts_on': '2025-10-01',
          'is_repeat': false,
          'updated_at': ts,
        });
    }
    await preparerClasse(tester, h);
    await tester.tap(find.byKey(const Key('note-e-0')));
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      tester.testTextInput.enterText('${i % 11}');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
    }
    await AppHarness.settle(tester);
    final notes = await (h.db.select(
      h.db.grades,
    )..where((g) => g.deletedAt.isNull())).get();
    expect(notes, hasLength(30));
    await tester.scrollUntilVisible(
      find.textContaining('30/30 saisies'),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('30/30 saisies'), findsOneWidget);
    await h.dispose(tester);
  });
}
