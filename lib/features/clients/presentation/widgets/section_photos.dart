import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../shared/widgets/visionneuse_photo.dart';
import 'section_titre.dart';

/// Section photo réutilisable (tissu ou modèle) : choix explicite caméra
/// ou galerie, miniatures avec suppression, et un commentaire libre sous
/// chaque photo (ex. "Wax hollandais") pour préciser ce qu'elle montre.
class SectionPhotos extends StatelessWidget {
  const SectionPhotos({
    super.key,
    required this.titre,
    required this.icone,
    required this.couleur,
    required this.chemins,
    required this.onAjouter,
    required this.onSupprimer,
    this.commentaires = const {},
    this.onCommentaireChange,
  });

  final String titre;
  final IconData icone;
  final Color couleur;
  final List<String> chemins;
  final VoidCallback onAjouter;
  final ValueChanged<String> onSupprimer;

  /// Commentaire actuel de chaque photo, indexé par chemin de fichier.
  final Map<String, String> commentaires;

  /// Appelé avec le chemin de la photo et le nouveau commentaire saisi.
  final void Function(String chemin, String commentaire)? onCommentaireChange;

  Future<void> _modifierCommentaire(BuildContext context, String chemin) async {
    final void Function(String, String)? onChange = onCommentaireChange;
    if (onChange == null) return;

    final TextEditingController controleur = TextEditingController(
      text: commentaires[chemin] ?? '',
    );
    final String? resultat = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Commentaire'),
        content: TextField(
          controller: controleur,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Ex. Wax hollandais, Bazin riche...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controleur.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (resultat != null) onChange(chemin, resultat.trim());
  }

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => afficherPhotosPleinEcran(
                              context,
                              elements: [
                                for (final String c in chemins)
                                  (
                                    cheminLocal: c,
                                    url: null,
                                    commentaire: commentaires[c],
                                  ),
                              ],
                              indexInitial: i,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadius.champ,
                              ),
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
                    if (onCommentaireChange != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      GestureDetector(
                        onTap: () => _modifierCommentaire(context, chemins[i]),
                        child: Text(
                          (commentaires[chemins[i]] ?? '').isEmpty
                              ? '+ Commentaire'
                              : commentaires[chemins[i]]!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: (commentaires[chemins[i]] ?? '').isEmpty
                                    ? Theme.of(context).colorScheme.outline
                                    : null,
                              ),
                        ),
                      ),
                    ],
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
