import 'categorie_vente.dart';

/// Modèle miroir de la table `ventes` (vente directe de prêt-à-porter, de
/// tissu ou d'article de couture — distincte d'une commande de couture sur
/// mesure, qui reste suivie via `Commande`/`Paiement`).
class Vente {
  const Vente({
    required this.id,
    required this.atelierId,
    required this.categorie,
    required this.designation,
    required this.quantite,
    required this.prixUnitaire,
    required this.montantTotal,
    required this.date,
    required this.createdAt,
    this.articleId,
  });

  final String id;
  final String atelierId;
  final CategorieVente categorie;
  final String designation;
  final double quantite;
  final double prixUnitaire;
  final double montantTotal;
  final DateTime date;
  final DateTime createdAt;
  /// Article du catalogue vendu, s'il a été choisi dans la liste plutôt que
  /// saisi librement (voir `Article`) — permet la décrémentation
  /// automatique du stock. Nullable : une vente "libre" reste possible.
  final String? articleId;

  factory Vente.depuisJson(Map<String, dynamic> json) {
    return Vente(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      categorie: CategorieVente.depuisJson(json['categorie'] as String),
      designation: json['designation'] as String,
      // Voir Commande.depuisJson : double.parse(toString()) tolère un
      // `numeric` PostgREST renvoyé en nombre ou en texte.
      quantite: double.parse(json['quantite'].toString()),
      prixUnitaire: double.parse(json['prix_unitaire'].toString()),
      montantTotal: double.parse(json['montant_total'].toString()),
      date: DateTime.parse(json['date_vente'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      articleId: json['article_id'] as String?,
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'categorie': categorie.valeurJson,
      'designation': designation,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'montant_total': montantTotal,
      'date_vente': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'article_id': articleId,
    };
  }
}
