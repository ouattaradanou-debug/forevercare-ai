import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../../../../shared/widgets/selecteur_photo.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../clients/presentation/widgets/section_photos.dart';
import '../../../clients/presentation/widgets/section_titre.dart';
import '../providers/uniformes_providers.dart';

/// Création d'un groupe d'uniformes : informations générales, répondant et
/// son contact, photos de modèles/tissus (hommes/garçons et femmes/filles).
/// Une fois enregistré, ouvre directement la fiche du groupe pour
/// commencer à y ajouter des membres.
class NouveauGroupeUniformePage extends ConsumerStatefulWidget {
  const NouveauGroupeUniformePage({super.key});

  @override
  ConsumerState<NouveauGroupeUniformePage> createState() =>
      _NouveauGroupeUniformePageState();
}

class _NouveauGroupeUniformePageState
    extends ConsumerState<NouveauGroupeUniformePage> {
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _repondantNomCtrl = TextEditingController();
  final TextEditingController _repondantTelephoneCtrl = TextEditingController();

  final Map<String, List<String>> _photos = {
    'modele_homme': [],
    'modele_femme': [],
    'tissu_homme': [],
    'tissu_femme': [],
  };
  final Map<String, String> _commentaires = {};

  bool _enregistrementEnCours = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _repondantNomCtrl.dispose();
    _repondantTelephoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _ajouterPhoto(String type) async {
    try {
      final photo = await choisirPhoto(context);
      if (photo == null) return;
      final File fichier = await ImageUtils.compresserEtPersister(
        File(photo.path),
      );
      setState(() => _photos[type] = [...?_photos[type], fichier.path]);
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

  void _supprimerPhoto(String type, String chemin) {
    setState(
      () => _photos[type] = (_photos[type] ?? []).where((c) => c != chemin).toList(),
    );
  }

  void _definirCommentaire(String chemin, String commentaire) {
    setState(() => _commentaires[chemin] = commentaire);
  }

  Future<void> _enregistrer() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    final String? atelierId = ref.read(atelierCourantProvider).asData?.value?.id;
    if (atelierId == null) return;

    setState(() => _enregistrementEnCours = true);
    try {
      final GroupeUniforme groupe = await ref
          .read(uniformeRepositoryProvider)
          .creerGroupe(
            atelierId: atelierId,
            nom: _nomCtrl.text.trim(),
            repondantNom: _texteOuNull(_repondantNomCtrl.text),
            repondantTelephone: _texteOuNull(_repondantTelephoneCtrl.text),
            cheminsPhotosParType: _photos,
            commentairesPhotos: _commentaires,
          );
      if (mounted) {
        context.pushReplacement('/uniformes/${groupe.id}', extra: groupe);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'enregistrer le groupe : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  String? _texteOuNull(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau groupe')),
      body: Form(
        key: _cleFormulaire,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xxl,
          ),
          children: [
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
                hintText: 'Ex. Promotion 2026 – Lycée X',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Le nom du groupe est obligatoire'
                  : null,
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
            SectionPhotos(
              titre: 'Photos des modèles (hommes/garçons)',
              icone: Icons.checkroom_outlined,
              couleur: AppColors.succes,
              chemins: _photos['modele_homme']!,
              onAjouter: () => _ajouterPhoto('modele_homme'),
              onSupprimer: (c) => _supprimerPhoto('modele_homme', c),
              commentaires: _commentaires,
              onCommentaireChange: _definirCommentaire,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionPhotos(
              titre: 'Photos des modèles (femmes/filles)',
              icone: Icons.checkroom_outlined,
              couleur: AppColors.succes,
              chemins: _photos['modele_femme']!,
              onAjouter: () => _ajouterPhoto('modele_femme'),
              onSupprimer: (c) => _supprimerPhoto('modele_femme', c),
              commentaires: _commentaires,
              onCommentaireChange: _definirCommentaire,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionPhotos(
              titre: 'Photos des tissus (hommes/garçons)',
              icone: Icons.texture_outlined,
              couleur: AppColors.or600,
              chemins: _photos['tissu_homme']!,
              onAjouter: () => _ajouterPhoto('tissu_homme'),
              onSupprimer: (c) => _supprimerPhoto('tissu_homme', c),
              commentaires: _commentaires,
              onCommentaireChange: _definirCommentaire,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionPhotos(
              titre: 'Photos des tissus (femmes/filles)',
              icone: Icons.texture_outlined,
              couleur: AppColors.or600,
              chemins: _photos['tissu_femme']!,
              onAjouter: () => _ajouterPhoto('tissu_femme'),
              onSupprimer: (c) => _supprimerPhoto('tissu_femme', c),
              commentaires: _commentaires,
              onCommentaireChange: _definirCommentaire,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _enregistrementEnCours ? null : _enregistrer,
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Enregistrer le groupe'),
            ),
          ],
        ),
      ),
    );
  }
}
