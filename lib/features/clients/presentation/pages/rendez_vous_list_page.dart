import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/commande.dart';
import '../../../../data/models/rendez_vous.dart';
import '../providers/clients_providers.dart';
import '../providers/finances_providers.dart';

/// Liste de tous les rendez-vous de l'atelier, du plus proche au plus
/// lointain, avec le nom du client concerné. Un appui ouvre la fiche du
/// client.
///
/// Repère visuel selon l'état des finances (propriétaire uniquement : les
/// commandes ne sont de toute façon jamais visibles d'un apprenti, voir
/// RLS et PermissionsApprenti — cette page n'a donc rien de spécial à
/// masquer) :
/// - tenue retirée mais pas encore soldée -> fond rouge (il reste à
///   encaisser) ;
/// - soldée mais tenue pas encore retirée -> fond vert (il ne reste qu'à
///   remettre la tenue) ;
/// - soldée ET tenue retirée -> le client n'a plus rien à suivre, il
///   disparaît de la liste (voir Commande.estSoldee).
class RendezVousListPage extends ConsumerWidget {
  const RendezVousListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RendezVousAvecClient>> rendezVousAsync = ref.watch(
      rendezVousAtelierProvider,
    );
    final List<Commande> commandes =
        ref.watch(commandesAtelierProvider).asData?.value ?? const [];
    final Map<String, Commande> commandeParClient = {
      for (final Commande c in commandes) c.clientId: c,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Rendez-vous')),
      body: rendezVousAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (tousLesRendezVous) {
          final List<RendezVousAvecClient> rendezVous = tousLesRendezVous
              .where(
                (rdv) =>
                    !(commandeParClient[rdv.client.id]?.estSoldee ?? false),
              )
              .toList();

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
              final Commande? commande = commandeParClient[rdv.client.id];
              final bool resteAEncaisser =
                  commande != null &&
                  commande.tenueRetiree &&
                  commande.resteAPayer > 0;
              final bool resteARemettre =
                  commande != null &&
                  !commande.tenueRetiree &&
                  commande.resteAPayer <= 0;
              final Color? fond = resteAEncaisser
                  ? AppColors.erreur.withValues(alpha: 0.45)
                  : resteARemettre
                  ? AppColors.succes.withValues(alpha: 0.45)
                  : null;

              return Card(
                color: fond,
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
