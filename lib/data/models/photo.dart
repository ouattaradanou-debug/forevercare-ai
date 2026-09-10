import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Une photo (tissu ou modèle) rattachée à un client. Stockée localement ;
/// l'envoi vers Supabase Storage sera ajouté en Phase 3. `commentaire`
/// permet de préciser ce que montre la photo (ex. "Wax hollandais"), pour
/// aider un tailleur qui ne lit pas forcément à s'y retrouver rien qu'à
/// l'affichage.
class Photo {
  const Photo({
    required this.id,
    required this.clientId,
    required this.type,
    required this.cheminLocal,
    required this.source,
    required this.createdAt,
    this.commentaire,
  });

  final String id;
  final String clientId;
  final String type;
  final String cheminLocal;
  final String source;
  final DateTime createdAt;
  final String? commentaire;

  factory Photo.depuisLigneLocale(PhotoLocal ligne) {
    return Photo(
      id: ligne.id,
      clientId: ligne.clientId,
      type: ligne.type,
      cheminLocal: ligne.cheminLocal,
      source: ligne.source,
      createdAt: ligne.createdAt,
      commentaire: ligne.commentaire,
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
    );
  }
}
