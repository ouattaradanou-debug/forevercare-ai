import 'dart:io';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/core/sync/sync_engine.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/auth/domain/identifiant.dart';
import 'package:uuid/uuid.dart';

/// Résultat d'une connexion.
sealed class LoginOutcome;

class LoggedIn extends LoginOutcome;

/// Compte valide mais rattaché à aucune école : proposer « Créer mon école ».
class NoSchool extends LoginOutcome;

/// Données saisies à la création de l'école (première utilisation).
class NewSchool {
  const new({
    required this.directorName,
    required this.email,
    required this.password,
    required this.schoolName,
    required this.yearLabel,
    this.commune,
    this.province,
    this.region,
    this.schoolType = 'publique',
    this.phone,
    this.loginPhone,
    this.managesPrimary = true,
    this.managesPreschool = false,
  });

  final String directorName;
  final String email;
  final String password;
  final String schoolName;
  final String yearLabel;
  final String? commune;
  final String? province;
  final String? region;
  final String schoolType;
  final String? phone;

  /// Numéro du directeur pour se connecter (facultatif, A11).
  final String? loginPhone;
  final bool managesPrimary;
  final bool managesPreschool;
}

class AuthService {
  new({
    required this.api,
    required this.store,
    required this.engine,
    this.deviceLabel = 'Téléphone',
  });

  final AuthApi api;
  final LocalStore store;
  final SyncEngine engine;
  final String deviceLabel;
  static const _uuid = Uuid();

  AppDatabase get db => store.db;

  Stream<LocalSessionRow?> watchSession() =>
      db.select(db.localSession).watchSingleOrNull();

  Future<LocalSessionRow?> session() =>
      db.select(db.localSession).getSingleOrNull();

  /// Connexion (en ligne la première fois sur ce téléphone).
  Future<LoginOutcome> login(String identifiant, String password) async {
    final email = identifiantVersEmail(identifiant);
    if (email == null) {
      throw const UserMessage(
        'Identifiant non reconnu : saisissez votre numéro de téléphone, '
        'votre adresse e-mail ou votre identifiant.',
      );
    }
    if (password.isEmpty) {
      throw const UserMessage('Saisissez votre mot de passe.');
    }
    String userId;
    var compte = email;
    try {
      userId = await api.signIn(email, password);
    } on UserMessage catch (e) {
      if (typeIdentifiant(identifiant) != TypeIdentifiant.telephone ||
          !e.message.contains('incorrect')) {
        rethrow;
      }
      // Pas un compte « numéro » : peut-être le numéro choisi par un
      // directeur pour se connecter (A11).
      final trouve = await api.emailForPhone(email.split('@').first, password);
      if (trouve == null) {
        throw UserMessage(
          '${e.message} Directeur : si votre numéro n’est pas encore '
          'enregistré, connectez-vous avec votre adresse e-mail puis '
          'ajoutez-le dans « Mon compte ».',
        );
      }
      compte = trouve;
      userId = await api.signIn(compte, password);
    }
    return await _openSession(userId, compte);
  }

  Future<LoginOutcome> _openSession(String userId, String email) async {
    final memberships = await api.myMemberships(userId);
    if (memberships.isEmpty) return NoSchool();
    final m = memberships.first;
    final previous = await session();
    if (previous != null && previous.userId != userId) {
      await db.clearAll();
    }
    final schoolId = m['school_id'] as String;
    final device = await _registerDevice(schoolId);
    await db
        .into(db.localSession)
        .insertOnConflictUpdate(
          LocalSessionCompanion.insert(
            id: const Value(1),
            userId: userId,
            login: email,
            membershipId: m['id'] as String,
            schoolId: schoolId,
            role: m['role'] as String,
            displayName: m['display_name'] as String,
            deviceId: device.$1,
            deviceSeries: Value(device.$2),
          ),
        );
    await engine.syncNow();
    return LoggedIn();
  }

