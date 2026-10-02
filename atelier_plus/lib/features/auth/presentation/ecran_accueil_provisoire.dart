import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/atelier.dart';
import '../../../data/models/utilisateur.dart';
import '../../../data/sync/sync_providers.dart';
import '../../abonnement/data/etat_abonnement.dart';
import '../../abonnement/providers/abonnement_providers.dart';
import '../providers/auth_providers.dart';

/// Couleurs propres à cet écran (en-tête bleu marine), distinctes de la
/// palette terre cuite/doré utilisée partout ailleurs dans l'app : choix
/// visuel demandé pour l'accueil uniquement, pas un changement de thème
/// global.
class _CouleursAccueil {
  const _CouleursAccueil._();

  static const Color enteteHaut = Color(0xFF2A3A70);
  static const Color enteteBas = Color(0xFF141B3E);
  static const Color carteEssaiFond = Color(0xFFF3E6C9);
  static const Color carteEssaiIcone = Color(0xFFD4A24C);
}

/// Écran d'accueil : en-tête bleu marine (logo/nom d'atelier, bouton de
/// déconnexion, salutation et date), rappel d'essai gratuit en cours, puis
/// une grille d'actions rapides (nouveau client, clients, rendez-vous,
/// équipe, et pour le propriétaire : types de tenue, abonnement). Le vrai
/// tableau de bord (statistiques) sera construit dans une phase ultérieure.
class EcranAccueilProvisoire extends ConsumerStatefulWidget {
  const EcranAccueilProvisoire({super.key});

  @override
  ConsumerState<EcranAccueilProvisoire> createState() => _EcranAccueilProvisoireState();
}

class _EcranAccueilProvisoireState extends ConsumerState<EcranAccueilProvisoire> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(abonnementRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final atelier = ref.watch(atelierCourantProvider);
    final utilisateur = ref.watch(utilisateurCourantProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);
    final tachesEnAttente = ref.watch(tachesSyncEnAttenteProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EnTete(
                atelier: atelier,
                utilisateur: utilisateur,
                tachesEnAttente: tachesEnAttente,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _CarteEssai(),
                    const SizedBox(height: 8),
                    Text(
                      'Actions rapides',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF231A14),
                          ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.15,
                      children: [
                        _CarteAction(
                          icone: Icons.person_add_alt_1_outlined,
                          libelle: 'Nouveau client',
                          fondIcone: const Color(0xFFE3E1F5),
                          couleurIcone: const Color(0xFF3B3470),
                          onTap: () => context.push(AppRoutes.creationClient),
                        ),
                        _CarteAction(
                          icone: Icons.groups_outlined,
                          libelle: 'Mes clients',
                          fondIcone: const Color(0xFFF5DCD3),
                          couleurIcone: const Color(0xFF8A4B24),
                          onTap: () => context.push(AppRoutes.clients),
                        ),
                        _CarteAction(
                          icone: Icons.event_outlined,
                          libelle: 'Rendez-vous',
                          fondIcone: const Color(0xFFF5E8C8),
                          couleurIcone: const Color(0xFFA47B1B),
                          onTap: () => context.push(AppRoutes.rendezVous),
                        ),
                        if (estProprietaire)
                          _CarteAction(
                            icone: Icons.diversity_3_outlined,
                            libelle: 'Mon équipe',
                            fondIcone: const Color(0xFFE0E3F5),
                            couleurIcone: const Color(0xFF2A3A70),
                            onTap: () => context.push(AppRoutes.apprentis),
                          ),
                        if (estProprietaire)
                          _CarteAction(
                            icone: Icons.checkroom_outlined,
                            libelle: 'Mes types de tenue',
                            fondIcone: const Color(0xFFF5DCD3),
                            couleurIcone: const Color(0xFF8A4B24),
                            onTap: () => context.push(AppRoutes.typesTenue),
                          ),
                        if (estProprietaire)
                          _CarteAction(
                            icone: Icons.workspace_premium_outlined,
                            libelle: 'Mon abonnement',
                            fondIcone: const Color(0xFFF5E8C8),
                            couleurIcone: const Color(0xFFA47B1B),
                            onTap: () => context.push(AppRoutes.abonnement),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnTete extends StatelessWidget {
  const _EnTete({
    required this.atelier,
    required this.utilisateur,
    required this.tachesEnAttente,
  });

  final AsyncValue<Atelier?> atelier;
  final AsyncValue<Utilisateur?> utilisateur;
  final int tachesEnAttente;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_CouleursAccueil.enteteHaut, _CouleursAccueil.enteteBas],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                atelier.when(
                  data: (a) => CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    backgroundImage: a?.logoUrl == null ? null : NetworkImage(a!.logoUrl!),
                    child: a?.logoUrl == null
                        ? const Icon(Icons.storefront, color: Colors.white, size: 24)
                        : null,
                  ),
                  loading: () => const CircleAvatar(radius: 26, backgroundColor: Colors.white24),
                  error: (_, __) => const CircleAvatar(radius: 26, backgroundColor: Colors.white24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      atelier.when(
                        data: (a) => Text(
                          a?.nom ?? 'Atelier+',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      utilisateur.when(
                        data: (u) => Text(
                          u == null ? '' : (u.estProprietaire ? 'Propriétaire' : 'Apprenti'),
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                if (tachesEnAttente > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Tooltip(
                      message: '$tachesEnAttente modification(s) en attente de connexion',
                      child: const Icon(Icons.cloud_off, color: Colors.white70, size: 20),
                    ),
                  ),
                IconButton(
                  tooltip: 'Se déconnecter',
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    final conteneur = ProviderScope.containerOf(context, listen: false);
                    await conteneur.read(authRepositoryProvider).deconnecter();
                    if (context.mounted) context.go(AppRoutes.connexion);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            utilisateur.when(
              data: (u) => Text(
                u == null ? '' : 'Bonjour, ${u.nom}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              loading: () => const SizedBox(height: 36),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 6),
            Text(
              Formatters.dateLongue(DateTime.now()),
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteEssai extends ConsumerWidget {
  const _CarteEssai();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnement = ref.watch(abonnementCourantProvider).valueOrNull;
    if (abonnement == null || abonnement.statut != 'essai') return const SizedBox.shrink();
    if (estEnModeConsultationSeule(abonnement)) return const SizedBox.shrink();

    final jours = joursRestantsEssai(abonnement);
    final String sousTitre;
    if (jours <= 0) {
      sousTitre = 'Se termine aujourd\'hui';
    } else if (jours == 1) {
      sousTitre = '1 jour restant';
    } else {
      sousTitre = '$jours jours restants';
    }

    return Material(
      color: _CouleursAccueil.carteEssaiFond,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(AppRoutes.abonnement),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _CouleursAccueil.carteEssaiIcone,
                child: const Icon(Icons.hourglass_top, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Essai gratuit en cours',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF231A14)),
                    ),
                    Text(sousTitre, style: const TextStyle(color: Color(0xFF6F6259))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6F6259)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarteAction extends StatelessWidget {
  const _CarteAction({
    required this.icone,
    required this.libelle,
    required this.fondIcone,
    required this.couleurIcone,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final Color fondIcone;
  final Color couleurIcone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: fondIcone,
                child: Icon(icone, color: couleurIcone, size: 22),
              ),
              Text(
                libelle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF231A14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
