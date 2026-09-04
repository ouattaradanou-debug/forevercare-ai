import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notifications locales de rappel de rendez-vous.
///
/// Un seul rappel par rendez-vous, programmé 1 heure avant (choix simple et
/// documenté — pas de configuration fine demandée par le cahier des
/// charges). L'identifiant de notification est dérivé de manière
/// déterministe de l'id du rendez-vous, pour pouvoir l'annuler/le
/// reprogrammer facilement en cas de modification.
class NotificationsService {
  NotificationsService._();

  static final NotificationsService instance = NotificationsService._();

  static const Duration delaiRappel = Duration(hours: 1);
  static const String _canalId = 'rappels_rdv';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialise = false;

  Future<void> initialiser() async {
    if (_initialise) return;

    tz_data.initializeTimeZones();
    try {
      final nomFuseau = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(nomFuseau));
    } catch (_) {
      // Fuseau horaire indisponible (rare) : reste sur UTC par défaut
      // plutôt que de bloquer le démarrage de l'application.
    }

    const parametresAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const parametresIos = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: parametresAndroid, iOS: parametresIos),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialise = true;
  }

  /// Programme le rappel. Ne fait rien si l'heure de rappel calculée
  /// (rendez-vous moins [delaiRappel]) est déjà passée.
  Future<void> planifierRappelRendezVous({
    required String rendezVousId,
    required DateTime dateHeureRendezVous,
    required String titre,
    required String corps,
  }) async {
    final momentRappel = dateHeureRendezVous.subtract(delaiRappel);
    if (momentRappel.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      _idNotification(rendezVousId),
      titre,
      corps,
      tz.TZDateTime.from(momentRappel, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _canalId,
          'Rappels de rendez-vous',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Requis par la version installée (18.0.1) du plugin, même si elle
      // ne s'applique qu'à un iOS < 10 qu'Atelier+ ne cible pas.
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> annulerRappel(String rendezVousId) {
    return _plugin.cancel(_idNotification(rendezVousId));
  }

  /// Les identifiants de notification doivent être des entiers 32 bits :
  /// dérivés du hash de l'UUID du rendez-vous, masqué au bit de signe.
  int _idNotification(String rendezVousId) => rendezVousId.hashCode & 0x7fffffff;
}
