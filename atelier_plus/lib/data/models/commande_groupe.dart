/// Modèle miroir de la table `commandes_groupe` — commande globale d'un
/// groupe d'uniformes (un groupe a une seule commande plutôt qu'une par
/// membre, voir CommandeGroupeEntries). Table dédiée, séparée de `Commande`
/// (clients), pour ne jamais risquer de modification sur une table déjà en
/// production.
class CommandeGroupe {
  const CommandeGroupe({
    required this.id,
    required this.atelierId,
    required this.groupeId,
    required this.montantTotal,
    required this.avance,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String groupeId;
  final double montantTotal;
  final double avance;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CommandeGroupe.depuisJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String);
    return CommandeGroupe(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      groupeId: json['groupe_id'] as String,
      // Voir Commande.depuisJson : double.parse(toString()) tolère un
      // `numeric` PostgREST renvoyé en nombre ou en texte.
      montantTotal: double.parse(json['montant_total'].toString()),
      avance: double.parse(json['avance'].toString()),
      createdAt: createdAt,
      // Repli sur created_at si absent (voir Mesure.depuisJson).
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : createdAt,
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'groupe_id': groupeId,
      'montant_total': montantTotal,
      'avance': avance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
