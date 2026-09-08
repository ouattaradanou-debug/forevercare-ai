import 'dart:io';

import 'package:flutter/material.dart';

/// Ouvre une ou plusieurs photos en plein écran, avec zoom (pincer) et
/// défilement entre les photos d'une même galerie (glisser à gauche/droite).
Future<void> afficherPhotosPleinEcran(
  BuildContext context, {
  required List<String> chemins,
  required int indexInitial,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => _VisionneusePhotoPage(
        chemins: chemins,
        indexInitial: indexInitial,
      ),
    ),
  );
}

class _VisionneusePhotoPage extends StatefulWidget {
  const _VisionneusePhotoPage({
    required this.chemins,
    required this.indexInitial,
  });

  final List<String> chemins;
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.chemins.length > 1
            ? Text('${_indexCourant + 1} / ${widget.chemins.length}')
            : null,
      ),
      body: PageView.builder(
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
    );
  }
}
