import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Un membre d'un groupe d'uniformes (voir GroupeUniforme) : identité
/// minimale, ses mesures sont historisées séparément (voir MesureUniforme).
class MembreGroupeUniforme {
  const MembreGroupeUniforme({
    required this.id,
    required this.groupeId,
    this.nom,
    this.prenom,
    this.sexe,
    this.tenueTerminee = false,
    required this.createdAt,
    required this.updatedAt,
    this.synced = true,
  });

  final String id;
  final String groupeId;
  final String? nom;
  final String? prenom;
  final String? sexe;

  /// Coché par le tailleur une fois la tenue de ce membre confectionnée —
  /// voir GroupeUniformeDetailPage.
  final bool tenueTerminee;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Faux tant que ce membre n'a pas été confirmé reçu par Supabase — voir
  /// SyncEngine.
  final bool synced;

  String get nomComplet {
    final String texte = [
      nom,
      prenom,
    ].where((v) => v != null && v.trim().isNotEmpty).join(' ');
    return texte.isEmpty ? 'Membre sans nom' : texte;
  }

  factory MembreGroupeUniforme.depuisSupabase(Map<String, dynamic> json) {
    return MembreGroupeUniforme(
      id: json['id'] as String,
      groupeId: json['groupe_id'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      sexe: json['sexe'] as String?,
      tenueTerminee: json['tenue_terminee'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      synced: true,
    );
  }

  factory MembreGroupeUniforme.depuisLigneLocale(
    MembreGroupeUniformeLocal ligne,
  ) {
    return MembreGroupeUniforme(
      id: ligne.id,
      groupeId: ligne.groupeId,
      nom: ligne.nom,
      prenom: ligne.prenom,
      sexe: ligne.sexe,
      tenueTerminee: ligne.tenueTerminee,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
      synced: ligne.synced,
    );
  }

  MembresGroupeUniformeCompanion versCompagnonLocal() {
    return MembresGroupeUniformeCompanion(
      id: Value(id),
      groupeId: Value(groupeId),
      nom: Value(nom),
      prenom: Value(prenom),
      sexe: Value(sexe),
      tenueTerminee: Value(tenueTerminee),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }
}
