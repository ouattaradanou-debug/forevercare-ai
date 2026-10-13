import 'package:shared_preferences/shared_preferences.dart';

const _cleTelephone = 'dernier_telephone_connexion';
const _clePin = 'dernier_pin_connexion';

/// Mémorise localement le numéro de téléphone et le code PIN de la
/// dernière connexion réussie, pour pré-remplir l'écran de connexion la
/// fois suivante (après une déconnexion explicite, par exemple) — le
/// tailleur n'a ainsi plus besoin de les retaper à chaque fois.
///
/// Stockage en clair (SharedPreferences, non chiffré) : ne change rien au
/// niveau de sécurité réel de l'application, qui repose déjà entièrement
/// sur l'appareil lui-même comme seule protection (tout le reste des
/// données de l'atelier est aussi en cache local non chiffré, voir
/// data/local/database.dart).
class IdentifiantsConnexionMemorises {
  const IdentifiantsConnexionMemorises._();

  static Future<void> enregistrer({required String telephone, required String pin}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleTelephone, telephone);
    await prefs.setString(_clePin, pin);
  }

  /// Retourne `(telephone, pin)`, ou `null` si aucune connexion précédente
  /// n'a été mémorisée sur cet appareil.
  static Future<(String, String)?> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final telephone = prefs.getString(_cleTelephone);
    final pin = prefs.getString(_clePin);
    if (telephone == null || pin == null) return null;
    return (telephone, pin);
  }
}
