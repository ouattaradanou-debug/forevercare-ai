import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as chemin;
import 'package:path_provider/path_provider.dart';

/// Compression d'image avant tout envoi vers Supabase Storage : essentiel
/// pour des utilisateurs dont la connexion internet est instable et souvent
/// facturée au volume de données.
class ImageUtils {
  ImageUtils._();

  static Future<File> compresser(File original) async {
    final Directory dossierTemp = await getTemporaryDirectory();
    final String cheminCible = chemin.join(
      dossierTemp.path,
      'atelier_plus_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );

    final resultat = await FlutterImageCompress.compressAndGetFile(
      original.path,
      cheminCible,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
    );

    return resultat != null ? File(resultat.path) : original;
  }

  /// Compresse puis copie l'image dans le stockage permanent de
  /// l'application (survit au redémarrage du téléphone, contrairement au
  /// dossier temporaire que le système peut vider à tout moment). Utilisé
  /// pour les photos de brouillon, tant qu'elles ne sont pas encore
  /// envoyées à Supabase Storage.
  static Future<File> compresserEtPersister(File original) async {
    final File compresse = await compresser(original);
    final Directory dossierDocuments = await getApplicationDocumentsDirectory();
    final Directory dossierPhotos = Directory(
      chemin.join(dossierDocuments.path, 'photos_brouillons'),
    );
    if (!await dossierPhotos.exists()) {
      await dossierPhotos.create(recursive: true);
    }
    final String cheminPermanent = chemin.join(
      dossierPhotos.path,
      '${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    return compresse.copy(cheminPermanent);
  }
}
