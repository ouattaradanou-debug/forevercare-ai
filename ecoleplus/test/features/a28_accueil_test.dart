import 'package:ecoleplus/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'phase9_bibliotheque_test.dart' show calme;

/// Tailles d'écran demandées (points) : largeur × hauteur.
const tailles = [
  Size(360, 800),
  Size(360, 740),
  Size(375, 812),
  Size(390, 844),
  Size(412, 915),
];

/// Barre d'état (24 points) et barre de navigation Android (48 points).
const haut = 24.0;
const bas = 48.0;

Future<void> verifierAccueil(
  WidgetTester tester,
  Size taille,
  List<String> elements,
) async {
  final ecran = Rect.fromLTWH(
    0,
    haut,
    taille.width,
    taille.height - haut - bas,
  );
  expect(
    find.descendant(
      of: find.byType(HomePage),
      matching: find.byType(Scrollable),
    ),
    findsNothing,
    reason: '${taille.width}×${taille.height} : aucun défilement',
  );
  final rects = <String, Rect>{};
  for (final e in elements) {
    final f = e.startsWith('#')
        ? find.byKey(Key(e.substring(1)))
        : find.text(e);
    expect(
      f,
      findsOneWidget,
      reason: '$e présent (${taille.width}×${taille.height})',
    );
    final r = tester.getRect(f);
    expect(
      ecran.contains(r.topLeft) &&
          ecran.contains(r.bottomRight - const Offset(0.1, 0.1)),
      isTrue,
      reason:
          '$e entièrement visible à l’écran (${taille.width}×'
          '${taille.height}) : $r dans $ecran',
    );
    rects[e] = r;
  }
  // Aucune tuile ne chevauche une autre.
  final tuiles = [
    for (final e in rects.entries)
      if (e.key.startsWith('#theme-')) e.value,
  ];
  for (var i = 0; i < tuiles.length; i++) {
    for (var j = i + 1; j < tuiles.length; j++) {
      expect(tuiles[i].overlaps(tuiles[j]), isFalse, reason: 'chevauchement');
    }
  }
}

Future<void> taille(WidgetTester tester, Size s) async {
  tester.view
    ..devicePixelRatio = 2
    ..physicalSize = s * 2
    ..padding = const FakeViewPadding(top: haut * 2, bottom: bas * 2);
  addTearDown(tester.view.resetPadding);
  await AppHarness.settle(tester);
}

void main() {
  const directeur = [
    '#titre-page',
    '#cloche',
    '#profil',
    '#bonjour',
    '#synchro',
    '#theme-bord',
    '#theme-recherche',
    '#theme-eleves',
    '#theme-pedagogie',
    '#theme-administration',
    '#theme-finances',
    '#theme-rapports',
    '#theme-bibliotheque',
    '#theme-ecole',
    'Se déconnecter',
  ];

  testWidgets('accueil du directeur : tout tient sur un écran, sans '
      'défilement, sur les 5 tailles de téléphone', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await calme(tester);
    for (final s in tailles) {
      await taille(tester, s);
      await verifierAccueil(tester, s, directeur);
    }
    // Chaque accès fonctionne.
    await taille(tester, tailles.first);
    for (final (cle, titre) in const [
      ('bord', 'Tableau de bord'),
      ('recherche', 'Rechercher'),
      ('eleves', 'Élèves et classes'),
      ('rapports', 'Rapports'),
      ('ecole', 'Mon école'),
    ]) {
      await tester.tap(find.byKey(Key('theme-$cle')));
      await AppHarness.settle(tester);
      expect(
        tester.widget<Text>(find.byKey(const Key('titre-page')).last).data,
        titre,
      );
      await tester.tap(find.byTooltip('Retour').first);
      await AppHarness.settle(tester);
    }
    await tester.tap(find.byKey(const Key('cloche')));
    await AppHarness.settle(tester);
    expect(find.text('Notifications'), findsWidgets);
    await tester.tap(find.byTooltip('Retour').first);
    await AppHarness.settle(tester);
    await tester.tap(find.text('Se déconnecter'));
    await AppHarness.settle(tester);
    expect(find.text('Se déconnecter ?'), findsOne);
    await h.dispose(tester);
  });

  testWidgets('accueil de l’enseignant (« Ma journée ») : tout tient sur un '
      'écran sur les 5 tailles', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, '70112233');
    await calme(tester);
    for (final s in tailles) {
      await taille(tester, s);
      await verifierAccueil(tester, s, const [
        '#titre-page',
        '#cloche',
        '#bonjour',
        '#ma-journee',
        '#theme-bord',
        '#theme-recherche',
        '#theme-classe',
        '#theme-notes',
        '#theme-ia',
        '#theme-bibliotheque',
        '#theme-compte',
        'Se déconnecter',
      ]);
    }
    await h.dispose(tester);
  });
}
