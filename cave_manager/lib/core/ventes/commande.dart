import 'statut_commande.dart';

/// Une commande (une vente) — point 5, Phase 3 du cahier des charges.
class Commande {
  const Commande({
    required this.id,
    required this.caveId,
    required this.clientId,
    required this.statut,
    required this.total,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String caveId;
  final String? clientId;
  final StatutCommande statut;

  /// Recalculé côté serveur par trigger à chaque ligne ajoutée — jamais
  /// saisi ni recalculé côté client.
  final int total;
  final String createdBy;
  final DateTime createdAt;

  factory Commande.depuisJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as String,
      caveId: json['cave_id'] as String,
      clientId: json['client_id'] as String?,
      statut: StatutCommande.depuisPostgres(json['statut'] as String),
      total: json['total'] as int,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
