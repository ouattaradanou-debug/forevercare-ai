import 'package:flutter/material.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderSummaryCard
/// ============================================================================
///
/// Affiche le récapitulatif financier de la commande.
///
/// Ce widget est purement visuel.
/// Les calculs sont réalisés dans OrderState.
///
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.onDiscountChanged,
  });

  final double subtotal;
  final double discount;
  final double total;

  final ValueChanged<double>? onDiscountChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Résumé de la commande',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SummaryRow(
              label: 'Sous-total',
              value: subtotal,
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue: discount == 0
                  ? ''
                  : discount.toStringAsFixed(0),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Remise (FCFA)',
                prefixIcon: Icon(Icons.discount),
              ),
              onChanged: (value) {
                final parsed =
                    double.tryParse(value.trim()) ?? 0;

                onDiscountChanged?.call(parsed);
              },
            ),

            const Divider(height: 32),

            _SummaryRow(
              label: 'Total',
              value: total,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = isTotal
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          )
        : theme.textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style,
          ),
        ),
        Text(
          '${value.toStringAsFixed(0)} FCFA',
          style: style,
        ),
      ],
    );
  }
}