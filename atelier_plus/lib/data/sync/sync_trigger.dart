import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'photo_upload_queue.dart';
import 'sync_engine.dart';

/// Déclenche automatiquement le traitement de la file d'attente de
/// synchronisation dès qu'une connexion est détectée, conformément à
/// l'exigence "déclenchement automatique dès que connectivity_plus détecte
/// une connexion".
class SyncTrigger {
  SyncTrigger({required SyncEngine syncEngine, required PhotoUploadQueue photoUploadQueue})
      : _syncEngine = syncEngine,
        _photoUploadQueue = photoUploadQueue;

  final SyncEngine _syncEngine;
  final PhotoUploadQueue _photoUploadQueue;
  StreamSubscription<List<ConnectivityResult>>? _abonnement;

  Future<void> demarrer() async {
    // Passe immédiate : couvre le cas où l'appareil est déjà en ligne au
    // démarrage avec des tâches laissées en attente d'une session
    // précédente (pas seulement une transition hors-ligne -> en ligne).
    final etatInitial = await Connectivity().checkConnectivity();
    if (_estEnLigne(etatInitial)) {
      unawaited(_traiterLesDeuxFiles());
    }

    _abonnement = Connectivity().onConnectivityChanged.listen((etat) {
      if (_estEnLigne(etat)) {
        unawaited(_traiterLesDeuxFiles());
      }
    });
  }

  /// La file de synchronisation "classique" (clients, mesures, finances...)
  /// est rejouée avant celle des photos : une photo hors-ligne référence
  /// parfois un client/groupe lui-même créé hors-ligne, qui doit donc déjà
  /// exister côté serveur au moment de l'envoi de la photo.
  Future<void> _traiterLesDeuxFiles() async {
    await _syncEngine.traiterFileAttente();
    await _photoUploadQueue.traiterPhotosEnAttente();
  }

  bool _estEnLigne(List<ConnectivityResult> etat) {
    return etat.any((resultat) => resultat != ConnectivityResult.none);
  }

  void arreter() {
    _abonnement?.cancel();
  }
}
