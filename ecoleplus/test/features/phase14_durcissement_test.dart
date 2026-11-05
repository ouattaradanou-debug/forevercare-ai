import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'phase10_finances_test.dart' show saisir;
import 'phase8_cartes_test.dart' show accueil, tap;
import 'phase9_bibliotheque_test.dart' show calme;

void main() {
  testWidgets('sauvegarde chiffrée (mot de passe) puis restauration sur un '
      'autre téléphone : l’élément non envoyé est repris puis envoyé ; '
      'mauvais mot de passe refusé', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await calme(tester);

    // Ancien téléphone, sans Internet : une modification non envoyée.
    h.online = false;
    await tester.tap(find.text('Mon école'));
    await AppHarness.settle(tester);
    await tester.scrollUntilVisible(
      find.widgetWithText(TextField, 'Commune'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Commune'),
      'Commune de l’ancien téléphone',
    );
    await AppHarness.settle(tester);
    expect(find.text('1 élément en attente'), findsOneWidget);

    // Sauvegarde : mot de passe trop court refusé, puis accepté.
    await tap(tester, find.text('Sauvegarde'));
    await tap(tester, find.text('Créer une sauvegarde'));
    await saisir(tester, 'sauvegarde-mdp', 'court');
    await saisir(tester, 'sauvegarde-mdp2', 'court');
    await tap(tester, find.text('Valider'));
    expect(find.text('Au moins 8 caractères.'), findsOne);
    await saisir(tester, 'sauvegarde-mdp', 'ecole-test-2026');
    await saisir(tester, 'sauvegarde-mdp2', 'ecole-test-2026');
    await tap(tester, find.text('Valider'));
    await calme(tester);
    final nom = h.fichiersSortis.keys.singleWhere(
      (n) => n.startsWith('ecoleplus-sauvegarde-'),
    );
    final octets = h.fichiersSortis[nom]!;
    expect(
      String.fromCharCodes(octets).contains('Commune de l’ancien'),
      isFalse,
      reason: 'fichier chiffré : rien de lisible',
    );
    final fichier = File('${h.mediaDir.path}/recu-$nom')
      ..writeAsBytesSync(octets);

    // « Nouveau téléphone » : il n'a que ce que le serveur lui envoie.
    await h.db.customStatement('DELETE FROM outbox');
    await h.db.customStatement("UPDATE schools SET commune = NULL");
    h.online = true;
    h.sauvegardeChoisie = fichier.path;

    // Mauvais mot de passe.
    await tap(tester, find.text('Restaurer une sauvegarde'));
    await saisir(tester, 'sauvegarde-mdp', 'mauvais-mot');
    await tester.tap(find.text('Valider'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Mot de passe incorrect'), findsOne);
    await AppHarness.settle(tester);

    // Bon mot de passe : 1 élément repris.
    await tap(tester, find.text('Restaurer une sauvegarde'));
    await saisir(tester, 'sauvegarde-mdp', 'ecole-test-2026');
    await tap(tester, find.text('Valider'));
    expect(find.textContaining('1 élément(s) n’avaient pas encore'), findsOne);
    await tap(tester, find.text('Reprendre'));
    expect(
      tester.widget<Text>(find.byKey(const Key('restauration-resultat'))).data,
      startsWith('1 élément(s) repris'),
    );
    await accueil(tester);
    await h.synchroniser(tester);
    expect(
      h.server.table('schools').values.single['commune'],
      'Commune de l’ancien téléphone',
    );
    await h.dispose(tester);
  });
}
