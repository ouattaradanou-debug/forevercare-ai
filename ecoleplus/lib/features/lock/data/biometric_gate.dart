import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

/// Résultat d'une ouverture par l'empreinte : réussie, ou refusée avec une
/// phrase simple à afficher (null : l'utilisateur a seulement annulé).
class ResultatEmpreinte {
  const new({required this.ok, this.message});
  static const reussi = ResultatEmpreinte(ok: true);
  final bool ok;
  final String? message;
}

/// Empreinte digitale. Si elle échoue (doigt mouillé, capteur abîmé), la
/// fenêtre du téléphone propose aussi son propre code ou schéma : on peut
/// donc toujours ouvrir l'application sans Internet.
abstract interface class BiometricGate {
  Future<bool> disponible();
  Future<ResultatEmpreinte> authentifier();
}

/// Phrase simple pour chaque refus du téléphone (au lieu d'un échec muet).
String? messageEmpreinte(LocalAuthExceptionCode code) => switch (code) {
  LocalAuthExceptionCode.userCanceled ||
  LocalAuthExceptionCode.systemCanceled ||
  LocalAuthExceptionCode.timeout => null,
  LocalAuthExceptionCode.temporaryLockout =>
    'Trop d’essais : l’empreinte est bloquée quelques instants. Attendez '
        '30 secondes puis réessayez.',
  LocalAuthExceptionCode.biometricLockout =>
    'Trop d’essais : le téléphone a bloqué l’empreinte. Déverrouillez '
        'd’abord le téléphone avec son code, puis réessayez.',
  LocalAuthExceptionCode.noBiometricsEnrolled =>
    'Aucune empreinte n’est enregistrée sur ce téléphone. Ajoutez-en une '
        'dans les réglages du téléphone (Sécurité → Empreinte digitale).',
  LocalAuthExceptionCode.noCredentialsSet =>
    'Le téléphone n’a ni empreinte ni code de verrouillage. Ajoutez-en un '
        'dans les réglages du téléphone.',
  LocalAuthExceptionCode.noBiometricHardware ||
  LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
    'Le capteur d’empreinte n’est pas disponible pour le moment. '
        'Réessayez plus tard ou touchez « Empreinte refusée ? ».',
  _ =>
    'L’empreinte n’a pas fonctionné. Réessayez, ou touchez « Empreinte '
        'refusée ? ».',
};

class LocalAuthGate implements BiometricGate {
  final _auth = LocalAuthentication();

  @override
  Future<bool> disponible() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } on Object {
      return false;
    }
  }

  @override
  Future<ResultatEmpreinte> authentifier() async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Posez votre doigt sur le capteur',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Ouvrir EcolePlus',
            signInHint: 'Empreinte, ou code du téléphone',
            cancelButton: 'Annuler',
          ),
        ],
      );
      return ok
          ? ResultatEmpreinte.reussi
          : const ResultatEmpreinte(
              ok: false,
              message: 'Empreinte non reconnue. Réessayez.',
            );
    } on LocalAuthException catch (e) {
      return ResultatEmpreinte(ok: false, message: messageEmpreinte(e.code));
    } on Object {
      return ResultatEmpreinte(
        ok: false,
        message: messageEmpreinte(LocalAuthExceptionCode.unknownError),
      );
    }
  }
}

/// Pour les tests : capteur présent ou non, empreinte acceptée ou non.
class FakeBiometricGate implements BiometricGate {
  new({this.present = true, this.accepte = true, this.refus});
  bool present;
  bool accepte;

  /// Refus du téléphone simulé (sinon « non reconnue »).
  LocalAuthExceptionCode? refus;
  @override
  Future<bool> disponible() async => present;
  @override
  Future<ResultatEmpreinte> authentifier() async => accepte
      ? ResultatEmpreinte.reussi
      : ResultatEmpreinte(
          ok: false,
          message: refus == null
              ? 'Empreinte non reconnue. Réessayez.'
              : messageEmpreinte(refus!),
        );
}

/// Téléphone sans capteur (et tests).
class NoBiometricGate implements BiometricGate {
  @override
  Future<bool> disponible() async => false;
  @override
  Future<ResultatEmpreinte> authentifier() async => const ResultatEmpreinte(
    ok: false,
    message: 'Ce téléphone n’a pas de capteur d’empreinte.',
  );
}
