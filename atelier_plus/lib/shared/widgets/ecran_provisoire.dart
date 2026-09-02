import 'package:flutter/material.dart';

/// Écran temporaire affiché pour les routes pas encore implémentées.
/// Sera retiré au fur et à mesure que les écrans réels des phases
/// suivantes remplaceront chaque route.
class EcranProvisoire extends StatelessWidget {
  const EcranProvisoire({super.key, required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: Center(
        child: Text(
          '$titre\n(à venir)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
