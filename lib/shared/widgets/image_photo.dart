import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Affiche une photo depuis le fichier local si présent sur cet appareil
/// (`cheminLocal` non vide), sinon depuis `url` — cas d'une photo reçue
/// d'un autre appareil de l'atelier et jamais téléchargée sur celui-ci
/// (voir Photo et SyncEngine.tirerDonneesAtelier).
Widget imagePhoto({
  required String cheminLocal,
  String? url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  if (cheminLocal.isNotEmpty) {
    return Image.file(File(cheminLocal), width: width, height: height, fit: fit);
  }

  if (url != null) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) =>
          const Icon(Icons.broken_image_outlined),
    );
  }

  // Ni fichier local ni URL : la photo est en attente d'envoi et son
  // fichier a disparu de l'appareil (cas très rare, voir
  // ClientRepository.pousserPhoto).
  return const Icon(Icons.broken_image_outlined);
}
