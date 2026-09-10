import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Le « solde » financier d'un client : montant total convenu pour la
/// prestation, avance déjà versée, et si la tenue terminée a été retirée
/// par le client (voir supabase/schema.sql, tables `commandes`/
/// `paiements`, et supabase/migration_phase3_tenue_retiree.sql). Un seul
/// enregistrement par client — voir FinancesRepository. Réservé au
/// propriétaire (RLS + jamais affiché à un apprenti côté application, voir
/// PermissionsApprenti).
class Commande {
  const Commande({
    required this.id,
    required this.clientId,
    required this.montantTotal,
    required this.avance,
    this.tenueRetiree = false,
    required this.createdAt,
    required this.updatedAt,
    this.synced = true,
  });

  final String id;
  final String clientId;
  final double montantTotal;
  final double avance;
  final bool tenueRetiree;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Faux tant que cette ligne n'a pas été confirmée reçue par Supabase —
  /// voir SyncEngine.
  final bool synced;

  double get resteAPayer => montantTotal - avance;

  /// Vrai lorsque le client n'a plus rien à faire ni à payer : la tenue
  /// est retirée et le solde est entièrement réglé. Utilisé pour ne plus
  /// afficher ce client parmi les rendez-vous à suivre sur l'accueil (voir
  /// HomePage, section rappels).
  bool get estSoldee => tenueRetiree && resteAPayer <= 0;

  factory Commande.depuisSupabase(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      montantTotal: (json['montant_total'] as num).toDouble(),
      avance: (json['avance'] as num).toDouble(),
      tenueRetiree: json['tenue_retiree'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      synced: true,
    );
  }

  factory Commande.depuisLigneLocale(CommandeLocal ligne) {
    return Commande(
      id: ligne.id,
      clientId: ligne.clientId,
      montantTotal: ligne.montantTotal,
      avance: ligne.avance,
      tenueRetiree: ligne.tenueRetiree,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
      synced: ligne.synced,
    );
  }

  CommandesCompanion versCompagnonLocal() {
    return CommandesCompanion(
      id: Value(id),
      clientId: Value(clientId),
      montantTotal: Value(montantTotal),
      avance: Value(avance),
      tenueRetiree: Value(tenueRetiree),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }
}
