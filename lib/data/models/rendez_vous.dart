import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';
import 'client.dart';

/// Type de rendez-vous : essai (essayage) ou remise de la commande
/// terminée (livraison).
enum TypeRendezVous {
  essayage,
  livraison;

  static TypeRendezVous depuisTexte(String valeur) {
    return TypeRendezVous.values.firstWhere(
      (t) => t.name == valeur,
      orElse: () => TypeRendezVous.essayage,
    );
  }

  String get libelle => switch (this) {
    TypeRendezVous.essayage => 'Essayage',
    TypeRendezVous.livraison => 'Livraison',
  };
}

/// Un rendez-vous planifié pour un client (voir supabase/schema.sql,
/// table `rendez_vous`). Toujours rattaché à un client déjà finalisé —
/// voir `BrouillonClient.rendezVousEnAttente` pour les rendez-vous
/// planifiés pendant la saisie, avant que le client n'existe.
class RendezVous {
  const RendezVous({
    required this.id,
    required this.clientId,
    required this.dateHeure,
    required this.type,
    this.statut = 'planifie',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clientId;
  final DateTime dateHeure;
  final TypeRendezVous type;
  final String statut;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RendezVous.depuisSupabase(Map<String, dynamic> json) {
    return RendezVous(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      dateHeure: DateTime.parse(json['date_heure'] as String),
      type: TypeRendezVous.depuisTexte(json['type'] as String),
      statut: json['statut'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory RendezVous.depuisLigneLocale(RendezVousLocal ligne) {
    return RendezVous(
      id: ligne.id,
      clientId: ligne.clientId,
      dateHeure: ligne.dateHeure,
      type: TypeRendezVous.depuisTexte(ligne.type),
      statut: ligne.statut,
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
    );
  }

  RendezVousTableCompanion versCompagnonLocal() {
    return RendezVousTableCompanion(
      id: Value(id),
      clientId: Value(clientId),
      dateHeure: Value(dateHeure),
      type: Value(type.name),
      statut: Value(statut),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}

/// Un rendez-vous accompagné du client concerné — pour l'écran "Rendez-vous"
/// de l'atelier, où l'on affiche le nom du client à côté de chaque date
/// (la table `rendez_vous` ne connaît elle-même que `client_id`).
class RendezVousAvecClient {
  const RendezVousAvecClient({required this.rendezVous, required this.client});

  final RendezVous rendezVous;
  final Client client;
}
