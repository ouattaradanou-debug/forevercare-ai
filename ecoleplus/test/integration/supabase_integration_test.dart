// Tests d'intégration contre le serveur Supabase LOCAL (supabase start,
// db reset, functions serve). Ignorés si SUPABASE_URL n'est pas défini.
//   SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_ANON_KEY=... \
//     flutter test test/integration
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/core/sync/supabase_sync_remote.dart';
import 'package:ecoleplus/core/sync/sync_engine.dart';
import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/auth/data/auth_service.dart';
import 'package:ecoleplus/features/auth/data/members_service.dart';
import 'package:ecoleplus/features/bibliotheque/data/bibliotheque_repository.dart';
import 'package:ecoleplus/features/bibliotheque/data/documents_en_ligne.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:ecoleplus/features/bulletins/data/bulletins_repository.dart';
import 'package:ecoleplus/features/documents/data/documents_repository.dart';
import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/finances/data/finances_repository.dart';
import 'package:ecoleplus/features/forms/data/fiche_scolarite_repository.dart';
import 'package:ecoleplus/features/grades/data/grades_repository.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/maternelle/data/maternelle_repository.dart';
import 'package:ecoleplus/features/medical/data/medical_api.dart';
import 'package:ecoleplus/features/medical/domain/fiche_medicale.dart';
import 'package:ecoleplus/features/photos/data/photos_repository.dart';
import 'package:ecoleplus/features/photos/domain/traitement_photo.dart';
import 'package:ecoleplus/features/programme/data/programme_repository.dart';
import 'package:ecoleplus/features/programme/domain/programme.dart';
import 'package:ecoleplus/features/school/data/school_repository.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

final String? url = Platform.environment['SUPABASE_URL'];
final String anonKey = Platform.environment['SUPABASE_ANON_KEY'] ?? '';
const ecoleTest = '10000000-0000-4000-8000-000000000001';
const motDePasse = 'motdepasse-test';

/// Réseau coupable à volonté (mode avion simulé).
class ToggleRemote implements SyncRemote {
  new(this.inner);
  final SyncRemote inner;
  bool online = true;

  Future<T> _go<T>(Future<T> Function() f) =>
      online ? f() : Future.error(const RemoteUnavailable('mode avion'));

  @override
  Future<DateTime> serverNow() => _go(inner.serverNow);
  @override
  Future<List<PushResult>> push(List<PushChange> c) => _go(() => inner.push(c));
  @override
  Future<List<Map<String, dynamic>>> pull(
    String table, {
    required String syncedAt,
    required String tie,
    required String tieColumn,
    required int limit,
  }) => _go(
    () => inner.pull(
      table,
      syncedAt: syncedAt,
      tie: tie,
      tieColumn: tieColumn,
      limit: limit,
    ),
  );
  @override
  Future<List<Map<String, dynamic>>> fetchAll(String t) =>
      _go(() => inner.fetchAll(t));
  @override
  Future<Set<String>> identifiants(String t) =>
      _go(() => inner.identifiants(t));
  @override
  Future<Map<String, dynamic>?> fetchRow(String t, Map<String, Object?> k) =>
      _go(() => inner.fetchRow(t, k));
  @override
  Future<void> upload(String b, String p, Uint8List d, String c) =>
      _go(() => inner.upload(b, p, d, c));
  @override
  Future<String> debutEnvoi(String b, String p, int t, String c) =>
      _go(() => inner.debutEnvoi(b, p, t, c));
  @override
  Future<int> positionEnvoi(String a) => _go(() => inner.positionEnvoi(a));

  /// Coupure du réseau après ce nombre de morceaux (null : jamais).
  int? couperApresMorceaux;
  int morceauxEnvoyes = 0;

  @override
  Future<int> envoyerMorceau(String a, int p, Uint8List o) {
    if (couperApresMorceaux != null &&
        morceauxEnvoyes >= couperApresMorceaux!) {
      online = false;
    }
    return _go(() async {
      final r = await inner.envoyerMorceau(a, p, o);
      morceauxEnvoyes++;
      return r;
    });
  }

  @override
  int get tailleMorceau => inner.tailleMorceau;
  @override
  Future<Uint8List> download(String b, String p) =>
      _go(() => inner.download(b, p));
  @override
  Future<bool> heartbeat(String d, int n, String v) =>
      _go(() => inner.heartbeat(d, n, v));
}

/// Un téléphone réel (client Supabase propre, base locale en mémoire).
class Phone {
  new({this.mediaDir}) {
    client = SupabaseClient(
      url!,
      anonKey,
      authOptions: const AuthClientOptions(
        autoRefreshToken: false,
        authFlowType: AuthFlowType.implicit,
      ),
    );
    db = AppDatabase(NativeDatabase.memory());
    store = LocalStore(db, Clock());
    remote = ToggleRemote(SupabaseSyncRemote(client));
    api = SupabaseAuthApi(client);
    engine = SyncEngine(
      store: store,
      remote: remote,
      mediaDir: mediaDir,
      onRevoked: () => effacerTelephoneDeconnecte(db, api),
    );
    auth = AuthService(api: api, store: store, engine: engine);
    repo = SchoolRepository(store, mediaDir: mediaDir);
  }

  final Directory? mediaDir;

  late final SupabaseClient client;
  late final AppDatabase db;
  late final LocalStore store;
  late final ToggleRemote remote;
  late final SyncEngine engine;
  late final SupabaseAuthApi api;
  late final AuthService auth;
  late final SchoolRepository repo;

  bool get online => remote.online;
  set online(bool v) => remote.online = v;

  Future<void> close() async {
    await db.close();
    await client.dispose();
  }
}

Future<Phone> connecte(
  String login, [
  String password = motDePasse,
  Directory? mediaDir,
]) async {
  final p = Phone(mediaDir: mediaDir);
  final r = await p.auth.login(login, password);
  expect(r, isA<LoggedIn>());
  expect(
    p.engine.state.phase,
    SyncPhase.idle,
    reason: '${p.engine.state.error}',
  );
  return p;
}

