import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Un type de tenue (gabarit) : "Robe", "Costume", "Mini-jupe"... `atelierId`
/// nul = gabarit par défaut fourni par Atelier+, visible par tous.
class TypeTenue {
  const TypeTenue({
    required this.id,
    required this.atelierId,
    required this.nom,
    required this.sexe,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? atelierId;
  final String nom;
  final String sexe;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get estGabaritParDefaut => atelierId == null;

  factory TypeTenue.depuisSupabase(Map<String, dynamic> json) {
    return TypeTenue(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String?,
      nom: json['nom'] as String,
      sexe: json['sexe'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory TypeTenue.depuisLigneLocale(TypeTenueLocal ligne) {
    return TypeTenue(
      id: ligne.id,
      atelierId: ligne.atelierId,
      nom: ligne.nom,
      sexe: ligne.sexe,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
    );
  }

  TypesTenueCompanion versCompagnonLocal() {
    return TypesTenueCompanion(
      id: Value(id),
      atelierId: Value(atelierId),
      nom: Value(nom),
      sexe: Value(sexe),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
