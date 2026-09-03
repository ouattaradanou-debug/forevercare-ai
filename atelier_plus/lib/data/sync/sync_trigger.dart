import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync_engine.dart';

/// Déclenche automatiquement le traitement de la file d'attente de
/// synchronisation dès qu'une connexion est détectée, conformément à
/// l'exigence "déclenchement automatique dès que connectivity_plus détecte
/// une connexion".
class SyncTrigger {
  SyncTrigger({required SyncEngine syncEngine}) : _syncEngine = syncEngine;

  final SyncEngine _syncEngine;
  StreamSubscription<List<ConnectivityResult>>? _abonnement;

  Future<void> demarrer() async {
    // Passe immédiate : couvre le cas où l'appareil est déjà en ligne au
    // démarrage avec des tâches laissées en attente d'une session
    // précédente (pas seulement une transition hors-ligne -> en ligne).
    final etatInitial = await Connectivity().checkConnectivity();
    if (_estEnLigne(etatInitial)) {
      unawaited(_syncEngine.traiterFileAttente());
    }

    _abonnement = Connectivity().onConnectivityChanged.listen((etat) {
      if (_estEnLigne(etat)) {
        unawaited(_syncEngine.traiterFileAttente());
      }
    });
  }

  bool _estEnLigne(List<ConnectivityResult> etat) {
    return etat.any((resultat) => resultat != ConnectivityResult.none);
  }

  void arreter() {
    _abonnement?.cancel();
  }
}
