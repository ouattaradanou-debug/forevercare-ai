import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Une photo (modèle ou tissu, homme ou femme) rattachée à un GROUPE
/// d'uniformes plutôt qu'à un client — voir GroupeUniforme. Mêmes
/// conventions que Photo pour `cheminLocal`/`url` (voir cette classe et
/// lib/shared/widgets/image_photo.dart).
class PhotoGroupeUniforme {
  const PhotoGroupeUniforme({
    required this.id,
    required this.groupeId,
    required this.type,
    required this.cheminLocal,
    required this.source,
    required this.createdAt,
    this.commentaire,
    this.url,
    this.synced = true,
  });

  final String id;
  final String groupeId;

  /// 'modele_homme', 'modele_femme', 'tissu_homme' ou 'tissu_femme'.
  final String type;
  final String cheminLocal;
  final String source;
  final DateTime createdAt;
  final String? commentaire;
  final String? url;

  /// Faux tant que cette photo n'a pas été envoyée à Supabase Storage —
  /// voir SyncEngine et UniformeRepository.pousserPhoto.
  final bool synced;

  factory PhotoGroupeUniforme.depuisSupabase(Map<String, dynamic> json) {
    return PhotoGroupeUniforme(
      id: json['id'] as String,
      groupeId: json['groupe_id'] as String,
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

  factory PhotoGroupeUniforme.depuisLigneLocale(
    PhotoGroupeUniformeLocal ligne,
  ) {
    return PhotoGroupeUniforme(
      id: ligne.id,
      groupeId: ligne.groupeId,
      type: ligne.type,
      cheminLocal: ligne.cheminLocal,
      source: ligne.source,
      createdAt: ligne.createdAt,
      commentaire: ligne.commentaire,
      url: ligne.url,
      synced: ligne.synced,
    );
  }

  PhotosGroupeUniformeCompanion versCompagnonLocal() {
    return PhotosGroupeUniformeCompanion(
      id: Value(id),
      groupeId: Value(groupeId),
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
