import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Affichage plein écran d'une photo (ouverte en appuyant sur sa vignette),
/// avec zoom/déplacement tactile. Utilisé partout où une photo (tissu,
/// modèle) peut être agrandie : Nouveau client, fiche client.
///
/// [cheminLocal] prime sur [url] : une photo ajoutée hors-ligne, pas encore
/// envoyée à Supabase Storage, n'a qu'un fichier local à afficher (voir
/// PhotoClient.cheminLocalEnAttente).
class EcranPhotoPleinEcran extends StatelessWidget {
  const EcranPhotoPleinEcran({super.key, required this.url, this.cheminLocal});

  final String url;
  final String? cheminLocal;

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
          child: cheminLocal != null
              ? Image.file(File(cheminLocal!))
              : CachedNetworkImage(imageUrl: url),
        ),
      ),
    );
  }
}

/// Ouvre [url] (ou [cheminLocal] si la photo est encore en attente d'envoi)
/// en plein écran, zoomable — raccourci partagé par les vignettes de photo.
void ouvrirPhotoPleinEcran(BuildContext context, String url, {String? cheminLocal}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => EcranPhotoPleinEcran(url: url, cheminLocal: cheminLocal),
    ),
  );
}
