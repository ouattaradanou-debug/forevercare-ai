import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Fiche client. Tous les champs d'identité sont optionnels : seule
/// l'existence d'au moins une mesure conditionne la création officielle
/// (voir BrouillonRepository / ClientRepository).
class Client {
  const Client({
    required this.id,
    required this.atelierId,
    this.nom,
    this.prenom,
    this.telephone,
    this.sexe,
    this.datePriseMesures,
    required this.createdAt,
    required this.updatedAt,
    this.synced = true,
  });

  final String id;
  final String atelierId;
  final String? nom;
  final String? prenom;
  final String? telephone;
  final String? sexe;
  final DateTime? datePriseMesures;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Faux tant que cette fiche n'a pas été confirmée reçue par Supabase —
  /// voir SyncEngine.
  final bool synced;

  String get nomComplet {
    final String texte = [
      nom,
      prenom,
    ].where((v) => v != null && v.trim().isNotEmpty).join(' ');
    return texte.isEmpty ? 'Client sans nom' : texte;
  }

  factory Client.depuisSupabase(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      telephone: json['telephone'] as String?,
      sexe: json['sexe'] as String?,
      datePriseMesures: json['date_prise_mesures'] != null
          ? DateTime.parse(json['date_prise_mesures'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      synced: true,
    );
  }

  factory Client.depuisLigneLocale(ClientLocal ligne) {
    return Client(
      id: ligne.id,
      atelierId: ligne.atelierId,
      nom: ligne.nom,
      prenom: ligne.prenom,
      telephone: ligne.telephone,
      sexe: ligne.sexe,
      datePriseMesures: ligne.datePriseMesures,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
      synced: ligne.synced,
    );
  }

  ClientsCompanion versCompagnonLocal() {
    return ClientsCompanion(
      id: Value(id),
      atelierId: Value(atelierId),
      nom: Value(nom),
      prenom: Value(prenom),
      telephone: Value(telephone),
      sexe: Value(sexe),
      datePriseMesures: Value(datePriseMesures),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }
}
