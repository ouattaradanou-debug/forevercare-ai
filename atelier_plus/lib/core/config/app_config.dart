/// Constantes de configuration globales de l'application.
class AppConfig {
  const AppConfig._();

  static const String nomApplication = 'Atelier+';

  /// Durée de l'essai gratuit à la création d'un compte atelier.
  /// Doit rester cohérente avec `date_fin_essai = now() + interval '30 days'`
  /// défini dans le déclencheur `creer_abonnement_essai` du schéma Supabase.
  static const int dureeEssaiJours = 30;

  /// Seuils d'affichage du bandeau de rappel d'expiration d'essai (Phase 4).
  static const List<int> rappelsEssaiJoursAvant = [7, 3, 1];
}
