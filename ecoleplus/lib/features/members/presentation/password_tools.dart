import 'dart:math';

/// Mot de passe provisoire facile à dicter (sans l, 1, O, 0 ambigus).
String motDePasseProvisoire([Random? random]) {
  const lettres = 'abcdefghjkmnpqrstuvwxyz';
  const chiffres = '23456789';
  final r = random ?? Random.secure();
  String pick(String s, int n) =>
      List.generate(n, (_) => s[r.nextInt(s.length)]).join();
  return '${pick(lettres, 4)}-${pick(chiffres, 4)}';
}
