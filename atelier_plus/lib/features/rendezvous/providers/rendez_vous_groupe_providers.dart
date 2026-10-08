import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/rendez_vous_groupe.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../data/rendez_vous_groupe_repository.dart';

final rendezVousGroupeRepositoryProvider = Provider<RendezVousGroupeRepository>((ref) {
  return RendezVousGroupeRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Rendez-vous d'un groupe d'uniformes, triés par date — équivalent de
/// `rendezVousTriesProvider` (clients), filtré sur un seul groupe.
final rendezVousDuGroupeProvider =
    StreamProvider.family<List<RendezVousGroupe>, String>((ref, groupeId) {
  final baseLocale = ref.watch(baseLocaleProvider);
  return baseLocale.observerRendezVousDuGroupe(groupeId).map(
        (lignes) => lignes
            .map(
              (ligne) => RendezVousGroupe(
                id: ligne.id,
                atelierId: ligne.atelierId,
                groupeId: ligne.groupeId,
                dateHeure: ligne.dateHeure,
                type: ligne.type,
                statut: ligne.statut,
                urgent: ligne.urgent,
                updatedAt: ligne.updatedAt,
              ),
            )
            .toList(),
      );
});
