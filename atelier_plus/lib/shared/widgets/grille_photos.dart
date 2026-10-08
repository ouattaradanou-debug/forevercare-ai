import 'package:audioplayers/audioplayers.dart';
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

  void _ouvrirPleinEcran() => ouvrirPhotoPleinEcran(context, widget.photo.url);

  @override
  Widget build(BuildContext context) {
    final aUnAudio = widget.photo.audioUrl != null;

    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _ouvrirPleinEcran,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(widget.photo.url, width: 90, height: 90, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          if (_enCoursEnvoi)
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
