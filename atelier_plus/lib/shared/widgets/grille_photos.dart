import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../core/widgets/ecran_photo_plein_ecran.dart';
import '../../data/models/photo_client.dart';
import '../../features/clients/providers/photos_providers.dart';

const Color _bleuSeda = Color(0xFF1B4FA0);
const Color _orangeSeda = Color(0xFFF5821F);

/// Grille de vignettes photo (voir [TuilePhoto]) + bouton d'ajout, partagée
/// entre la fiche client ("Nouveau client") et un groupe d'uniformes : toute
/// évolution de cette grille ou de ses vignettes (ajout/lecture/suppression
/// de note vocale, etc.) s'applique donc automatiquement partout où elle est
/// utilisée, sans duplication de code.
class GrillePhotosSection extends StatelessWidget {
  const GrillePhotosSection({
    super.key,
    required this.photos,
    required this.enCours,
    required this.onAjouter,
  });

  final List<PhotoClient> photos;
  final bool enCours;
  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final photo in photos) TuilePhoto(photo: photo),
        InkWell(
          onTap: enCours ? null : onAjouter,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDD3C8)),
            ),
            child: enCours
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_a_photo_outlined),
          ),
        ),
      ],
    );
  }
}

/// Petit titre ("Tissu", "Modèle") au-dessus d'une [LigneSexesPhotos] —
/// partagé entre le détail d'un groupe et sa création.
class SousTitrePhotos extends StatelessWidget {
  const SousTitrePhotos(this.titre, {super.key});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Text(
        titre,
        style: const TextStyle(fontWeight: FontWeight.bold, color: _bleuSeda, fontSize: 13),
      ),
    );
  }
}

/// Deux colonnes Hommes/Femmes côte à côte pour une même catégorie de photo
/// (tissu ou modèle) d'un groupe d'uniformes — partagé entre le détail d'un
/// groupe et sa création, afin que toute évolution de cette disposition
/// s'applique aux deux écrans.
class LigneSexesPhotos extends StatelessWidget {
  const LigneSexesPhotos({
    super.key,
    required this.photosHomme,
    required this.photosFemme,
    required this.enCoursHomme,
    required this.enCoursFemme,
    required this.onAjouterHomme,
    required this.onAjouterFemme,
  });

  final List<PhotoClient> photosHomme;
  final List<PhotoClient> photosFemme;
  final bool enCoursHomme;
  final bool enCoursFemme;
  final VoidCallback onAjouterHomme;
  final VoidCallback onAjouterFemme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ColonneSexePhotos(
            libelle: 'Hommes',
            photos: photosHomme,
            enCours: enCoursHomme,
            onAjouter: onAjouterHomme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ColonneSexePhotos(
            libelle: 'Femmes',
            photos: photosFemme,
            enCours: enCoursFemme,
            onAjouter: onAjouterFemme,
          ),
        ),
      ],
    );
  }
}

class _ColonneSexePhotos extends StatelessWidget {
  const _ColonneSexePhotos({
    required this.libelle,
    required this.photos,
    required this.enCours,
    required this.onAjouter,
  });

  final String libelle;
  final List<PhotoClient> photos;
  final bool enCours;
  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: const TextStyle(fontSize: 12, color: Color(0xFF6F6259))),
        const SizedBox(height: 6),
        GrillePhotosSection(photos: photos, enCours: enCours, onAjouter: onAjouter),
      ],
    );
  }
}

/// Vignette d'une photo avec, en superposition, le contrôle de note vocale
/// de description : un micro tant qu'aucun vocal n'existe (appui = démarre,
/// appui = arrête et envoie), puis un bouton lecture/pause une fois un
/// vocal enregistré.
class TuilePhoto extends ConsumerStatefulWidget {
  const TuilePhoto({super.key, required this.photo});

  final PhotoClient photo;

  @override
  ConsumerState<TuilePhoto> createState() => _TuilePhotoState();
}

