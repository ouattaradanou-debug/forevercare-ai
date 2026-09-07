import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Modèle de domaine d'un atelier, indépendant de sa source (Supabase ou
/// cache local Drift).
class Atelier {
  const Atelier({
    required this.id,
    required this.nom,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String nom;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Atelier.depuisSupabase(Map<String, dynamic> json) {
    return Atelier(
      id: json['id'] as String,
      nom: json['nom'] as String,
      logoUrl: json['logo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory Atelier.depuisLigneLocale(AtelierLocal ligne) {
    return Atelier(
      id: ligne.id,
      nom: ligne.nom,
      logoUrl: ligne.logoUrl,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
    );
  }

  AteliersCompanion versCompagnonLocal() {
    return AteliersCompanion(
      id: Value(id),
      nom: Value(nom),
      logoUrl: Value(logoUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
