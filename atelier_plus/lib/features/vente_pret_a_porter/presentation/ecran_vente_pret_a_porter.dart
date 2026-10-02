import 'package:flutter/material.dart';

/// Emplacement réservé pour la vente d'articles prêts à porter (catalogue,
/// stock, enregistrement de ventes) — périmètre encore à définir.
class EcranVentePretAPorter extends StatelessWidget {
  const EcranVentePretAPorter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vente prête à porter')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.checkroom, size: 48),
              SizedBox(height: 16),
              Text(
                'Bientôt disponible',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'La vente d\'articles prêts à porter sera ajoutée ici.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
