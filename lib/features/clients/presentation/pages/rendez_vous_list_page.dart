import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/rendez_vous.dart';
import '../providers/clients_providers.dart';

/// Liste de tous les rendez-vous de l'atelier, du plus proche au plus
/// lointain, avec le nom du client concerné. Un appui ouvre la fiche du
/// client.
class RendezVousListPage extends ConsumerWidget {
  const RendezVousListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RendezVousAvecClient>> rendezVousAsync = ref.watch(
      rendezVousAtelierProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Rendez-vous')),
      body: rendezVousAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (rendezVous) {
          if (rendezVous.isEmpty) {
            return const Center(child: Text('Aucun rendez-vous planifié.'));
          }
          final DateFormat format = DateFormat(
            "EEEE d MMMM 'à' HH'h'mm",
            'fr_FR',
          );
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: rendezVous.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final RendezVousAvecClient rdv = rendezVous[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.m),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.or600.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.event_available,
                      color: AppColors.or600,
                    ),
                  ),
                  title: Text(rdv.client.nomComplet),
                  subtitle: Text(format.format(rdv.rendezVous.dateHeure)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    '/clients/${rdv.client.id}',
                    extra: rdv.client,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
