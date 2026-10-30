import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:ecoleplus/app/app.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/dictee/dictee.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/bibliotheque/data/bibliotheque_repository.dart';
import 'package:ecoleplus/features/bibliotheque/presentation/bibliotheque_pages.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:ecoleplus/features/import/presentation/import_page.dart';
import 'package:ecoleplus/features/lock/data/biometric_gate.dart';
import 'package:ecoleplus/features/lock/data/lock_service.dart';
import 'package:ecoleplus/features/lock/presentation/lock_providers.dart';
import 'package:ecoleplus/features/medical/presentation/medical_pages.dart';
import 'package:ecoleplus/features/photos/presentation/photo_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'fake_auth_api.dart';
import 'fake_documents_en_ligne.dart';
import 'fake_medical_api.dart';
import 'fake_server.dart';

const ecoleId = '10000000-0000-4000-8000-000000000001';
const anneeId = '20000000-0000-4000-8000-000000002025';

/// L'application complète, branchée sur un serveur et une authentification
/// simulés, avec une base locale en mémoire.
class AppHarness {
  new() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemote(server);
    auth = FakeAuthApi(server);
    enLigne = FakeDocumentsEnLigne(server);
  }

  /// Recherche dans le texte et espace utilisé (serveur simulé).
  late final FakeDocumentsEnLigne enLigne;

  /// Documents ouverts dans l'application de lecture du téléphone (chemin).
  final List<String> fichiersOuverts = [];

  /// Une application de lecture est installée (sinon : proposition de
  /// partager).
  bool lecteurInstalle = true;

  /// Fichiers renvoyés par « Ajouter des documents » (vide : annulé).
  List<FichierChoisi> fichiersChoisis = const [];

  final server = FakeServer();
  late final AppDatabase db;
  late final FakeRemote remote;
  late final FakeAuthApi auth;

  /// Dictée simulée (pas de micro dans les tests).
  final dictee = FakeDictee();

  /// PDF « imprimés » ou « partagés » (nom → contenu).
  final Map<String, Uint8List> pdfSortis = {};

  /// Image renvoyée par « Prendre / Choisir une photo » (null : annulé).
  Uint8List? imageChoisie;

  /// Fonctions du serveur pour le dossier médico-scolaire.
  final medical = FakeMedicalApi();

  /// Fichiers envoyés (Excel) : nom → contenu.
  final Map<String, Uint8List> fichiersSortis = {};

  /// Fichier renvoyé par « Choisir le fichier » (import Excel).
  Uint8List? fichierAImporter;

  /// Capteur d'empreinte du téléphone simulé (absent par défaut).
  BiometricGate biometrie = NoBiometricGate();
  final Directory mediaDir = Directory.systemTemp.createTempSync(
    'ecoleplus_media',
  );

  bool get online => remote.online;
  set online(bool v) {
    remote.online = v;
    auth.online = v;
    enLigne.enLigne = v;
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
    // Phase 2 : niveaux, un enseignant, deux classes, quatre élèves.
    const niveaux = [
      'PS',
      'MS',
      'GS',
      'CP1',
      'CP2',
      'CE1',
      'CE2',
      'CM1',
      'CM2',
    ];
    for (final (i, n) in niveaux.indexed) {
      server.seed('levels', {
        'code': n,
        'cycle': i < 3 ? 'maternelle' : 'primaire',
        'label': switch (n) {
          'PS' => 'Petite section',
          'MS' => 'Moyenne section',
          'GS' => 'Grande section',
          _ => n,
        },
        'sort_order': i + 1,
      });
    }
    server
      ..seed('teachers', {
        'id': 't-un',
        'school_id': ecoleId,
        'last_name': 'ENSEIGNANT',
        'first_names': 'Un',
        'sex': 'F',
        'status': 'actif',
        'seniority_general_from': '2008-10-01',
        'updated_at': ts,
      })
      ..seed('classes', {
        'id': 'c-cm1',
        'school_id': ecoleId,
        'school_year_id': anneeId,
        'level_code': 'CM1',
        'name': 'CM1 A',
        'main_teacher_id': 't-un',
        'updated_at': ts,
      })
      ..seed('classes', {
        'id': 'c-ce1',
        'school_id': ecoleId,
        'school_year_id': anneeId,
        'level_code': 'CE1',
        'name': 'CE1 A',
        'updated_at': ts,
      });
    for (final (i, (prenom, sexe, classe)) in [
      ('Aïcha', 'F', 'c-cm1'),
      ('Boukary', 'M', 'c-cm1'),
      ('Clarisse', 'F', 'c-cm1'),
      ('Daouda', 'M', 'c-ce1'),
    ].indexed) {
      server
        ..seed('students', {
          'id': 'e-$i',
          'school_id': ecoleId,
          'last_name': 'TEST',
          'first_names': prenom,
          'sex': sexe,
          'registry_number': i + 1,
          'student_code': 'EL-${i + 1}',
          'updated_at': ts,
        })
        ..seed('enrollments', {
          'id': 'i-$i',
          'school_id': ecoleId,
          'student_id': 'e-$i',
          'class_id': classe,
          'school_year_id': anneeId,
          'level_code': classe == 'c-cm1' ? 'CM1' : 'CE1',
          'starts_on': '2025-10-01',
          'is_repeat': false,
          'updated_at': ts,
        });
    }
    server.registryCounter = 4;
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
    // Écran haut (densité 2) : tout l’accueil visible sans défiler.
    tester.view
      ..physicalSize = const Size(720, 2600)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          syncRemoteProvider.overrideWithValue(remote as SyncRemote),
          authApiProvider.overrideWithValue(auth as AuthApi),
          mediaDirProvider.overrideWithValue(mediaDir),
          clockProvider.overrideWithValue(Clock()),
          syncSchedulerProvider.overrideWithValue(null),
          lockServiceProvider.overrideWithValue(
            LockService(db, iterations: 50),
          ),
          biometricGateProvider.overrideWithValue(biometrie),
          dicteeProvider.overrideWithValue(dictee),
          medicalApiProvider.overrideWithValue(medical),
          choisirImageProvider.overrideWithValue(
            ({required camera}) async => imageChoisie,
          ),
          sortiePdfProvider.overrideWithValue(
            SortiePdf(
              imprimer: (pdf, nom) async => pdfSortis[nom] = pdf,
              partager: (pdf, nom) async => pdfSortis['partage:$nom'] = pdf,
            ),
          ),
          sortieFichierProvider.overrideWithValue(
            (octets, nom, type) async => fichiersSortis[nom] = octets,
          ),
          documentsEnLigneProvider.overrideWithValue(enLigne),
          ouvrirFichierProvider.overrideWithValue((chemin, type) async {
            if (lecteurInstalle) fichiersOuverts.add(chemin);
            return lecteurInstalle;
          }),
          choisirFichiersProvider.overrideWithValue(
            () async => fichiersChoisis,
          ),
          choisirTableurProvider.overrideWithValue(
            () async => fichierAImporter,
          ),
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

  Future<void> login(
    WidgetTester tester,
    String login, {
    bool creerCode = true,
  }) async {
    await tester.tap(find.text('Se connecter'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('login')), login);
    await tester.enterText(
      find.byKey(const Key('password')),
      'motdepasse-test',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await settle(tester);
    if (creerCode && find.text('Code de verrouillage').evaluate().isNotEmpty) {
      await taperCode(tester, '4071');
      await taperCode(tester, '4071');
    }
  }

  /// Tape un code sur le clavier à gros chiffres puis « OK ».
  static Future<void> taperCode(WidgetTester tester, String code) async {
    for (final c in code.split('')) {
      await tester.tap(find.byKey(Key('pin-$c')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('pin-ok')));
    await settle(tester);
  }

  /// Lance une synchronisation (bandeau → « Synchroniser maintenant ») puis
  /// revient à l'écran précédent.
  Future<void> synchroniser(WidgetTester tester) async {
    await tester.tap(find.byType(SyncBanner).first);
    await settle(tester);
    await tester.tap(find.text('Synchroniser maintenant'));
    await settle(tester);
    await tester.tap(find.byTooltip('Retour').first);
    await settle(tester);
  }

  /// Touche un bouton de l'accueil, en faisant défiler si besoin.
  static Future<void> toucher(WidgetTester tester, String bouton) async {
    await tester.scrollUntilVisible(
      find.text(bouton),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(bouton));
    await tester.pump();
    await tester.tap(find.text(bouton));
  }

  /// Fait défiler l'accueil jusqu'au bouton, sans le toucher.
  static Future<void> toucherVisible(WidgetTester tester, String bouton) =>
      tester.scrollUntilVisible(
        find.text(bouton),
        200,
        scrollable: find.byType(Scrollable).first,
      );

  /// Ouvre un écran rangé dans « Mon école » (années, options, sauvegarde).
  static Future<void> ouvrirDansMonEcole(
    WidgetTester tester,
    String bouton,
  ) async {
    await tester.tap(find.text('Mon école'));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text(bouton),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(bouton));
    await tester.pump();
    await tester.tap(find.text(bouton));
    await settle(tester);
  }

  /// Ferme puis rouvre l'application (même base locale).
  Future<void> relancer(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await pump(tester);
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Laisse drift annuler ses requêtes « surveillées » avant la fermeture.
    await tester.pump(const Duration(seconds: 1));
    await db.close();
    await tester.pump(const Duration(seconds: 1));
  }
}

class FakeDictee implements Dictee {
  bool micro = true;
  String texte = '';
  String? erreur;
  int ecoutes = 0;

  @override
  Future<bool> preparer() async => micro;

  @override
  Future<void> ecouter({
    required void Function(String texte) surTexte,
    required void Function(String? erreur) surFin,
  }) async {
    ecoutes++;
    if (texte.isNotEmpty) surTexte(texte);
    surFin(erreur);
  }

  @override
  Future<void> arreter() async {}
}
