import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../helpers/app_harness.dart';
import 'cartes_domain_test.dart' show photoDeTest;
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

/// Touche un bouton dont l'action dure (traitement d'image, PDF).
Future<void> tapLong(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) await voir(tester, f);
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.runAsync(() async {
    await tester.tap(f);
    await Future<void>.delayed(const Duration(seconds: 3));
  });
  await AppHarness.settle(tester);
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 500)),
  );
  await AppHarness.settle(tester);
}

void main() {
  testWidgets('photo prise hors ligne : gardée sur le téléphone, recadrée '
      'et compressée, puis envoyée à la synchronisation', (tester) async {
    final h = AppHarness()
      ..seedEcoleTest()
      ..imageChoisie = photoDeTest(1);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    h.online = false;

    await AppHarness.toucher(tester, 'Élèves');
    await AppHarness.settle(tester);
    await tap(tester, find.text('TEST Aïcha'));
    await tapLong(tester, find.byKey(const Key('choisir-photo')));
    expect(find.byKey(const Key('cadre-photo')), findsOneWidget);
    await tapLong(tester, find.byKey(const Key('valider-cadre')));

    final aicha = (await h.db.select(h.db.students).get()).firstWhere(
      (s) => s.id == 'e-0',
    );
    expect(aicha.photoPath, startsWith('$ecoleId/eleves/e-0-'));
    final fichier = File('${h.mediaDir.path}/${aicha.photoPath}');
    expect(fichier.existsSync(), isTrue);
    final jpeg = img.decodeJpg(fichier.readAsBytesSync())!;
    expect((jpeg.width, jpeg.height), (300, 400));
    expect(fichier.lengthSync(), lessThan(50 * 1024));
    expect(h.server.files, isEmpty, reason: 'hors ligne : rien envoyé');
    expect(find.byKey(const Key('retirer-photo')), findsOneWidget);

    h.online = true;
    await accueil(tester);
    await h.synchroniser(tester);
    expect(h.server.files.keys, ['ecole-medias/${aicha.photoPath}']);
    expect(h.server.tables['students']!['e-0']!['photo_path'], aicha.photoPath);
    await h.dispose(tester);
  });

  testWidgets('cartes : lot avec des élèves sans photo (liste de contrôle, '
      'avertissement), planches A4 recto-verso, QR code opaque gardé d’une '
      'impression à l’autre', (tester) async {
    final h = AppHarness()
      ..seedEcoleTest()
      ..imageChoisie = photoDeTest(2);
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');

    // Une photo pour Aïcha ; les 3 autres élèves n'en ont pas.
    await AppHarness.toucher(tester, 'Élèves');
    await AppHarness.settle(tester);
    await tap(tester, find.text('TEST Aïcha'));
    await tapLong(tester, find.byKey(const Key('choisir-photo')));
    await tapLong(tester, find.byKey(const Key('valider-cadre')));
    await accueil(tester);

    await AppHarness.toucher(tester, 'Documents');
    await AppHarness.settle(tester);
    await tap(tester, find.text('Cartes scolaires'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await AppHarness.settle(tester);
    expect(
      find.text('3 élèves sans photo (cadre vide sur la carte)'),
      findsOneWidget,
    );
    await tap(tester, find.text('Générer les cartes (PDF)'));
    expect(find.text('3 élève(s) sans photo'), findsOneWidget);
    await tapLong(tester, find.widgetWithText(FilledButton, 'Générer'));
    final pdf = h.pdfSortis['Cartes_scolaires.pdf']!;
    final t = texteDuPdf(pdf);
    if (t != null) {
      for (final x in ['CARTE SCOLAIRE', 'TEST', 'Aïcha', 'Daouda', 'PHOTO']) {
        expect(t, contains(x));
      }
    }
    final cartes = await h.db.select(h.db.studentCards).get();
    expect(cartes, hasLength(4));
    expect(
      cartes.every((c) => RegExp(r'^[0-9a-f]{32}$').hasMatch(c.qrToken)),
      isTrue,
    );

    // Deuxième impression : mêmes identifiants (les cartes déjà distribuées
    // restent valables).
    final avant = {for (final c in cartes) c.studentId: c.qrToken};
    await tester.tap(find.text('Générer les cartes (PDF)'));
    await AppHarness.settle(tester);
    await tapLong(tester, find.widgetWithText(FilledButton, 'Générer'));
    final apres = await h.db.select(h.db.studentCards).get();
    expect({for (final c in apres) c.studentId: c.qrToken}, avant);

    await accueil(tester);
    await h.synchroniser(tester);
    expect(h.server.tables['student_cards'], hasLength(4));
    await h.dispose(tester);
  });
}
