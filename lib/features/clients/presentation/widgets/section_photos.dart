import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../shared/widgets/visionneuse_photo.dart';
import 'section_titre.dart';

/// Section photo réutilisable (tissu ou modèle) : choix explicite caméra
/// ou galerie, miniatures avec suppression.
class SectionPhotos extends StatelessWidget {
  const SectionPhotos({
    super.key,
    required this.titre,
    required this.icone,
    required this.couleur,
    required this.chemins,
    required this.onAjouter,
    required this.onSupprimer,
  });

  final String titre;
  final IconData icone;
  final Color couleur;
  final List<String> chemins;
  final VoidCallback onAjouter;
  final ValueChanged<String> onSupprimer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitre(icone: icone, titre: titre, couleur: couleur),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (int i = 0; i < chemins.length; i++)
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => afficherPhotosPleinEcran(
                        context,
                        chemins: chemins,
                        indexInitial: i,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.champ),
                        child: Image.file(
                          File(chemins[i]),
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => onSupprimer(chemins[i]),
                        child: const CircleAvatar(
                          radius: 11,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.champ),
              onTap: onAjouter,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.champ),
                ),
                child: const Icon(Icons.add_a_photo_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