void main() {
  final skip = url == null ? 'SUPABASE_URL non défini (serveur local)' : null;
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  group('A6 et A5', mainA6);

  test('deux téléphones du directeur en mode avion : dernière modification '
      'gagne, trace côté serveur, aucun doublon', () async {
    final a = await connecte('directeur@ecole-test.local');
    final b = await connecte('directeur@ecole-test.local');
    final annee =
        (await a.db.select(a.db.schools).getSingle()).currentSchoolYearId!;
    final entete = await (a.db.select(
      a.db.adminHeaders,
    )..where((h) => h.schoolYearId.equals(annee))).getSingle();

    a.online = false;
    b.online = false;
    await a.repo.saveHeader(entete.id, {'ceb': 'CEB du téléphone A'});
    final current = await (a.db.select(
      a.db.schoolYears,
    )..where((y) => y.id.equals(annee))).getSingle();
    final nouvelle = await a.repo.prepareNextYear(ecoleTest, current);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await b.repo.saveHeader(entete.id, {'ceb': 'CEB du téléphone B'});
    expect(await a.store.pendingCount(), 3);
    expect((await a.engine.syncNow()).phase, SyncPhase.offline);

    b.online = true;
    await b.engine.syncNow();
    a.online = true;
    await a.engine.syncNow();
    await a.engine.syncNow(); // second passage : rien ne doit être dupliqué
    await b.engine.syncNow();

    final serveur = await a.client
        .from('admin_headers')
        .select()
        .eq('id', entete.id)
        .single();
    expect(serveur['ceb'], 'CEB du téléphone B');
    final traces = await a.client
        .from('sync_conflicts')
        .select()
        .eq('row_id', entete.id);
    expect(
      traces.any((t) => (t['loser'] as Map)['ceb'] == 'CEB du téléphone A'),
      isTrue,
    );
    final annees = await a.client
        .from('school_years')
        .select()
        .eq('school_id', ecoleTest)
        .eq('label', '2026-2027');
    expect(annees, hasLength(1));
    expect(annees.single['id'], nouvelle);
    for (final p in [a, b]) {
      final h = await p.store.read('admin_headers', {'id': entete.id});
      expect(h!['ceb'], 'CEB du téléphone B');
      expect(await p.store.pendingCount(), 0);
    }
    await a.close();
    await b.close();
  }, skip: skip);

  test('enseignant : ne reçoit que ses données ; une modification interdite '
      'est refusée avec un message clair', () async {
    final t = await connecte('enseignant1@ecole-test.local');
    expect(await t.db.select(t.db.memberships).get(), hasLength(1));
    expect(await t.db.select(t.db.schools).get(), hasLength(1));
    expect(await t.db.select(t.db.delegatePermissions).get(), isEmpty);

    await t.store.save('schools', {'id': ecoleTest, 'name': 'Piratée'});
    await t.store.save('school_modules', {
      'school_id': ecoleTest,
      'module_key': 'cantine',
      'enabled': true,
    });
    await t.engine.syncNow();

    final refus = await t.db.select(t.db.outbox).get();
    expect(refus.map((e) => e.status).toSet(), {'refuse'});
    expect(refus.first.message, contains('pas le droit'));
    expect(
      (await t.store.read('schools', {'id': ecoleTest}))!['name'],
      'École Test',
    );
    final cantine = await t.store.read('school_modules', {
      'school_id': ecoleTest,
      'module_key': 'cantine',
    });
    expect(cantine!['enabled'], isFalse);
    await t.close();
  }, skip: skip);

  test('une école ne reçoit jamais les données d’une autre école', () async {
    final d2 = await connecte('directeur@ecole-temoin.local');
    final ecoles = await d2.db.select(d2.db.schools).get();
    expect(ecoles.map((e) => e.name), ['École Témoin']);
    // Uniquement les comptes de l'École Témoin (un autre test peut y avoir
    // ajouté un enseignant).
    final membres = await d2.db.select(d2.db.memberships).get();
    expect(membres.map((m) => m.displayName), contains('Directeur Témoin'));
    expect(membres.map((m) => m.schoolId).toSet(), {
      '10000000-0000-4000-8000-000000000002',
    });
    expect(await d2.db.select(d2.db.adminHeaders).get(), isEmpty);
    await d2.close();
  }, skip: skip);

  test('options : OFF → ON → OFF depuis le téléphone du directeur', () async {
    final d = await connecte('directeur@ecole-test.local');
    Future<bool> serveur() async =>
        (await d.client
                .from('school_modules')
                .select('enabled')
                .eq('school_id', ecoleTest)
                .eq('module_key', 'cantine')
                .single())['enabled']
            as bool;

    expect(await serveur(), isFalse);
    await d.repo.setModule(ecoleTest, 'cantine', on: true);
    await d.engine.syncNow();
    expect(await serveur(), isTrue);
    await d.repo.setModule(ecoleTest, 'cantine', on: false);
    await d.engine.syncNow();
    expect(await serveur(), isFalse);
    expect(await d.store.pendingCount(), 0);
    await d.close();
  }, skip: skip);

  test('création d’une école par un nouveau directeur', () async {
    final p = Phone();
    final email = 'directrice${DateTime.now().millisecondsSinceEpoch}@neuve.bf';
    await p.auth.createSchool(
      NewSchool(
        directorName: 'Directrice Neuve',
        email: email,
        password: 'mot-de-passe-1',
        schoolName: 'École Neuve',
        yearLabel: '2026-2027',
        region: 'Région Neuve',
      ),
    );
    final session = await p.auth.session();
    expect(session!.role, 'directeur');
    expect(session.deviceSeries, 'A');
    final ecole = await p.db.select(p.db.schools).getSingle();
    expect(ecole.name, 'École Neuve');
    expect(await p.db.select(p.db.schoolYears).get(), hasLength(1));
    expect(await p.db.select(p.db.adminHeaders).get(), hasLength(1));
    expect(
      (await p.db.select(p.db.schoolModules).get()).where((m) => m.enabled),
      isEmpty,
    );
    await p.close();
  }, skip: skip);

  test('le directeur crée un compte (téléphone) ; l’enseignant se connecte ; '
      'le directeur réinitialise son mot de passe', () async {
    final d = await connecte('directeur@ecole-test.local');
    final members = MembersService(d.api, d.store);
    final numero = '7${DateTime.now().millisecondsSinceEpoch % 10000000}'
        .padRight(8, '0');
    final identifiant = await members.create(
      schoolId: ecoleTest,
      displayName: 'Nouvel Enseignant',
      role: 'enseignant',
      login: numero,
      password: 'provisoire-1',
    );
    expect(identifiant, endsWith('@tel.ecoleplus.invalid'));

    final e = await connecte(numero, 'provisoire-1');
    expect((await e.auth.session())!.role, 'enseignant');
    final m = (await e.auth.session())!.membershipId;
    await members.resetPassword(m, 'nouveau-mdp-2');
    await e.close();
    final e2 = await connecte(numero, 'nouveau-mdp-2');
    await e2.close();
    await d.close();
  }, skip: skip);

  test(
    'mot de passe oublié : code reçu par e-mail puis nouveau mot de passe',
    () async {
      final p = Phone();
      await p.auth.sendRecoveryCode('secretaire@ecole-test.local');
      final code = await _dernierCode('secretaire@ecole-test.local');
      await p.auth.confirmRecovery(
        'secretaire@ecole-test.local',
        code,
        'nouveau-secret-1',
      );
      expect((await p.auth.session())!.role, 'delegue');
      await p.close();
      final p2 = await connecte(
        'secretaire@ecole-test.local',
        'nouveau-secret-1',
      );
      expect(await p2.db.select(p2.db.delegatePermissions).get(), hasLength(1));
      await p2.close();
    },
    skip: skip,
  );
}

