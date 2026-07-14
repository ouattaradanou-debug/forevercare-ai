import 'package:flutter/material.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderNotesCard
/// ============================================================================
///
/// Zone de saisie des remarques d'une commande.
///
/// Ce widget est purement visuel.
/// Toute la logique est déléguée au OrderController.
///
class OrderNotesCard extends StatelessWidget {
  const OrderNotesCard({
    super.key,
    required this.notes,
    this.onChanged,
  });

  /// Notes de la commande.
  final String notes;

  /// Callback appelé lors de la modification.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.sticky_note_2_outlined),
                SizedBox(width: 8),
                Text(
                  'Remarques',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: notes,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                    'Ajouter une remarque concernant cette commande...',
                border: OutlineInputBorder(),
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}