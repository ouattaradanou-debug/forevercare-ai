import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifications_service.dart';

const String _cleJoursAvant = 'rappel_jours_avant';

/// Choix proposés pour "Me rappeler les rendez-vous X avant" — en jours.
const List<int> choixJoursAvantRappel = [1, 2, 3, 7];

/// Persiste le délai de rappel choisi (jours avant le rendez-vous) et le
/// répercute sur [NotificationsService], qui l'utilise pour tout nouveau
/// rappel programmé.
class PreferenceRappelNotifier extends Notifier<int> {
  @override
  int build() {
    _charger();
    return 2;
  }

  Future<void> _charger() async {
    final prefs = await SharedPreferences.getInstance();
    final jours = prefs.getInt(_cleJoursAvant) ?? 2;
    NotificationsService.instance.delaiRappel = Duration(days: jours);
    state = jours;
  }

  Future<void> definir(int jours) async {
    state = jours;
    NotificationsService.instance.delaiRappel = Duration(days: jours);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cleJoursAvant, jours);
  }
}

final preferenceRappelProvider =
    NotifierProvider<PreferenceRappelNotifier, int>(PreferenceRappelNotifier.new);
