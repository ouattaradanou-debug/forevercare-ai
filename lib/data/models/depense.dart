import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Une dépense de l'atelier (voir supabase/schema.sql). Historisée : jamais
/// modifiée ni supprimée après enregistrement, une correction se fait par
/// une nouvelle dépense (voir FinancesRepository, comme pour Paiement).
class Depense {
  const Depense({
    required this.id,
    required this.atelierId,
    required this.montant,
    this.description,
    required this.dateDepense,
    required this.createdAt,
    this.synced = true,
  });

  final String id;
  final String atelierId;
  final double montant;
  final String? description;
  final DateTime dateDepense;
  final DateTime createdAt;

  /// Faux tant que cette dépense n'a pas été confirmée reçue par Supabase
  /// — voir SyncEngine.
  final bool synced;

  factory Depense.depuisSupabase(Map<String, dynamic> json) {
    return Depense(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      montant: (json['montant'] as num).toDouble(),
      description: json['description'] as String?,
      dateDepense: DateTime.parse(json['date_depense'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      synced: true,
    );
  }

  factory Depense.depuisLigneLocale(DepenseLocal ligne) {
    return Depense(
      id: ligne.id,
      atelierId: ligne.atelierId,
      montant: ligne.montant,
      description: ligne.description,
      dateDepense: ligne.dateDepense,
      createdAt: ligne.createdAt,
      synced: ligne.synced,
    );
  }

  DepensesCompanion versCompagnonLocal() {
    return DepensesCompanion(
      id: Value(id),
      atelierId: Value(atelierId),
      montant: Value(montant),
      description: Value(description),
      dateDepense: Value(dateDepense),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }
}
