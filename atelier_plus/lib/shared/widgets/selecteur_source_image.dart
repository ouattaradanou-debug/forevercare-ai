import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Affiche une feuille de choix "Caméra / Galerie" et retourne le fichier
/// choisi accompagné de la source utilisée, ou `null` si l'utilisateur
/// annule. La source est renvoyée explicitement (jamais déduite du chemin
/// du fichier, peu fiable) car le schéma exige de savoir si une photo vient
/// de la caméra ou de la galerie (table `photos`, colonne `source`).
///
/// Utilisé partout où l'application capture une photo (logo d'atelier en
/// Phase 1, photos de tissus/modèles en Phase 2) : le choix explicite entre
/// caméra et galerie à chaque capture est une exigence transversale du
/// projet, jamais une valeur par défaut implicite.
Future<(XFile fichier, ImageSource source)?> choisirSourceEtImage(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Prendre une photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choisir dans la galerie'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );

  if (source == null) return null;

  final picker = ImagePicker();
  final fichier = await picker.pickImage(source: source, imageQuality: 85);
  if (fichier == null) return null;

  return (fichier, source);
}
