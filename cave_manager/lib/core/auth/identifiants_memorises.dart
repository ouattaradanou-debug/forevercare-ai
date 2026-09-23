import 'package:shared_preferences/shared_preferences.dart';

/// Mémorisation locale du numéro de téléphone et du code PIN, pour
/// pré-remplir l'écran de connexion (demandé explicitement : "un seul
/// clic sur Se connecter", y compris après une déconnexion volontaire).
///
/// ⚠️ Compromis sécurité signalé et accepté avec l'utilisateur : le code
/// PIN est stocké **en clair** dans le stockage local de l'app (pas
/// chiffré). Quiconque a un accès physique au téléphone déverrouillé (ou
/// à une sauvegarde ADB) pourrait le récupérer. Accepté car ce PIN
/// protège déjà moins que la session persistante existante (qui, elle,
/// donne un accès complet sans aucun PIN une fois le téléphone
/// déverrouillé) — ce n'est pas une régression de sécurité du même ordre
/// que, par exemple, stocker un mot de passe partagé entre plusieurs
/// services.
class IdentifiantsMemorises {
  static const _cleTelephone = 'identifiants_memorises_telephone';
  static const _clePin = 'identifiants_memorises_pin';

  static Future<void> enregistrer(
      {required String telephone, required String pin}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleTelephone, telephone);
    await prefs.setString(_clePin, pin);
  }

  /// Renvoie `(telephone, pin)`, chacun `null` si rien n'est mémorisé.
  static Future<(String?, String?)> charger() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_cleTelephone), prefs.getString(_clePin));
  }
}
