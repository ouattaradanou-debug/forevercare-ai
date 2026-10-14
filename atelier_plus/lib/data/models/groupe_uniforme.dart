/// Modèle miroir de la table `groupes_uniformes`.
class GroupeUniforme {
  const GroupeUniforme({
    required this.id,
    required this.atelierId,
    required this.nom,
    this.repondantNom,
    this.repondantTelephone,
    required this.updatedAt,
    this.createdAt,
    this.supprimeLe,
  });

  final String id;
  final String atelierId;
  final String nom;
  final String? repondantNom;
  final String? repondantTelephone;
  final DateTime updatedAt;

  /// Nullable uniquement pour permettre l'ajout de ce champ sans casser un
  /// éventuel cache local existant (voir GroupeUniformeEntries.createdAt) —
  /// en pratique toujours renseigné, `groupes_uniformes.created_at` étant
  /// NOT NULL côté serveur. Détermine, à la suppression du groupe, si ses
  /// commandes/paiements doivent être conservés (voir
  /// AppConstants.dureeConservationFinances).
  final DateTime? createdAt;

  /// Non-null : groupe masqué (suppression demandée alors qu'il existait
  /// déjà depuis au moins deux semaines), sa commande/ses paiements étant
  /// conservés. Voir Client.supprimeLe pour le même principe.
  final DateTime? supprimeLe;

  factory GroupeUniforme.depuisJson(Map<String, dynamic> json) {
    return GroupeUniforme(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      nom: json['nom'] as String,
      repondantNom: json['repondant_nom'] as String?,
      repondantTelephone: json['repondant_telephone'] as String?,
      // Repli sur created_at (ou l'heure actuelle à défaut) si absent —
      // voir Mesure.depuisJson.
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now().toUtc()),
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      supprimeLe:
          json['supprime_le'] != null ? DateTime.parse(json['supprime_le'] as String) : null,
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'nom': nom,
      'repondant_nom': repondantNom,
      'repondant_telephone': repondantTelephone,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
