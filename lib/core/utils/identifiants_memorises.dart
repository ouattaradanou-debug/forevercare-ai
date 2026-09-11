import 'package:shared_preferences/shared_preferences.dart';

/// Mémorise localement le dernier numéro de téléphone et code PIN utilisés
/// avec succès, pour préremplir l'écran de connexion — un tailleur n'a
/// alors qu'à valider, sans ressaisir son code à chaque ouverture de
/// l'application. Propre à cet appareil (pas de synchronisation), écrasé à
/// chaque nouvelle connexion réussie (utile si plusieurs comptes se
/// connectent tour à tour sur le même téléphone).
class IdentifiantsMemorises {
  IdentifiantsMemorises._();

  static const String _cleTelephone = 'connexion_telephone_memorise';
  static const String _clePin = 'connexion_pin_memorise';

  static Future<void> enregistrer({
    required String telephone,
    required String pin,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleTelephone, telephone);
    await prefs.setString(_clePin, pin);
  }

  /// Numéro de téléphone et code PIN mémorisés, ou `null` chacun si aucune
  /// connexion réussie n'a encore eu lieu sur cet appareil.
  static Future<({String? telephone, String? pin})> lire() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (
      telephone: prefs.getString(_cleTelephone),
      pin: prefs.getString(_clePin),
    );
  }
}
