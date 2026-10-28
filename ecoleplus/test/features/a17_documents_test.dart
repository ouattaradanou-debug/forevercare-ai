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

Future<void> imprimer(WidgetTester tester) async {
  await voir(tester, find.byKey(const Key('document-imprimer')));
  await tester.runAsync(() async {
    await tester.tap(find.byKey(const Key('document-imprimer')));
    await Future<void>.delayed(const Duration(seconds: 2));
  });
  await AppHarness.settle(tester);
}

void main() {
  testWidgets('un seul bouton « Documents » : enseignants, élèves, école ; '
      'certificat de scolarité demi-page et attestation de prise de service '
      'imprimés et journalisés', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');

    // Signataire dans « Mon école ».
    await AppHarness.toucher(tester, 'Mon école');
    await AppHarness.settle(tester);
    await tap(tester, find.widgetWithText(ChoiceChip, 'La Directrice'));
    // Grade : une proposition d'un toucher (ou texte libre).
    await tap(
      tester,
      find.widgetWithText(ActionChip, 'Professeur Certifié des Écoles'),
    );
    final ecole = await h.db.select(h.db.schools).getSingle();
    expect(ecole.directorCivility, 'madame');
    expect(ecole.directorGrade, 'Professeur Certifié des Écoles');
    await retour(tester);

    await AppHarness.toucher(tester, 'Documents');
    await AppHarness.settle(tester);
    for (final t in ['Enseignants', 'Élèves']) {
      expect(find.text(t), findsOneWidget);
    }
    expect(find.text('Attestation de prise de service'), findsOneWidget);
    await voir(tester, find.text('École'));
    expect(find.text('École'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await AppHarness.settle(tester);

    // Certificat de scolarité, demi-page.
    await tap(tester, find.text('Certificat de scolarité'));
    await tester.enterText(find.byKey(const Key('recherche-personne')), 'aich');
    await AppHarness.settle(tester);
    expect(find.text('TEST Boukary'), findsNothing);
    await tap(tester, find.text('TEST Aïcha'));
    expect(find.byKey(const Key('manques')), findsOneWidget);
    await tap(tester, find.text('Demi-page'));
    await imprimer(tester);
    expect(
      h.pdfSortis.keys,
      contains('Certificat_de_scolarité_TEST_Aïcha.pdf'),
    );
    await retour(tester);
    await retour(tester);

    // Attestation de prise de service.
    await tap(tester, find.text('Attestation de prise de service'));
    await tap(tester, find.text('ENSEIGNANT Un'));
    expect(
      find.textContaining('n° de la décision d’affectation'),
      findsOneWidget,
    );
    await imprimer(tester);
    expect(
      h.pdfSortis.keys,
      contains('Attestation_de_prise_de_service_ENSEIGNANT_Un.pdf'),
    );

    final journal = await h.db.select(h.db.issuedDocuments).get();
    expect(
      {for (final j in journal) (j.docCode, j.studentId, j.teacherId)},
      {('certificat_scolarite', 'e-0', null), ('prise_service', null, 't-un')},
    );
    await h.synchroniser(tester);
    expect(h.server.tables['issued_documents'], hasLength(2));
    await h.dispose(tester);
  });
}
