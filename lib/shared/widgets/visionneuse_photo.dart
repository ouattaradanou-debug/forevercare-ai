import 'dart:io';

import 'package:flutter/material.dart';

/// Ouvre une ou plusieurs photos en plein écran, avec zoom (pincer) et
/// défilement entre les photos d'une même galerie (glisser à gauche/droite).
/// `commentaires`, si fourni, doit avoir la même longueur que `chemins` :
/// affiché en légende sous chaque photo (ex. le type de tissu).
Future<void> afficherPhotosPleinEcran(
  BuildContext context, {
  required List<String> chemins,
  required int indexInitial,
  List<String?>? commentaires,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => _VisionneusePhotoPage(
        chemins: chemins,
        indexInitial: indexInitial,
        commentaires: commentaires,
      ),
    ),
  );
}

class _VisionneusePhotoPage extends StatefulWidget {
  const _VisionneusePhotoPage({
    required this.chemins,
    required this.indexInitial,
    this.commentaires,
  });

  final List<String> chemins;
  final int indexInitial;
  final List<String?>? commentaires;

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
    final String? commentaireCourant =
        widget.commentaires != null &&
            _indexCourant < widget.commentaires!.length
        ? widget.commentaires![_indexCourant]
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.chemins.length > 1
            ? Text('${_indexCourant + 1} / ${widget.chemins.length}')
            : null,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controleur,
            itemCount: widget.chemins.length,
            onPageChanged: (i) => setState(() => _indexCourant = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.file(File(widget.chemins[index])),
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
