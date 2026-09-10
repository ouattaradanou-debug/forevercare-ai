import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Une prise de mesure historisée : `valeurs` associe le nom d'un champ de
/// mesure à la valeur saisie (texte, pour couvrir aussi bien "38" que "3"
/// pour un champ "Nombre de tenues").
class Mesure {
  const Mesure({
    required this.id,
    required this.clientId,
    required this.typeTenueId,
    required this.datePrise,
    required this.valeurs,
    required this.prisePar,
    required this.createdAt,
    this.synced = true,
  });

  final String id;
  final String clientId;
  final String typeTenueId;
  final DateTime datePrise;
  final Map<String, String> valeurs;
  final String prisePar;
  final DateTime createdAt;

  /// Faux tant que cette prise n'a pas été confirmée reçue par Supabase —
  /// voir SyncEngine.
  final bool synced;

  bool get aAuMoinsUneValeurRenseignee =>
      valeurs.values.any((v) => v.trim().isNotEmpty);

  factory Mesure.depuisSupabase(Map<String, dynamic> json) {
    final Map<String, dynamic> brut =
        json['valeurs'] as Map<String, dynamic>? ?? {};
    return Mesure(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      typeTenueId: json['type_tenue_id'] as String,
      datePrise: DateTime.parse(json['date_prise'] as String),
      valeurs: brut.map((k, v) => MapEntry(k, v.toString())),
      prisePar: json['prise_par'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      synced: true,
    );
  }

  factory Mesure.depuisLigneLocale(MesureLocal ligne) {
    final Map<String, dynamic> decode =
        jsonDecode(ligne.valeursJson) as Map<String, dynamic>;
    return Mesure(
      id: ligne.id,
      clientId: ligne.clientId,
      typeTenueId: ligne.typeTenueId,
      datePrise: ligne.datePrise,
      valeurs: decode.map((k, v) => MapEntry(k, v.toString())),
      prisePar: ligne.prisePar,
      createdAt: ligne.createdAt,
      synced: ligne.synced,
    );
  }

  MesuresCompanion versCompagnonLocal() {
    return MesuresCompanion(
      id: Value(id),
      clientId: Value(clientId),
      typeTenueId: Value(typeTenueId),
      datePrise: Value(datePrise),
      valeursJson: Value(jsonEncode(valeurs)),
      prisePar: Value(prisePar),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }
}
