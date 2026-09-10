import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Une photo (tissu ou modèle) rattachée à un client. `cheminLocal` pointe
/// vers le fichier sur CET appareil (vide si la photo vient d'un autre
/// appareil de l'atelier et n'a jamais été téléchargée ici — voir `url`,
/// qui sert alors de source d'affichage, voir
/// lib/shared/widgets/image_photo.dart). `commentaire` permet de préciser
/// ce que montre la photo (ex. "Wax hollandais"), pour aider un tailleur
/// qui ne lit pas forcément à s'y retrouver rien qu'à l'affichage.
class Photo {
  const Photo({
    required this.id,
    required this.clientId,
    required this.type,
    required this.cheminLocal,
    required this.source,
    required this.createdAt,
    this.commentaire,
    this.url,
    this.synced = true,
  });

  final String id;
  final String clientId;
  final String type;
  final String cheminLocal;
  final String source;
  final DateTime createdAt;
  final String? commentaire;
  final String? url;

  /// Faux tant que cette photo n'a pas été envoyée à Supabase Storage —
  /// voir SyncEngine et ClientRepository.pousserPhoto.
  final bool synced;

  factory Photo.depuisSupabase(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      type: json['type'] as String,
      // Reçue d'un autre appareil : aucun fichier local pour l'instant,
      // voir la doc de classe.
      cheminLocal: '',
      source: json['source'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      commentaire: json['commentaire'] as String?,
      url: json['url'] as String,
      synced: true,
    );
  }

  factory Photo.depuisLigneLocale(PhotoLocal ligne) {
    return Photo(
      id: ligne.id,
      clientId: ligne.clientId,
      type: ligne.type,
      cheminLocal: ligne.cheminLocal,
      source: ligne.source,
      createdAt: ligne.createdAt,
      commentaire: ligne.commentaire,
      url: ligne.url,
      synced: ligne.synced,
    );
  }

  PhotosCompanion versCompagnonLocal() {
    return PhotosCompanion(
      id: Value(id),
      clientId: Value(clientId),
      type: Value(type),
      cheminLocal: Value(cheminLocal),
      source: Value(source),
      createdAt: Value(createdAt),
      commentaire: Value(commentaire),
      url: Value(url),
      synced: Value(synced),
    );
  }
}
