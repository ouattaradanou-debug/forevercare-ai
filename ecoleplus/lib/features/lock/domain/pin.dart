import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Codes refusés car trop faciles à deviner.
const _codesFaciles = {
  '1234',
  '12345',
  '123456',
  '4321',
  '54321',
  '654321',
  '0123',
  '01234',
  '1212',
  '2580',
  '1122',
  '2000',
  '2025',
  '2026',
};

/// Règle du code : 4 à 6 chiffres, ni tous identiques, ni trop courant.
String? validerPin(String pin) {
  if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
    return 'Le code doit contenir 4 à 6 chiffres.';
  }
  if (pin.split('').toSet().length == 1 || _codesFaciles.contains(pin)) {
    return 'Ce code est trop facile à deviner. Choisissez-en un autre.';
  }
  return null;
}

/// Empreinte du code (PBKDF2-HMAC-SHA256) : le code n'est jamais stocké.
String empreintePin(String pin, String sel, int iterations) {
  final hmac = Hmac(sha256, utf8.encode(pin));
  final bloc = Uint8List.fromList([...base64.decode(sel), 0, 0, 0, 1]);
  var u = hmac.convert(bloc).bytes;
  final resultat = List<int>.of(u);
  for (var i = 1; i < iterations; i++) {
    u = hmac.convert(u).bytes;
    for (var j = 0; j < resultat.length; j++) {
      resultat[j] ^= u[j];
    }
  }
  return base64.encode(resultat);
}

String nouveauSel([Random? random]) {
  final r = random ?? Random.secure();
  return base64.encode(List.generate(16, (_) => r.nextInt(256)));
}

/// Attente imposée après des erreurs : aucune avant 5 erreurs, puis 30 s,
/// 1 min, 2 min… (15 min au plus) ; à partir de 10 erreurs, il faut se
/// reconnecter avec son mot de passe (null).
Duration? attenteApresErreurs(int erreurs) {
  if (erreurs < 5) return Duration.zero;
  if (erreurs >= 10) return null;
  final secondes = 30 * (1 << (erreurs - 5));
  return Duration(seconds: min(secondes, 15 * 60));
}
