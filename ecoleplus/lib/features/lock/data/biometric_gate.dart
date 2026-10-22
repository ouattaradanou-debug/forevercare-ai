import 'package:local_auth/local_auth.dart';

/// Empreinte digitale. Si elle échoue (doigt mouillé, capteur abîmé), le
/// téléphone propose son propre code ou schéma de déverrouillage : on peut
/// donc toujours ouvrir l'application sans Internet.
abstract interface class BiometricGate {
  Future<bool> disponible();
  Future<bool> authentifier();
}

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
  Future<bool> authentifier() async {
    try {
      return await _auth.authenticate(localizedReason: 'Ouvrir EcolePlus');
    } on Object {
      return false;
    }
  }
}

/// Pour les tests : capteur présent ou non, empreinte acceptée ou non.
class FakeBiometricGate implements BiometricGate {
  new({this.present = true, this.accepte = true});
  bool present;
  bool accepte;
  @override
  Future<bool> disponible() async => present;
  @override
  Future<bool> authentifier() async => accepte;
}

/// Téléphone sans capteur (et tests).
class NoBiometricGate implements BiometricGate {
  @override
  Future<bool> disponible() async => false;
  @override
  Future<bool> authentifier() async => false;
}
