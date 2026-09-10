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

  /// Indicatif pays utilisé pour compléter automatiquement les numéros
  /// locaux avant de les passer à WhatsApp (voir [lienWhatsApp]). Les
  /// ateliers utilisant cette version de l'app sont au Burkina Faso — à
  /// ajuster si l'app est un jour utilisée dans un autre pays.
  static const String _indicatifPays = '226';

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

  /// Lien "tel:" pour lancer un appel simple — fonctionne avec le numéro
  /// tel que saisi (format local), l'appareil le compose exactement comme
  /// le ferait le composeur natif.
  static Uri lienAppel(String telephone) {
    return Uri(scheme: 'tel', path: normaliser(telephone));
  }

  /// Lien "wa.me" pour ouvrir une discussion WhatsApp avec ce numéro.
  ///
  /// WhatsApp exige un numéro complet avec indicatif pays pour retrouver
  /// le bon contact. Les numéros saisis dans l'app sont locaux (8 chiffres
  /// au Burkina Faso, sans indicatif) : on ajoute donc automatiquement
  /// [_indicatifPays] devant un numéro à 8 chiffres qui ne l'a pas déjà.
  /// Un numéro d'une autre longueur (déjà saisi avec un indicatif, par
  /// exemple) n'est pas modifié.
  static Uri lienWhatsApp(String telephone) {
    final String chiffres = normaliser(telephone);
    final String numeroComplet =
        chiffres.length == 8 && !chiffres.startsWith(_indicatifPays)
        ? '$_indicatifPays$chiffres'
        : chiffres;
    return Uri.parse('https://wa.me/$numeroComplet');
  }
}
