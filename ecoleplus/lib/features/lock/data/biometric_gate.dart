import 'package:local_auth/local_auth.dart';

/// Empreinte digitale / reconnaissance du téléphone.
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
      return await _auth.authenticate(
        localizedReason: 'Ouvrir EcolePlus',
        biometricOnly: true,
      );
    } on Object {
      return false;
    }
  }
}

/// Téléphone sans capteur (et tests).
class NoBiometricGate implements BiometricGate {
  @override
  Future<bool> disponible() async => false;
  @override
  Future<bool> authentifier() async => false;
}
