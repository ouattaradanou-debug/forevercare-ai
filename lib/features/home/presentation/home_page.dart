import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/atelier.dart';
import '../../../data/models/brouillon_client.dart';
import '../../../data/models/utilisateur.dart';
import '../../../shared/widgets/selecteur_photo.dart';
import '../../../shared/widgets/stitched_divider.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../clients/presentation/providers/clients_providers.dart';
import 'widgets/home_action_card.dart';

/// Écran d'accueil d'Atelier+.
///
/// Depuis la Phase 1, l'en-tête affiche les vraies données de l'atelier et
/// de l'utilisateur connecté (cache local, lecture hors-ligne d'abord). Les
/// statistiques du jour restent des exemples de mise en page : elles seront
/// branchées sur les vraies données client/rendez-vous en Phases 2 et 3.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme texte = Theme.of(context).textTheme;
    final String dateDuJour = DateFormat.yMMMMEEEEd('fr_FR').format(
      DateTime.now(),
    );

    final Atelier? atelier = ref.watch(atelierCourantProvider).asData?.value;
    final Utilisateur? utilisateur = ref
        .watch(utilisateurCourantProvider)
        .asData?.value;
    final bool estProprietaire = utilisateur?.estProprietaire ?? false;
    final BrouillonClient? brouillon = ref
        .watch(brouillonActuelProvider)
        .asData
        ?.value;
    final bool aUnBrouillon =
        brouillon != null && !brouillon.estCompletementVide;
    final int nombreClients = ref.watch(clientsProvider).asData?.value.length ?? 0;
    final int nombreRendezVousAujourdhui = ref.watch(
      rendezVousAujourdhuiCompteProvider,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _EnTeteAtelier(
                dateDuJour: dateDuJour,
                atelier: atelier,
                utilisateur: utilisateur,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _BandeauEssaiGratuit(joursRestants: 30),
                  if (aUnBrouillon) ...[
                    const SizedBox(height: AppSpacing.m),
                    _CarteFicheACompleter(
                      brouillon: brouillon,
                      onTap: () => context.push('/clients/nouveau'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Text('Actions rapides', style: texte.headlineMedium),
                  const SizedBox(height: AppSpacing.m),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.m,
                    crossAxisSpacing: AppSpacing.m,
                    childAspectRatio: 0.95,
                    children: [
                      HomeActionCard(
                        icone: Icons.person_add_alt_1,
                        libelle: 'Nouveau client',
                        couleurAccent: AppColors.indigo700,
                        onTap: () => context.push('/clients/nouveau'),
                      ),
                      HomeActionCard(
                        icone: Icons.groups_outlined,
                        libelle: 'Mes clients',
                        couleurAccent: AppColors.terracotta600,
                        onTap: () => context.push('/clients'),
                      ),
                      HomeActionCard(
                        icone: Icons.event_available,
                        libelle: 'Rendez-vous',
                        couleurAccent: AppColors.or600,
                        onTap: () => context.push('/rendez-vous'),
                      ),
                      if (estProprietaire)
                        HomeActionCard(
                          icone: Icons.groups_2_outlined,
                          libelle: 'Mon équipe',
                          couleurAccent: AppColors.indigo500,
                          onTap: () => context.push('/apprentis'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  StitchedDivider(color: scheme.outline),
                  const SizedBox(height: AppSpacing.xl),
                  Text("Aujourd'hui", style: texte.headlineMedium),
                  const SizedBox(height: AppSpacing.m),
                  _RangeeStatistiques(
                    nombreClients: nombreClients,
                    nombreRendezVous: nombreRendezVousAujourdhui,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnTeteAtelier extends ConsumerWidget {
  const _EnTeteAtelier({
    required this.dateDuJour,
    required this.atelier,
    required this.utilisateur,
  });

  final String dateDuJour;
  final Atelier? atelier;
  final Utilisateur? utilisateur;

  String _initiales(String nom) {
    final List<String> mots = nom.trim().split(RegExp(r'\s+'));
    if (mots.isEmpty || mots.first.isEmpty) return 'A+';
    final String premiere = mots.first.substring(0, 1).toUpperCase();
    final String seconde = mots.length > 1 && mots[1].isNotEmpty
        ? mots[1].substring(0, 1).toUpperCase()
        : '';
    return '$premiere$seconde';
  }

  // Il n'existait jusqu'ici aucun moyen d'ajouter ou de changer le logo une
  // fois le compte créé (uniquement possible pendant l'inscription) — un
  // atelier créé sans logo à ce moment-là n'en avait ensuite plus jamais.
  // Appuyer sur l'avatar (propriétaire uniquement, voir policy RLS
  // `ateliers_update_proprietaire`) permet de le faire à tout moment.
  Future<void> _changerLogo(
    BuildContext context,
    WidgetRef ref,
    String atelierId,
  ) async {
    try {
      final XFile? photo = await choisirPhoto(context);
      if (photo == null) return;
      await ref
          .read(atelierRepositoryProvider)
          .televerserLogo(atelierId: atelierId, fichierOriginal: File(photo.path));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'enregistrer le logo : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Atelier? atelierActuel = atelier;
    final String nomAtelier = atelierActuel?.nom ?? 'Mon atelier';
    final String prenomUtilisateur = utilisateur?.nom.split(' ').first ?? '';

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
              GestureDetector(
                onTap: utilisateur?.estProprietaire == true && atelierActuel != null
                    ? () => _changerLogo(context, ref, atelierActuel.id)
                    : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.or500,
                      backgroundImage: atelier?.logoUrl != null
                          ? CachedNetworkImageProvider(atelier!.logoUrl!)
                          : null,
                      child: atelier?.logoUrl == null
                          ? Text(
                              _initiales(nomAtelier),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppColors.anthracite900),
                            )
                          : null,
                    ),
                    if (utilisateur?.estProprietaire == true)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.or600,
                          child: const Icon(
                            Icons.photo_camera_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomAtelier,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ecru50,
                      ),
                    ),
                    Text(
                      utilisateur == null
                          ? ''
                          : (utilisateur!.estProprietaire
                                ? 'Propriétaire'
                                : 'Apprenti'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ecru50.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(authRepositoryProvider).seDeconnecter(),
                icon: const Icon(Icons.logout),
                color: AppColors.ecru50,
                tooltip: 'Se déconnecter',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            prenomUtilisateur.isEmpty ? 'Bonjour' : 'Bonjour, $prenomUtilisateur',
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
  const _RangeeStatistiques({
    required this.nombreClients,
    required this.nombreRendezVous,
  });

  final int nombreClients;
  final int nombreRendezVous;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CarteStatistique(
            icone: Icons.groups_outlined,
            valeur: '$nombreClients',
            libelle: 'Clients',
            couleurAccent: AppColors.indigo700,
            onTap: () => context.push('/clients'),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _CarteStatistique(
            icone: Icons.event_outlined,
            valeur: '$nombreRendezVous',
            libelle: "Rendez-vous aujourd'hui",
            couleurAccent: AppColors.terracotta600,
            onTap: () => context.push('/rendez-vous'),
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
    this.onTap,
  });

  final IconData icone;
  final String valeur;
  final String libelle;
  final Color couleurAccent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
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
      ),
    );
  }
}

class _CarteFicheACompleter extends StatelessWidget {
  const _CarteFicheACompleter({required this.brouillon, required this.onTap});

  final BrouillonClient brouillon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String nom = [
      brouillon.nom,
      brouillon.prenom,
    ].where((v) => v != null && v.trim().isNotEmpty).join(' ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.terracotta500.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.terracotta500.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.terracotta500,
              child: Icon(
                Icons.edit_note,
                color: AppColors.ecru50,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fiche à compléter',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    nom.isEmpty ? 'Client sans nom' : nom,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
