import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/client.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/clients_repository.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  return ClientsRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

/// Résultats de recherche instantanée (nom/prénom/téléphone), lus depuis le
/// cache local — fonctionne hors-ligne. [requete] vide retourne tous les
/// clients de l'atelier.
final rechercheClientsProvider = StreamProvider.family<List<Client>, String>((ref, requete) async* {
  final utilisateur = await ref.watch(utilisateurCourantProvider.future);
  if (utilisateur == null) {
    yield const [];
    return;
  }
  final baseLocale = ref.watch(baseLocaleProvider);
  yield* baseLocale.rechercherClients(utilisateur.atelierId, requete).map(
        (lignes) => lignes
            .map(
              (ligne) => Client(
                id: ligne.id,
                atelierId: ligne.atelierId,
                nom: ligne.nom,
                prenom: ligne.prenom ?? '',
                telephone: ligne.telephone ?? '',
                sexe: ligne.sexe ?? '',
                datePriseMesures: ligne.datePriseMesures ?? ligne.updatedAt,
                createdAt: ligne.createdAt ?? ligne.updatedAt,
                updatedAt: ligne.updatedAt,
              ),
            )
            .toList(),
      );
});

final clientParIdProvider = FutureProvider.family<Client?, String>((ref, id) async {
  final baseLocale = ref.watch(baseLocaleProvider);
  final ligne = await baseLocale.clientParId(id);
  if (ligne == null) return null;
  return Client(
    id: ligne.id,
    atelierId: ligne.atelierId,
    nom: ligne.nom,
    prenom: ligne.prenom ?? '',
    telephone: ligne.telephone ?? '',
    sexe: ligne.sexe ?? '',
    datePriseMesures: ligne.datePriseMesures ?? ligne.updatedAt,
    createdAt: ligne.createdAt ?? ligne.updatedAt,
    updatedAt: ligne.updatedAt,
  );
});
