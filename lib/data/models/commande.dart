import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Le « solde » financier d'un client : montant total convenu pour la
/// prestation et avance déjà versée (voir supabase/schema.sql, tables
/// `commandes`/`paiements`). Un seul enregistrement par client — voir
/// FinancesRepository. Réservé au propriétaire (RLS + jamais affiché à un
/// apprenti côté application, voir PermissionsApprenti).
class Commande {
  const Commande({
    required this.id,
    required this.clientId,
    required this.montantTotal,
    required this.avance,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clientId;
  final double montantTotal;
  final double avance;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get resteAPayer => montantTotal - avance;

  factory Commande.depuisSupabase(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      montantTotal: (json['montant_total'] as num).toDouble(),
      avance: (json['avance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory Commande.depuisLigneLocale(CommandeLocal ligne) {
    return Commande(
      id: ligne.id,
      clientId: ligne.clientId,
      montantTotal: ligne.montantTotal,
      avance: ligne.avance,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
    );
  }

  CommandesCompanion versCompagnonLocal() {
    return CommandesCompanion(
      id: Value(id),
      clientId: Value(clientId),
      montantTotal: Value(montantTotal),
      avance: Value(avance),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
