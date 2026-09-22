import 'package:drift/drift.dart';

/// Cache local (Drift) des profils utilisateurs.
///
/// Contrainte de sécurité (prompt, section RLS) : le cache Drift d'un
/// Agent de vente ne doit répliquer QUE les données dont il a strictement
/// besoin. Pour cette table, un Agent de vente ne réplique donc que SA
/// PROPRE ligne (imposé par la policy RLS `profiles_select_self` côté
/// serveur : la requête de synchronisation ne recevra jamais les profils
/// des autres utilisateurs, il n'y a rien à filtrer côté client en plus).
class LocalProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get caveId => text()();
  TextColumn get nom => text()();
  TextColumn get prenom => text()();
  TextColumn get telephone => text()();
  TextColumn get role => text()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
