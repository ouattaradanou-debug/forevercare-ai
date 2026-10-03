/// Modèle miroir de la table `depenses`.
class Depense {
  const Depense({
    required this.id,
    required this.atelierId,
    required this.montant,
    this.description,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String atelierId;
  final double montant;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  factory Depense.depuisJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      montant: double.parse(json['montant'].toString()),
      description: json['description'] as String?,
      date: DateTime.parse(json['date_depense'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'montant': montant,
      'description': description,
      'date_depense': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
