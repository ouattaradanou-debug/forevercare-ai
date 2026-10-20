/// Horloge de l'application, corrigée de l'écart mesuré avec le serveur à
/// chaque synchronisation : un téléphone mal réglé ne fausse pas la règle
/// « dernière modification gagne ».
class Clock {
  new({this.offset = Duration.zero, DateTime Function()? source})
    : _source = source ?? DateTime.now;

  final DateTime Function() _source;
  Duration offset;

  DateTime now() => _source().toUtc().add(offset);

  String nowIso() => now().toIso8601String();

  /// Mémorise l'écart entre l'heure du serveur et celle du téléphone.
  void calibrate(DateTime serverNow) {
    offset = serverNow.toUtc().difference(_source().toUtc());
  }
}
