import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';

void main() {
  testWidgets('premier lancement : écran de bienvenue', (tester) async {
    final h = AppHarness();
    await h.pump(tester);
    expect(find.text('Bienvenue dans EcolePlus'), findsOneWidget);
    expect(find.text('Créer mon école'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('mauvais mot de passe : message clair', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await tester.tap(find.text('Se connecter'));
    await AppHarness.settle(tester);
    await tester.enterText(
      find.byKey(const Key('login')),
      'directeur@ecole-test.local',
    );
    await tester.enterText(find.byKey(const Key('password')), 'faux');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await AppHarness.settle(tester);
    expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('numéro inconnu : rappelle que le directeur se connecte avec '
      'son adresse e-mail', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await tester.tap(find.text('Se connecter'));
    await AppHarness.settle(tester);
    await tester.enterText(find.byKey(const Key('login')), '70 56 17 40');
    await tester.enterText(find.byKey(const Key('password')), '12345678');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await AppHarness.settle(tester);
    expect(
      find.textContaining('connectez-vous avec votre adresse e-mail'),
      findsOneWidget,
    );
    await h.dispose(tester);
  });

  testWidgets('première connexion sans Internet : message clair', (
    tester,
  ) async {
    final h = AppHarness()
      ..seedEcoleTest()
      ..online = false;
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    expect(find.textContaining('Pas de connexion Internet'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('directeur : accueil, gros boutons, tout synchronisé', (
    tester,
  ) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    expect(find.text('Bonjour Directeur Test'), findsOneWidget);
    for (final b in [
      'Élèves',
      'Classes',
      'Enseignants',
      'Documents',
      'Mon école',
      'Personnes et droits',
      'Sécurité',
    ]) {
      expect(find.text(b), findsOneWidget);
    }
    // Années, options et sauvegarde sont dans « Mon école » (8 boutons au
    // plus sur l'accueil).
    await AppHarness.ouvrirDansMonEcole(tester, 'Sauvegarde');
    expect(find.text('Sauvegarde'), findsWidgets);
    expect(find.text('Tout est synchronisé'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('enseignant (connexion par téléphone) : pas d’options ni de '
      'gestion des comptes', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, '70 11 22 33');
    expect(find.text('Bonjour Enseignant Un'), findsOneWidget);
    expect(find.text('Options de l’école'), findsNothing);
    expect(find.text('Personnes et droits'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('mode avion : la modification est gardée, puis envoyée au retour '
      'du réseau', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    h.online = false;

    await tester.tap(find.text('Mon école'));
    await AppHarness.settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Commune'),
      'Commune modifiée hors ligne',
    );
    await AppHarness.settle(tester);
    expect(find.text('1 élément en attente'), findsOneWidget);

    h.online = true;
    await tester.tap(find.text('1 élément en attente'));
    await AppHarness.settle(tester);
    await tester.tap(find.text('Synchroniser maintenant'));
    await AppHarness.settle(tester);
    expect(find.text('Tout est synchronisé'), findsWidgets);
    expect(
      h.server.table('schools').values.single['commune'],
      'Commune modifiée hors ligne',
    );
    await h.dispose(tester);
  });

  testWidgets('options : désactiver un module annonce que les données sont '
      'conservées', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await AppHarness.ouvrirDansMonEcole(tester, 'Options de l’école');

    await tester.tap(find.byKey(const Key('module-cantine')));
    await AppHarness.settle(tester);
    await tester.tap(find.byKey(const Key('module-cantine')));
    await AppHarness.settle(tester);
    expect(find.textContaining('Vos données sont conservées.'), findsOneWidget);
    expect(find.textContaining('le stock de vivres'), findsOneWidget);
    await tester.tap(find.text('Désactiver'));
    await AppHarness.settle(tester);

    // Au moins un niveau : le primaire seul ne peut pas être décoché.
    await tester.tap(find.byKey(const Key('niveau-primaire')));
    await AppHarness.settle(tester);
    expect(find.textContaining('Au moins un niveau'), findsOneWidget);

    // Dossier médico-scolaire : avertissement avant activation.
    await tester.scrollUntilVisible(
      find.byKey(const Key('module-medico_scolaire')),
      100,
    );
    await tester.tap(find.byKey(const Key('module-medico_scolaire')));
    await AppHarness.settle(tester);
    expect(find.text('Données de santé'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await AppHarness.settle(tester);

    final modules = await tester.runAsync(
      () => h.db.select(h.db.schoolModules).get(),
    );
    final etat = {for (final m in modules!) m.moduleKey: m.enabled};
    expect(etat, {
      'maternelle': false,
      'cantine': false,
      'medico_scolaire': false,
    });
    await h.dispose(tester);
  });

  testWidgets('années : préparer l’année suivante puis basculer, l’ancienne '
      'reste consultable', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await AppHarness.ouvrirDansMonEcole(tester, 'Années scolaires');
    await tester.tap(find.text('Préparer l’année 2026-2027'));
    await AppHarness.settle(tester);
    await tester.tap(find.text('Passer à l’année 2026-2027'));
    await AppHarness.settle(tester);
    await tester.tap(find.text('Passer à 2026-2027'));
    await AppHarness.settle(tester);

    expect(find.text('Archivée — consultable'), findsOneWidget);
    expect(find.text('Année en cours'), findsOneWidget);
    final headers = await tester.runAsync(
      () => h.db.select(h.db.adminHeaders).get(),
    );
    expect(headers, hasLength(2));
    expect(headers!.map((x) => x.ceb).toSet(), {
      'CEB Test 2',
    }, reason: 'en-têtes recopiés dans la nouvelle année');
    await h.dispose(tester);
  });

  testWidgets('création de l’école : brouillon gardé, puis école créée', (
    tester,
  ) async {
    final h = AppHarness();
    await h.pump(tester);
    await tester.tap(find.text('Créer mon école'));
    await AppHarness.settle(tester);
    await tester.enterText(
      find.byKey(const Key('director_name')),
      'Directrice Neuve',
    );
    await tester.enterText(find.byKey(const Key('school_name')), 'École Neuve');
    await tester.enterText(
      find.byKey(const Key('email')),
      'directrice@neuve.bf',
    );
    await tester.enterText(find.byKey(const Key('login_phone')), '70 56 17 40');
    await tester.enterText(
      find.byKey(const Key('password')),
      'motdepasse-test',
    );
    await AppHarness.settle(tester);
    final draft = await tester.runAsync(
      () => h.db.select(h.db.drafts).getSingle(),
    );
    expect(draft!.payload, contains('École Neuve'));
    expect(
      draft.payload,
      isNot(contains('motdepasse')),
      reason: 'jamais de mot de passe',
    );

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Créer mon école'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Créer mon école'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Créer mon école'));
    await AppHarness.settle(tester);
    await AppHarness.taperCode(tester, '4071');
    await AppHarness.taperCode(tester, '4071');
    expect(find.text('Bonjour Directrice Neuve'), findsOneWidget);
    expect(find.text('École Neuve'), findsOneWidget);
    expect(h.auth.loginPhones['22670561740'], isNotNull);

    // A11 : déconnexion, puis connexion avec le numéro du directeur.
    await tester.scrollUntilVisible(find.text('Se déconnecter'), 200);
    await tester.tap(find.text('Se déconnecter'));
    await AppHarness.settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
    await AppHarness.settle(tester);
    await h.login(tester, '70 56 17 40');
    expect(find.text('Bonjour Directrice Neuve'), findsOneWidget);
    await h.dispose(tester);
  });
}
