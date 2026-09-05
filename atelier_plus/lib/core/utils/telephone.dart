/// Utilitaires de normalisation du numéro de téléphone, utilisé comme
/// identifiant de connexion (propriétaire ET apprenti).
///
/// Supabase Auth n'a pas de mode "téléphone + PIN" natif sans passer par un
/// fournisseur SMS payant (coût et dépendance réseau incompatibles avec un
/// usage hors-ligne au quotidien). Choix retenu : un compte Auth classique
/// email/mot de passe, avec un **email synthétique dérivé du téléphone**
/// (jamais affiché à l'utilisateur, jamais réellement envoyé de mail) et le
/// PIN comme mot de passe. Le téléphone reste la seule chose saisie/vue par
/// l'utilisateur à l'écran.
class Telephone {
  const Telephone._();

  // Supabase Auth rejette ("email_address_invalid") tout domaine sans
  // enregistrement MX valide — 'atelierplus.local' puis 'atelierplus.app'
  // (domaine non réellement configuré) ont tous deux échoué à ce contrôle.
  // 'gmail.com' est garanti avoir des MX valides ; aucun email n'est
  // jamais réellement envoyé (Confirm email désactivé, aucun flux de
  // récupération de mot de passe par email dans l'app).
  static const String _domaineSynthetique = 'gmail.com';

  /// Ne garde que les chiffres (retire espaces, points, tirets, indicatif +).
  static String normaliser(String saisie) {
    return saisie.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Un numéro valide contient au moins 8 chiffres (formats ouest-africains
  /// courants : 8 à 10 chiffres selon le pays), sans imposer un indicatif
  /// précis pour rester utilisable dans toute la sous-région.
  static bool estValide(String saisie) {
    final chiffres = normaliser(saisie);
    return chiffres.length >= 8 && chiffres.length <= 15;
  }

  /// Construit l'email synthétique utilisé uniquement en interne par
  /// Supabase Auth. Déterministe : le même téléphone donne toujours le même
  /// email, ce qui permet de détecter les doublons via la contrainte
  /// unique sur `utilisateurs.telephone`.
  static String emailSynthetique(String saisie) {
    final chiffres = normaliser(saisie);
    return 'tel-$chiffres@$_domaineSynthetique';
  }
}
