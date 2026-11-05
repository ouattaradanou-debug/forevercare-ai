@Tags(['captures'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/phase8_cartes_test.dart' show accueil, tap;
import '../features/phase9_bibliotheque_test.dart' show calme;
import '../helpers/app_harness.dart';

/// Captures d'écran du guide d'utilisation (docs/guide/*.png), avec les
/// vraies polices. À relancer après un changement d'écran :
///   flutter test test/guide --update-goldens --tags captures
Future<void> polices() async {
  const dossier = '/opt/sdk/flutter/bin/cache/artifacts/material_fonts';
  final racine = Platform.environment['FLUTTER_ROOT'];
  final d = racine == null
      ? dossier
      : '$racine/bin/cache/artifacts/material_fonts';
  Future<ByteData> lire(String f) async =>
      ByteData.sublistView(await File('$d/$f').readAsBytes());
  final roboto = FontLoader('Roboto');
  for (final f in [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]) {
    roboto.addFont(lire(f));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(lire('MaterialIcons-Regular.otf'))).load();
}

Future<void> capture(WidgetTester tester, String nom) async {
  await AppHarness.settle(tester);
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/guide/$nom.png'),
  );
}

void main() {
  testWidgets('captures du guide (directeur et enseignant)', (tester) async {
    await tester.runAsync(polices);
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    // Téléphone courant : 360 × 780 points.
    tester.view
      ..physicalSize = const Size(720, 1560)
      ..devicePixelRatio = 2;
    await h.login(tester, 'directeur@ecole-test.local');
    await calme(tester);
    await capture(tester, '01-accueil-directeur');
    // Plus petit écran demandé (360 × 740), barres Android comprises.
    tester.view
      ..physicalSize = const Size(720, 1480)
      ..padding = const FakeViewPadding(top: 48, bottom: 96);
    await capture(tester, '00-accueil-360x740');
    tester.view
      ..physicalSize = const Size(720, 1560)
      ..resetPadding();
    await tap(tester, find.text('Tableau de bord'));
    await capture(tester, '02-tableau-de-bord');
    await accueil(tester);
    await tap(tester, find.text('Élèves et classes'));
    await capture(tester, '03-eleves-et-classes');
    await tap(tester, find.text('Élèves'));
    await capture(tester, '04-liste-eleves');
    await accueil(tester);
    await tap(tester, find.text('Finances'));
    await capture(tester, '05-finances');
    await accueil(tester);
    await tap(tester, find.text('Rapports'));
    await capture(tester, '06-rapports');
    await accueil(tester);
    await tap(tester, find.text('Rechercher'));
    await tester.enterText(find.byKey(const Key('recherche')), 'aich');
    await capture(tester, '07-recherche');
    await accueil(tester);
    await tap(tester, find.text('Pédagogie'));
    await tap(tester, find.text('Emploi du temps'));
    await tap(tester, find.byKey(const Key('classe-c-cm1')));
    await capture(tester, '08-emploi-du-temps');
    await accueil(tester);
    await tap(tester, find.byKey(const Key('cloche')));
    await capture(tester, '09-notifications');
    await accueil(tester);
    await tap(tester, find.text('Mon école'));
    await tester.scrollUntilVisible(
      find.text('Sauvegarde'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(tester, find.text('Sauvegarde'));
    await capture(tester, '10-sauvegarde');
    await accueil(tester);
    await tap(tester, find.text('Élèves et classes'));
    await tap(tester, find.text('Faire l’appel'));
    await tap(tester, find.byKey(const Key('classe-c-cm1')));
    await capture(tester, '11-appel');
    await h.dispose(tester);
  });
}
