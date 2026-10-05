import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../data/etat_abonnement.dart';
import '../providers/abonnement_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Statut de l'abonnement et transition essai -> abonnement.
///
/// Aucun moyen de paiement n'était spécifié au cahier des charges : le
/// bouton "Renouveler" ouvre une information de contact plutôt qu'un
/// paiement réel — l'intégration d'un prestataire de paiement (Mobile
/// Money ou autre) est un point d'extension future explicitement laissé de
/// côté ici, plutôt que simulée.
class EcranAbonnement extends ConsumerWidget {
  const EcranAbonnement({super.key});

  void _afficherContactRenouvellement(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renouveler mon abonnement'),
        content: const Text(
          'Le paiement en ligne n\'est pas encore disponible dans '
          'l\'application. Contactez le support Atelier+ pour renouveler '
          'votre abonnement — vos données restent intactes et consultables '
          'en attendant.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnementAsync = ref.watch(abonnementCourantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon abonnement'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: abonnementAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (abonnement) {
          if (abonnement == null) {
            return const Center(child: Text('Abonnement introuvable.'));
          }

          final consultationSeule = estEnModeConsultationSeule(abonnement);
          final jours = joursRestantsEssai(abonnement);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  consultationSeule ? Icons.lock_clock_outlined : Icons.verified_outlined,
                  size: 64,
                  color: consultationSeule ? Colors.red : Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  _libelleStatut(abonnement.statut, consultationSeule),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (abonnement.statut == 'essai')
                  Text(
                    consultationSeule
                        ? 'Essai terminé le ${Formatters.dateCourte(abonnement.dateFinEssai)}.'
                        : 'Il reste ${jours <= 1 ? "$jours jour" : "$jours jours"} '
                            '(fin le ${Formatters.dateCourte(abonnement.dateFinEssai)}).',
                    textAlign: TextAlign.center,
                  ),
                if (abonnement.dateRenouvellement != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Renouvelé jusqu\'au '
                      '${Formatters.dateCourte(abonnement.dateRenouvellement!)}.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Vos clients, mesures, rendez-vous et finances restent '
                  'consultables en toute circonstance, y compris en mode '
                  'consultation seule.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _afficherContactRenouvellement(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orangeSeda,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Renouveler mon abonnement'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _libelleStatut(String statut, bool consultationSeule) {
    if (consultationSeule) return 'Mode consultation seule';
    switch (statut) {
      case 'actif':
        return 'Abonnement actif';
      case 'essai':
        return 'Essai gratuit en cours';
      default:
        return statut;
    }
  }
}
