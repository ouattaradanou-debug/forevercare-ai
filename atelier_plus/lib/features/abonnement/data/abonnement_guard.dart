import '../../../data/local/database.dart';
import '../../../data/models/abonnement.dart';
import 'etat_abonnement.dart';

/// Levée par [verifierEcritureAutorisee] quand l'atelier est en mode
/// consultation seule (essai terminé, abonnement expiré/suspendu).
class ModeConsultationSeuleException implements Exception {
  const ModeConsultationSeuleException();

  @override
  String toString() =>
      'Votre période d\'essai est terminée. Renouvelez votre abonnement '
      'pour continuer à modifier vos données — elles restent consultables '
      'sans interruption.';
}

/// Vérifie, à partir du cache local (donc utilisable hors-ligne), que
/// l'atelier est autorisé à écrire. Appelée en tête de chaque méthode
/// d'écriture des repositories "métier quotidien" (clients, mesures,
/// photos, rendez-vous, finances, gabarits) — jamais pour les actions de
/// compte (connexion, gestion des apprentis) qui doivent rester
/// disponibles même en lecture seule.
///
/// N'échoue JAMAIS par excès de prudence si aucun abonnement n'est encore
/// en cache (ex. tout premier lancement hors-ligne avant toute connexion) :
/// bloquer un nouvel utilisateur légitime par un simple délai de
/// synchronisation serait pire que la fenêtre de risque, très étroite,
/// que cela laisse.
Future<void> verifierEcritureAutorisee(AppDatabase baseLocale, String atelierId) async {
  final ligne = await baseLocale.observerAbonnement(atelierId).first;
  if (ligne == null) return;

  final abonnement = Abonnement(
    id: ligne.id,
    atelierId: ligne.atelierId,
    statut: ligne.statut,
    dateFinEssai: ligne.dateFinEssai,
    dateRenouvellement: ligne.dateRenouvellement,
  );

  if (estEnModeConsultationSeule(abonnement)) {
    throw const ModeConsultationSeuleException();
  }
}
