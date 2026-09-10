import 'package:flutter/material.dart';

import 'image_photo.dart';

/// Un élément affichable par [afficherPhotosPleinEcran] : soit une photo
/// déjà persistée (`url` éventuellement renseignée), soit une photo encore
/// en cours de composition dans un formulaire (toujours locale, `url`
/// nulle) — les deux usages existants dans l'application, voir
/// ClientDetailPage et SectionPhotos.
typedef ElementPhoto = ({String cheminLocal, String? url, String? commentaire});

/// Ouvre une ou plusieurs photos en plein écran, avec zoom (pincer) et
/// défilement entre les photos d'une même galerie (glisser à gauche/droite).
/// Le commentaire de chaque photo (ex. le type de tissu), s'il y en a un,
/// s'affiche en légende. Fonctionne aussi bien pour une photo présente
/// localement que reçue d'un autre appareil (voir imagePhoto).
Future<void> afficherPhotosPleinEcran(
  BuildContext context, {
  required List<ElementPhoto> elements,
  required int indexInitial,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => _VisionneusePhotoPage(
        elements: elements,
        indexInitial: indexInitial,
      ),
    ),
  );
}

class _VisionneusePhotoPage extends StatefulWidget {
  const _VisionneusePhotoPage({
    required this.elements,
    required this.indexInitial,
  });

  final List<ElementPhoto> elements;
  final int indexInitial;

  @override
  State<_VisionneusePhotoPage> createState() => _VisionneusePhotoPageState();
}

class _VisionneusePhotoPageState extends State<_VisionneusePhotoPage> {
  late final PageController _controleur = PageController(
    initialPage: widget.indexInitial,
  );
  late int _indexCourant = widget.indexInitial;

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? commentaireCourant = widget.elements[_indexCourant].commentaire;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.elements.length > 1
            ? Text('${_indexCourant + 1} / ${widget.elements.length}')
            : null,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controleur,
            itemCount: widget.elements.length,
            onPageChanged: (i) => setState(() => _indexCourant = i),
            itemBuilder: (context, index) {
              final ElementPhoto element = widget.elements[index];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: imagePhoto(
                    cheminLocal: element.cheminLocal,
                    url: element.url,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          if (commentaireCourant != null && commentaireCourant.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: Colors.black54,
                child: Text(
                  commentaireCourant,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
