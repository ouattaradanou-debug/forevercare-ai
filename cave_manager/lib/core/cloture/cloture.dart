/// Une clôture de caisse (une journée) — point 5, Phase 5 du cahier des
/// charges. Immuable une fois écrite (aucune policy UPDATE/DELETE côté
/// serveur, voir migration 0015) : une correction passe par
/// `HistoriqueCorrection`, jamais par une modification de cette ligne.
class Cloture {
  const Cloture({
    required this.id,
    required this.caveId,
    required this.dateCloture,
    required this.cloturePar,
    required this.totalVentes,
    required this.totalEspeces,
    required this.totalMobileMoney,
    required this.nombreCommandes,
    required this.createdAt,
  });

  final String id;
  final String caveId;
  final DateTime dateCloture;
  final String cloturePar;
  final int totalVentes;
  final int totalEspeces;
  final int totalMobileMoney;
  final int nombreCommandes;
  final DateTime createdAt;

  int get totalEncaisse => totalEspeces + totalMobileMoney;

  factory Cloture.depuisJson(Map<String, dynamic> json) {
    return Cloture(
      id: json['id'] as String,
      caveId: json['cave_id'] as String,
      dateCloture: DateTime.parse(json['date_cloture'] as String),
      cloturePar: json['cloture_par'] as String,
      totalVentes: json['total_ventes'] as int,
      totalEspeces: json['total_especes'] as int,
      totalMobileMoney: json['total_mobile_money'] as int,
      nombreCommandes: json['nombre_commandes'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
