import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import 'phase10_finances_test.dart' show saisir, texte;
import 'phase8_cartes_test.dart' show accueil, retour, tap;
import 'phase9_bibliotheque_test.dart' show calme;

/// Touche « Demander » et regarde tout de suite (le message passe vite).
Future<void> genererCourt(WidgetTester tester) async {
  final f = find.byKey(const Key('ia-generer'));
  await tester.ensureVisible(f);
  await tester.tap(f);
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  testWidgets('assistant IA : compteur, préparation avec sources, '
      'Simplifier, modifier puis enregistrer, Mes fiches ; sans Internet la '
      'demande est gardée puis envoyée ; limite atteinte : message clair ; '
      'suivi du directeur', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await AppHarness.toucher(tester, 'Assistant IA');
    await AppHarness.settle(tester);
    expect(
      texte(tester.widget<Text>(find.byKey(const Key('compteur-ia'))).data),
      'Il vous reste 30 demandes ce mois-ci.',
    );

    // Préparer un cours.
    await tap(tester, find.text('Préparer un cours'));
    await saisir(tester, 'ia-niveau', 'CM1');
    await saisir(tester, 'ia-theme', 'Les fractions');
    await tap(tester, find.byKey(const Key('ia-generer')));
    await AppHarness.settle(tester);
    final d = h.assistant.demandes.single;
    expect(
      (d['kind'], d['theme'], d['niveau']),
      ('preparation', 'Les fractions', 'CM1'),
    );
    expect(d.containsKey('sans_bibliotheque'), isFalse);
    expect(find.text('Préparation : Les fractions'), findsOne);
    expect(
      texte(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(const Key('ia-sources')),
                matching: find.byType(Text),
              ),
            )
            .data,
      ),
      'Sources utilisées : Guide des fractions (p. 2)',
    );

    // Simplifier : la fiche précédente est renvoyée avec l'action.
    await tap(tester, find.byKey(const Key('ia-simplifier')));
    await AppHarness.settle(tester);
    final s = h.assistant.demandes.last;
    expect(s['action'], 'simplifier');
    expect((s['precedent']! as Map)['titre'], 'Préparation : Les fractions');
    expect(find.text('Préparation : Les fractions (simplifier)'), findsOne);

    // Modifier puis enregistrer.
    await tap(tester, find.byKey(const Key('ia-modifier')));
    await tester.enterText(
      find.byKey(const Key('ia-section-1')),
      '- Partager un mangue en 4 parts (retouché)',
    );
    await tap(tester, find.byKey(const Key('ia-modifier')));
    await tap(tester, find.byKey(const Key('ia-enregistrer')));
    await calme(tester);
    final f = await h.db.select(h.db.lessonPreps).getSingle();
    expect(f.kind, 'preparation');
    final contenu = jsonDecode(f.content) as Map<String, dynamic>;
    expect(
      ((contenu['sections'] as List)[1] as Map)['contenu'],
      contains('(retouché)'),
    );
    expect(jsonDecode(f.sources), hasLength(1));
    await accueil(tester);

    // Mes fiches.
    await AppHarness.toucher(tester, 'Assistant IA');
    await AppHarness.settle(tester);
    await tap(tester, find.text('Mes fiches'));
    expect(find.text('Préparation : Les fractions (simplifier)'), findsOne);
    await retour(tester);

    // Sans Internet : la demande est gardée, puis envoyée.
    h.assistant.horsLigne = true;
    await tap(tester, find.text('Aider un élève en difficulté'));
    await saisir(tester, 'ia-difficultes', 'confond dizaines et unités');
    await genererCourt(tester);
    expect(find.textContaining('votre demande est gardée'), findsOne);
    await calme(tester);
    await accueil(tester);
    await AppHarness.toucher(tester, 'Assistant IA');
    await AppHarness.settle(tester);
    expect(find.text('1 demande(s) en attente d’Internet'), findsOne);
    h.assistant.horsLigne = false;
    await tap(tester, find.byKey(const Key('envoyer-attente')));
    await AppHarness.settle(tester);
    expect(h.assistant.demandes.last['kind'], 'remediation');
    expect(find.text('Préparation : confond dizaines et unités'), findsOne);
    await retour(tester);
    expect(find.text('1 demande(s) en attente d’Internet'), findsNothing);

    // Limite atteinte : message clair, rien n'est gardé.
    h.assistant.limite = true;
    await tap(tester, find.text('Exercices et évaluations'));
    await saisir(tester, 'ia-theme', 'Conjugaison');
    await genererCourt(tester);
    expect(find.textContaining('Vous avez utilisé vos 30 demandes'), findsOne);
    await calme(tester);
    await retour(tester);
    h.assistant.limite = false;

    // Suivi du directeur : limite d'un enseignant.
    await tap(tester, find.text('Suivi de l’école (directeur)'));
    expect(find.text('Enseignant Un'), findsOne);
    await tap(tester, find.byKey(const Key('changer-limite-m-ens')));
    await tester.enterText(find.byKey(const Key('limite-ia')), '40');
    await tap(tester, find.byKey(const Key('valider-limite')));
    await calme(tester);
    final l = await h.db.select(h.db.aiTeacherLimits).getSingle();
    expect((l.membershipId, l.monthlyLimit), ('m-ens', 40));
    await h.dispose(tester);
  });
}
