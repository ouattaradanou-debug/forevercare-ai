import 'package:flutter/material.dart';

import '../widgets/dashboard_stat_card.dart';

class DashboardStatsSection extends StatelessWidget {
  const DashboardStatsSection({
    super.key,
    required this.totalClients,
    required this.totalProducts,
    required this.activeProducts,
    required this.lowStockProducts,
  });

  final int totalClients;
  final int totalProducts;
  final int activeProducts;
  final int lowStockProducts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d’ensemble',
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                icon: Icons.people,
                title: 'Clients',
                value: totalClients.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardStatCard(
                icon: Icons.inventory_2,
                title: 'Produits',
                value: totalProducts.toString(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                icon: Icons.check_circle,
                title: 'Produits actifs',
                value: activeProducts.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardStatCard(
                icon: Icons.warning_amber_rounded,
                title: 'Stock faible',
                value: lowStockProducts.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}