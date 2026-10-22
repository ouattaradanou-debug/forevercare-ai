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
import 'package:ecoleplus/features/school/data/school_repository.dart';
import 'package:flutter_test/flutter_test.dart';
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
  Future<Map<String, dynamic>?> fetchRow(String t, Map<String, Object?> k) =>
      _go(() => inner.fetchRow(t, k));
  @override
  Future<void> upload(String b, String p, Uint8List d, String c) =>
      _go(() => inner.upload(b, p, d, c));
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
    expect(
      membres.map((m) => m.schoolId).toSet(),
      {'10000000-0000-4000-8000-000000000002'},
    );
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
