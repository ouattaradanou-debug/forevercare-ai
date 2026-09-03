/// Modèle miroir de la table `paiements`.
class Paiement {
  const Paiement({
    required this.id,
    required this.atelierId,
    required this.commandeId,
    required this.montant,
    required this.datePaiement,
  });

  final String id;
  final String atelierId;
  final String commandeId;
  final double montant;
  final DateTime datePaiement;

  factory Paiement.depuisJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      commandeId: json['commande_id'] as String,
      // Voir Commande.depuisJson : double.parse(toString()) tolère un
      // `numeric` PostgREST renvoyé en nombre ou en texte.
      montant: double.parse(json['montant'].toString()),
      datePaiement: DateTime.parse(json['date_paiement'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'commande_id': commandeId,
      'montant': montant,
      'date_paiement': datePaiement.toIso8601String(),
    };
  }
}
