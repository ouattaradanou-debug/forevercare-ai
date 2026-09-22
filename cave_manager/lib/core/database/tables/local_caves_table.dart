import 'package:drift/drift.dart';

/// Cache local (Drift) de la table `caves`. Une seule ligne en pratique
/// (un appareil = une cave), répliquée pour permettre à l'écran d'accueil
/// et à la configuration de fonctionner hors ligne.
class LocalCaves extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  TextColumn get typeCave => text()();
  TextColumn get telephone => text()();
  TextColumn get localisation => text()();
  TextColumn get devise => text().withDefault(const Constant('FCFA'))();
  BoolColumn get journeeOuverte => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
