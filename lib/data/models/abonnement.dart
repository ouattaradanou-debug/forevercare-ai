import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Abonnement d'un atelier (voir supabase/schema.sql, décision 6) : ligne
/// créée automatiquement par un trigger serveur à la création de l'atelier
/// (essai gratuit de 30 jours), jamais écrite depuis l'application — RLS en
/// lecture seule pour tout membre de l'atelier. Les renouvellements seront
/// écrits par une Edge Function (Phase 4, pas encore construite) ; pour
/// l'instant `statut` reste donc `'essai'` tant que `dateFinEssai` n'est
/// pas dépassée.
class Abonnement {
  const Abonnement({
    required this.id,
    required this.atelierId,
    required this.statut,
    required this.dateFinEssai,
    this.dateRenouvellement,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String statut;
  final DateTime dateFinEssai;
  final DateTime? dateRenouvellement;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Jours restants avant la fin de l'essai gratuit, jamais négatif — voir
  /// HomePage (bandeau "Essai gratuit"), seul endroit qui l'utilise
  /// aujourd'hui.
  int get joursRestantsEssai {
    final int jours = dateFinEssai.difference(DateTime.now()).inDays;
    return jours < 0 ? 0 : jours;
  }

  factory Abonnement.depuisSupabase(Map<String, dynamic> json) {
    return Abonnement(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      statut: json['statut'] as String,
      dateFinEssai: DateTime.parse(json['date_fin_essai'] as String),
      dateRenouvellement: json['date_renouvellement'] == null
          ? null
          : DateTime.parse(json['date_renouvellement'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory Abonnement.depuisLigneLocale(AbonnementLocal ligne) {
    return Abonnement(
      id: ligne.id,
      atelierId: ligne.atelierId,
      statut: ligne.statut,
      dateFinEssai: ligne.dateFinEssai,
      dateRenouvellement: ligne.dateRenouvellement,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
    );
  }

  AbonnementsCompanion versCompagnonLocal() {
    return AbonnementsCompanion(
      id: Value(id),
      atelierId: Value(atelierId),
      statut: Value(statut),
      dateFinEssai: Value(dateFinEssai),
      dateRenouvellement: Value(dateRenouvellement),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
