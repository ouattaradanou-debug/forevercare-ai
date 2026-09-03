import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../data/etat_abonnement.dart';
import '../providers/abonnement_providers.dart';

/// Bandeau de rappel d'expiration d'essai (J-7 à J-1) ou d'alerte "mode
/// consultation seule" si l'essai est terminé sans abonnement actif.
/// N'affiche rien en dehors de ces deux cas (abonnement actif, ou essai à
/// plus de 7 jours de son terme).
class BandeauEssai extends ConsumerWidget {
  const BandeauEssai({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnement = ref.watch(abonnementCourantProvider).valueOrNull;
    if (abonnement == null) return const SizedBox.shrink();

    final consultationSeule = estEnModeConsultationSeule(abonnement);
    final rappel = doitAfficherRappelEssai(abonnement);
    if (!consultationSeule && !rappel) return const SizedBox.shrink();

    final jours = joursRestantsEssai(abonnement);
    final String message;
    if (consultationSeule) {
      message = 'Votre essai gratuit est terminé — mode consultation seule. '
          'Vos données restent intactes.';
    } else if (jours <= 0) {
      message = 'Votre essai gratuit se termine aujourd\'hui.';
    } else if (jours == 1) {
      message = 'Votre essai gratuit se termine demain.';
    } else {
      message = 'Votre essai gratuit se termine dans $jours jours.';
    }

    return Material(
      color: consultationSeule ? Colors.red.shade700 : Colors.orange.shade700,
      child: InkWell(
        onTap: () => context.push(AppRoutes.abonnement),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.white)),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