class _TuilePhotoState extends ConsumerState<TuilePhoto> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _enregistrement = false;
  bool _enCoursEnvoi = false;
  bool _lecture = false;
  bool _suppressionEnCours = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _lecture = false);
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _basculerEnregistrement() async {
    if (_enregistrement) {
      final chemin = await _recorder.stop();
      if (mounted) setState(() => _enregistrement = false);
      if (chemin == null) return;

      setState(() => _enCoursEnvoi = true);
      try {
        await ref.read(photosRepositoryProvider).ajouterAudioAPhoto(
              photo: widget.photo,
              cheminFichierAudio: chemin,
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'envoi du vocal : $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _enCoursEnvoi = false);
      }
      return;
    }

    if (!await _recorder.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autorisez le micro pour enregistrer une note vocale.')),
        );
      }
      return;
    }

    if (_lecture) {
      await _player.stop();
      if (mounted) setState(() => _lecture = false);
    }

    final dossierTemp = await getTemporaryDirectory();
    final chemin = p.join(dossierTemp.path, '${const Uuid().v4()}.m4a');
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: chemin);
    if (mounted) setState(() => _enregistrement = true);
  }

  Future<void> _basculerLecture() async {
    if (_lecture) {
      await _player.pause();
      if (mounted) setState(() => _lecture = false);
    } else {
      await _player.play(UrlSource(widget.photo.audioUrl!));
      if (mounted) setState(() => _lecture = true);
    }
  }

  Future<void> _supprimerAudio() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le vocal ?'),
        content: const Text('Cette note vocale sera retirée de cette photo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    if (_lecture) {
      await _player.stop();
      if (mounted) setState(() => _lecture = false);
    }

    setState(() => _enCoursEnvoi = true);
    try {
      await ref.read(photosRepositoryProvider).supprimerAudioDePhoto(widget.photo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enCoursEnvoi = false);
    }
  }

  void _ouvrirPleinEcran() => ouvrirPhotoPleinEcran(
        context,
        widget.photo.url,
        cheminLocal: widget.photo.cheminLocalEnAttente,
      );

  /// Supprime définitivement la photo (pas seulement sa note vocale) —
  /// demande confirmation, comme pour un groupe ou un client.
  Future<void> _supprimerPhoto() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette photo ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    if (_lecture) {
      await _player.stop();
      if (mounted) setState(() => _lecture = false);
    }

    setState(() => _suppressionEnCours = true);
    try {
      await ref.read(photosRepositoryProvider).supprimerPhoto(widget.photo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _suppressionEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aUnAudio = widget.photo.audioUrl != null;
    final enAttenteEnvoi = widget.photo.enAttenteEnvoi;

    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _ouvrirPleinEcran,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: enAttenteEnvoi
                      ? Image.file(
                          File(widget.photo.cheminLocalEnAttente!),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.photo.url,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration.zero,
                          placeholder: (context, url) => Container(
                            width: 90,
                            height: 90,
                            color: const Color(0xFFEDEAE4),
                            child: const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 90,
                            height: 90,
                            color: const Color(0xFFEDEAE4),
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: Color(0xFF6F6259),
                            ),
                          ),
                        ),
                ),
              ),
              // Photo ajoutée hors-ligne, pas encore envoyée : le tailleur
              // doit comprendre qu'elle n'est pour l'instant que sur son
              // téléphone (voir PhotoUploadQueue, qui l'enverra
              // automatiquement dès le retour de la connexion).
              if (enAttenteEnvoi && !_suppressionEnCours)
                Positioned(
                  bottom: 4,
                  left: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 11, color: Colors.white),
                        SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'En attente',
                            style: TextStyle(fontSize: 9, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_suppressionEnCours)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black38,
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  top: -6,
                  right: -6,
                  child: _BoutonRondPhoto(
                    icone: Icons.close,
                    couleurFond: const Color(0xFF8A2E2E),
                    onTap: _supprimerPhoto,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (enAttenteEnvoi)
            // Pas de note vocale possible avant l'envoi de la photo
            // elle-même (voir PhotosRepository.ajouterAudioAPhoto).
            const SizedBox(height: 28)
          else if (_enCoursEnvoi)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_enregistrement)
            _BoutonRondPhoto(
              icone: Icons.stop,
              couleurFond: Colors.red,
              onTap: _basculerEnregistrement,
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (aUnAudio) ...[
                  _BoutonRondPhoto(
                    icone: _lecture ? Icons.pause : Icons.play_arrow,
                    couleurFond: _bleuSeda,
                    onTap: _basculerLecture,
                  ),
                  const SizedBox(width: 3),
                ],
                _BoutonRondPhoto(
                  icone: Icons.mic,
                  couleurFond: aUnAudio ? _orangeSeda : _bleuSeda,
                  onTap: _basculerEnregistrement,
                ),
                if (aUnAudio) ...[
                  const SizedBox(width: 3),
                  _BoutonRondPhoto(
                    icone: Icons.delete_outline,
                    couleurFond: const Color(0xFF8A2E2E),
                    onTap: _supprimerAudio,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _BoutonRondPhoto extends StatelessWidget {
  const _BoutonRondPhoto({required this.icone, required this.couleurFond, required this.onTap});

  final IconData icone;
  final Color couleurFond;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: couleurFond,
        child: Icon(icone, size: 16, color: Colors.white),
      ),
    );
  }
}
