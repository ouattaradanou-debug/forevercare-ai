import 'package:flutter/material.dart';

/// Affichage plein écran d'une photo (ouverte en appuyant sur sa vignette),
/// avec zoom/déplacement tactile. Utilisé partout où une photo (tissu,
/// modèle) peut être agrandie : Nouveau client, fiche client.
class EcranPhotoPleinEcran extends StatelessWidget {
  const EcranPhotoPleinEcran({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}

/// Ouvre [url] en plein écran, zoomable — raccourci partagé par les
/// vignettes de photo.
void ouvrirPhotoPleinEcran(BuildContext context, String url) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => EcranPhotoPleinEcran(url: url),
    ),
  );
}
