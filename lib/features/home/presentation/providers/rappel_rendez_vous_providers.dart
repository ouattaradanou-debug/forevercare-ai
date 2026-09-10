import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_service.dart';
import '../../../clients/presentation/providers/clients_providers.dart';

/// Délai de rappel (en jours avant un rendez-vous) choisi par le tailleur —
/// un réglage propre à cet appareil, persisté localement (pas besoin de
/// synchronisation : chaque téléphone gère ses propres rappels).
class RappelJoursNotifier extends AsyncNotifier<int> {
  static const String _cle = 'rappel_jours_avant_rendez_vous';
  static const int _defaut = 2;

  @override
  Future<int> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cle) ?? _defaut;
  }

  Future<void> definir(int jours) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cle, jours);
    state = AsyncData(jours);
  }
}

final AsyncNotifierProvider<RappelJoursNotifier, int> rappelJoursProvider =
    AsyncNotifierProvider<RappelJoursNotifier, int>(RappelJoursNotifier.new);

/// Replanifie les rappels locaux (voir NotificationService) à chaque
/// changement de la liste des rendez-vous de l'atelier ou du délai choisi.
/// Simple point d'entrée à regarder passivement depuis HomePage — sa valeur
/// n'a pas d'intérêt, seul l'effet de bord de planification compte.
final Provider<void> planificationRappelsProvider = Provider<void>((ref) {
  final rendezVous = ref.watch(rendezVousAtelierProvider).asData?.value;
  final joursAvant = ref.watch(rappelJoursProvider).asData?.value;
  if (rendezVous == null || joursAvant == null) return;
  NotificationService.instance.planifierRappelsRendezVous(
    rendezVous: rendezVous,
    joursAvant: joursAvant,
  );
});
