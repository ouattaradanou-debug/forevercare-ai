import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/maternelle/data/maternelle_repository.dart';
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

Future<void> accueil(WidgetTester tester) async {
  while (find.byTooltip('Retour').evaluate().isNotEmpty) {
    await retour(tester);
  }
}

Future<void> saisir(WidgetTester tester, String label, String texte) async {
  final f = find.widgetWithText(AutoSaveField, label);
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.enterText(f, texte);
  await AppHarness.settle(tester);
  await tester.pump(const Duration(seconds: 1));
  await AppHarness.settle(tester);
}

Future<void> imprimer(WidgetTester tester, String bouton) async {
  final f = find.text(bouton);
  await voir(tester, f);
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.runAsync(() async {
    await tester.tap(f);
    await Future<void>.delayed(const Duration(seconds: 2));
  });
  await AppHarness.settle(tester);
}

Future<void> basculerMaternelle(
  WidgetTester tester, {
  required bool activer,
}) async {
  await AppHarness.ouvrirDansMonEcole(tester, 'Options de l’école');
  await tester.tap(find.byKey(const Key('module-maternelle')));
  await AppHarness.settle(tester);
  if (!activer) {
    expect(find.textContaining('les livrets d’évaluation'), findsOneWidget);
    await tester.tap(find.text('Désactiver'));
    await AppHarness.settle(tester);
  }
  await accueil(tester);
}

const ts = '2026-10-21T07:00:00.000Z';

/// Une grande section (GS A) et deux enfants.
void seedMaternelle(AppHarness h) {
  h.server.seed('classes', {
    'id': 'c-gs',
    'school_id': ecoleId,
    'school_year_id': anneeId,
    'level_code': 'GS',
    'name': 'GS A',
    'updated_at': ts,
  });
  for (final (i, prenom) in ['Awa', 'Bila'].indexed) {
    h.server
      ..seed('students', {
        'id': 'k-$i',
        'school_id': ecoleId,
        'last_name': 'PETIT',
        'first_names': prenom,
        'sex': i == 0 ? 'F' : 'M',
        'updated_at': ts,
      })
      ..seed('enrollments', {
        'id': 'ik-$i',
        'school_id': ecoleId,
        'student_id': 'k-$i',
        'class_id': 'c-gs',
        'school_year_id': anneeId,
        'level_code': 'GS',
        'starts_on': '2025-10-01',
        'is_repeat': false,
        'updated_at': ts,
      });
  }
}

