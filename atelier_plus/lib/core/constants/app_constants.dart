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
}
