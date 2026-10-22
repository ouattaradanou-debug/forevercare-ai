import 'package:drift/drift.dart' show Value;
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/lock/data/biometric_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';

void main() {
  testWidgets('après la connexion, un code est obligatoire (refus des codes '
      'faciles et des codes différents)', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local', creerCode: false);
    expect(find.text('Code de verrouillage'), findsOneWidget);

    await AppHarness.taperCode(tester, '1234');
    expect(find.textContaining('trop facile'), findsOneWidget);
    await AppHarness.taperCode(tester, '4071');
    await AppHarness.taperCode(tester, '4072');
    expect(find.textContaining('différents'), findsOneWidget);
    await AppHarness.taperCode(tester, '4071');
    await AppHarness.taperCode(tester, '4071');
    expect(find.text('Bonjour Directeur Test'), findsOneWidget);
    final lock = await tester.runAsync(() => h.db.select(h.db.appLock).get());
    expect(lock!.single.pinHash, isNot(contains('4071')));
    await h.dispose(tester);
  });

  testWidgets('réouverture : l’application est verrouillée ; mauvais code '
      'refusé, bon code accepté', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await h.relancer(tester);

    expect(find.text('Tapez votre code'), findsOneWidget);
    expect(find.text('Bonjour Directeur Test'), findsOneWidget);
    await AppHarness.taperCode(tester, '9999');
    expect(find.text('Code incorrect.'), findsOneWidget);
    await AppHarness.taperCode(tester, '4071');
    expect(find.text('Mon école'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('empreinte OU code : on choisit l’empreinte, aucun code n’est '
      'créé et la réouverture se fait au doigt', (tester) async {
    final capteur = FakeBiometricGate(accepte: false);
    final h = AppHarness()
      ..seedEcoleTest()
      ..biometrie = capteur;
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local', creerCode: false);
    expect(find.textContaining('Comment voulez-vous ouvrir'), findsOneWidget);
    expect(find.text('Avec mon empreinte'), findsOneWidget);
    expect(find.byKey(const Key('pin-1')), findsNothing);

    await tester.tap(find.text('Avec mon empreinte'));
    await AppHarness.settle(tester);
    expect(find.textContaining('Empreinte non reconnue'), findsOneWidget);
    capteur.accepte = true;
    await tester.tap(find.text('Avec mon empreinte'));
    await AppHarness.settle(tester);
    expect(find.text('Bonjour Directeur Test'), findsOneWidget);
    final lock = await tester.runAsync(() => h.db.select(h.db.appLock).get());
    expect(lock!.single.pinHash, isEmpty);
    expect(lock.single.biometric, isTrue);

    // Réouverture : pas de clavier, le doigt suffit.
    capteur.accepte = false;
    await h.relancer(tester);
    expect(find.text('Posez votre doigt sur le capteur'), findsOneWidget);
    expect(find.byKey(const Key('pin-1')), findsNothing);
    capteur.accepte = true;
    await tester.tap(find.text('Ouvrir avec mon empreinte'));
    await AppHarness.settle(tester);
    expect(find.text('Mon école'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('empreinte OU code : on choisit le code ; l’empreinte n’est '
      'alors plus proposée à l’ouverture', (tester) async {
    final h = AppHarness()
      ..seedEcoleTest()
      ..biometrie = FakeBiometricGate();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local', creerCode: false);
    await tester.tap(find.byKey(const Key('choisir-code')));
    await AppHarness.settle(tester);
    // ✓ inactif tant qu'il manque des chiffres.
    await tester.tap(find.byKey(const Key('pin-4')));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('pin-ok'))).onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('pin-effacer')));
    await tester.pump();
    await AppHarness.taperCode(tester, '4071');
    expect(find.textContaining('une seconde fois'), findsOneWidget);
    await AppHarness.taperCode(tester, '4071');
    expect(find.text('Bonjour Directeur Test'), findsOneWidget);

    await h.relancer(tester);
    expect(find.text('Tapez votre code'), findsOneWidget);
    expect(find.text('Ouvrir avec mon empreinte'), findsNothing);
    await AppHarness.taperCode(tester, '4071');
    expect(find.text('Mon école'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('A11 : le directeur ajoute son numéro dans « Mon compte » puis '
      'se connecte avec', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    await AppHarness.toucher(tester, 'Sécurité');
    await AppHarness.settle(tester);
    await AppHarness.toucher(tester, 'Mon compte');
    await AppHarness.settle(tester);
    await tester.tap(find.text('Mon numéro pour me connecter'));
    await AppHarness.settle(tester);
    // Numéro déjà identifiant d'un enseignant : refusé.
    await tester.enterText(find.byKey(const Key('numero')), '70 11 22 33');
    await tester.tap(find.text('Enregistrer'));
    await AppHarness.settle(tester);
    expect(find.textContaining('déjà utilisé'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('numero')), '70 56 17 40');
    await tester.tap(find.text('Enregistrer'));
    await AppHarness.settle(tester);
    expect(h.auth.loginPhones['22670561740'], 'u-dir');

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Retour').first);
      await AppHarness.settle(tester);
    }
    await tester.scrollUntilVisible(find.text('Se déconnecter'), 200);
    await tester.tap(find.text('Se déconnecter'));
    await AppHarness.settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
    await AppHarness.settle(tester);

    // Mauvais mot de passe : refus, sans révéler l'e-mail.
    await tester.tap(find.text('Se connecter'));
    await AppHarness.settle(tester);
    await tester.enterText(find.byKey(const Key('login')), '70561740');
    await tester.enterText(find.byKey(const Key('password')), 'faux-mdp-1');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await AppHarness.settle(tester);
    expect(find.textContaining('incorrect'), findsOneWidget);
    expect(find.textContaining('ecole-test.local'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('password')),
      'motdepasse-test',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await AppHarness.settle(tester);
    await AppHarness.taperCode(tester, '4071');
    await AppHarness.taperCode(tester, '4071');
    expect(find.text('Bonjour Directeur Test'), findsOneWidget);
    final session = await tester.runAsync(
      () => h.db.select(h.db.localSession).getSingle(),
    );
    expect(session!.login, 'directeur@ecole-test.local');
    await h.dispose(tester);
  });

  testWidgets('directeur : déconnecter le téléphone perdu d’un enseignant ; '
      'le journal le montre', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    h.server
      ..seed('devices', {
        'id': 'tel-ens',
        'school_id': ecoleId,
        'user_id': 'u-ens',
        'label': 'Téléphone de l’enseignant',
        'series_code': 'B',
        'pending_count': 3,
        'last_sync_at': '2026-10-10T08:00:00.000Z',
        'updated_at': '2026-10-10T08:00:00.000Z',
      })
      ..seed('audit_log', {
        'id': 'a1',
        'school_id': ecoleId,
        'occurred_at': '2099-01-01T08:00:00.000Z',
        'actor_id': 'u-ens',
        'action': 'recuperation_mot_de_passe',
        'table_name': 'memberships',
        'details': '{"personne":"Enseignant Un","methode":"question secrète"}',
      });
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    expect(find.text('1 événement de sécurité à voir'), findsOneWidget);

    await AppHarness.toucher(tester, 'Sécurité');
    await AppHarness.settle(tester);
    await tester.tap(find.text('Téléphones de l’école'));
    await AppHarness.settle(tester);
    expect(find.text('3 élément(s) pas encore envoyé(s)'), findsOneWidget);
    expect(find.textContaining('ne sont pas encore envoyés'), findsOneWidget);
    await tester.tap(find.text('Déconnecter ce téléphone'));
    await AppHarness.settle(tester);
    expect(
      find.textContaining('3 élément(s) non envoyés seront perdus'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Déconnecter'));
    await AppHarness.settle(tester);
    expect(h.auth.revoked, ['tel-ens']);

    await tester.tap(find.byTooltip('Retour').first);
    await AppHarness.settle(tester);
    await tester.tap(find.text('Journal d’activité'));
    await AppHarness.settle(tester);
    expect(
      find.text(
        'Enseignant Un a changé son mot de passe grâce à sa question secrète',
      ),
      findsOneWidget,
    );
    await h.dispose(tester);
  });

  testWidgets('téléphone déconnecté par le directeur : données effacées, '
      'message clair', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    final session = await tester.runAsync(
      () => h.db.select(h.db.localSession).getSingle(),
    );
    h.server.revokedDevices.add(session!.deviceId);

    await tester.tap(find.text('Tout est synchronisé'));
    await AppHarness.settle(tester);
    await tester.tap(find.text('Synchroniser maintenant'));
    for (var i = 0; i < 4; i++) {
      await AppHarness.settle(tester);
    }
    expect(find.textContaining('déconnecté par le directeur'), findsWidgets);
    expect(find.text('Créer mon école'), findsOneWidget);
    final schools = await tester.runAsync(
      () => h.db.select(h.db.schools).get(),
    );
    expect(schools, isEmpty);
    await h.dispose(tester);
  });

  testWidgets('question secrète : choisie dans « Mon compte », puis utilisée '
      'pour changer un mot de passe oublié', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, '70 11 22 33');
    expect(
      find.textContaining('Choisissez une question secrète'),
      findsOneWidget,
    );
    await AppHarness.toucher(tester, 'Mon compte');
    await AppHarness.settle(tester);
    await tester.tap(find.text('Choisir ma question secrète'));
    await AppHarness.settle(tester);
    await tester.enterText(
      find.byKey(const Key('question')),
      'Mon premier élève ?',
    );
    await tester.enterText(find.byKey(const Key('reponse')), 'Moussa');
    await tester.enterText(find.byKey(const Key('confirmation')), 'Moussa');
    await tester.tap(find.text('Enregistrer'));
    await AppHarness.settle(tester);
    expect(h.auth.questions['u-ens']!.$1, 'Mon premier élève ?');

    // Se déconnecter, puis « Mot de passe oublié ? »
    await tester.tap(find.byTooltip('Retour').first);
    await AppHarness.settle(tester);
    await tester.scrollUntilVisible(find.text('Se déconnecter'), 200);
    await tester.tap(find.text('Se déconnecter'));
    await AppHarness.settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
    await AppHarness.settle(tester);
    await tester.tap(find.text('Se connecter'));
    await AppHarness.settle(tester);
    await tester.tap(find.text('Mot de passe oublié ?'));
    await AppHarness.settle(tester);
    await tester.enterText(find.byKey(const Key('login')), '70112233');
    await tester.tap(find.text('Répondre à ma question secrète'));
    await AppHarness.settle(tester);
    expect(find.text('Mon premier élève ?'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('reponse')), 'moussa');
    await tester.enterText(
      find.byKey(const Key('new-password')),
      'nouveau-mdp-1',
    );
    await tester.tap(find.text('Changer mon mot de passe'));
    await AppHarness.settle(tester);
    expect(find.text('Code de verrouillage'), findsOneWidget);
    expect(
      h.auth.users['22670112233@tel.ecoleplus.invalid']!.$1,
      'nouveau-mdp-1',
    );
    await h.dispose(tester);
  });

  testWidgets('alerte conditionnelle : seulement si des données attendent '
      'depuis plus de 3 jours', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    expect(find.textContaining('ne sont pas encore envoyés'), findsNothing);

    h.online = false;
    await tester.runAsync(
      () => h.db
          .into(h.db.outbox)
          .insert(
            OutboxCompanion.insert(
              targetTable: 'schools',
              rowKey: '{"id":"$ecoleId"}',
              payload: '{"id":"$ecoleId","updated_at":"2026-10-17T08:00:00Z"}',
              createdAt: DateTime.now()
                  .toUtc()
                  .subtract(const Duration(days: 4))
                  .toIso8601String(),
              attempts: const Value(0),
            ),
          ),
    );
    await AppHarness.settle(tester);
    expect(
      find.textContaining('1 élément saisi depuis 4 jours'),
      findsOneWidget,
    );
    await h.dispose(tester);
  });

  testWidgets('période de composition : des notes non envoyées depuis 2 '
      'jours suffisent pour l’alerte (1 jour au lieu de 3)', (tester) async {
    final h = AppHarness()..seedEcoleTest();
    await h.pump(tester);
    await h.login(tester, 'directeur@ecole-test.local');
    h.online = false;
    Future<void> enAttente(String table) => tester.runAsync(
      () => h.db
          .into(h.db.outbox)
          .insert(
            OutboxCompanion.insert(
              targetTable: table,
              rowKey: '{"id":"x-$table"}',
              payload: '{"id":"x-$table"}',
              createdAt: DateTime.now()
                  .toUtc()
                  .subtract(const Duration(days: 2))
                  .toIso8601String(),
              attempts: const Value(0),
            ),
          ),
    );
    await enAttente('schools');
    await AppHarness.settle(tester);
    expect(find.textContaining('ne sont pas encore envoyés'), findsNothing);
    await enAttente('grades');
    await AppHarness.settle(tester);
    expect(
      find.textContaining('2 éléments saisis depuis 2 jours'),
      findsOneWidget,
    );
    await h.dispose(tester);
  });
}
