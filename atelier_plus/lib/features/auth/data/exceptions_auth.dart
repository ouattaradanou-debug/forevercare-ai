/// Le compte Supabase Auth existe mais la ligne `utilisateurs` associée est
/// manquante (échec réseau entre les deux écritures lors de la création de
/// compte). Cas rare mais réel avec une connexion instable : signalé
/// explicitement plutôt que de laisser l'application planter.
class CompteIncompletException implements Exception {
  const CompteIncompletException(this.atelierId);

  final String? atelierId;

  @override
  String toString() =>
      'Le compte a été créé mais son profil est incomplet. '
      'Réessayez de vous connecter ou contactez le support.';
}

/// Le numéro de téléphone est déjà utilisé par un compte existant.
class TelephoneDejaUtiliseException implements Exception {
  const TelephoneDejaUtiliseException();

  @override
  String toString() => 'Ce numéro de téléphone est déjà associé à un compte.';
}

/// Téléphone/PIN incorrects à la connexion.
class IdentifiantsInvalidesException implements Exception {
  const IdentifiantsInvalidesException();

  @override
  String toString() => 'Numéro de téléphone ou code PIN incorrect.';
}
