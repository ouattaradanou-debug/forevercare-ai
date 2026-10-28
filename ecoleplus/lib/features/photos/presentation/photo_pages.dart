import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/photos/data/photos_repository.dart';
import 'package:ecoleplus/features/photos/domain/traitement_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final photosRepositoryProvider = Provider<PhotosRepository>(
  (ref) => PhotosRepository(
    ref.watch(localStoreProvider),
    mediaDir: ref.watch(mediaDirProvider),
  ),
);

/// Choix d'une image : caméra (téléphone) ou galerie / fichier. Remplacé
/// dans les tests.
typedef ChoisirImage = Future<Uint8List?> Function({required bool camera});

final choisirImageProvider = Provider<ChoisirImage>(
  (ref) => ({required camera}) async {
    final f = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    return f == null ? null : await f.readAsBytes();
  },
);

/// Caméra disponible : téléphone seulement (sur l'ordinateur, « Choisir une
/// image » depuis un fichier).
final cameraDisponibleProvider = Provider<bool>(
  (ref) => Platform.isAndroid || Platform.isIOS,
);

/// Prend ou choisit une image, la fait recadrer, puis la compresse.
/// [ratio] : largeur / hauteur du cadre (3/4 pour une photo d'identité).
Future<Uint8List?> obtenirImage(
  BuildContext context,
  WidgetRef ref, {
  required bool camera,
  double ratio = 3 / 4,
  bool logo = false,
}) async {
  final brute = await ref.read(choisirImageProvider)(camera: camera);
  if (brute == null || !context.mounted) return null;
  final r = await Navigator.of(context).push<Recadrage>(
    MaterialPageRoute(
      builder: (_) => RecadragePage(brute, ratio: ratio, logo: logo),
    ),
  );
  if (r == null) return null;
  return logo ? await preparerLogo(brute, r) : await preparerPhoto(brute, r);
}

/// Cadre de recadrage : déplacez et agrandissez l'image avec les doigts
/// pour placer le visage dans le cadre.
class RecadragePage extends StatefulWidget {
  const new(this.octets, {this.ratio = 3 / 4, this.logo = false, super.key});
  final Uint8List octets;
  final double ratio;
  final bool logo;

  @override
  State<RecadragePage> createState() => _RecadrageState();
}

class _RecadrageState extends State<RecadragePage> {
  final _controle = TransformationController();
  ui.Size? _taille;
  late Size _cadre;
  late double _echelle;

