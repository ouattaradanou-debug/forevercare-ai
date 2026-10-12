import 'package:flutter/services.dart';

const _canalWhatsApp = MethodChannel('atelier_plus/whatsapp');

/// Envoie [cheminFichier] directement sur la conversation WhatsApp du
/// numéro [telephoneNormalise] (chiffres uniquement, avec indicatif pays —
/// voir [Telephone.normaliser]), sans passer par le menu de partage
/// générique : WhatsApp s'ouvre déjà sur la bonne conversation avec le
/// fichier joint, il ne reste plus qu'à confirmer l'envoi dans WhatsApp.
///
/// Retourne `true` si l'envoi a bien été lancé côté natif (voir
/// MainActivity.kt), `false` si WhatsApp n'est pas installé ou que
/// l'opération échoue pour une autre raison — l'appelant doit alors se
/// rabattre sur le menu de partage générique (iOS notamment, où ce canal
/// natif n'est pas implémenté).
Future<bool> envoyerFichierVersWhatsApp({
  required String cheminFichier,
  required String telephoneNormalise,
}) async {
  try {
    final reussi = await _canalWhatsApp.invokeMethod<bool>('envoyerFichier', {
      'cheminFichier': cheminFichier,
      'jid': '$telephoneNormalise@s.whatsapp.net',
    });
    return reussi ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}
