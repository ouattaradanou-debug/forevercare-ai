import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Une prise de mesure d'un membre de groupe d'uniformes — mêmes principes
/// que Mesure (historisée, `valeurs` associe le nom d'un champ à la valeur
/// saisie), mais rattachée à un membre plutôt qu'à un client classique. Ne
/// doit jamais être confondue avec Mesure : voir
/// supabase/migration_phase8_uniformes.sql.
class MesureUniforme {
  const MesureUniforme({
    required this.id,
    required this.membreId,
    required this.typeTenueId,
    required this.datePrise,
    required this.valeurs,
    required this.prisePar,
    required this.createdAt,
    this.synced = true,
  });

  final String id;
  final String membreId;
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

  factory MesureUniforme.depuisSupabase(Map<String, dynamic> json) {
    final Map<String, dynamic> brut =
        json['valeurs'] as Map<String, dynamic>? ?? {};
    return MesureUniforme(
      id: json['id'] as String,
      membreId: json['membre_id'] as String,
      typeTenueId: json['type_tenue_id'] as String,
      datePrise: DateTime.parse(json['date_prise'] as String),
      valeurs: brut.map((k, v) => MapEntry(k, v.toString())),
      prisePar: json['prise_par'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      synced: true,
    );
  }

  factory MesureUniforme.depuisLigneLocale(MesureUniformeLocal ligne) {
    final Map<String, dynamic> decode =
        jsonDecode(ligne.valeursJson) as Map<String, dynamic>;
    return MesureUniforme(
      id: ligne.id,
      membreId: ligne.membreId,
      typeTenueId: ligne.typeTenueId,
      datePrise: ligne.datePrise,
      valeurs: decode.map((k, v) => MapEntry(k, v.toString())),
      prisePar: ligne.prisePar,
      createdAt: ligne.createdAt,
      synced: ligne.synced,
    );
  }

  MesuresUniformeCompanion versCompagnonLocal() {
    return MesuresUniformeCompanion(
      id: Value(id),
      membreId: Value(membreId),
      typeTenueId: Value(typeTenueId),
      datePrise: Value(datePrise),
      valeursJson: Value(jsonEncode(valeurs)),
      prisePar: Value(prisePar),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }
}
