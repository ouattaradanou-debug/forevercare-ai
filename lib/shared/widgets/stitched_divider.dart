import 'package:flutter/material.dart';

/// Séparateur en forme de point de couture (fil pointillé).
///
/// Détail d'identité visuelle discret mais distinctif, qui rappelle
/// l'univers du métier sans nuire à la lisibilité.
class StitchedDivider extends StatelessWidget {
  const StitchedDivider({super.key, this.color, this.hauteur = 10});

  final Color? color;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    final Color couleur =
        color ?? Theme.of(context).colorScheme.outline;
    return SizedBox(
      height: hauteur,
      width: double.infinity,
      child: CustomPaint(
        painter: _PointilleDePaint(couleur: couleur),
      ),
    );
  }
}

class _PointilleDePaint extends CustomPainter {
  _PointilleDePaint({required this.couleur});

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint peinture = Paint()
      ..color = couleur
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const double largeurTiret = 7;
    const double espace = 6;
    final double milieu = size.height / 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, milieu),
        Offset(x + largeurTiret, milieu),
        peinture,
      );
      x += largeurTiret + espace;
    }
  }

  @override
  bool shouldRepaint(covariant _PointilleDePaint oldDelegate) =>
      oldDelegate.couleur != couleur;
}
