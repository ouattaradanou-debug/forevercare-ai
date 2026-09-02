import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Compression et upload d'images vers Supabase Storage.
///
/// Toute image capturée (logo d'atelier, photos de tissus/modèles) passe
/// par la même compression avant envoi : essentielle avec une connexion
/// instable, pour réduire le volume transféré et le temps d'upload.
class StockageRepository {
  StockageRepository(this._client);

  final SupabaseClient _client;
  static const _uuid = Uuid();

  /// Compresse [fichier] puis l'envoie dans [bucket]/[dossier]/ sous un nom
  /// unique. Retourne l'URL publique du fichier stocké.
  Future<String> televerserImageCompressee({
    required XFile fichier,
    required String bucket,
    required String dossier,
  }) async {
    final octetsCompresses = await _compresser(fichier);
    final nomFichier = '$dossier/${_uuid.v4()}.jpg';

    await _client.storage.from(bucket).uploadBinary(
          nomFichier,
          octetsCompresses,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
        );

    return _client.storage.from(bucket).getPublicUrl(nomFichier);
  }

  Future<Uint8List> _compresser(XFile fichier) async {
    final dossierTemp = await getTemporaryDirectory();
    final cheminSortie = p.join(
      dossierTemp.path,
      '${_uuid.v4()}.jpg',
    );

    final resultat = await FlutterImageCompress.compressAndGetFile(
      fichier.path,
      cheminSortie,
      quality: 70,
      minWidth: 1280,
      minHeight: 1280,
    );

    if (resultat == null) {
      // Compression indisponible pour ce format (rare) : on envoie
      // l'original plutôt que de bloquer l'utilisateur.
      return File(fichier.path).readAsBytes();
    }

    return resultat.readAsBytes();
  }
}