void mainA6() {
  final skip = url == null ? 'SUPABASE_URL non défini (serveur local)' : null;

  test('nouveau téléphone du directeur : il retrouve toutes les données, '
      'y compris l’image d’en-tête', () async {
    final dirA = Directory.systemTemp.createTempSync('telA');
    final dirB = Directory.systemTemp.createTempSync('telB');
    final a = await connecte('directeur@ecole-test.local', motDePasse, dirA);
    final annee =
        (await a.db.select(a.db.schools).getSingle()).currentSchoolYearId!;
    final entete = await (a.db.select(
      a.db.adminHeaders,
    )..where((h) => h.schoolYearId.equals(annee))).getSingle();
    final image = File('${dirA.path}/embleme.png')
      ..writeAsBytesSync(List.generate(2000, (i) => i % 256));
    await a.repo.setEmblem(entete, image);
    await a.repo.updateSchool(ecoleTest, {'commune': 'Commune du téléphone A'});
    await a.engine.syncNow();
    expect(await a.db.select(a.db.fileUploads).get(), isEmpty);

    // L'ancien téléphone est perdu : on se connecte sur un téléphone neuf.
    final b = await connecte('directeur@ecole-test.local', motDePasse, dirB);
    expect(
      (await b.store.read('schools', {'id': ecoleTest}))!['commune'],
      'Commune du téléphone A',
    );
    expect(await b.db.select(b.db.schoolYears).get(), isNotEmpty);
    expect(
      await b.db.select(b.db.memberships).get(),
      hasLength(greaterThan(3)),
    );
    final copie = File('${dirB.path}/$ecoleTest/entetes/${entete.id}.png');
    expect(copie.existsSync(), isTrue, reason: 'image téléchargée');
    expect(copie.readAsBytesSync(), image.readAsBytesSync());
    await a.close();
    await b.close();
  }, skip: skip);

  test('téléphone perdu : le directeur le déconnecte, ses données sont '
      'effacées au retour du réseau', () async {
    final t = await connecte('enseignant2@ecole-test.local');
    final idPerdu = (await t.auth.session())!.deviceId;
    expect(await t.db.select(t.db.schools).get(), hasLength(1));

    final d = await connecte('directeur@ecole-test.local');
    await d.engine.syncNow();
    expect(
      await d.store.read('devices', {'id': idPerdu}),
      isNotNull,
      reason: 'le directeur voit le téléphone',
    );
    await d.api.revokeDevice(idPerdu);

    final etat = await t.engine.syncNow();
    expect(etat.phase, SyncPhase.revoked);
    expect(await t.db.select(t.db.schools).get(), isEmpty);
    expect(await t.db.select(t.db.localSession).get(), isEmpty);
    final identite = await t.db.select(t.db.deviceIdentity).getSingle();
    expect(identite.deviceId, isNot(idPerdu));
    expect(identite.notice, contains('déconnecté par le directeur'));

    // La personne se reconnecte (nouveau téléphone ou téléphone retrouvé).
    final r = await t.auth.login('enseignant2@ecole-test.local', motDePasse);
    expect(r, isA<LoggedIn>());
    expect(await t.db.select(t.db.schools).get(), hasLength(1));
    await d.engine.syncNow();
    final journal = await d.db.select(d.db.auditLog).get();
    expect(journal.map((j) => j.action), contains('deconnexion_telephone'));
    await t.close();
    await d.close();
  }, skip: skip);

  test('question secrète : mot de passe changé sans le directeur, qui en est '
      'informé dans son journal', () async {
    final s = await connecte('secretaire@ecole-test.local');
    expect(await s.api.hasRecoveryQuestion(), isFalse);
    await s.api.setRecoveryQuestion('Mon premier élève ?', 'Éléonore');
    expect(await s.api.hasRecoveryQuestion(), isTrue);
    await s.close();

    final nouveau = Phone();
    expect(
      await nouveau.auth.recoveryQuestion('secretaire@ecole-test.local'),
      'Mon premier élève ?',
    );
    await expectLater(
      nouveau.auth.recoverWithAnswer(
        'secretaire@ecole-test.local',
        'mauvaise',
        'nouveau-mdp-9',
      ),
      throwsA(isA<UserMessage>()),
    );
    await nouveau.auth.recoverWithAnswer(
      'secretaire@ecole-test.local',
      ' ELEONORE ',
      'nouveau-mdp-9',
    );
    expect((await nouveau.auth.session())!.role, 'delegue');
    await nouveau.close();

    final d = await connecte('directeur@ecole-test.local');
    final journal = await d.db.select(d.db.auditLog).get();
    expect(journal.map((j) => j.action), contains('recuperation_mot_de_passe'));
    await d.close();
  }, skip: skip);

  test('A11 : le directeur enregistre son numéro, puis se connecte avec ; '
      'un mauvais mot de passe ne révèle rien', () async {
    final d = await connecte('directeur@ecole-temoin.local');
    final members = MembersService(d.api, d.store);
    await members.create(
      schoolId: '10000000-0000-4000-8000-000000000002',
      displayName: 'Enseignant Témoin',
      role: 'enseignant',
      login: '70561748',
      password: 'provisoire-1',
    );
    await expectLater(
      d.auth.setLoginPhone('70 56 17 48'),
      throwsA(isA<UserMessage>()),
      reason: 'numéro déjà identifiant d’un enseignant',
    );
    await d.auth.setLoginPhone('70 56 17 49');
    expect(await d.auth.loginPhone(), '22670561749');
    await expectLater(
      members.create(
        schoolId: '10000000-0000-4000-8000-000000000002',
        displayName: 'Autre',
        role: 'enseignant',
        login: '70561749',
        password: 'provisoire-1',
      ),
      throwsA(isA<UserMessage>()),
      reason: 'numéro déjà pris par le directeur',
    );
    await d.close();

    final faux = Phone();
    await expectLater(
      faux.auth.login('70561749', 'pas-le-bon-mdp'),
      throwsA(
        isA<UserMessage>().having(
          (e) => e.message,
          'message',
          allOf(contains('incorrect'), isNot(contains('temoin'))),
        ),
      ),
    );
    await faux.close();

    final p = await connecte('+226 70 56 17 49');
    expect((await p.auth.session())!.login, 'directeur@ecole-temoin.local');
    expect((await p.auth.session())!.role, 'directeur');
    final journal = await p.db.select(p.db.auditLog).get();
    expect(journal.map((j) => j.action), contains('connexion_par_numero'));
    await p.auth.setLoginPhone('');
    expect(await p.auth.loginPhone(), isNull);
    await p.close();
  }, skip: skip);

  test('phase 2 : deux téléphones hors ligne inscrivent chacun un élève ; '
      'numéros d’ordre uniques et à la suite ; l’enseignant ne reçoit '
      'jamais le registre', () async {
    final a = await connecte('directeur@ecole-test.local');
    final b = await connecte('directeur@ecole-test.local');
    a.online = false;
    b.online = false;
    final repoA = StudentsRepository(a.store);
    final repoB = StudentsRepository(b.store);
    final classe = await (a.db.select(
      a.db.classes,
    )..where((c) => c.name.equals('CE1 A'))).getSingle();
    final idA = await repoA.creer(
      schoolId: ecoleTest,
      lastName: 'hors ligne',
      firstNames: 'Téléphone A',
      classe: classe,
    );
    final idB = await repoB.creer(
      schoolId: ecoleTest,
      lastName: 'hors ligne',
      firstNames: 'Téléphone B',
      classe: classe,
    );
    await repoA.modifierRegistre(idA, ecoleTest, {
      'origin_school': 'École Lointaine',
    });
    final provisoire = await (a.db.select(
      a.db.students,
    )..where((s) => s.id.equals(idA))).getSingle();
    expect(provisoire.registryNumber, isNull);
    expect(provisoire.registryProvisional, startsWith('P-'));

    a.online = true;
    b.online = true;
    await a.engine.syncNow();
    await b.engine.syncNow();
    await a.engine.syncNow();
    final numeros = [
      for (final id in [idA, idB])
        (await (a.db.select(
          a.db.students,
        )..where((s) => s.id.equals(id))).getSingle()).registryNumber,
    ];
    expect(numeros.whereType<int>().length, 2);
    expect(numeros.toSet().length, 2, reason: 'jamais le même numéro');
    expect((numeros[0]! - numeros[1]!).abs(), 1, reason: 'à la suite');

    // L'enseignante du CM1 ne reçoit ni le registre ni les élèves du CE1.
    final e = await connecte('enseignant1@ecole-test.local');
    expect(await e.db.select(e.db.studentRegistry).get(), isEmpty);
    final siens = await e.db.select(e.db.students).get();
    expect(siens.map((s) => s.id), isNot(contains(idA)));
    expect(await e.db.select(e.db.officialForms).get(), isEmpty);
    await e.close();
    await a.close();
    await b.close();
  }, skip: skip);

  test(
    'identifiant d’élève en double (deux téléphones) : refus expliqué, '
    'avec l’élève concerné ; la fiche reprend la valeur du serveur',
    () async {
      final a = await connecte('directeur@ecole-test.local');
      final repo = StudentsRepository(a.store);
      final eleves =
          await (a.db.select(a.db.students)
                ..where((s) => s.schoolId.equals(ecoleTest))
                ..orderBy([(s) => OrderingTerm.asc(s.registryNumber)]))
              .get();
      final premier = eleves[0];
      final second = eleves[1];
      // Saisie faite ailleurs (sans la vérification de l'écran).
      await repo.modifier(second.id, {'student_code': premier.studentCode});
      await a.engine.syncNow();
      final refus = await (a.db.select(
        a.db.outbox,
      )..where((o) => o.status.equals('refuse'))).getSingle();
      expect(
        refus.message,
        'Élève ${second.lastName} ${second.firstNames} — Modification '
        'refusée : cet identifiant d’élève est déjà utilisé par un autre '
        'élève. Choisissez-en un autre sur la fiche.',
      );
      final apres = await (a.db.select(
        a.db.students,
      )..where((s) => s.id.equals(second.id))).getSingle();
      expect(apres.studentCode, second.studentCode);
      // Les autres modifications de la fiche passent normalement.
      await (a.db.delete(
        a.db.outbox,
      )..where((o) => o.status.equals('refuse'))).go();
      await repo.modifier(second.id, {'birth_place': 'Dapelogo'});
      await a.engine.syncNow();
      expect(
        await (a.db.select(
          a.db.outbox,
        )..where((o) => o.status.equals('refuse'))).get(),
        isEmpty,
      );
      await a.close();
    },
    skip: skip,
  );

  test('phase 3 : le cas calculé à la main du jeu de test (CM1, '
      'composition 1) ; l’enseignante note sa classe et seulement elle ; '
      'note hors barème refusée par le serveur ; résultats annuels', () async {
    const cm1 = 'c0000000-0000-4000-8000-000000000002';
    const cm2Compo = 'f0000000-0000-4000-8000-000000000002';
    const cm2Eleve = 'd0000000-0000-4000-8000-000000000006';
    final dir = await connecte('directeur@ecole-test.local');
    final repo = GradesRepository(dir.store);
    var d = (await repo.chargerDonnees(cm1))!;
    var c = d.trimestre(1); // « Composition 1 » du jeu de test = 1er trimestre
    String ligne(Resultat r) =>
        '${r.eleve.nom} ${r.rangTexte} ${centiemesTexte(r.moyenne)} '
        '${centiemesTexte(r.total)}';
    // Histoire sans note ignorée ; Dessin à coefficient 0 sans effet ;
    // absence de Daouda en Calcul non comptée (règle par défaut).
    expect(c.resultats.map(ligne), [
      'TEST Aïcha 1re 7 21',
      'TEST Boukary 2e ex-aequo 6 18',
      'TEST Clarisse 2e ex-aequo 6 18',
      'TEST Daouda 4e 5,5 11',
    ]);
    expect(c.statistiques.moyenneClasse, 613); // (7+6+6+5,5)/4 = 6,125

    // L'enseignante du CM1 corrige une note de sa classe : acceptée.
    final ens = await connecte('enseignant1@ecole-test.local');
    final repoE = GradesRepository(ens.store);
    final dE = (await repoE.chargerDonnees(cm1))!;
    final compo = dE.compositions.single;
    final clarisse = dE.eleves.firstWhere((e) => e.firstNames == 'Clarisse');
    final calcul = dE.matieres.firstWhere((m) => m.matiere.name == 'Calcul');
    await repoE.enregistrerNote(
      composition: compo,
      studentId: clarisse.id,
      subjectId: calcul.matiere.id,
      centiemes: 800,
    );
    // Une note du CM2 (pas sa classe), écrite sans passer par l'écran.
    await ens.store.save('grades', {
      'id': GradesRepository.idNote(cm2Compo, cm2Eleve, calcul.matiere.id),
      'school_id': ecoleTest,
      'assessment_id': cm2Compo,
      'student_id': cm2Eleve,
      'subject_id': calcul.matiere.id,
      'score': 10,
      'status': 'note',
    });
    // Une note hors barème (12 sur 10), écrite sans passer par l'écran.
    await ens.store.save('grades', {
      'id': GradesRepository.idNote(compo.id, clarisse.id, 'hors'),
      'school_id': ecoleTest,
      'assessment_id': compo.id,
      'student_id': clarisse.id,
      'subject_id': dE.matieres
          .firstWhere((m) => m.matiere.name == 'Lecture')
          .matiere
          .id,
      'score': 12,
      'status': 'note',
    });
    await ens.engine.syncNow();
    final refus = await (ens.db.select(
      ens.db.outbox,
    )..where((o) => o.status.equals('refuse'))).get();
    expect(refus, hasLength(2), reason: refus.map((r) => r.message).join());
    expect(
      refus.map((r) => r.message).join(' | '),
      contains('Note hors barème : 12 sur 10.'),
    );

    // Le directeur reçoit la correction : Clarisse passe 1re ex-aequo.
    await dir.engine.syncNow();
    d = (await repo.chargerDonnees(cm1))!;
    c = d.trimestre(1);
    expect(c.resultats.map(ligne).take(2), [
      'TEST Aïcha 1re ex-aequo 7 21',
      'TEST Clarisse 1re ex-aequo 7 21',
    ]);

    // Coefficient d'une matière créée ailleurs (jeu de test) : modifié,
    // sans doublon.
    await repo.definirCoefficient(d.classe, calcul.matiere.id, 2);
    await dir.engine.syncNow();
    expect(
      await (dir.db.select(
        dir.db.outbox,
      )..where((o) => o.status.equals('refuse'))).get(),
      isEmpty,
    );
    d = (await repo.chargerDonnees(cm1))!;
    expect(
      d.matieres.firstWhere((m) => m.matiere.name == 'Calcul').lien.coefficient,
      2,
    );

    // Pas encore de moyenne annuelle : seul le 1er trimestre est noté.
    expect(d.annee().statistiques.classes, 0);

    // 2e et 3e trimestres saisis par l'enseignante (épreuves créées sur son
    // téléphone) : Lecture 7 pour tous.
    final lecture = dE.matieres.firstWhere((m) => m.matiere.name == 'Lecture');
    for (final t in const [2, 3]) {
      final dT = (await repoE.chargerDonnees(cm1))!;
      final epreuves = await repoE.preparerTrimestre(dT, t);
      for (final e in dT.eleves) {
        await repoE.enregistrerNote(
          composition: epreuves.single,
          studentId: e.id,
          subjectId: lecture.matiere.id,
          centiemes: 700,
        );
      }
    }
    await ens.engine.syncNow();
    expect(
      await (ens.db.select(
        ens.db.outbox,
      )..where((o) => o.status.equals('refuse'))).get(),
      hasLength(2),
      reason: 'seulement les deux refus voulus plus haut',
    );
    await dir.engine.syncNow();
    d = (await repo.chargerDonnees(cm1))!;

    // Résultats annuels gardés (directeur) : (T1 + T2 + T3) ÷ 3.
    final n = await repo.enregistrerResultatsAnnuels(
      d,
      d.annee(),
      date: '2026-06-30',
    );
    expect(n, 4);
    await dir.engine.syncNow();
    final serveur = await dir.client
        .from('annual_results')
        .select('student_id, general_average, rank, rank_ex_aequo, class_size')
        .eq('class_id', cm1);
    expect(serveur, hasLength(4));
    final aicha = serveur.firstWhere(
      (r) => r['student_id'] == 'd0000000-0000-4000-8000-000000000001',
    );
    // 1er trimestre avec Calcul coefficient 2 : Aïcha (8+14+6)/4 = 7 ;
    // Clarisse (7+16+6)/4 = 7,25. Année : Aïcha (7+7+7)/3 = 7 ; Clarisse
    // (7,25+7+7)/3 = 7,08 → Clarisse 1re, Aïcha 2e.
    expect(aicha['rank'], 2);
    expect(aicha['general_average'], 7);
    expect(aicha['class_size'], 4);
    await ens.engine.syncNow();
    expect(
      await (ens.db.select(
        ens.db.annualResults,
      )..where((r) => r.classId.equals(cm1))).get(),
      hasLength(4),
      reason: 'l’enseignante lit les résultats de ses élèves',
    );
    await ens.close();
    await dir.close();
  }, skip: skip);

  test('phase 4 : appréciation de l’enseignante, observation et décision du '
      'directeur (la décision de l’enseignante est ignorée) ; bulletin avec '
      'rang ; fiche de scolarité « 7e/39 » et copie conforme journalisée, '
      'refusée à l’enseignante', () async {
    const cm1 = 'c0000000-0000-4000-8000-000000000002';
    const fatou = 'd0000000-0000-4000-8000-000000000005';
    final ens = await connecte('enseignant1@ecole-test.local');
    final dir = await connecte('directeur@ecole-test.local');
    final gE = GradesRepository(ens.store);
    final bE = BulletinsRepository(ens.store, gE);
    final dE = (await gE.chargerDonnees(cm1))!;
    final clarisse = dE.eleves.firstWhere((e) => e.firstNames == 'Clarisse');
    await bE.enregistrerCarte(dE, clarisse.id, 1, {
      'teacher_appreciation': 'Peut mieux faire',
      'decision': 'Redouble',
    });
    await ens.engine.syncNow();
    Future<List<OutboxEntry>> refus(Phone p) => (p.db.select(
      p.db.outbox,
    )..where((o) => o.status.equals('refuse'))).get();
    expect(await refus(ens), isEmpty);

    final gD = GradesRepository(dir.store);
    final bD = BulletinsRepository(dir.store, gD);
    await dir.engine.syncNow();
    var dD = (await gD.chargerDonnees(cm1))!;
    var carte = (await bD.watchCartes(cm1).first).single;
    expect(carte.teacherAppreciation, 'Peut mieux faire');
    expect(carte.decision, isNull, reason: 'décision réservée au directeur');
    await bD.enregistrerCarte(dD, clarisse.id, 1, {
      'director_observation': 'Élève sérieuse',
    });
    await dir.engine.syncNow();
    expect(await refus(dir), isEmpty);
    await ens.engine.syncNow();
    carte = (await bE.watchCartes(cm1).first).single;
    expect(carte.directorObservation, 'Élève sérieuse');

    // Bulletin du 1er trimestre : même rang que le classement en direct
    // (les notes ont pu être corrigées par le test de la phase 3).
    dD = (await gD.chargerDonnees(cm1))!;
    final b = (await bD.bulletins(dD, 1, eleve: clarisse.id)).single;
    final r = dD
        .trimestre(1)
        .resultats
        .firstWhere((x) => x.eleve.id == clarisse.id);
    expect(b.rang, '${r.rangTexte}/4');
    expect(b.statistiques.effectif, 4);
    expect(b.appreciation, 'Peut mieux faire');
    expect(b.observation, 'Élève sérieuse');

    // Fiche de scolarité de Fatou : CM1 l'an passé, 7e/39.
    final fD = FicheScolariteRepository(dir.store, gD);
    final f = (await fD.fiche(fatou, copieConforme: true))!;
    expect(f.cours[('CM1', 1)]!.classement, '7e/39');
    expect(f.cours[('CM1', 1)]!.moyenneTexte, '7,25');
    await fD.journaliser(ecoleTest, fatou, copieConforme: true);
    await dir.engine.syncNow();
    expect(await refus(dir), isEmpty);
    final copies = await dir.client
        .from('scolarity_copy_log')
        .select('is_certified_copy')
        .eq('student_id', fatou);
    expect(copies, [
      {'is_certified_copy': true},
    ]);
    final journal = await dir.client
        .from('audit_log')
        .select('action')
        .eq('table_name', 'scolarity_copy_log');
    expect(journal, hasLength(1));

    // L'enseignante ne peut pas générer de fiche de scolarité.
    await FicheScolariteRepository(
      ens.store,
      gE,
    ).journaliser(ecoleTest, clarisse.id, copieConforme: false);
    await ens.engine.syncNow();
    expect(await refus(ens), hasLength(1));
    await ens.close();
    await dir.close();
  }, skip: skip);

  test('A17 : documents du directeur préremplis, délivrés et journalisés ; '
      'refusés à l’enseignante', () async {
    const fatou = 'd0000000-0000-4000-8000-000000000005';
    final dir = await connecte('directeur@ecole-test.local');
    await dir.store.save('schools', {
      'id': ecoleTest,
      'director_civility': 'madame',
      'director_grade': 'Professeur Certifié des Écoles',
    });
    final repo = DocumentsRepository(dir.store);
    final d = (await repo.document(
      CodeDocument.certificatScolarite,
      ecoleTest,
      fatou,
    ))!;
    expect(d.eleve!.nom, 'TEST Fatou');
    expect(d.eleve!.accords.inscrit, 'inscrite');
    expect(d.signataire.titreSignature, 'La Directrice');
    await repo.journaliser(CodeDocument.certificatScolarite, ecoleTest, fatou);
    await dir.engine.syncNow();
    Future<List<OutboxEntry>> refus(Phone p) => (p.db.select(
      p.db.outbox,
    )..where((o) => o.status.equals('refuse'))).get();
    expect(await refus(dir), isEmpty);
    final serveur = await dir.client
        .from('issued_documents')
        .select('doc_code')
        .eq('student_id', fatou);
    expect(serveur, [
      {'doc_code': 'certificat_scolarite'},
    ]);

    final ens = await connecte('enseignant1@ecole-test.local');
    await DocumentsRepository(ens.store)
        .journaliser(CodeDocument.attestationNiveau, ecoleTest, fatou);
    await ens.engine.syncNow();
    expect(await refus(ens), hasLength(1));
    await ens.close();
    await dir.close();
  }, skip: skip);

  test('phase 5 : programme saisi au téléphone, version finale verrouillée '
      'au serveur ; le bilan reste modifiable ; « Modifier » rouvre ; '
      'l’enseignante ne voit rien', () async {
    final dir = await connecte('directeur@ecole-test.local');
    final ecole = await (dir.db.select(
      dir.db.schools,
    )..where((s) => s.id.equals(ecoleTest))).getSingle();
    final annee = ecole.currentSchoolYearId!;
    final repo = ProgrammeRepository(dir.store);
    // L'objectif du jeu de test arrive avec ses deux activités.
    expect(
      (await repo.watchObjectifs(annee).first).single.activites,
      hasLength(2),
    );
    final o = await repo.ajouterObjectif(ecoleTest, annee, 'Gérer le courrier');
    final a = await repo.ajouterActivite(ecoleTest, o, 'Classer le courrier');
    await repo.modifierActivite(a, {'expected_result': 'Courrier classé'});
    final n = await repo.validerVersionFinale(
      FormulaireActivites.programme,
      ecole,
      annee,
    );
    expect(n, 1);
    await dir.engine.syncNow();
    Future<List<OutboxEntry>> refus(Phone p) => (p.db.select(
      p.db.outbox,
    )..where((o) => o.status.equals('refuse'))).get();
    expect(await refus(dir), isEmpty);
    final versions = await dir.client
        .from('form_versions')
        .select('version_no, is_final, snapshot');
    expect(versions, hasLength(1));
    expect(versions.single['snapshot'], isA<Map<String, dynamic>>());
    expect(
      (versions.single['snapshot'] as Map)['objectifs'] as List,
      hasLength(2),
    );

    // Verrou : un changement du programme est refusé par le serveur…
    await repo.modifierActivite(a, {'expected_result': 'Autre chose'});
    await dir.engine.syncNow();
    expect(await refus(dir), hasLength(1));
    // … mais le bilan se remplit.
    await repo.modifierActivite(a, {
      'achieved_result': 'Tout est classé',
      'success_rate': 90,
    });
    await dir.engine.syncNow();
    expect(await refus(dir), hasLength(1));
    final ligne = await dir.client
        .from('activity_lines')
        .select('expected_result, success_rate')
        .eq('id', a)
        .single();
    expect(ligne['expected_result'], 'Courrier classé');
    expect(ligne['success_rate'], 90);

    // « Modifier » : verrou levé, la version 1 reste.
    await repo.deverrouiller(ecoleTest, annee, 'B6');
    await repo.modifierActivite(a, {
      'expected_result': 'Courrier classé chaque semaine',
    });
    await dir.engine.syncNow();
    final apres = await dir.client
        .from('activity_lines')
        .select('expected_result')
        .eq('id', a)
        .single();
    expect(apres['expected_result'], 'Courrier classé chaque semaine');
    expect(await dir.client.from('form_versions').select('id'), hasLength(1));

    final ens = await connecte('enseignant1@ecole-test.local');
    expect(await ens.db.select(ens.db.activityLines).get(), isEmpty);
    await ens.close();
    await dir.close();
  }, skip: skip);

  test('phase 6 : une école active la maternelle, l’autre ne voit rien '
      'changer ; l’enseignante de la grande section évalue et fait l’appel, '
      'pas l’autre ; désactivée, tout disparaît sans rien effacer', () async {
    const temoin = '10000000-0000-4000-8000-000000000002';
    Future<(int, int, int)> comptes(Phone p) async => (
      (await p.db.select(p.db.classes).get()).length,
      (await p.db.select(p.db.students).get()).length,
      (await p.db.select(p.db.enrollments).get()).length,
    );
    Future<List<OutboxEntry>> refus(Phone p) => (p.db.select(
      p.db.outbox,
    )..where((o) => o.status.equals('refuse'))).get();

    final dir = await connecte('directeur@ecole-test.local');
    final avant = await comptes(dir);

    // L'École Témoin active la maternelle et ouvre une grande section.
    final t = await connecte('directeur@ecole-temoin.local');
    await t.repo.setModule(temoin, 'maternelle', on: true);
    await MaternelleRepository(t.store).assurerParDefaut(temoin);
    await t.store.save('classes', {
      'id': 'c2000000-0000-4000-8000-000000000001',
      'school_id': temoin,
      'school_year_id': '20000000-0000-4000-8000-000000009025',
      'level_code': 'GS',
      'name': 'GS Témoin',
    });
    await t.engine.syncNow();
    expect(await refus(t), isEmpty);

    // L'École Test (primaire seule) : exactement les mêmes effectifs.
    await dir.engine.syncNow();
    expect(await comptes(dir), avant);
    expect(await dir.db.select(dir.db.learningDomains).get(), isEmpty);

    // L'École Test active à son tour la maternelle.
    final m = MaternelleRepository(dir.store);
    await dir.repo.setModule(ecoleTest, 'maternelle', on: true);
    await m.assurerParDefaut(ecoleTest);
    const gs = 'c2000000-0000-4000-8000-000000000002';
    await dir.store.save('classes', {
      'id': gs,
      'school_id': ecoleTest,
      'school_year_id': '20000000-0000-4000-8000-000000002025',
      'level_code': 'GS',
      'name': 'GS A',
      'main_teacher_id': 'b0000000-0000-4000-8000-000000000002',
    });
    await dir.engine.syncNow();
    expect(await refus(dir), isEmpty);
    expect(
      await dir.client.from('learning_domains').select('id'),
      hasLength(6),
      reason: 'seulement ceux de l’École Test',
    );

    // Enseignante de la grande section : évaluation, livret, appel.
    final ens2 = await connecte('enseignant2@ecole-test.local');
    final classe = (await MaternelleRepository(ens2.store).classe(gs))!;
    final me = MaternelleRepository(ens2.store);
    final periode = await me.assurerTrimestre(classe, 1);
    final niveaux = await me.watchNiveaux(ecoleTest).first;
    final domaines = await me.watchDomaines(ecoleTest).first;
    expect((niveaux.length, domaines.length), (3, 6));
    const enfant = 'd0000000-0000-4000-8000-000000000012';
    await me.evaluer(
      schoolId: ecoleTest,
      periodId: periode,
      studentId: enfant,
      domainId: domaines.first.id,
      levelId: niveaux.first.id,
    );
    await me.enregistrerLivret(ecoleTest, periode, enfant, {
      'teacher_appreciation': 'Bon début',
      'observation': 'ignorée',
    });
    await me.marquer(classe, enfant, '2025-11-03', 'absent');
    await ens2.engine.syncNow();
    expect(await refus(ens2), isEmpty);
    final livret = await dir.client
        .from('preschool_booklets')
        .select('teacher_appreciation, observation')
        .single();
    expect(livret, {'teacher_appreciation': 'Bon début', 'observation': null});

    // L'autre enseignante : refusé.
    final ens1 = await connecte('enseignant1@ecole-test.local');
    final m1 = MaternelleRepository(ens1.store);
    await m1.evaluer(
      schoolId: ecoleTest,
      periodId: periode,
      studentId: enfant,
      domainId: domaines.last.id,
      levelId: niveaux.first.id,
    );
    await ens1.engine.syncNow();
    expect(await refus(ens1), hasLength(1));

    // Désactivation : invisible, mais conservé.
    await dir.repo.setModule(ecoleTest, 'maternelle', on: false);
    await t.repo.setModule(temoin, 'maternelle', on: false);
    await dir.engine.syncNow();
    await t.engine.syncNow();
    expect(
      await dir.client.from('preschool_evaluations').select('id'),
      isEmpty,
    );
    expect(await dir.client.from('classes').select('id').eq('id', gs), isEmpty);
    await ens1.close();
    await ens2.close();
    await t.close();
    await dir.close();
  }, skip: skip);

  test('phase 7 : dossier médico-scolaire par les fonctions du serveur ; '
      'refus journalisés ; seule l’aptitude exposée atteint l’enseignante ; '
      'rien sur le téléphone', () async {
    const aicha = 'd0000000-0000-4000-8000-000000000001';
    const cm1 = 'c0000000-0000-4000-8000-000000000002';
    const annee = '20000000-0000-4000-8000-000000002025';
    final dir = await connecte('directeur@ecole-test.local');
    final api = SupabaseMedicalApi(dir.client);

    // Module désactivé : refus, même au directeur.
    await expectLater(api.lire(aicha), throwsA(isA<UserMessage>()));

    await dir.repo.setModule(ecoleTest, 'medico_scolaire', on: true);
    await dir.engine.syncNow();
    await api.enregistrer(
      aicha,
      fiche: {'groupe_sanguin_rhesus': 'O+', 'vacc_bcg': '2017'},
      examens: [
        ExamenAnnuel('2025-2026', {'poids': '24 kg'}),
      ],
      aptitude: {
        'school_year_id': annee,
        'aptitude': 'a_surveiller',
        'expose_to_teacher': true,
      },
    );
    final d = await api.lire(aicha);
    expect(d.fiche['groupe_sanguin_rhesus'], 'O+');
    expect(d.examens.single.valeurs['poids'], '24 kg');
    expect(d.aptitudesParAnnee.single.exposee, isTrue);
    await api.noterImpression(aicha);

    final ens = await connecte('enseignant1@ecole-test.local');
    final apiEns = SupabaseMedicalApi(ens.client);
    await expectLater(apiEns.lire(aicha), throwsA(isA<UserMessage>()));
    expect(await apiEns.aptitudesDeLaClasse(cm1), {aicha: 'a_surveiller'});
    expect(await apiEns.journal(ecoleTest), isEmpty);

    final journal = await api.journal(ecoleTest);
    expect(
      journal.where((l) => !l.autorise && l.eleve == 'TEST Aïcha'),
      hasLength(2),
      reason: 'directeur module désactivé, puis enseignante',
    );
    expect(
      journal.map((l) => l.action),
      containsAll(['consultation', 'modification', 'impression']),
    );

    // Rien sur les téléphones.
    for (final p in [dir, ens]) {
      final tables = await p.db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      for (final t in tables) {
        final nom = t.read<String>('name');
        final lignes = await p.db.customSelect('SELECT * FROM "$nom"').get();
        expect(
          lignes.any((l) => l.data.values.any((v) => '$v' == 'O+')),
          isFalse,
          reason: nom,
        );
      }
    }
    await dir.repo.setModule(ecoleTest, 'medico_scolaire', on: false);
    await dir.engine.syncNow();
    await ens.close();
    await dir.close();
  }, skip: skip);

  test(
    'phase 10 : encaissements hors ligne sur deux téléphones (directeur '
    'et secrétaire) : numéros uniques, aucun doublon ; reçu inaltérable ; '
    'justificatif privé ; enseignant sans aucune donnée financière',
    () async {
      final tmp = Directory.systemTemp.createTempSync('finances');
      final dir = await connecte(
        'directeur@ecole-test.local',
        motDePasse,
        Directory('${tmp.path}/dir')..createSync(),
      );
      final sec = await connecte(
        'secretaire@ecole-test.local',
        motDePasse,
        Directory('${tmp.path}/sec')..createSync(),
      );
      const ecole = '10000000-0000-4000-8000-000000000001';
      const annee = '20000000-0000-4000-8000-000000002025';
      const aicha = 'd0000000-0000-4000-8000-000000000001';
      FinancesRepository repo(Phone p) =>
          FinancesRepository(p.store, remote: p.remote, mediaDir: p.mediaDir);
      final rDir = repo(dir);
      final rSec = repo(sec);

      dir.online = false;
      sec.online = false;
      Future<PaymentRow> payer(FinancesRepository r, int m) => r.encaisser(
        schoolId: ecole,
        yearId: annee,
        studentId: aicha,
        rubric: 'scolarite',
        feeItemId: null,
        montant: m,
        mode: 'especes',
      );
      final d1 = await payer(rDir, 1000);
      final d2 = await payer(rDir, 2000);
      final s1 = await payer(rSec, 3000);
      final s2 = await payer(rSec, 4000);
      final numeros = {
        for (final x in [d1, d2, s1, s2]) x.receiptNumber,
      };
      expect(numeros, hasLength(4));
      final depense = await rSec.depenser(
        schoolId: ecole,
        yearId: annee,
        categorie: 'fournitures',
        libelle: 'Cahiers',
        montant: 2500,
        date: '2025-10-07',
        mode: 'especes',
        justificatif: (Uint8List.fromList(List.filled(2048, 7)), 'image/jpeg'),
      );

      dir.online = true;
      sec.online = true;
      await sec.engine.syncNow();
      await dir.engine.syncNow();
      await sec.engine.syncNow();
      // Nouvel envoi des mêmes écritures : refus silencieux (déjà reçues).
      await dir.engine.syncNow();
      final serveur = await dir.client
          .from('payments')
          .select('receipt_number')
          .inFilter('id', [d1.id, d2.id, s1.id, s2.id]);
      expect(serveur, hasLength(4));
      expect({for (final r in serveur) r['receipt_number']}, numeros);
      for (final p in [dir, sec]) {
        final ids = {
          for (final x in await p.db.select(p.db.payments).get()) x.id,
        };
        expect(ids, containsAll([d1.id, d2.id, s1.id, s2.id]));
      }
      expect(await dir.db.select(dir.db.outbox).get(), isEmpty);

      // Justificatif dans le compartiment privé ; lu par le directeur.
      final img = await dir.client.storage
          .from('finances')
          .download(depense.justificationPath!);
      expect(img, hasLength(2048));

      // Reçu inaltérable, même par l'API du directeur.
      await dir.client.from('payments').update({'amount': 1}).eq('id', d1.id);
      final relu = await dir.client
          .from('payments')
          .select('amount')
          .eq('id', d1.id)
          .single();
      expect(relu['amount'], 1000);
      await dir.client.from('payments').delete().eq('id', d1.id);
      expect(
        await dir.client.from('payments').select('id').eq('id', d1.id),
        hasLength(1),
      );
      // Numéro falsifié (série d'un autre téléphone) : refusé.
      final rep = await dir.client.rpc<dynamic>(
        'sync_push',
        params: {
          'p_changes': [
            {
              'change_id': 1,
              'table': 'payments',
              'row': {
                'id': '77700000-0000-4000-8000-000000000001',
                'school_id': ecole,
                'school_year_id': annee,
                'rubric': 'autre',
                'amount': 100,
                'method': 'especes',
                'paid_at': DateTime.now().toUtc().toIso8601String(),
                'device_id': s1.deviceId,
                'device_seq': 99,
                'receipt_number': s1.receiptNumber.replaceAll(
                  RegExp(r'\d{5}$'),
                  '00099',
                ),
              },
            },
          ],
        },
      );
      final statut = (rep as List<dynamic>).cast<Map<String, dynamic>>();
    expect(statut.single['status'], 'rejete');

      // Enseignante : rien, ni sur son téléphone ni par l'API.
      final ens = await connecte('enseignant1@ecole-test.local');
      expect(await ens.db.select(ens.db.payments).get(), isEmpty);
      expect(await ens.db.select(ens.db.expenses).get(), isEmpty);
      expect(await ens.client.from('payments').select('id'), isEmpty);
      await expectLater(
        ens.client.storage
            .from('finances')
            .download(depense.justificationPath!),
        throwsA(anything),
      );

      await ens.close();
      await sec.close();
      await dir.close();
      tmp.deleteSync(recursive: true);
    },
    skip: skip,
  );

  test('A21 : document de la corbeille effacé définitivement (fichier et '
      'fiche) ; il disparaît du téléphone de l’enseignante ; un enseignant ne '
      'peut pas effacer', () async {
    final tmp = Directory.systemTemp.createTempSync('effacer');
    final dir = await connecte(
      'directeur@ecole-test.local',
      motDePasse,
      Directory('${tmp.path}/dir')..createSync(),
    );
    final repo = BibliothequeRepository(
      dir.store,
      remote: dir.remote,
      mediaDir: dir.mediaDir,
    );
    const ecole = '10000000-0000-4000-8000-000000000001';
    final f = File('${tmp.path}/Rapport.pdf')
      ..writeAsStringSync(
        '%PDF-1.4 rapport ${DateTime.now().microsecondsSinceEpoch}',
      );
    final id = (await repo.ajouter(
      schoolId: ecole,
      espace: Espace.bibliotheque,
      fichiers: [FichierChoisi('Rapport.pdf', f.path)],
      fiche: const FicheDocument(commun: true),
      gestionnaire: true,
    )).ids.single;
    await dir.engine.syncNow();
    await repo.envoyer();
    await dir.engine.syncNow();
    final chemin = (await (dir.db.select(
      dir.db.documents,
    )..where((d) => d.id.equals(id))).getSingle()).storagePath!;

    final ens1 = await connecte(
      'enseignant1@ecole-test.local',
      motDePasse,
      Directory('${tmp.path}/ens1')..createSync(),
    );
    final repoEns = BibliothequeRepository(
      ens1.store,
      remote: ens1.remote,
      mediaDir: ens1.mediaDir,
    );
    expect(
      (await ens1.db.select(ens1.db.documents).get()).map((d) => d.id),
      contains(id),
    );

    await repo.mettreALaCorbeille(id);
    await dir.engine.syncNow();
    // Un enseignant ne peut pas effacer.
    await expectLater(
      SupabaseDocumentsEnLigne(ens1.client).effacer(id, chemin),
      throwsA(isA<UserMessage>()),
    );
    await SupabaseDocumentsEnLigne(dir.client).effacer(id, chemin);
    await repo.oublier(id);
    await expectLater(
      dir.client.storage.from('documents').download(chemin),
      throwsA(anything),
    );
    expect(
      await dir.client.from('documents').select('id').eq('id', id),
      isEmpty,
    );

    // Téléphone de l'enseignante : retiré à la synchronisation.
    await ens1.engine.syncNow();
    expect(await repoEns.reconcilier(), greaterThanOrEqualTo(1));
    expect(
      (await ens1.db.select(ens1.db.documents).get()).map((d) => d.id),
      isNot(contains(id)),
    );

    await ens1.close();
    await dir.close();
    tmp.deleteSync(recursive: true);
  }, skip: skip);

  test(
    'phase 9 : document de 14 Mo envoyé par morceaux, coupure puis '
    'reprise sans doublon ; visible par la seule classe choisie ; '
    'archives jamais lues par un enseignant ; recherche dans le texte',
    () async {
      final tmp = Directory.systemTemp.createTempSync('biblio');
      final dir = await connecte(
        'directeur@ecole-test.local',
        motDePasse,
        Directory('${tmp.path}/dir')..createSync(),
      );
      final repo = BibliothequeRepository(
        dir.store,
        remote: dir.remote,
        mediaDir: dir.mediaDir,
      );
      const ecole = '10000000-0000-4000-8000-000000000001';
      const cm1 = 'c0000000-0000-4000-8000-000000000002';
      const taille = 14 * 1024 * 1024;
      final octets = Uint8List(taille);
      for (var i = 0; i < taille; i++) {
        octets[i] = (i * 7 + i ~/ 4096) % 251;
      }
      // Contenu unique à chaque passage (sinon : doublon reconnu).
      octets.setAll(0, utf8.encode('${DateTime.now().microsecondsSinceEpoch}'));
      final source = File('${tmp.path}/Guide_CM1.pdf')
        ..writeAsBytesSync(octets);
      final ajout = await repo.ajouter(
        schoolId: ecole,
        espace: Espace.bibliotheque,
        fichiers: [FichierChoisi('Guide_CM1.pdf', source.path)],
        fiche: const FicheDocument(classes: [cm1], type: 'Guide du maître'),
        gestionnaire: true,
      );
      final id = ajout.ids.single;
      await dir.engine.syncNow(); // la fiche d'abord

      // Coupure après le 1er morceau (6 Mo).
      dir.remote.couperApresMorceaux = 1;
      await expectLater(repo.envoyer(), throwsA(isA<RemoteUnavailable>()));
      final enCours = await dir.db.select(dir.db.documentUploads).getSingle();
      expect(enCours.sentBytes, dir.remote.tailleMorceau);
      expect(enCours.uploadUrl, isNotNull);

      // Retour du réseau : reprise au même endroit.
      dir
        ..online = true
        ..remote.couperApresMorceaux = null;
      await repo.envoyer();
      await dir.engine.syncNow();
      expect(
        dir.remote.morceauxEnvoyes,
        3,
        reason: '6 + 6 + 2 Mo, rien renvoyé',
      );
      expect(await dir.db.select(dir.db.documentUploads).get(), isEmpty);
      final d = await (dir.db.select(
        dir.db.documents,
      )..where((x) => x.id.equals(id))).getSingle();
      final recu = await dir.client.storage
          .from('documents')
          .download(d.storagePath!);
      expect(recu, octets);
      final ligne = await dir.client
          .from('documents')
          .select('uploaded_at, approved')
          .eq('id', id)
          .single();
      expect(ligne['uploaded_at'], isNotNull);

      // Archives : un procès-verbal.
      final pv = File('${tmp.path}/PV_conseil.pdf')
        ..writeAsBytesSync(utf8.encode('%PDF-1.4 proces-verbal'));
      final archive = await repo.ajouter(
        schoolId: ecole,
        espace: Espace.archives,
        fichiers: [FichierChoisi('PV_conseil.pdf', pv.path)],
        fiche: const FicheDocument(type: 'Procès-verbal'),
        gestionnaire: true,
      );
      await dir.engine.syncNow();
      await repo.envoyer();
      await dir.engine.syncNow();
      final archiveId = archive.ids.single;
      final pvLigne = await dir.client
          .from('documents')
          .select('ai_allowed, storage_path')
          .eq('id', archiveId)
          .single();
      expect(pvLigne['ai_allowed'], isFalse);

      // Enseignante du CM1 : reçoit la fiche, pas les archives ; ouvre le
      // fichier à la demande.
      final ens1 = await connecte(
        'enseignant1@ecole-test.local',
        motDePasse,
        Directory('${tmp.path}/ens1')..createSync(),
      );
      final vus1 = await ens1.db.select(ens1.db.documents).get();
      expect(vus1.map((x) => x.id), contains(id));
      expect(vus1.map((x) => x.id), isNot(contains(archiveId)));
      final f = await BibliothequeRepository(
        ens1.store,
        remote: ens1.remote,
        mediaDir: ens1.mediaDir,
      ).obtenir(vus1.firstWhere((x) => x.id == id));
      expect(f.lengthSync(), taille);
      await expectLater(
        ens1.client.storage
            .from('documents')
            .download(pvLigne['storage_path'] as String),
        throwsA(anything),
      );

      // Enseignant du CM2 : ni la fiche ni le fichier.
      final ens2 = await connecte('enseignant2@ecole-test.local');
      final vus2 = await ens2.db.select(ens2.db.documents).get();
      expect(vus2.map((x) => x.id), isNot(contains(id)));
      await expectLater(
        ens2.client.storage.from('documents').download(d.storagePath!),
        throwsA(anything),
      );

      // Espace utilisé (serveur) : les deux fichiers.
      final occ = await SupabaseDocumentsEnLigne(dir.client).occupation(ecole);
      expect(occ.utilise, greaterThanOrEqualTo(taille));
      expect(occ.documents, greaterThanOrEqualTo(2));

      await ens2.close();
      await ens1.close();
      await dir.close();
      tmp.deleteSync(recursive: true);
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 5)),
  );

  test('phase 8 : photo déposée par le directeur, reçue par l’enseignante '
      'de la classe, refusée à l’enseignant d’une autre classe ; aucun lien '
      'public', () async {
    final tmp = Directory.systemTemp.createTempSync('photos');
    final dir = await connecte(
      'directeur@ecole-test.local',
      motDePasse,
      Directory('${tmp.path}/dir')..createSync(),
    );
    final aicha =
        await (dir.db.select(dir.db.students)..where(
              (s) => s.id.equals('d0000000-0000-4000-8000-000000000001'),
            ))
            .getSingle();
    final brute = img.encodeJpg(
      img.Image(width: 900, height: 1200)..clear(img.ColorRgb8(120, 90, 60)),
    );
    final jpeg = await preparerPhoto(brute, Recadrage.tout);
    await PhotosRepository(
      dir.store,
      mediaDir: dir.mediaDir,
    ).enregistrerPhoto(aicha, jpeg);
    await dir.engine.syncNow();
    final chemin = (await (dir.db.select(
      dir.db.students,
    )..where((s) => s.id.equals(aicha.id))).getSingle()).photoPath!;
    expect(
      await dir.client.storage.from('ecole-medias').download(chemin),
      hasLength(jpeg.length),
    );

    // Enseignante de CM1 A : la photo arrive sur son téléphone.
    final ens1 = await connecte(
      'enseignant1@ecole-test.local',
      motDePasse,
      Directory('${tmp.path}/ens1')..createSync(),
    );
    expect(File('${tmp.path}/ens1/$chemin').existsSync(), isTrue);

    // Enseignant de CM2 A : refus.
    final ens2 = await connecte('enseignant2@ecole-test.local');
    await expectLater(
      ens2.client.storage.from('ecole-medias').download(chemin),
      throwsA(anything),
    );

    // Aucun lien public.
    final url = dir.client.storage.from('ecole-medias').getPublicUrl(chemin);
    final http = HttpClient();
    final rep = await (await http.getUrl(Uri.parse(url))).close();
    expect(rep.statusCode, isNot(200));
    http.close();

    await ens2.close();
    await ens1.close();
    await dir.close();
    tmp.deleteSync(recursive: true);
  }, skip: skip);
}

/// Lit le code à 6 chiffres dans la boîte de test locale (Mailpit).
Future<String> _dernierCode(String destinataire) async {
  final http = HttpClient();
  Future<Map<String, dynamic>> get(String path) async {
    final req = await http.getUrl(Uri.parse('http://127.0.0.1:54324$path'));
    final res = await req.close();
    return jsonDecode(await res.transform(utf8.decoder).join())
        as Map<String, dynamic>;
  }

  for (var i = 0; i < 20; i++) {
    final list = await get('/api/v1/messages');
    final messages = (list['messages'] as List).cast<Map<String, dynamic>>();
    final m = messages.where(
      (m) =>
          (m['To'] as List).any((t) => (t as Map)['Address'] == destinataire),
    );
    if (m.isNotEmpty) {
      final detail = await get('/api/v1/message/${m.first['ID']}');
      final code = RegExp(r'\b(\d{6})\b').firstMatch('${detail['HTML']}');
      if (code != null) {
        http.close();
        return code.group(1)!;
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
  http.close();
  throw StateError('Aucun code reçu');
}
