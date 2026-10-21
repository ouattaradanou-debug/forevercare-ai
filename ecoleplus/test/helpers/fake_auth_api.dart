import 'package:ecoleplus/features/auth/data/auth_api.dart';

import 'fake_server.dart';

/// Authentification simulée : comptes en mémoire, écoles créées directement
/// dans le serveur simulé (comme le ferait create_school).
class FakeAuthApi implements AuthApi {
  new(this.server);

  final FakeServer server;
  final Map<String, (String password, String id)> users = {};
  bool online = true;
  String? _current;
  final sentCodes = <String>[];

  void _check() {
    if (!online) throw const UserMessage(messageHorsLigne);
  }

  void addUser(String email, String password, String id) =>
      users[email] = (password, id);

  @override
  String? get currentUserId => _current;

  @override
  Future<String> signIn(String email, String password) async {
    _check();
    final u = users[email];
    if (u == null || u.$1 != password) {
      throw const UserMessage('Identifiant ou mot de passe incorrect.');
    }
    return _current = u.$2;
  }

  @override
  Future<String> signUp(String email, String password) async {
    _check();
    if (users.containsKey(email)) {
      throw const UserMessage(
        'Un compte existe déjà avec cette adresse : connectez-vous.',
      );
    }
    final id = 'user-${users.length + 1}';
    users[email] = (password, id);
    return _current = id;
  }

  @override
  Future<List<Map<String, dynamic>>> myMemberships(String userId) async {
    _check();
    return [
      for (final m in server.table('memberships').values)
        if (m['user_id'] == userId && m['active'] == true) Map.of(m),
    ];
  }

  @override
  Future<Map<String, dynamic>> createSchool(Map<String, dynamic> p) async {
    _check();
    const ts = '2026-10-21T08:00:00.000Z';
    final school = p['school_id'] as String;
    server
      ..seed('schools', {
        'id': school,
        'name': p['name'],
        'commune': p['commune'],
        'region': p['region'],
        'province': p['province'],
        'school_type': p['school_type'],
        'manages_primary': p['manages_primary'],
        'grading_scale': 10,
        'show_race_religion': false,
        'absent_rule': 'non_compte',
        'director_name': p['director_name'],
        'current_school_year_id': p['school_year_id'],
        'updated_at': ts,
      })
      ..seed('school_years', {
        'id': p['school_year_id'],
        'school_id': school,
        'label': p['year_label'],
        'updated_at': ts,
      })
      ..seed('admin_headers', {
        'id': p['admin_header_id'],
        'school_id': school,
        'school_year_id': p['school_year_id'],
        'country': 'BURKINA FASO',
        'school_label': p['name'],
        'updated_at': ts,
      })
      ..seed('memberships', {
        'id': p['membership_id'],
        'school_id': school,
        'user_id': _current,
        'role': 'directeur',
        'display_name': p['director_name'],
        'active': true,
        'updated_at': ts,
      });
    for (final k in ['maternelle', 'cantine', 'medico_scolaire']) {
      server.seed('school_modules', {
        'school_id': school,
        'module_key': k,
        'enabled': k == 'maternelle' && p['manages_preschool'] == true,
        'updated_at': ts,
      });
    }
    return {'school_id': school, 'already_created': false};
  }

  @override
  Future<Map<String, dynamic>> registerDevice(
    String deviceId,
    String schoolId,
    String label,
  ) async {
    _check();
    final row = {
      'id': deviceId,
      'school_id': schoolId,
      'user_id': _current,
      'label': label,
      'series_code': 'A',
      'pending_count': 0,
      'last_sync_at': '2026-10-21T08:00:00.000Z',
      'updated_at': '2026-10-21T08:00:00.000Z',
    };
    server.seed('devices', row);
    return row;
  }

  @override
  Future<void> sendRecoveryCode(String email) async {
    _check();
    sentCodes.add(email);
  }

  @override
  Future<void> confirmRecovery(
    String email,
    String code,
    String newPassword,
  ) async {
    _check();
    if (code != '123456') throw const UserMessage('Code incorrect ou expiré.');
    final u = users[email]!;
    users[email] = (newPassword, u.$2);
    _current = u.$2;
  }

  @override
  Future<Map<String, dynamic>> manageMembers(Map<String, dynamic> body) async {
    _check();
    final m = {
      'id': body['membership_id'],
      'school_id': body['school_id'],
      'user_id': 'user-${users.length + 1}',
      'role': body['role'],
      'display_name': body['display_name'],
      'active': true,
      'updated_at': '2026-10-21T08:00:00.000Z',
    };
    server.seed('memberships', m);
    return {'membre': m, 'identifiant': '22670112233@tel.ecoleplus.invalid'};
  }

  @override
  Future<void> signOut() async => _current = null;

  final Map<String, (String question, String answer)> questions = {};
  final revoked = <String>[];

  @override
  Future<bool> hasRecoveryQuestion() async {
    _check();
    return questions.containsKey(_current);
  }

  @override
  Future<void> setRecoveryQuestion(String question, String answer) async {
    _check();
    questions[_current!] = (question, answer.toLowerCase().trim());
  }

  String? _idOf(String email) => users[email]?.$2;

  @override
  Future<String> recoveryQuestion(String email) async {
    _check();
    final q = questions[_idOf(email)];
    if (q == null) throw const UserMessage('Aucune question secrète.');
    return q.$1;
  }

  @override
  Future<void> recoverWithAnswer(
    String email,
    String answer,
    String password,
  ) async {
    _check();
    final q = questions[_idOf(email)];
    if (q == null || q.$2 != answer.toLowerCase().trim()) {
      throw const UserMessage('Réponse incorrecte.');
    }
    users[email] = (password, users[email]!.$2);
  }

  @override
  Future<void> revokeDevice(String deviceId) async {
    _check();
    revoked.add(deviceId);
    server.revokedDevices.add(deviceId);
  }
}
