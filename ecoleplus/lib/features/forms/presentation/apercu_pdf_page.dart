import 'dart:typed_data';

import 'package:ecoleplus/core/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

/// Pages d'un PDF en images (remplacé dans les tests).
final rendrePagesProvider =
    Provider<Future<List<Uint8List>> Function(Uint8List pdf)>(
      (ref) =>
          (pdf) async => [
            await for (final page in Printing.raster(pdf, dpi: 160))
              await page.toPng(),
          ],
    );

/// Ce qu'il faut pour afficher l'aperçu : le PDF et son nom de fichier.
class ApercuPdf {
  const new(this.pdf, this.nom);
  final Uint8List pdf;
  final String nom;
}

/// Aperçu d'un document dans l'application : on agrandit avec deux doigts
/// (ou les boutons + et −) pour bien relire, puis on imprime ou partage.
class ApercuPdfPage extends ConsumerStatefulWidget {
  const new(this.apercu, {super.key});
  final ApercuPdf apercu;

  @override
  ConsumerState<ApercuPdfPage> createState() => _ApercuState();
}

class _ApercuState extends ConsumerState<ApercuPdfPage> {
  late final Future<List<Uint8List>> _pages = ref.read(rendrePagesProvider)(
    widget.apercu.pdf,
  );
  final _zoom = TransformationController();
  static const _max = 5.0;

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _changer(double facteur) {
    final actuel = _zoom.value.getMaxScaleOnAxis();
    final cible = (actuel * facteur).clamp(1.0, _max);
    setState(() {
      _zoom.value = Matrix4.diagonal3Values(cible, cible, 1);
    });
  }

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: 'Aperçu',
    showSync: false,
    body: Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Uint8List>>(
            future: _pages,
            builder: (context, snap) {
              if (snap.hasError) {
                return const InfoMessage(
                  'L’aperçu n’a pas pu s’afficher. Vous pouvez quand même '
                  'imprimer ou partager le document.',
                );
              }
              final pages = snap.data;
              if (pages == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return ColoredBox(
                color: Colors.grey.shade300,
                child: LayoutBuilder(
                  builder: (context, c) => InteractiveViewer(
                    key: const Key('apercu-zoom'),
                    transformationController: _zoom,
                    constrained: false,
                    minScale: 1,
                    maxScale: _max,
                    boundaryMargin: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: c.maxWidth,
                      child: Column(
                        children: [
                          for (final p in pages)
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 3,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                                child: Image.memory(p, fit: BoxFit.fitWidth),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text(
                  'Écartez deux doigts sur la page pour agrandir.',
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    IconButton(
                      key: const Key('apercu-moins'),
                      tooltip: 'Réduire',
                      icon: const Icon(Icons.zoom_out),
                      onPressed: () => _changer(1 / 1.5),
                    ),
                    IconButton(
                      key: const Key('apercu-plus'),
                      tooltip: 'Agrandir',
                      icon: const Icon(Icons.zoom_in),
                      onPressed: () => _changer(1.5),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      key: const Key('apercu-partager'),
                      icon: const Icon(Icons.share),
                      label: const Text('Partager'),
                      onPressed: () => Printing.sharePdf(
                        bytes: widget.apercu.pdf,
                        filename: widget.apercu.nom,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      key: const Key('apercu-imprimer'),
                      icon: const Icon(Icons.print),
                      label: const Text('Imprimer'),
                      onPressed: () => Printing.layoutPdf(
                        onLayout: (_) async => widget.apercu.pdf,
                        name: widget.apercu.nom,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
