import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Un groupe de commande d'uniformes (promotion scolaire, établissement,
/// équipe...) : nom, répondant et son contact, plusieurs membres (voir
/// MembreGroupeUniforme). Module entièrement indépendant des clients
/// classiques — voir supabase/migration_phase8_uniformes.sql.
class GroupeUniforme {
  const GroupeUniforme({
    required this.id,
    required this.atelierId,
    required this.nom,
    this.repondantNom,
    this.repondantTelephone,
    required this.createdAt,
    required this.updatedAt,
    this.synced = true,
  });

  final String id;
  final String atelierId;
  final String nom;
  final String? repondantNom;
  final String? repondantTelephone;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Faux tant que ce groupe n'a pas été confirmé reçu par Supabase — voir
  /// SyncEngine.
  final bool synced;

  factory GroupeUniforme.depuisSupabase(Map<String, dynamic> json) {
    return GroupeUniforme(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      nom: json['nom'] as String,
      repondantNom: json['repondant_nom'] as String?,
      repondantTelephone: json['repondant_telephone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      synced: true,
    );
  }

  factory GroupeUniforme.depuisLigneLocale(GroupeUniformeLocal ligne) {
    return GroupeUniforme(
      id: ligne.id,
      atelierId: ligne.atelierId,
      nom: ligne.nom,
      repondantNom: ligne.repondantNom,
      repondantTelephone: ligne.repondantTelephone,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
      synced: ligne.synced,
    );
  }

  GroupesUniformesCompanion versCompagnonLocal() {
    return GroupesUniformesCompanion(
      id: Value(id),
      atelierId: Value(atelierId),
      nom: Value(nom),
      repondantNom: Value(repondantNom),
      repondantTelephone: Value(repondantTelephone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }
}
