import 'dart:async';
import 'dart:io';

import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Erreur à montrer telle quelle à l'utilisateur (français simple).
class UserMessage implements Exception {
  const new(this.message);
  final String message;
  @override
  String toString() => message;
}

const messageHorsLigne =
    'Pas de connexion Internet. Cette action a besoin du réseau : '
    'réessayez quand vous aurez une connexion.';

/// Opérations qui exigent le serveur (connexion, création de compte…).
abstract interface class AuthApi {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  String? get currentUserId;
  Future<List<Map<String, dynamic>>> myMemberships(String userId);
  Future<Map<String, dynamic>> createSchool(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> registerDevice(
    String deviceId,
    String schoolId,
    String label,
  );
  Future<void> sendRecoveryCode(String email);
  Future<void> confirmRecovery(String email, String code, String newPassword);
  Future<Map<String, dynamic>> manageMembers(Map<String, dynamic> body);
  Future<void> signOut();

  // Question secrète (A5) et téléphones (A6).
  Future<bool> hasRecoveryQuestion();
  Future<void> setRecoveryQuestion(String question, String answer);
  Future<String> recoveryQuestion(String email);
  Future<void> recoverWithAnswer(String email, String answer, String password);
  Future<void> revokeDevice(String deviceId);

  // Connexion par le numéro d'un compte à e-mail (A11). Numéros au format
  // 226XXXXXXXX.
  Future<String?> loginPhone();
  Future<void> setLoginPhone(String? phone);

  /// E-mail du compte si ce numéro ET ce mot de passe correspondent, sinon
  /// null.
  Future<String?> emailForPhone(String phone, String password);
}

class SupabaseAuthApi implements AuthApi {
  new(this.client);
  final SupabaseClient client;

  Future<T> _guard<T>(Future<T> Function() f) async {
    try {
      return await f().timeout(const Duration(seconds: 30));
    } on SocketException {
      throw const UserMessage(messageHorsLigne);
    } on TimeoutException {
      throw const UserMessage(messageHorsLigne);
    } on RemoteUnavailable {
      throw const UserMessage(messageHorsLigne);
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('invalid login') || m.contains('invalid credentials')) {
        throw const UserMessage('Identifiant ou mot de passe incorrect.');
      }
      if (m.contains('already registered') || m.contains('already exists')) {
        throw const UserMessage(
          'Un compte existe déjà avec cette adresse : connectez-vous.',
        );
      }
      if (m.contains('token') && m.contains('expired') ||
          m.contains('otp') ||
          m.contains('invalid') && m.contains('token')) {
        throw const UserMessage('Code incorrect ou expiré.');
      }
      if (m.contains('password')) {
        throw const UserMessage(
          'Mot de passe trop simple : au moins 8 caractères.',
        );
      }
      if (e is AuthRetryableFetchException) {
        throw const UserMessage(messageHorsLigne);
      }
      throw const UserMessage('La connexion a échoué. Réessayez.');
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['erreur'] is String) {
        throw UserMessage(details['erreur'] as String);
      }
      throw const UserMessage('L’opération a échoué. Réessayez.');
    } on PostgrestException catch (e) {
      throw UserMessage(
        e.code == 'P0001' ? e.message : 'L’opération a été refusée.',
      );
    } on Exception catch (e) {
      if (e.toString().contains('ClientException')) {
        throw const UserMessage(messageHorsLigne);
      }
      rethrow;
    }
  }

  @override
  String? get currentUserId => client.auth.currentUser?.id;

  @override
  Future<String> signIn(String email, String password) => _guard(() async {
    final r = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return r.user!.id;
  });

  @override
  Future<String> signUp(String email, String password) => _guard(() async {
    final r = await client.auth.signUp(email: email, password: password);
    if (r.session == null) {
      throw const UserMessage(
        'Votre compte est créé. Ouvrez le message reçu par e-mail pour le '
        'confirmer, puis connectez-vous.',
      );
    }
    return r.user!.id;
  });

  @override
  Future<List<Map<String, dynamic>>> myMemberships(String userId) =>
      _guard(() async {
        final rows = await client
            .from('memberships')
            .select()
            .eq('user_id', userId)
            .eq('active', true)
            .isFilter('deleted_at', null);
        return [for (final r in rows) Map<String, dynamic>.from(r)];
      });

  @override
  Future<Map<String, dynamic>> createSchool(Map<String, dynamic> payload) =>
      _guard(() async {
        final r = await client.rpc<dynamic>(
          'create_school',
          params: {'p': payload},
        );
        return Map<String, dynamic>.from(r as Map);
      });

  @override
  Future<Map<String, dynamic>> registerDevice(
    String deviceId,
    String schoolId,
    String label,
  ) => _guard(() async {
    final r = await client.rpc<dynamic>(
      'register_device',
      params: {'p_device_id': deviceId, 'p_school': schoolId, 'p_label': label},
    );
    return Map<String, dynamic>.from(r as Map);
  });

  @override
  Future<void> sendRecoveryCode(String email) =>
      _guard(() => client.auth.resetPasswordForEmail(email));

  @override
  Future<void> confirmRecovery(String email, String code, String newPassword) =>
      _guard(() async {
        await client.auth.verifyOTP(
          email: email,
          token: code.trim(),
          type: OtpType.recovery,
        );
        await client.auth.updateUser(UserAttributes(password: newPassword));
      });

  @override
  Future<Map<String, dynamic>> manageMembers(Map<String, dynamic> body) =>
      _guard(() async {
        final r = await client.functions.invoke('gerer-membres', body: body);
        return Map<String, dynamic>.from(r.data as Map);
      });

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } on Object {
      // Hors ligne : la session locale est effacée quand même.
    }
  }

  @override
  Future<bool> hasRecoveryQuestion() => _guard(
    () async => await client.rpc<dynamic>('has_recovery_question') == true,
  );

  @override
  Future<void> setRecoveryQuestion(String question, String answer) => _guard(
    () => client.rpc<dynamic>(
      'set_recovery_question',
      params: {'p_question': question, 'p_answer': answer},
    ),
  );

  Future<Map<String, dynamic>> _recuperation(Map<String, dynamic> body) =>
      _guard(() async {
        final r = await client.functions.invoke(
          'recuperer-mot-de-passe',
          body: body,
        );
        return Map<String, dynamic>.from(r.data as Map);
      });

  @override
  Future<String> recoveryQuestion(String email) async =>
      (await _recuperation({'action': 'question', 'login': email}))['question']
          as String;

  @override
  Future<void> recoverWithAnswer(
    String email,
    String answer,
    String password,
  ) => _recuperation({
    'action': 'repondre',
    'login': email,
    'reponse': answer,
    'password': password,
  });

  @override
  Future<void> revokeDevice(String deviceId) => _guard(
    () =>
        client.rpc<dynamic>('revoke_device', params: {'p_device_id': deviceId}),
  );

  @override
  Future<String?> loginPhone() => _guard(
    () async => await client.rpc<dynamic>('get_login_phone') as String?,
  );

  @override
  Future<void> setLoginPhone(String? phone) => _guard(
    () => client.rpc<dynamic>('set_login_phone', params: {'p_phone': phone}),
  );

  @override
  Future<String?> emailForPhone(String phone, String password) =>
      _guard(() async {
        try {
          final r = await client.functions.invoke(
            'connexion-telephone',
            body: {'telephone': phone, 'password': password},
          );
          return (r.data as Map)['email'] as String?;
        } on FunctionException catch (e) {
          // Refus « numéro ou mot de passe » : pas une panne.
          if (e.status == 401) return null;
          rethrow;
        }
      });
}
