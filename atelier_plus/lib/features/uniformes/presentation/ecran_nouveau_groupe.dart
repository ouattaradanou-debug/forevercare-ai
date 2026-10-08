import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/router/app_router.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../core/widgets/en_tete_section.dart';
import '../../../data/models/groupe_uniforme.dart';
import '../../../data/models/photo_client.dart';
import '../../../shared/widgets/grille_photos.dart';
import '../../../shared/widgets/selecteur_source_image.dart';
import '../../auth/providers/auth_providers.dart';
import '../../clients/providers/photos_providers.dart';
import '../providers/uniformes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Création d'un groupe d'uniformes en un seul écran : informations du
/// groupe/répondant, puis photos de tissu et de modèle (hommes/femmes).
/// Même principe que EcranNouveauClient : le groupe est créé dès la
/// première action qui en a besoin (ajout d'une photo, ou bouton final),
/// à partir des informations déjà saisies — et les photos passent par le
/// même GrillePhotosSection partagé avec "Nouveau client", donc toute
/// évolution future de la gestion des photos côté client s'applique
/// automatiquement ici aussi.
class EcranNouveauGroupe extends ConsumerStatefulWidget {
  const EcranNouveauGroupe({super.key});

  @override
  ConsumerState<EcranNouveauGroupe> createState() => _EcranNouveauGroupeState();
}

class _EcranNouveauGroupeState extends ConsumerState<EcranNouveauGroupe> {
  final _nomCtrl = TextEditingController();
  final _repondantNomCtrl = TextEditingController();
  final _repondantTelCtrl = TextEditingController();
  final Map<String, bool> _photoEnCours = {};
  final _dicteeVocale = stt.SpeechToText();

