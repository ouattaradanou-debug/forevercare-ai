/// Utilitaires liés au numéro de téléphone, identifiant de connexion
/// principal d'Atelier+.
///
/// Décision d'architecture (Phase 1) : Supabase Auth ne propose nativement
/// que deux façons simples de s'authentifier sans matériel supplémentaire :
/// email + mot de passe, ou téléphone + SMS (OTP). La seconde nécessite un
/// fournisseur SMS payant (Twilio...) et une connexion fiable au moment de
/// l'inscription — deux contraintes incompatibles avec le public visé
/// (connexion instable, coût à éviter). On utilise donc email + mot de
/// passe, mais on ne montre jamais d'email à l'utilisateur : un email
/// "synthétique" est construit à partir du numéro de téléphone
/// (ex. 0700000000 → 0700000000@atelierplus.app) et sert uniquement en
/// interne pour Supabase Auth. Le mot de passe est un code PIN à 6 chiffres,
/// plus adapté à des utilisateurs peu technophiles qu'un mot de passe
/// classique.
class TelephoneUtils {
  TelephoneUtils._();

  static const String _domaineSynthetique = 'atelierplus.app';

  /// Ne garde que les chiffres du numéro saisi (retire espaces, tirets...).
  static String normaliser(String telephone) {
    return telephone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Construit l'email synthétique utilisé en interne par Supabase Auth.
  static String emailSynthetique(String telephone) {
    return '${normaliser(telephone)}@$_domaineSynthetique';
  }

  static bool estValide(String telephone) {
    final String chiffres = normaliser(telephone);
    return chiffres.length >= 8 && chiffres.length <= 15;
  }
}
