import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Un paiement reçu pour la commande d'un client (voir supabase/schema.sql).
/// Historisé : jamais modifié ni supprimé après enregistrement, une
/// correction se fait par un nouveau paiement (voir FinancesRepository).
class Paiement {
  const Paiement({
    required this.id,
    required this.commandeId,
    required this.montant,
    required this.datePaiement,
    required this.createdAt,
  });

  final String id;
  final String commandeId;
  final double montant;
  final DateTime datePaiement;
  final DateTime createdAt;

  factory Paiement.depuisSupabase(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'] as String,
      commandeId: json['commande_id'] as String,
      montant: (json['montant'] as num).toDouble(),
      datePaiement: DateTime.parse(json['date_paiement'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory Paiement.depuisLigneLocale(PaiementLocal ligne) {
    return Paiement(
      id: ligne.id,
      commandeId: ligne.commandeId,
      montant: ligne.montant,
      datePaiement: ligne.datePaiement,
      createdAt: ligne.createdAt,
    );
  }

  PaiementsCompanion versCompagnonLocal() {
    return PaiementsCompanion(
      id: Value(id),
      commandeId: Value(commandeId),
      montant: Value(montant),
      datePaiement: Value(datePaiement),
      createdAt: Value(createdAt),
    );
  }
}
