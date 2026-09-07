import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/image_utils.dart';
import '../local/app_database.dart';
import '../models/atelier.dart';

/// Accès à l'atelier : création, logo, lecture distante et cache local.
class AtelierRepository {
  AtelierRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;

  static const String _table = 'ateliers';
  static const String _bucketLogos = 'logos';

  Future<Atelier> creerAtelier(String nom) async {
    final Map<String, dynamic> ligne = await _client
        .from(_table)
        .insert({'nom': nom})
        .select()
        .single();
    final Atelier atelier = Atelier.depuisSupabase(ligne);
    await enregistrerLocalement(atelier);
    return atelier;
  }

  /// Compresse puis envoie le logo dans Supabase Storage, met à jour la
  /// ligne `ateliers.logo_url` distante et locale, et renvoie l'atelier à
  /// jour.
  Future<Atelier> televerserLogo({
    required String atelierId,
    required File fichierOriginal,
  }) async {
    final File fichierCompresse = await ImageUtils.compresser(
      fichierOriginal,
    );
    final String cheminStockage = '$atelierId/logo.jpg';

    await _client.storage
        .from(_bucketLogos)
        .upload(
          cheminStockage,
          fichierCompresse,
          fileOptions: const FileOptions(upsert: true),
        );

    final String urlPublique = _client.storage
        .from(_bucketLogos)
        .getPublicUrl(cheminStockage);

    final Map<String, dynamic> ligne = await _client
        .from(_table)
        .update({'logo_url': urlPublique})
        .eq('id', atelierId)
        .select()
        .single();

    final Atelier atelier = Atelier.depuisSupabase(ligne);
    await enregistrerLocalement(atelier);
    return atelier;
  }

  Future<Atelier> recupererDepuisSupabase(String atelierId) async {
    final Map<String, dynamic> ligne = await _client
        .from(_table)
        .select()
        .eq('id', atelierId)
        .single();
    return Atelier.depuisSupabase(ligne);
  }

  Future<void> enregistrerLocalement(Atelier atelier) async {
    await _db
        .into(_db.ateliers)
        .insertOnConflictUpdate(atelier.versCompagnonLocal());
  }

  Stream<Atelier?> observerAtelierLocal(String atelierId) {
    final query = _db.select(_db.ateliers)
      ..where((t) => t.id.equals(atelierId));
    return query.watchSingleOrNull().map(
      (ligne) => ligne == null ? null : Atelier.depuisLigneLocale(ligne),
    );
  }
}
