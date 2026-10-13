import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/abonnement/providers/abonnement_providers.dart';
import '../../features/clients/providers/clients_providers.dart';
import '../../features/finances/providers/finances_providers.dart';
import '../../features/mesures/providers/gabarits_providers.dart';
import '../../features/rendezvous/providers/rendez_vous_groupe_providers.dart';
import '../../features/rendezvous/providers/rendezvous_providers.dart';
import '../../features/uniformes/providers/uniformes_providers.dart';
import '../../features/ventes/providers/ventes_providers.dart';

/// Rapatrie en une seule fois toutes les listes de l'atelier depuis
/// Supabase (clients, groupes d'uniformes, rendez-vous, catalogue de
/// ventes, gabarits de mesure, abonnement, récapitulatif financier) —
/// appelé juste après une connexion réussie (voir EcranConnexion), pour
/// que le tailleur retrouve immédiatement toutes ses données déjà
/// enregistrées sans avoir à ouvrir chaque écran un par un ("perte de
/// téléphone", changement d'appareil).
///
/// Le détail propre à un client ou un groupe précis (mesures, photos,
/// historique de commande) continue de se charger à l'ouverture de sa
/// fiche, comme pour un appareil déjà utilisé au quotidien — inutile de
/// tout précharger ici, et beaucoup plus lent si l'atelier a beaucoup de
/// clients. Toutes les listes utilisées par l'écran d'accueil et les
/// écrans de liste étant lues en flux depuis le cache local (`watch`),
/// elles apparaissent au fur et à mesure que chaque rapatriement se
/// termine, sans qu'il soit nécessaire de recharger l'écran.
Future<void> synchroniserIntegralementApresConnexion(
  ProviderContainer conteneur,
  String atelierId,
) async {
  await Future.wait([
    conteneur.read(clientsRepositoryProvider).chargerDepuisServeur(atelierId),
    conteneur.read(groupesUniformesRepositoryProvider).chargerDepuisServeur(atelierId),
    conteneur.read(rendezVousRepositoryProvider).chargerDepuisServeur(atelierId),
    conteneur.read(rendezVousGroupeRepositoryProvider).chargerTousDepuisServeur(atelierId),
    conteneur.read(articlesRepositoryProvider).chargerDepuisServeur(atelierId),
    conteneur.read(ventesRepositoryProvider).chargerDepuisServeur(atelierId),
    conteneur.read(gabaritsRepositoryProvider).chargerDepuisServeur(atelierId),
    conteneur.read(abonnementRepositoryProvider).chargerDepuisServeur(atelierId),
    conteneur.read(financesRepositoryProvider).chargerRecapitulatifDepuisServeur(atelierId),
  ]);
}
