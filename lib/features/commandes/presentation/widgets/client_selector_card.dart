import 'package:flutter/material.dart';

/// ============================================================================
/// ForeverCare AI
/// ClientSelectorCard
/// ============================================================================
///
/// Carte de sélection du client.
///
/// Pour cette première version, le widget est purement
/// visuel et ne dépend pas encore du module Clients.
/// L'intégration avec la recherche des clients sera
/// réalisée dans un sprint ultérieur.
///
class ClientSelectorCard extends StatelessWidget {
  const ClientSelectorCard({
    super.key,
    this.clientName,
    this.clientPhone,
    this.onSelect,
    this.onClear,
  });

  /// Nom du client sélectionné.
  final String? clientName;

  /// Téléphone du client.
  final String? clientPhone;

  /// Action de sélection.
  final VoidCallback? onSelect;

  /// Action de suppression.
  final VoidCallback? onClear;

  bool get hasClient =>
      clientName != null && clientName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            if (!hasClient)
              OutlinedButton.icon(
                onPressed: onSelect,
                icon: const Icon(Icons.person_search),
                label: const Text(
                  'Sélectionner un client',
                ),
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Text(
                    clientName![0].toUpperCase(),
                  ),
                ),
                title: Text(clientName!),
                subtitle: Text(
                  clientPhone ?? '',
                ),
                trailing: IconButton(
                  tooltip: 'Supprimer',
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
              ),
          ],
        ),
      ),
    );
  }
}