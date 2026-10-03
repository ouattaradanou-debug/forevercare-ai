import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../providers/finances_providers.dart';

/// Liste de toutes les dépenses enregistrées, la plus récente en premier.
class EcranHistoriqueDepenses extends ConsumerWidget {
  const EcranHistoriqueDepenses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depenses = ref.watch(depensesDeLAtelierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des dépenses')),
      body: SafeArea(
        child: depenses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
          data: (liste) {
            if (liste.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucune dépense enregistrée pour le moment.'),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: liste.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final depense = liste[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF5E3E3),
                    child: Icon(Icons.remove, color: Color(0xFFB3261E)),
                  ),
                  title: Text(Formatters.montant(depense.montant)),
                  subtitle: Text(
                    depense.description == null || depense.description!.isEmpty
                        ? Formatters.dateLongue(depense.date)
                        : '${depense.description}\n${Formatters.dateLongue(depense.date)}',
                  ),
                  isThreeLine: depense.description != null && depense.description!.isNotEmpty,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