  @override
  void initState() {
    super.initState();
    ui.decodeImageFromList(widget.octets, (i) {
      if (mounted) {
        setState(
          () => _taille = ui.Size(i.width.toDouble(), i.height.toDouble()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  /// Zone visible dans le cadre, en fractions de l'image.
  Recadrage _zone() {
    final t = _taille!;
    final c = _cadre;
    final inverse = Matrix4.inverted(_controle.value);
    final a = MatrixUtils.transformPoint(inverse, Offset.zero);
    final b = MatrixUtils.transformPoint(inverse, Offset(c.width, c.height));
    final l = t.width * _echelle;
    final h = t.height * _echelle;
    return Recadrage(
      (a.dx / l).clamp(0, 1),
      (a.dy / h).clamp(0, 1),
      ((b.dx - a.dx) / l).clamp(0, 1),
      ((b.dy - a.dy) / h).clamp(0, 1),
    );
  }

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: widget.logo ? 'Cadrer le logo' : 'Cadrer la photo',
    showSync: false,
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            widget.logo
                ? 'Déplacez et agrandissez l’image pour placer le logo dans '
                      'le cadre.'
                : 'Déplacez et agrandissez la photo avec deux doigts : le '
                      'visage au centre du cadre, les épaules en bas.',
          ),
        ),
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (context, contraintes) {
                final t = _taille;
                if (t == null) return const CircularProgressIndicator();
                var w = contraintes.maxWidth * 0.9;
                var h = w / widget.ratio;
                if (h > contraintes.maxHeight * 0.95) {
                  h = contraintes.maxHeight * 0.95;
                  w = h * widget.ratio;
                }
                _cadre = Size(w, h);
                // L'image couvre tout le cadre au départ.
                _echelle = [
                  w / t.width,
                  h / t.height,
                ].reduce((a, b) => a > b ? a : b);
                final l = t.width * _echelle;
                final hh = t.height * _echelle;
                if (_controle.value.isIdentity()) {
                  _controle.value = Matrix4.translationValues(
                    (w - l) / 2,
                    (h - hh) / 2,
                    0,
                  );
                }
                return Container(
                  key: const Key('cadre-photo'),
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipRect(
                    child: InteractiveViewer(
                      transformationController: _controle,
                      constrained: false,
                      maxScale: 6,
                      child: SizedBox(
                        width: l,
                        height: hh,
                        child: Image.memory(widget.octets, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            key: const Key('valider-cadre'),
            icon: const Icon(Icons.check),
            label: const Text('Garder ce cadre'),
            onPressed: _taille == null
                ? null
                : () => Navigator.of(context).pop(_zone()),
          ),
        ),
      ],
    ),
  );
}

/// Photo d'un élève sur sa fiche : affichage, prise, remplacement, retrait.
class PhotoEleve extends ConsumerStatefulWidget {
  const new({required this.eleve, required this.modifiable, super.key});
  final StudentRow eleve;
  final bool modifiable;

  @override
  ConsumerState<PhotoEleve> createState() => _PhotoEleveState();
}

class _PhotoEleveState extends ConsumerState<PhotoEleve> {
  bool _occupe = false;

  Future<void> _prendre({required bool camera}) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final jpeg = await obtenirImage(context, ref, camera: camera);
      if (jpeg != null) {
        await ref
            .read(photosRepositoryProvider)
            .enregistrerPhoto(widget.eleve, jpeg);
      }
    });
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(photosRepositoryProvider);
    final f = repo.fichier(widget.eleve.photoPath);
    final camera = ref.watch(cameraDisponibleProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const Key('photo-eleve'),
            width: 90,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.grey.shade200,
            ),
            child: f != null
                ? Image.file(f, key: ValueKey(f.path), fit: BoxFit.cover)
                : widget.eleve.photoPath != null
                ? const Center(
                    child: Text(
                      'Photo en cours de réception',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                  )
                : const Icon(Icons.person, size: 64, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          if (widget.modifiable)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (camera)
                    OutlinedButton.icon(
                      key: const Key('prendre-photo'),
                      icon: const Icon(Icons.photo_camera),
                      label: Text(
                        widget.eleve.photoPath == null
                            ? 'Prendre la photo'
                            : 'Reprendre la photo',
                      ),
                      onPressed: _occupe ? null : () => _prendre(camera: true),
                    ),
                  OutlinedButton.icon(
                    key: const Key('choisir-photo'),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      camera ? 'Choisir dans la galerie' : 'Choisir une image',
                    ),
                    onPressed: _occupe ? null : () => _prendre(camera: false),
                  ),
                  if (widget.eleve.photoPath != null)
                    TextButton.icon(
                      key: const Key('retirer-photo'),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Retirer la photo'),
                      onPressed: _occupe
                          ? null
                          : () async {
                              final ok = await confirmer(
                                context,
                                titre: 'Retirer la photo ?',
                                message:
                                    'La photo ne figurera plus sur la carte '
                                    'scolaire. La photo est facultative.',
                                bouton: 'Retirer',
                              );
                              if (ok) {
                                await repo.retirerPhoto(widget.eleve);
                              }
                            },
                    ),
                  if (_occupe) const LinearProgressIndicator(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Logo de l'école (facultatif) : imprimé sur les cartes scolaires.
class LogoEcole extends ConsumerStatefulWidget {
  const new({required this.ecole, super.key});
  final SchoolRow ecole;

  @override
  ConsumerState<LogoEcole> createState() => _LogoEcoleState();
}

class _LogoEcoleState extends ConsumerState<LogoEcole> {
  bool _occupe = false;

  Future<void> _choisir({required bool camera}) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final jpeg = await obtenirImage(
        context,
        ref,
        camera: camera,
        ratio: 1,
        logo: true,
      );
      if (jpeg != null) {
        await ref
            .read(photosRepositoryProvider)
            .enregistrerLogo(widget.ecole, jpeg);
      }
    });
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(photosRepositoryProvider);
    final f = repo.fichier(widget.ecole.logoPath);
    final camera = ref.watch(cameraDisponibleProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Logo de l’école (facultatif)'),
        const Text(
          'S’il existe, il s’imprime sur les cartes scolaires. Photographiez '
          'le logo bien à plat, sur fond clair.',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              key: const Key('logo-ecole'),
              width: 72,
              height: 72,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: f != null
                  ? Image.file(f, key: ValueKey(f.path), fit: BoxFit.contain)
                  : const Icon(Icons.image_outlined, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [
                  if (camera)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Photographier'),
                      onPressed: _occupe ? null : () => _choisir(camera: true),
                    ),
                  OutlinedButton.icon(
                    key: const Key('choisir-logo'),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choisir une image'),
                    onPressed: _occupe ? null : () => _choisir(camera: false),
                  ),
                  if (widget.ecole.logoPath != null)
                    TextButton(
                      onPressed: _occupe
                          ? null
                          : () => repo.retirerLogo(widget.ecole),
                      child: const Text('Retirer'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
