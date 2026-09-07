import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/stitched_divider.dart';
import 'widgets/home_action_card.dart';

/// Écran d'accueil statique d'Atelier+.
///
/// Phase 0 : cet écran ne consomme aucune donnée réelle. Il sert à valider
/// la direction visuelle (palette couture, typographie affirmée,
/// micro-interactions) avant de brancher la logique métier dans les phases
/// suivantes. Les valeurs affichées (nom d'atelier, statistiques) sont des
/// exemples de mise en page.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme texte = Theme.of(context).textTheme;
    final String dateDuJour = DateFormat.yMMMMEEEEd('fr_FR').format(
      DateTime.now(),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _EnTeteAtelier(dateDuJour: dateDuJour)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _BandeauEssaiGratuit(joursRestants: 23),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Actions rapides', style: texte.headlineMedium),
                  const SizedBox(height: AppSpacing.m),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.m,
                    crossAxisSpacing: AppSpacing.m,
                    childAspectRatio: 1.15,
                    children: [
                      HomeActionCard(
                        icone: Icons.person_add_alt_1,
                        libelle: 'Nouveau client',
                        couleurAccent: AppColors.indigo700,
                        onTap: () {},
                      ),
                      HomeActionCard(
                        icone: Icons.straighten,
                        libelle: 'Prendre des mesures',
                        couleurAccent: AppColors.terracotta600,
                        onTap: () {},
                      ),
                      HomeActionCard(
                        icone: Icons.event_available,
                        libelle: 'Rendez-vous',
                        couleurAccent: AppColors.or600,
                        onTap: () {},
                      ),
                      HomeActionCard(
                        icone: Icons.savings_outlined,
                        libelle: 'Finances',
                        couleurAccent: AppColors.succes,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  StitchedDivider(color: scheme.outline),
                  const SizedBox(height: AppSpacing.xl),
                  Text("Aujourd'hui", style: texte.headlineMedium),
                  const SizedBox(height: AppSpacing.m),
                  const _RangeeStatistiques(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnTeteAtelier extends StatelessWidget {
  const _EnTeteAtelier({required this.dateDuJour});

  final String dateDuJour;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.indigo900, AppColors.indigo700],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.card + 8),
          bottomRight: Radius.circular(AppRadius.card + 8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.or500,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.ecru50.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AC',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.anthracite900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atelier Awa Couture',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ecru50,
                      ),
                    ),
                    Text(
                      'Propriétaire',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ecru50.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                color: AppColors.ecru50,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Bonjour, Awa',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.ecru50,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            dateDuJour,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.ecru50.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _BandeauEssaiGratuit extends StatelessWidget {
  const _BandeauEssaiGratuit({required this.joursRestants});

  final int joursRestants;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.or500.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.or500.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.or500,
            child: Icon(
              Icons.hourglass_top,
              color: AppColors.anthracite900,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Essai gratuit en cours',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$joursRestants jours restants',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _RangeeStatistiques extends StatelessWidget {
  const _RangeeStatistiques();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _CarteStatistique(
            icone: Icons.groups_outlined,
            valeur: '128',
            libelle: 'Clients',
            couleurAccent: AppColors.indigo700,
          ),
        ),
        SizedBox(width: AppSpacing.m),
        Expanded(
          child: _CarteStatistique(
            icone: Icons.event_outlined,
            valeur: '4',
            libelle: 'Rendez-vous',
            couleurAccent: AppColors.terracotta600,
          ),
        ),
      ],
    );
  }
}

class _CarteStatistique extends StatelessWidget {
  const _CarteStatistique({
    required this.icone,
    required this.valeur,
    required this.libelle,
    required this.couleurAccent,
  });

  final IconData icone;
  final String valeur;
  final String libelle;
  final Color couleurAccent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleurAccent),
          const SizedBox(height: AppSpacing.s),
          Text(valeur, style: Theme.of(context).textTheme.displayMedium),
          Text(
            libelle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
