enum TypePhoto {
  tissu,
  modele;

  static TypePhoto depuisTexte(String valeur) {
    return TypePhoto.values.firstWhere((v) => v.name == valeur);
  }
}

enum SourcePhoto {
  camera,
  galerie;

  static SourcePhoto depuisTexte(String valeur) {
    return SourcePhoto.values.firstWhere((v) => v.name == valeur);
  }
}

/// Modèle miroir de la table `photos`.
class PhotoClient {
  const PhotoClient({
    required this.id,
    required this.atelierId,
    required this.clientId,
    required this.type,
    required this.url,
    required this.source,
    this.audioUrl,
    required this.createdAt,
  });

  final String id;
  final String atelierId;
  final String clientId;
  final TypePhoto type;
  final String url;
  final SourcePhoto source;
  final String? audioUrl;
  final DateTime createdAt;

  factory PhotoClient.depuisJson(Map<String, dynamic> json) {
    return PhotoClient(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      clientId: json['client_id'] as String,
      type: TypePhoto.depuisTexte(json['type'] as String),
      url: json['url'] as String,
      source: SourcePhoto.depuisTexte(json['source'] as String),
      audioUrl: json['audio_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'client_id': clientId,
      'type': type.name,
      'url': url,
      'source': source.name,
      'audio_url': audioUrl,
    };
  }
}
