import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/rendez_vous.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/rendez_vous_repository.dart';

final rendezVousRepositoryProvider = Provider<RendezVousRepository>((ref) {
  return RendezVousRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Rendez-vous de l'atelier, triés par date — lecture locale (hors-ligne).
final rendezVousTriesProvider = StreamProvider<List<RendezVous>>((ref) async* {
  final utilisateur = await ref.watch(utilisateurCourantProvider.future);
  if (utilisateur == null) {
    yield const [];
    return;
  }
  final baseLocale = ref.watch(baseLocaleProvider);
  yield* baseLocale.observerRendezVousTries(utilisateur.atelierId).map(
        (lignes) => lignes
            .map(
              (ligne) => RendezVous(
                id: ligne.id,
                atelierId: ligne.atelierId,
                clientId: ligne.clientId,
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
