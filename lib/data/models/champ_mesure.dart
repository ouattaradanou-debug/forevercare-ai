import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Un champ de mesure d'un gabarit (ex : "Tour de taille", unité "cm").
class ChampMesure {
  const ChampMesure({
    required this.id,
    required this.typeTenueId,
    required this.nom,
    this.unite,
    required this.statut,
    required this.ordre,
    this.estPersonnalise = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String typeTenueId;
  final String nom;
  final String? unite;
  final String statut;
  final int ordre;
  final bool estPersonnalise;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get estActif => statut == 'actif';

  factory ChampMesure.depuisSupabase(Map<String, dynamic> json) {
    return ChampMesure(
      id: json['id'] as String,
      typeTenueId: json['type_tenue_id'] as String,
      nom: json['nom'] as String,
      unite: json['unite'] as String?,
      statut: json['statut'] as String,
      ordre: (json['ordre'] as num?)?.toInt() ?? 0,
      estPersonnalise: json['est_personnalise'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory ChampMesure.depuisLigneLocale(ChampMesureLocal ligne) {
    return ChampMesure(
      id: ligne.id,
      typeTenueId: ligne.typeTenueId,
      nom: ligne.nom,
      unite: ligne.unite,
      statut: ligne.statut,
      ordre: ligne.ordre,
      estPersonnalise: ligne.estPersonnalise,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
    );
  }

  ChampsMesureCompanion versCompagnonLocal() {
    return ChampsMesureCompanion(
      id: Value(id),
      typeTenueId: Value(typeTenueId),
      nom: Value(nom),
      unite: Value(unite),
      statut: Value(statut),
      ordre: Value(ordre),
      estPersonnalise: Value(estPersonnalise),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
