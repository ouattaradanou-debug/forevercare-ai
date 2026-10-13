/// Valeurs constantes partagées par toute l'application.
class AppConstants {
  const AppConstants._();

  // Statuts de rendez-vous (doivent correspondre au CHECK constraint SQL).
  static const String rdvPlanifie = 'planifie';
  static const String rdvConfirme = 'confirme';
  static const String rdvTermine = 'termine';
  static const String rdvAnnule = 'annule';

  // Types de rendez-vous.
  static const String rdvEssayage = 'essayage';
  static const String rdvLivraison = 'livraison';

  // Types de photo.
  static const String photoTissu = 'tissu';
  static const String photoModele = 'modele';

  // Source de capture d'une photo.
  static const String sourceCamera = 'camera';
  static const String sourceGalerie = 'galerie';

  // Devise affichée dans toute l'application.
  static const String codeDevise = 'FCFA';

  /// Au-delà de cette ancienneté (date de création), supprimer un client ou
  /// un groupe d'uniformes ne supprime plus ses données financières
  /// (commandes/paiements) : elles sont conservées, détachées, pour ne
  /// jamais faire reculer les totaux déjà comptabilisés dans les
  /// récapitulatifs de "Suivi des finances". En-dessous de ce seuil,
  /// l'enregistrement est considéré comme trop récent pour avoir déjà été
  /// compté nulle part (probable erreur de saisie) et tout est supprimé
  /// normalement. Voir ClientsRepository.supprimerClient et
  /// GroupesUniformesRepository.supprimerGroupe.
  ///
  /// Réglable pour un test ponctuel via
  /// `--dart-define=DUREE_CONSERVATION_FINANCES_SECONDES=10` (vérifier le
  /// comportement "ancien" sans attendre deux semaines) — ne jamais garder
  /// cette option au-delà d'un test, elle n'a aucun effet si elle est omise.
  static const int _secondesSurchargees =
      int.fromEnvironment('DUREE_CONSERVATION_FINANCES_SECONDES', defaultValue: -1);
  static const Duration dureeConservationFinances =
      _secondesSurchargees >= 0 ? Duration(seconds: _secondesSurchargees) : Duration(days: 14);
}
