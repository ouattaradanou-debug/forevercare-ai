import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:ecoleplus/app/app.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'fake_auth_api.dart';
import 'fake_server.dart';

const ecoleId = '10000000-0000-4000-8000-000000000001';
const anneeId = '20000000-0000-4000-8000-000000002025';

/// L'application complète, branchée sur un serveur et une authentification
/// simulés, avec une base locale en mémoire.
class AppHarness {
  AppHarness() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemote(server);
    auth = FakeAuthApi(server);
  }

  final server = FakeServer();
  late final AppDatabase db;
  late final FakeRemote remote;
  late final FakeAuthApi auth;
  final mediaDir = Directory.systemTemp.createTempSync('ecoleplus_media');

  set online(bool v) {
    remote.online = v;
    auth.online = v;
  }

  /// École Test côté serveur, avec un directeur et un enseignant.
  void seedEcoleTest() {
    const ts = '2026-10-21T07:00:00.000Z';
    server
      ..seed('modules_catalog', {
        'key': 'maternelle',
        'label': 'Maternelle',
        'description': 'Classes de maternelle',
        'sort_order': 1,
      })
      ..seed('modules_catalog', {
        'key': 'cantine',
        'label': 'Cantine',
        'description': 'Repas et stock de vivres',
        'sort_order': 2,
      })
      ..seed('modules_catalog', {
        'key': 'medico_scolaire',
        'label': 'Dossier médico-scolaire',
        'description': 'Fiches médicales',
        'sort_order': 3,
      })
      ..seed('schools', {
        'id': ecoleId,
        'name': 'École Test',
        'school_type': 'publique',
        'manages_primary': true,
        'grading_scale': 10,
        'show_race_religion': false,
        'absent_rule': 'non_compte',
        'current_school_year_id': anneeId,
        'updated_at': ts,
      })
      ..seed('school_years', {
        'id': anneeId,
        'school_id': ecoleId,
        'label': '2025-2026',
        'updated_at': ts,
      })
      ..seed('admin_headers', {
        'id': 'h-2025',
        'school_id': ecoleId,
        'school_year_id': anneeId,
        'country': 'BURKINA FASO',
        'region': 'Région Test B',
        'ceb': 'CEB Test 2',
        'updated_at': ts,
      })
      ..seed('memberships', {
        'id': 'm-dir',
        'school_id': ecoleId,
        'user_id': 'u-dir',
        'role': 'directeur',
        'display_name': 'Directeur Test',
        'active': true,
        'updated_at': ts,
      })
      ..seed('memberships', {
        'id': 'm-ens',
        'school_id': ecoleId,
        'user_id': 'u-ens',
        'role': 'enseignant',
        'display_name': 'Enseignant Un',
        'active': true,
        'updated_at': ts,
      });
    for (final k in ['maternelle', 'cantine', 'medico_scolaire']) {
      server.seed('school_modules', {
        'school_id': ecoleId,
        'module_key': k,
        'enabled': false,
        'updated_at': ts,
      });
    }
    auth
      ..addUser('directeur@ecole-test.local', 'motdepasse-test', 'u-dir')
      ..addUser(
        '22670112233@tel.ecoleplus.invalid',
        'motdepasse-test',
        'u-ens',
      );
  }

  Future<void> pump(WidgetTester tester) async {
    await initializeDateFormatting('fr');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          syncRemoteProvider.overrideWithValue(remote as SyncRemote),
          authApiProvider.overrideWithValue(auth as AuthApi),
          mediaDirProvider.overrideWithValue(mediaDir),
          clockProvider.overrideWithValue(Clock()),
          syncSchedulerProvider.overrideWithValue(null),
        ],
        child: const EcolePlusApp(),
      ),
    );
    await settle(tester);
  }

  /// Laisse passer les écritures en base et les minuteries (enregistrement
  /// automatique).
  static Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 800));
    }
  }

  Future<void> login(WidgetTester tester, String login) async {
    await tester.tap(find.text('Se connecter'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('login')), login);
    await tester.enterText(
      find.byKey(const Key('password')),
      'motdepasse-test',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await settle(tester);
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Laisse drift annuler ses requêtes « surveillées » avant la fermeture.
    await tester.pump(const Duration(seconds: 1));
    await db.close();
    await tester.pump(const Duration(seconds: 1));
  }
}
