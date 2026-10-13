import '../constants/app_constants.dart';

/// Phrase à insérer dans une confirmation de suppression de client/groupe,
/// expliquant ce qu'il advient de sa commande et ses paiements — voir
/// AppConstants.dureeConservationFinances (ClientsRepository.supprimerClient,
/// GroupesUniformesRepository.supprimerGroupe) : au-delà de deux semaines
/// d'existence, ils sont conservés plutôt que supprimés, pour ne jamais
/// faire reculer les récapitulatifs financiers déjà établis.
String phraseDevenirFinances(DateTime? createdAt) {
  final ancien = createdAt == null ||
      DateTime.now().toUtc().difference(createdAt) >= AppConstants.dureeConservationFinances;
  return ancien
      ? 'Les montants déjà enregistrés (commande, paiements) seront '
          'conservés et resteront comptés dans vos récapitulatifs financiers.'
      : 'Toutes ses données financières (commande, paiements) seront également supprimées.';
}
