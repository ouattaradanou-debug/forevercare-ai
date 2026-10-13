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
  static const Duration dureeConservationFinances = Duration(days: 14);
}