  Future<(String, String?)> _registerDevice(String schoolId) async {
    var identity = await db.select(db.deviceIdentity).getSingleOrNull();
    if (identity == null) {
      final id = _uuid.v4();
      await db
          .into(db.deviceIdentity)
          .insert(
            DeviceIdentityCompanion.insert(id: const Value(1), deviceId: id),
          );
      identity = DeviceIdentityRow(id: 1, deviceId: id);
    }
    try {
      final d = await api.registerDevice(
        identity.deviceId,
        schoolId,
        deviceLabel,
      );
      return (identity.deviceId, d['series_code'] as String?);
    } on UserMessage {
      // Téléphone déjà inscrit dans une autre école : nouvelle identité.
      final id = _uuid.v4();
      await db
          .into(db.deviceIdentity)
          .insertOnConflictUpdate(
            DeviceIdentityCompanion.insert(id: const Value(1), deviceId: id),
          );
      final d = await api.registerDevice(id, schoolId, deviceLabel);
      return (id, d['series_code'] as String?);
    }
  }

  /// Première utilisation : compte du directeur + école + première année.
  Future<void> createSchool(NewSchool s) async {
    final email = identifiantVersEmail(s.email);
    if (email == null || typeIdentifiant(s.email) != TypeIdentifiant.email) {
      throw const UserMessage(
        'Saisissez une adresse e-mail valide : elle servira à récupérer '
        'votre mot de passe.',
      );
    }
    if (s.password.length < 8) {
      throw const UserMessage(
        'Choisissez un mot de passe d’au moins 8 caractères.',
      );
    }
    final telephone = numeroDeConnexion(s.loginPhone);
    final userId = api.currentUserId ?? await api.signUp(email, s.password);
    if (telephone != null) await api.setLoginPhone(telephone);
    await api.createSchool({
      'school_id': _uuid.v4(),
      'school_year_id': _uuid.v4(),
      'membership_id': _uuid.v4(),
      'admin_header_id': _uuid.v4(),
      'name': s.schoolName.trim(),
      'year_label': s.yearLabel.trim(),
      'commune': s.commune,
      'province': s.province,
      'region': s.region,
      'school_type': s.schoolType,
      'phone': s.phone,
      'email': email,
      'director_name': s.directorName.trim(),
      'manages_primary': s.managesPrimary,
      'manages_preschool': s.managesPreschool,
    });
    await _openSession(userId, email);
  }

  Future<void> sendRecoveryCode(String identifiant) {
    final type = typeIdentifiant(identifiant);
    if (type != TypeIdentifiant.email) {
      throw const UserMessage(
        'Pour un numéro de téléphone ou un identifiant, demandez à votre '
        'directeur de vous donner un nouveau mot de passe.',
      );
    }
    return api.sendRecoveryCode(identifiantVersEmail(identifiant)!);
  }

  Future<void> confirmRecovery(
    String identifiant,
    String code,
    String newPassword,
  ) async {
    if (newPassword.length < 8) {
      throw const UserMessage(
        'Choisissez un mot de passe d’au moins 8 caractères.',
      );
    }
    final email = identifiantVersEmail(identifiant)!;
    await api.confirmRecovery(email, code, newPassword);
    final userId = api.currentUserId;
    if (userId != null) await _openSession(userId, email);
  }

  /// Le directeur a déconnecté ce téléphone (perte, vol) : les données de
  /// l'école sont effacées, le téléphone reçoit une nouvelle identité.
  Future<void> handleRevoked() =>
      effacerTelephoneDeconnecte(db, api, engine.mediaDir);

  /// Message à montrer une fois sur l'écran d'accueil (puis effacé).
  Future<String?> takeNotice() async {
    final row = await db.select(db.deviceIdentity).getSingleOrNull();
    if (row?.notice == null) return null;
    await db
        .update(db.deviceIdentity)
        .write(const DeviceIdentityCompanion(notice: Value(null)));
    return row!.notice;
  }

