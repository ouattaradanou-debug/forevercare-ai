import 'package:flutter/material.dart';

/// Barre d'actions rapides du dossier client.
///
/// Ce widget ne contient aucune logique métier.
/// Les actions sont déléguées au parent.
class ClientQuickActions extends StatelessWidget {
  const ClientQuickActions({
    super.key,
    this.onEdit,
    this.onCall,
    this.onWhatsApp,
    this.onShare,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Modifier'),
            ),
            FilledButton.tonalIcon(
              onPressed: onCall,
              icon: const Icon(Icons.phone),
              label: const Text('Appeler'),
            ),
            FilledButton.tonalIcon(
              onPressed: onWhatsApp,
              icon: const Icon(Icons.chat),
              label: const Text('WhatsApp'),
            ),
            OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: const Text('Partager'),
            ),
          ],
        ),
      ),
    );
  }
}
