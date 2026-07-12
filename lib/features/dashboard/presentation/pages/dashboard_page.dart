import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/navigation/app_drawer.dart';
import '../../../clients/presentation/providers/client_providers.dart';
import '../../../produits/presentation/providers/product_providers.dart';
import '../sections/dashboard_stats_section.dart';
import '../widgets/dashboard_header.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final clientsAsync = ref.watch(clientsProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('ForeverCare AI'),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: clientsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Erreur : $error')),
          data: (clients) {
            return productsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Erreur : $error')),
              data: (products) {
                final totalClients = clients.length;
                final totalProducts = products.length;

                final activeProducts = products
                    .where((p) => p.isActive)
                    .length;

                final lowStockProducts = products
                    .where((p) => p.isLowStock)
                    .length;

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const DashboardHeader(),

                    const SizedBox(height: 24),

                    DashboardStatsSection(
                      totalClients: totalClients,
                      totalProducts: totalProducts,
                      activeProducts: activeProducts,
                      lowStockProducts: lowStockProducts,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}