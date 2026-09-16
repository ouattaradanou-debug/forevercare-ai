import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../../../../data/models/photo_groupe_uniforme.dart';
import '../../../../shared/widgets/image_photo.dart';
import '../../../../shared/widgets/selecteur_photo.dart';
import '../../../../shared/widgets/visionneuse_photo.dart';
import '../../../clients/presentation/widgets/indicateur_sauvegarde.dart';
import '../../../clients/presentation/widgets/section_titre.dart';
import '../providers/uniformes_providers.dart';

/// Modification des informations générales d'un groupe déjà créé (nom,
/// répondant, contact, photos) — auto-enregistré au fil de la saisie,
/// sans bouton "Enregistrer" séparé (voir la demande).
class ModifierGroupeUniformePage extends ConsumerStatefulWidget {
  const ModifierGroupeUniformePage({super.key, required this.groupe});

  final GroupeUniforme groupe;

  @override
  ConsumerState<ModifierGroupeUniformePage> createState() =>
      _ModifierGroupeUniformePageState();
}

class _ModifierGroupeUniformePageState
    extends ConsumerState<ModifierGroupeUniformePage> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _repondantNomCtrl;
  late final TextEditingController _repondantTelephoneCtrl;

  Timer? _debounce;
  bool _indicateurVisible = false;
  Timer? _timerIndicateur;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.groupe.nom);
    _repondantNomCtrl = TextEditingController(
      text: widget.groupe.repondantNom ?? '',
    );
    _repondantTelephoneCtrl = TextEditingController(
      text: widget.groupe.repondantTelephone ?? '',
    );
    _nomCtrl.addListener(_programmerSauvegarde);
    _repondantNomCtrl.addListener(_programmerSauvegarde);
    _repondantTelephoneCtrl.addListener(_programmerSauvegarde);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timerIndicateur?.cancel();
    _nomCtrl.dispose();
    _repondantNomCtrl.dispose();
    _repondantTelephoneCtrl.dispose();
    super.dispose();
  }

  void _programmerSauvegarde() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), _sauvegarder);
  }

  Future<void> _sauvegarder() async {
    if (_nomCtrl.text.trim().isEmpty) return;
    await ref
        .read(uniformeRepositoryProvider)
        .actualiserGroupe(
          groupeId: widget.groupe.id,
          nom: _nomCtrl.text.trim(),
          repondantNom: _texteOuNull(_repondantNomCtrl.text),
          repondantTelephone: _texteOuNull(_repondantTelephoneCtrl.text),
        );
    if (!mounted) return;
    _timerIndicateur?.cancel();
    setState(() => _indicateurVisible = true);
    _timerIndicateur = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _indicateurVisible = false);
    });
  }

  String? _texteOuNull(String v) => v.trim().isEmpty ? null : v.trim();

  Future<void> _ajouterPhoto(String type) async {
    try {
      final photo = await choisirPhoto(context);
      if (photo == null) return;
      final File fichier = await ImageUtils.compresserEtPersister(
        File(photo.path),
      );
      await ref
          .read(uniformeRepositoryProvider)
          .ajouterPhotoGroupe(
            groupeId: widget.groupe.id,
            type: type,
            cheminLocal: fichier.path,
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Accès à la caméra ou à la galerie refusé. Vérifie les "
            "autorisations de l'application dans les paramètres du "
            'téléphone.',
          ),
        ),
      );
    }
  }

  Future<void> _supprimerPhoto(String photoId) async {
    try {
      await ref.read(uniformeRepositoryProvider).supprimerPhotoGroupe(photoId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de supprimer la photo : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<PhotoGroupeUniforme> photos =
        ref.watch(photosGroupeUniformeProvider(widget.groupe.id)).asData?.value ??
        const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le groupe')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.xxl,
        ),
        children: [
          IndicateurSauvegarde(visible: _indicateurVisible),
          const SizedBox(height: AppSpacing.s),
          SectionTitre(
            icone: Icons.groups_outlined,
            titre: 'Informations générales',
            couleur: AppColors.indigo700,
          ),
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: _nomCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nom du groupe / de la promotion / établissement',
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: _repondantNomCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nom et prénom du répondant',
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: _repondantTelephoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Contact téléphonique du répondant',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionPhotosModifiable(
            titre: 'Photos des modèles (hommes/garçons)',
            icone: Icons.checkroom_outlined,
            couleur: AppColors.succes,
            photos: photos.where((p) => p.type == 'modele_homme').toList(),
            onAjouter: () => _ajouterPhoto('modele_homme'),
            onSupprimer: _supprimerPhoto,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionPhotosModifiable(
            titre: 'Photos des modèles (femmes/filles)',
            icone: Icons.checkroom_outlined,
            couleur: AppColors.succes,
            photos: photos.where((p) => p.type == 'modele_femme').toList(),
            onAjouter: () => _ajouterPhoto('modele_femme'),
            onSupprimer: _supprimerPhoto,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionPhotosModifiable(
            titre: 'Photos des tissus (hommes/garçons)',
            icone: Icons.texture_outlined,
            couleur: AppColors.or600,
            photos: photos.where((p) => p.type == 'tissu_homme').toList(),
            onAjouter: () => _ajouterPhoto('tissu_homme'),
            onSupprimer: _supprimerPhoto,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionPhotosModifiable(
            titre: 'Photos des tissus (femmes/filles)',
            icone: Icons.texture_outlined,
            couleur: AppColors.or600,
            photos: photos.where((p) => p.type == 'tissu_femme').toList(),
            onAjouter: () => _ajouterPhoto('tissu_femme'),
            onSupprimer: _supprimerPhoto,
          ),
        ],
      ),
    );
  }
}

/// Galerie de photos déjà enregistrées, avec ajout et suppression
/// immédiats (chaque action s'enregistre aussitôt, pas de brouillon).
class _SectionPhotosModifiable extends StatelessWidget {
  const _SectionPhotosModifiable({
    required this.titre,
    required this.icone,
    required this.couleur,
    required this.photos,
    required this.onAjouter,
    required this.onSupprimer,
  });

  final String titre;
  final IconData icone;
  final Color couleur;
  final List<PhotoGroupeUniforme> photos;
  final VoidCallback onAjouter;
  final ValueChanged<String> onSupprimer;

  @override
  Widget build(BuildContext context) {
    final List<ElementPhoto> elements = [
      for (final PhotoGroupeUniforme p in photos)
        (cheminLocal: p.cheminLocal, url: p.url, commentaire: p.commentaire),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitre(icone: icone, titre: titre, couleur: couleur),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (int i = 0; i < photos.length; i++)
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => afficherPhotosPleinEcran(
                        context,
                        elements: elements,
                        indexInitial: i,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.champ),
                        child: imagePhoto(
                          cheminLocal: photos[i].cheminLocal,
                          url: photos[i].url,
                          width: 84,
                          height: 84,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => onSupprimer(photos[i].id),
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