void main() {
  testWidgets('maternelle OFF → ON → OFF → ON : rien tant qu’elle est '
      'désactivée ; domaines et niveaux proposés ; évaluation en couleurs '
      'et pictogrammes ; livret sans note ; présences ; données '
      'conservées', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    seedMaternelle(h);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');

    // OFF : la classe de maternelle n'apparaît nulle part.
    await AppHarness.toucher(tester, 'Notes et classement');
    await AppHarness.settle(tester);
    expect(find.text('CM1 A'), findsOneWidget);
    expect(find.text('GS A'), findsNothing);
    expect(find.text('Réglages de la maternelle'), findsNothing);
    await accueil(tester);

    // ON : liste de domaines et trois niveaux proposés.
    await basculerMaternelle(tester, activer: true);
    expect(await h.db.select(h.db.learningDomains).get(), hasLength(6));
    expect(await h.db.select(h.db.qualitativeLevels).get(), hasLength(3));

    await AppHarness.toucher(tester, 'Notes et classement');
    await AppHarness.settle(tester);
    await tap(tester, find.text('Réglages de la maternelle'));
    expect(find.text('1. Langage'), findsOneWidget);
    await voir(
      tester,
      find.byKey(
        ValueKey(
          'niveau-${MaternelleRepository.idNiveau(ecoleId, 'en_cours')}',
        ),
      ),
    );
    await voir(tester, find.byKey(const Key('classement-maternelle')));
    final classement = tester.widget<SwitchListTile>(
      find.byKey(const Key('classement-maternelle')),
    );
    expect(classement.value, isFalse, reason: 'pas de classement par défaut');
    await retour(tester);

    await tap(tester, find.text('GS A'));
    expect(find.text('0/6 domaines évalués'), findsNWidgets(2));
    await tap(tester, find.text('PETIT Awa'));
    final langage = MaternelleRepository.idDomaineParDefaut(ecoleId, 'Langage');
    await tap(tester, find.byKey(Key('niveau-$langage-acquis')));
    final graphisme = MaternelleRepository.idDomaineParDefaut(
      ecoleId,
      'Graphisme et préécriture',
    );
    await tap(tester, find.byKey(Key('niveau-$graphisme-en_cours')));
    await saisir(
      tester,
      'Appréciation de l’enseignant(e)',
      'Awa participe avec plaisir.',
    );
    await saisir(tester, 'Observations du directeur', 'Bon trimestre.');
    await imprimer(tester, 'Livret de l’enfant (PDF)');
    expect(h.pdfSortis.keys, contains('Livret_PETIT_Awa_T1.pdf'));
    final t = texteDuPdf(h.pdfSortis['Livret_PETIT_Awa_T1.pdf']!);
    if (t != null) {
      for (final x in [
        'LIVRET D’ÉVALUATION — MATERNELLE',
        'PETIT Awa',
        'GS A',
        'Langage',
        'Acquis',
        'Awa participe avec plaisir.',
        'Bon trimestre.',
        '2 domaine(s) évalué(s) sur 6',
      ]) {
        expect(t, contains(x));
      }
      expect(t, isNot(contains('Rang')));
      expect(t, isNot(contains('Moyenne')));
    }
    await retour(tester);
    expect(find.text('2/6 domaines évalués'), findsOneWidget);

    // Présences.
    await tap(tester, find.text('Présences'));
    await tap(tester, find.byKey(const Key('presence-k-1-absent')));
    await tap(tester, find.byKey(const Key('tous-presents')));
    expect(find.textContaining('1 absent(s)'), findsOneWidget);
    final presences = await h.db.select(h.db.attendance).get();
    expect(
      {for (final p in presences) p.studentId: p.status},
      {'k-0': 'present', 'k-1': 'absent'},
    );
    await accueil(tester);

    await h.synchroniser(tester);
    expect(h.server.tables['learning_domains'], hasLength(6));
    expect(h.server.tables['preschool_evaluations'], hasLength(2));
    expect(h.server.tables['preschool_booklets'], hasLength(1));
    expect(h.server.tables['attendance'], hasLength(2));

    // OFF : masquée partout, rien d'effacé.
    await basculerMaternelle(tester, activer: false);
    await AppHarness.toucher(tester, 'Notes et classement');
    await AppHarness.settle(tester);
    expect(find.text('GS A'), findsNothing);
    expect(find.text('Réglages de la maternelle'), findsNothing);
    await accueil(tester);
    expect(await h.db.select(h.db.preschoolEvaluations).get(), hasLength(2));

    // ON à nouveau : tout revient, sans doublon de domaines.
    await basculerMaternelle(tester, activer: true);
    expect(await h.db.select(h.db.learningDomains).get(), hasLength(6));
    await AppHarness.toucher(tester, 'Notes et classement');
    await AppHarness.settle(tester);
    await tap(tester, find.text('GS A'));
    expect(find.text('2/6 domaines évalués'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('école « maternelle seule » : aucun écran du primaire', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    seedMaternelle(h);
    h.server.tables['schools']![ecoleId]!['manages_primary'] = false;
    h.server.tables['school_modules']!['$ecoleId|maternelle']!['enabled'] =
        true;
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');

    expect(find.text('Notes et classement'), findsNothing);
    await AppHarness.toucher(tester, 'Évaluations (maternelle)');
    await AppHarness.settle(tester);
    expect(find.text('GS A'), findsOneWidget);
    for (final x in [
      'CM1 A',
      'CE1 A',
      'Mentions (appréciations selon la moyenne)',
      'Modèle de bulletin',
    ]) {
      expect(find.text(x), findsNothing, reason: x);
    }
    await accueil(tester);

    await AppHarness.toucher(tester, 'Documents');
    await AppHarness.settle(tester);
    for (final x in [
      'Registre matricule (B2)',
      'Fiche de scolarité (B4)',
      'Bulletins',
    ]) {
      expect(find.text(x), findsNothing, reason: x);
    }
    await h.dispose(tester);
  });
}
