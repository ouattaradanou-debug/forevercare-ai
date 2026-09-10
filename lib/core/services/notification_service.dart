import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/rendez_vous.dart';

/// Rappels locaux de rendez-vous : notifications planifiées directement sur
/// l'appareil (aucun serveur, aucune connexion requise au moment du rappel),
/// un nombre de jours avant chaque rendez-vous au choix du tailleur (voir
/// `rappelJoursProvider`).
///
/// Fuseau horaire fixé à Africa/Abidjan (heure d'Afrique de l'Ouest, pas de
/// changement d'heure saisonnier) : l'application cible des ateliers
/// ouest-africains, ce qui évite la dépendance à un plugin supplémentaire de
/// détection du fuseau de l'appareil.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialise = false;

  Future<void> initialiser() async {
    if (_initialise) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Abidjan'));

    const AndroidInitializationSettings parametresAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings parametresIOS =
        DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: parametresAndroid,
        iOS: parametresIOS,
      ),
    );

    final AndroidFlutterLocalNotificationsPlugin? pluginAndroid = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await pluginAndroid?.requestNotificationsPermission();

    final IOSFlutterLocalNotificationsPlugin? pluginIOS = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await pluginIOS?.requestPermissions(alert: true, badge: true, sound: true);

    _initialise = true;
  }

  static const AndroidNotificationDetails _detailsAndroid =
      AndroidNotificationDetails(
        'rappels_rendez_vous',
        'Rappels de rendez-vous',
        channelDescription:
            'Rappelle les rendez-vous clients à venir avant leur date.',
        importance: Importance.high,
        priority: Priority.high,
      );

  static const NotificationDetails _details = NotificationDetails(
    android: _detailsAndroid,
    iOS: DarwinNotificationDetails(),
  );

  /// Envoie immédiatement une notification factice, pour que le tailleur
  /// puisse vérifier que les rappels s'affichent bien sur son téléphone
  /// sans attendre plusieurs jours qu'un vrai rappel se déclenche.
  Future<void> envoyerNotificationTest() async {
    if (!_initialise) await initialiser();
    await _plugin.show(
      id: 999999999,
      title: 'Rappel de rendez-vous',
      body:
          "Ceci est un rappel test : c'est ainsi que s'affichera un vrai "
          'rappel avant un rendez-vous.',
      notificationDetails: _details,
    );
  }

  /// Remplace l'ensemble des rappels planifiés par un nouveau jeu, calculé à
  /// partir de la liste actuelle des rendez-vous de l'atelier et du délai
  /// choisi par le tailleur. Appelé à chaque changement (voir
  /// `planificationRappelsProvider`) : idempotent et peu coûteux vu le
  /// volume attendu (quelques dizaines de rendez-vous par atelier).
  ///
  /// Un rendez-vous dont le rappel tomberait déjà dans le passé (rendez-vous
  /// trop proche pour avoir encore `joursAvant` jours devant lui) n'a
  /// simplement pas de rappel planifié, plutôt que d'en déclencher un
  /// immédiatement.
  Future<void> planifierRappelsRendezVous({
    required List<RendezVousAvecClient> rendezVous,
    required int joursAvant,
  }) async {
    if (!_initialise) await initialiser();
    await _plugin.cancelAll();

    final tz.TZDateTime maintenant = tz.TZDateTime.now(tz.local);
    for (final RendezVousAvecClient rdv in rendezVous) {
      final DateTime dateRdv = rdv.rendezVous.dateHeure;
      final tz.TZDateTime dateRappel = tz.TZDateTime(
        tz.local,
        dateRdv.year,
        dateRdv.month,
        dateRdv.day,
      ).subtract(Duration(days: joursAvant)).add(const Duration(hours: 8));

      if (!dateRappel.isAfter(maintenant)) continue;

      final int id = rdv.rendezVous.id.hashCode & 0x7FFFFFFF;
      final String jourLibelle = joursAvant == 1
          ? '1 jour'
          : '$joursAvant jours';
      await _plugin.zonedSchedule(
        id: id,
        title: 'Rappel de rendez-vous',
        body: 'Rendez-vous avec ${rdv.client.nomComplet} dans $jourLibelle.',
        scheduledDate: dateRappel,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
