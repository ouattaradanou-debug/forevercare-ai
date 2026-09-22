import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Émet `true`/`false` à chaque changement de connectivité. Consommé par
/// le point d'entrée de l'app pour déclencher `SyncService.synchroniser()`
/// dès le retour du réseau (règle offline-first du prompt : synchronisation
/// différée bidirectionnelle "dès le retour de connexion").
final connectiviteProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (resultats) => !resultats.contains(ConnectivityResult.none),
      );
});