  /// Mot de passe oublié par question secrète (en ligne).
  Future<String> recoveryQuestion(String identifiant) {
    final email = identifiantVersEmail(identifiant);
    if (email == null) {
      throw const UserMessage('Identifiant non reconnu.');
    }
    return api.recoveryQuestion(email);
  }

  Future<void> recoverWithAnswer(
    String identifiant,
    String answer,
    String newPassword,
  ) async {
    if (newPassword.length < 8) {
      throw const UserMessage(
        'Choisissez un mot de passe d’au moins 8 caractères.',
      );
    }
    final email = identifiantVersEmail(identifiant)!;
    await api.recoverWithAnswer(email, answer, newPassword);
    await login(identifiant, newPassword);
  }

  /// Code oublié : la personne se reconnecte avec son mot de passe (en
  /// ligne) ; ses données et ses éléments non envoyés sont conservés.
  Future<void> reconnectSameUser(String password) async {
    final s = await session();
    if (s == null) throw const UserMessage('Aucune session.');
    final userId = await api.signIn(s.login, password);
    if (userId != s.userId) {
      throw const UserMessage('Ce mot de passe n’est pas celui de ce compte.');
    }
  }

  Future<String?> loginPhone() => api.loginPhone();

  /// Enregistre (ou retire, si vide) le numéro de connexion du compte.
  Future<void> setLoginPhone(String saisie) =>
      api.setLoginPhone(numeroDeConnexion(saisie));

  /// Déconnexion : efface les données de l'école de ce téléphone.
  /// L'écran prévient avant si des éléments ne sont pas encore envoyés.
  Future<void> logout() async {
    await api.signOut();
    await db.clearAll();
    await effacerMedias(engine.mediaDir);
  }
}

/// Le directeur a déconnecté ce téléphone (perte, vol) : les données de
/// l'école sont effacées et le téléphone reçoit une nouvelle identité.
/// Fonction autonome : appelée par le moteur de synchronisation.
Future<void> effacerTelephoneDeconnecte(
  AppDatabase db,
  AuthApi api, [
  Directory? mediaDir,
]) async {
  // L'avis est écrit AVANT l'effacement : l'écran d'accueil qui s'affiche
  // juste après doit pouvoir le lire.
  await db
      .into(db.deviceIdentity)
      .insertOnConflictUpdate(
        DeviceIdentityCompanion.insert(
          id: const Value(1),
          deviceId: const Uuid().v4(),
          notice: const Value(
            'Ce téléphone a été déconnecté par le directeur. Les données '
            'de l’école ont été retirées. Reconnectez-vous si c’est votre '
            'téléphone.',
          ),
        ),
      );
  await api.signOut();
  await db.clearAll();
  await effacerMedias(mediaDir);
}

/// Efface les fichiers de l'école sur ce téléphone (photos, logo, images
/// d’en-tête, documents) : dossiers au nom de l’école (identifiant) et
/// « documents ». La base elle-même (même dossier) n'est pas touchée.
Future<void> effacerMedias(Directory? dir) async {
  if (dir == null || !dir.existsSync()) return;
  final ecole = RegExp(r'^[0-9a-fA-F-]{36}$');
  await for (final e in dir.list()) {
    final nom = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (e is Directory && (nom == 'documents' || ecole.hasMatch(nom))) {
      await e.delete(recursive: true);
    }
  }
}

/// Numéro saisi → 226XXXXXXXX ; null si vide. Message clair si invalide.
String? numeroDeConnexion(String? saisie) {
  if (saisie == null || saisie.trim().isEmpty) return null;
  if (typeIdentifiant(saisie) != TypeIdentifiant.telephone) {
    throw const UserMessage(
      'Numéro de téléphone invalide : 8 chiffres (ex. 70 12 34 56).',
    );
  }
  return identifiantVersEmail(saisie)!.split('@').first;
}