  GroupeUniforme? _groupe;
  bool _enregistrementGroupeEnCours = false;
  bool _enregistrementFinalEnCours = false;
  bool _dicteeDisponible = false;
  String? _champEnDictee;
  String? _erreur;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _repondantNomCtrl.dispose();
    _repondantTelCtrl.dispose();
    _dicteeVocale.stop();
    super.dispose();
  }

  /// Démarre/arrête la dictée vocale pour [champ] — même principe que
  /// EcranNouveauClient._basculerDictee : un seul champ à la fois peut être
  /// en cours de dictée.
  Future<void> _basculerDictee(
    String champ,
    TextEditingController controleur, {
    bool chiffresSeulement = false,
  }) async {
    if (_champEnDictee == champ) {
      await _dicteeVocale.stop();
      if (mounted) setState(() => _champEnDictee = null);
      return;
    }

    if (_champEnDictee != null) {
      await _dicteeVocale.stop();
    }

    if (!_dicteeDisponible) {
      _dicteeDisponible = await _dicteeVocale.initialize(
        onStatus: (statut) {
          if ((statut == 'done' || statut == 'notListening') && mounted) {
            setState(() => _champEnDictee = null);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _champEnDictee = null);
        },
      );
      if (!_dicteeDisponible) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dictée vocale indisponible sur cet appareil.')),
          );
        }
        return;
      }
    }

    setState(() => _champEnDictee = champ);
    await _dicteeVocale.listen(
      localeId: 'fr_FR',
      onResult: (resultat) {
        var texte = resultat.recognizedWords;
        if (chiffresSeulement) {
          texte = texte.replaceAll(RegExp(r'[^0-9]'), '');
        }
        controleur.text = texte;
        controleur.selection = TextSelection.collapsed(offset: controleur.text.length);
        if (mounted) setState(() {});
      },
    );
  }

  /// Crée le groupe si ce n'est pas déjà fait, à partir des informations
  /// actuellement saisies. Retourne `null` (et affiche une erreur) si le
  /// nom n'est pas encore rempli — voir EcranNouveauClient._assurerClientCree.
  Future<GroupeUniforme?> _assurerGroupeCree() async {
    if (_groupe != null) return _groupe;

    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) {
      setState(() => _erreur = 'Renseignez le nom du groupe avant de continuer.');
      return null;
    }

    setState(() {
      _enregistrementGroupeEnCours = true;
      _erreur = null;
    });
    try {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      final repondantNom = _repondantNomCtrl.text.trim();
      final repondantTel = _repondantTelCtrl.text.trim();
      final groupe = await ref.read(groupesUniformesRepositoryProvider).creerGroupe(
            atelierId: utilisateur!.atelierId,
            nom: nom,
            repondantNom: repondantNom.isEmpty ? null : repondantNom,
            repondantTelephone: repondantTel.isEmpty ? null : repondantTel,
          );
      if (mounted) setState(() => _groupe = groupe);
      return groupe;
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
      return null;
    } finally {
      if (mounted) setState(() => _enregistrementGroupeEnCours = false);
    }
  }

  String _cleEnCours(TypePhoto type, String sexe) => '${type.name}_$sexe';

  Future<void> _ajouterPhoto(TypePhoto type, String sexe) async {
    final groupe = await _assurerGroupeCree();
    if (groupe == null || !mounted) return;

    final resultat = await choisirSourceEtImage(context);
    if (resultat == null || !mounted) return;
    final (fichier, sourceImage) = resultat;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null || !mounted) return;

    final cle = _cleEnCours(type, sexe);
    setState(() => _photoEnCours[cle] = true);
    try {
      await ref.read(photosRepositoryProvider).ajouterPhoto(
            atelierId: utilisateur.atelierId,
            groupeId: groupe.id,
            sexe: sexe,
            type: type,
            source: sourceImage == ImageSource.camera ? SourcePhoto.camera : SourcePhoto.galerie,
            fichier: fichier,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'envoi : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _photoEnCours[cle] = false);
    }
  }

  /// Termine la création : crée le groupe si besoin, synchronise une
  /// dernière fois le nom/répondant si modifiés après coup (ex. après
  /// l'avoir créé en ajoutant une photo avant de remplir le répondant),
  /// puis ouvre le détail du groupe.
  Future<void> _terminer() async {
    final groupe = await _assurerGroupeCree();
    if (groupe == null || !mounted) return;

    final nom = _nomCtrl.text.trim();
    final repondantNom = _repondantNomCtrl.text.trim();
    final repondantTel = _repondantTelCtrl.text.trim();
    final repondantNomActuel = repondantNom.isEmpty ? null : repondantNom;
    final repondantTelActuel = repondantTel.isEmpty ? null : repondantTel;

    if (nom != groupe.nom ||
        repondantNomActuel != groupe.repondantNom ||
        repondantTelActuel != groupe.repondantTelephone) {
      setState(() => _enregistrementFinalEnCours = true);
      await executerAvecErreurAffichee(
        context,
        () => ref.read(groupesUniformesRepositoryProvider).modifierGroupe(
              groupe: groupe,
              nom: nom,
              repondantNom: repondantNomActuel,
              repondantTelephone: repondantTelActuel,
            ),
      );
      if (mounted) setState(() => _enregistrementFinalEnCours = false);
    }
    if (!mounted) return;
    context.pushReplacement(AppRoutes.detailGroupeUniforme(groupe.id));
  }

  @override
  Widget build(BuildContext context) {
    final photosGroupe = _groupe == null
        ? const <PhotoClient>[]
        : ref.watch(photosDuGroupeProvider(_groupe!.id)).valueOrNull ?? const [];
    List<PhotoClient> filtrerPhotos(TypePhoto type, String sexe) =>
        photosGroupe.where((p) => p.type == type && p.sexe == sexe).toList();

    final enCours = _enregistrementGroupeEnCours || _enregistrementFinalEnCours;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      appBar: AppBar(
        title: const Text('Nouveau groupe'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EnTeteSection(
                    icone: Icons.groups_outlined,
                    couleurFond: const Color(0xFFE3E1F5),
                    couleurIcone: const Color(0xFF3B3470),
                    titre: 'Informations du groupe',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nom du groupe',
                      hintText: 'Ex. : Promotion 2026, Équipe commerciale...',
                      prefixIcon: IconButton(
                        icon: Icon(_champEnDictee == 'nom' ? Icons.mic : Icons.mic_none),
                        color: _champEnDictee == 'nom' ? Colors.red : _bleuSeda,
                        tooltip: 'Dicter le nom du groupe',
                        onPressed: () => _basculerDictee('nom', _nomCtrl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _repondantNomCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nom du répondant (optionnel)',
                      prefixIcon: IconButton(
                        icon: Icon(_champEnDictee == 'repondantNom' ? Icons.mic : Icons.mic_none),
                        color: _champEnDictee == 'repondantNom' ? Colors.red : _bleuSeda,
                        tooltip: 'Dicter le nom du répondant',
                        onPressed: () => _basculerDictee('repondantNom', _repondantNomCtrl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _repondantTelCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Téléphone du répondant (optionnel)',
                      prefixIcon: IconButton(
                        icon: Icon(_champEnDictee == 'repondantTel' ? Icons.mic : Icons.mic_none),
                        color: _champEnDictee == 'repondantTel' ? Colors.red : _bleuSeda,
                        tooltip: 'Dicter le téléphone du répondant',
                        onPressed: () => _basculerDictee(
                          'repondantTel',
                          _repondantTelCtrl,
                          chiffresSeulement: true,
                        ),
                      ),
                    ),
                  ),
                  if (_erreur != null) ...[
                    const SizedBox(height: 12),
                    Text(_erreur!, style: const TextStyle(color: Color(0xFFB3261E))),
                  ],
                  const SizedBox(height: 28),
                  EnTeteSection(
                    icone: Icons.texture_outlined,
                    couleurFond: const Color(0xFFF0E6C8),
                    couleurIcone: const Color(0xFFA47B1B),
                    titre: 'Photos du tissu',
                  ),
                  const SizedBox(height: 12),
                  LigneSexesPhotos(
                    photosHomme: filtrerPhotos(TypePhoto.tissu, 'Homme'),
                    photosFemme: filtrerPhotos(TypePhoto.tissu, 'Femme'),
                    enCoursHomme: _photoEnCours[_cleEnCours(TypePhoto.tissu, 'Homme')] ?? false,
                    enCoursFemme: _photoEnCours[_cleEnCours(TypePhoto.tissu, 'Femme')] ?? false,
                    onAjouterHomme: () => _ajouterPhoto(TypePhoto.tissu, 'Homme'),
                    onAjouterFemme: () => _ajouterPhoto(TypePhoto.tissu, 'Femme'),
                  ),
                  const SizedBox(height: 28),
                  EnTeteSection(
                    icone: Icons.checkroom_outlined,
                    couleurFond: const Color(0xFFDCEADF),
                    couleurIcone: const Color(0xFF2E7D32),
                    titre: 'Photos du ou des modèles',
                  ),
                  const SizedBox(height: 12),
                  LigneSexesPhotos(
                    photosHomme: filtrerPhotos(TypePhoto.modele, 'Homme'),
                    photosFemme: filtrerPhotos(TypePhoto.modele, 'Femme'),
                    enCoursHomme: _photoEnCours[_cleEnCours(TypePhoto.modele, 'Homme')] ?? false,
                    enCoursFemme: _photoEnCours[_cleEnCours(TypePhoto.modele, 'Femme')] ?? false,
                    onAjouterHomme: () => _ajouterPhoto(TypePhoto.modele, 'Homme'),
                    onAjouterFemme: () => _ajouterPhoto(TypePhoto.modele, 'Femme'),
                  ),
                ],
              ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6F1),
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: FilledButton(
            onPressed: enCours ? null : _terminer,
            style: FilledButton.styleFrom(
              backgroundColor: _orangeSeda,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            child: enCours
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enregistrer le groupe'),
          ),
        ),
      ),
    );
  }
}
