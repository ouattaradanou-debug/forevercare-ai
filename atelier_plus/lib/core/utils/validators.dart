import 'telephone.dart';

/// Règles de validation de formulaire, centralisées et en français pour
/// pouvoir être affichées directement comme messages d'erreur.
class Validators {
  const Validators._();

  static String? nomRequis(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }
    return null;
  }

  static String? telephone(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Le numéro de téléphone est obligatoire.';
    }
    if (!Telephone.estValide(valeur)) {
      return 'Numéro de téléphone invalide.';
    }
    return null;
  }

  /// Le PIN sert de mot de passe Supabase Auth : 6 chiffres exactement,
  /// pour respecter la longueur minimale par défaut de Supabase (6
  /// caractères) tout en restant un clavier numérique simple à saisir.
  static String? pin(String? valeur) {
    if (valeur == null || valeur.isEmpty) {
      return 'Le code PIN est obligatoire.';
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(valeur)) {
      return 'Le code PIN doit contenir exactement 6 chiffres.';
    }
    return null;
  }

  static String? confirmationPin(String pinSaisi, String? confirmation) {
    if (confirmation != pinSaisi) {
      return 'Les deux codes PIN ne correspondent pas.';
    }
    return null;
  }
}
