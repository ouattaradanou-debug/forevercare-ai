import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:uuid/uuid.dart';

/// Comptes des enseignants et délégués (création, réinitialisation :
/// en ligne uniquement).
class MembersService {
  new(this.api, this.store);

  final AuthApi api;
  final LocalStore store;

  /// Crée le compte et renvoie l'identifiant de connexion à communiquer.
  Future<String> create({
    required String schoolId,
    required String displayName,
    required String role,
    required String login,
    required String password,
    List<String> permissions = const [],
    String? phone,
  }) async {
    if (displayName.trim().isEmpty) {
      throw const UserMessage('Saisissez le nom de la personne.');
    }
    if (password.length < 8) {
      throw const UserMessage(
        'Le mot de passe provisoire doit contenir au moins 8 caractères.',
      );
    }
    final r = await api.manageMembers({
      'action': 'creer',
      'membership_id': const Uuid().v4(),
      'school_id': schoolId,
      'display_name': displayName.trim(),
      'role': role,
      'login': login,
      'password': password,
      'permissions': permissions,
      'phone': phone,
    });
    final membre = Map<String, dynamic>.from(r['membre'] as Map);
    await store.writeLocal(store.table('memberships'), membre);
    return r['identifiant'] as String;
  }

  Future<void> resetPassword(String membershipId, String password) async {
    if (password.length < 8) {
      throw const UserMessage(
        'Le mot de passe provisoire doit contenir au moins 8 caractères.',
      );
    }
    await api.manageMembers({
      'action': 'reinitialiser',
      'membership_id': membershipId,
      'password': password,
    });
  }
}
