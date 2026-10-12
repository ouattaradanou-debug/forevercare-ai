import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/notifications_service.dart';
import '../../../core/notifications/preference_rappel.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/atelier.dart';
import '../../../data/models/client.dart';
import '../../../data/models/groupe_uniforme.dart';
import '../../../data/models/rendez_vous.dart';
import '../../../data/models/rendez_vous_groupe.dart';
import '../../../data/models/utilisateur.dart';
import '../../../data/sync/sync_providers.dart';
import '../../abonnement/data/etat_abonnement.dart';
import '../../abonnement/providers/abonnement_providers.dart';
import '../../clients/providers/clients_providers.dart';
import '../../rendezvous/providers/rendez_vous_groupe_providers.dart';
import '../../rendezvous/providers/rendezvous_providers.dart';
import '../../uniformes/providers/uniformes_providers.dart';
import '../providers/auth_providers.dart';

/// Un rendez-vous (client ou groupe) prêt à afficher dans la carte
/// "Rendez-vous aujourd'hui" — même principe que la fusion de l'écran
/// "Rendez-vous" (voir ecran_liste_rendez_vous.dart), simplifié ici car
/// purement en lecture (pas d'action de statut depuis l'accueil).
class _RdvAujourdhui {
  const _RdvAujourdhui({
    required this.id,
    required this.nom,
    required this.dateHeure,
    required this.estGroupe,
  });

  final String id;
  final String nom;
  final DateTime dateHeure;
  final bool estGroupe;
}

/// Couleurs propres à l'en-tête de l'accueil — dégradé bleu vers orange
/// SEDA Tech (voir AppColors pour la palette globale, qui reprend les
/// mêmes couleurs de marque).
class _CouleursAccueil {
  const _CouleursAccueil._();

  static const Color enteteHaut = Color(0xFF1B4FA0);
  static const Color enteteBas = Color(0xFFE8701A);
  static const Color carteEssaiFond = Color(0xFFFCE4CC);
  static const Color carteEssaiIcone = Color(0xFFF5821F);
}

/// Couleurs cycliques des puces devant chaque client concerné par le
/// rappel (_CarteRappel) — simple repère visuel, sans signification propre.
const List<Color> _couleursPuces = [
  Color(0xFFF5821F),
  Color(0xFF1B4FA0),
  Color(0xFF2E7D32),
  Color(0xFF8456D9),
];

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

    // Tant que utilisateurCourantProvider n'a pas encore résolu une première
    // fois (bref instant à l'ouverture de l'application, avant la toute
    // première lecture du cache local), estProprietaireProvider vaut `false`
    // par défaut. Plutôt que de bloquer tout l'écran derrière un indicateur
    // de chargement (ce qui donne l'impression que l'application met plus
    // de temps à s'ouvrir, pour un gain purement visuel) ou de laisser les
    // tuiles réservées au propriétaire/"Aujourd'hui" apparaître d'un coup
    // sans prévenir, on affiche l'écran tout de suite avec un petit
    // indicateur discret à la place du contenu encore en résolution.
    final enResolution = utilisateur.isLoading && !utilisateur.hasValue;

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
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: _CouleursAccueil.carteEssaiIcone, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          'Actions rapides',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _CouleursAccueil.enteteHaut,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: [
                        _CarteAction(
                          icone: Icons.person_add_alt_1_outlined,
                          libelle: 'Nouveau client',
                          couleurs: const [Color(0xFF3B5BDB), Color(0xFF1B4FA0)],
                          onTap: () => context.push(AppRoutes.creationClient),
                        ),
                        _CarteAction(
                          icone: Icons.groups_outlined,
                          libelle: 'Mes clients',
                          couleurs: const [Color(0xFFFFA94D), Color(0xFFF5821F)],
                          onTap: () => context.push(AppRoutes.clients),
                        ),
                        _CarteAction(
                          icone: Icons.event_outlined,
                          libelle: 'Rendez-vous',
                          couleurs: const [Color(0xFF9775FA), Color(0xFF6741D9)],
                          onTap: () => context.push(AppRoutes.rendezVous),
                        ),
                        if (estProprietaire) ...[
                          _CarteAction(
                            icone: Icons.remove_circle_outline,
                            libelle: 'Enregistrer dépenses',
                            couleurs: const [Color(0xFF4CAF77), Color(0xFF2E7D32)],
                            onTap: () => context.push(AppRoutes.nouvelleDepense),
                          ),
                          _CarteAction(
                            icone: Icons.storefront_outlined,
                            libelle: 'Ventes',
                            couleurs: const [Color(0xFFB088F5), Color(0xFF8456D9)],
                            onTap: () => context.push(AppRoutes.ventes),
                          ),
                          _CarteAction(
                            icone: Icons.inventory_2_outlined,
                            libelle: 'Stock',
                            couleurs: const [Color(0xFFEF6E6E), Color(0xFFB3261E)],
                            onTap: () => context.push(AppRoutes.gestionStock),
                          ),
                        ] else if (enResolution)
                          const _CarteActionChargement(),
                      ],
                    ),
                    if (estProprietaire) ...[
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFDDD3C8)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: _CouleursAccueil.enteteHaut, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            'Aujourd\'hui',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _CouleursAccueil.enteteHaut,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _SectionAujourdhui(),
                    ] else if (enResolution) ...[
                      const SizedBox(height: 24),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ],
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: atelier.when(
                    data: (a) => CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      backgroundImage: a?.logoUrl == null ? null : NetworkImage(a!.logoUrl!),
                      child: a?.logoUrl == null
                          ? const Icon(Icons.storefront, color: _CouleursAccueil.enteteHaut, size: 22)
                          : null,
                    ),
                    loading: () => const CircleAvatar(radius: 24, backgroundColor: Colors.white24),
                    error: (_, __) => const CircleAvatar(radius: 24, backgroundColor: Colors.white24),
                  ),
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
                  tooltip: 'Paramètres',
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => context.push(AppRoutes.parametres),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 8),
                  child: Icon(Icons.calendar_today, color: Colors.white, size: 20),
                ),
                Expanded(
                  child: utilisateur.when(
                    data: (u) => Text(
                      u == null ? '' : 'Bonjour, ${u.nom}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    loading: () => const SizedBox(height: 34),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                Formatters.dateLongue(DateTime.now()),
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
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

/// Statistiques du jour (nombre de clients, rendez-vous du jour), rappel de
/// rendez-vous configurable, et accès au suivi des finances / aux mesures
/// d'uniformes — visible uniquement du propriétaire (données financières et
/// réglages d'atelier).
class _SectionAujourdhui extends ConsumerWidget {
  const _SectionAujourdhui();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(rechercheClientsProvider('')).valueOrNull ?? const <Client>[];
    final rendezVous = ref.watch(rendezVousTriesProvider).valueOrNull ?? const <RendezVous>[];
    final rendezVousGroupe =
        ref.watch(rendezVousGroupeTriesProvider).valueOrNull ?? const <RendezVousGroupe>[];
    final groupes = ref.watch(groupesUniformesProvider).valueOrNull ?? const <GroupeUniforme>[];
    final parGroupe = {for (final g in groupes) g.id: g};
    final parClient = {for (final c in clients) c.id: c};

    final maintenant = DateTime.now();
    final debutJour = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final finJour = debutJour.add(const Duration(days: 1));
    bool estAujourdhui(DateTime dateHeure, String statut) {
      if (statut == AppConstants.rdvAnnule) return false;
      final local = dateHeure.toLocal();
      return !local.isBefore(debutJour) && local.isBefore(finJour);
    }

    final rdvAujourdhui = [
      ...rendezVous.where((r) => estAujourdhui(r.dateHeure, r.statut)).map(
            (r) => _RdvAujourdhui(
              id: r.clientId,
              nom: parClient[r.clientId]?.nomComplet ?? '…',
              dateHeure: r.dateHeure,
              estGroupe: false,
            ),
          ),
      ...rendezVousGroupe.where((r) => estAujourdhui(r.dateHeure, r.statut)).map(
            (r) => _RdvAujourdhui(
              id: r.groupeId,
              // Nom du répondant (plus parlant que le nom interne du
              // groupe) — même choix que l'écran "Rendez-vous".
              nom: parGroupe[r.groupeId]?.repondantNom ?? parGroupe[r.groupeId]?.nom ?? '…',
              dateHeure: r.dateHeure,
              estGroupe: true,
            ),
          ),
    ]..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE3EAF7),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _CarteStat(
                      icone: Icons.groups_outlined,
                      valeur: '${clients.length}',
                      libelle: 'Clients',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CarteStat(
                      icone: Icons.event_outlined,
                      valeur: '${rdvAujourdhui.length}',
                      libelle: 'Rendez-vous\naujourd\'hui',
                      onTap: rdvAujourdhui.isEmpty
                          ? null
                          : () => _afficherRdvAujourdhui(context, rdvAujourdhui),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(Icons.favorite, color: _CouleursAccueil.enteteBas, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chaque rendez-vous est une création unique !',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: _CouleursAccueil.enteteHaut,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _CarteRappel(clients: clients, rendezVous: rendezVous),
      ],
    );
  }
}

/// Liste, dans une boîte en bas d'écran, les clients et groupes d'uniformes
/// ayant rendez-vous aujourd'hui (déjà triés par heure) — touchée depuis la
/// carte "Rendez-vous aujourd'hui". Toucher une ligne ouvre directement la
/// fiche du client ou le détail du groupe concerné.
void _afficherRdvAujourdhui(
  BuildContext context,
  List<_RdvAujourdhui> rdvAujourdhui,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rendez-vous aujourd\'hui',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4FA0)),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final r in rdvAujourdhui)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          r.estGroupe ? Icons.groups_outlined : Icons.person_outline,
                          color: const Color(0xFF1B4FA0),
                        ),
                        title: Text(r.nom),
                        subtitle: Text(Formatters.heure(r.dateHeure.toLocal())),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF6F6259)),
                        onTap: () {
                          Navigator.pop(context);
                          context.push(
                            r.estGroupe
                                ? AppRoutes.detailGroupeUniforme(r.id)
                                : AppRoutes.ficheClient(r.id),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CarteStat extends StatelessWidget {
  const _CarteStat({
    required this.icone,
    required this.valeur,
    required this.libelle,
    this.onTap,
  });

  final IconData icone;
  final String valeur;
  final String libelle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icone, color: const Color(0xFF1B4FA0)),
                  if (onTap != null)
                    const Icon(Icons.chevron_right, color: Color(0xFF6F6259), size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(valeur, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(libelle, style: const TextStyle(color: Color(0xFF6F6259))),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarteRappel extends ConsumerWidget {
  const _CarteRappel({required this.clients, required this.rendezVous});

  final List<Client> clients;
  final List<RendezVous> rendezVous;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joursAvant = ref.watch(preferenceRappelProvider);
    final maintenant = DateTime.now();
    final limite = maintenant.add(Duration(days: joursAvant));
    final parClient = {for (final c in clients) c.id: c};

    // Déjà triés par date croissante (observerRendezVousTries).
    final concernes = <String>[];
    for (final r in rendezVous) {
      if (r.statut == AppConstants.rdvAnnule) continue;
      final local = r.dateHeure.toLocal();
      if (local.isBefore(maintenant) || local.isAfter(limite)) continue;
      final nom = parClient[r.clientId]?.nomComplet;
      if (nom != null && !concernes.contains(nom)) concernes.add(nom);
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined, color: Color(0xFFF5821F)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Me rappeler les rendez-vous',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: joursAvant,
            items: choixJoursAvantRappel
                .map(
                  (j) => DropdownMenuItem(
                    value: j,
                    child: Text(j == 1 ? '1 jour avant' : '$j jours avant'),
                  ),
                )
                .toList(),
            onChanged: (j) {
              if (j != null) ref.read(preferenceRappelProvider.notifier).definir(j);
            },
          ),
          const SizedBox(height: 16),
          const Text('Clients concernés par ce rappel', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (concernes.isEmpty)
            const Text(
              'Aucun rendez-vous à venir pour le moment.',
              style: TextStyle(color: Color(0xFF6F6259)),
            )
          else
            for (var i = 0; i < concernes.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _couleursPuces[i % _couleursPuces.length],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(concernes[i]),
                  ],
                ),
              ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => NotificationsService.instance.envoyerNotificationTest(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_active_outlined,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Tester un rappel maintenant',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteAction extends StatelessWidget {
  const _CarteAction({
    required this.icone,
    required this.libelle,
    required this.couleurs,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final List<Color> couleurs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: couleurs,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icone, color: Colors.white, size: 22),
                    const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                  ],
                ),
                Text(
                  libelle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Occupe la place des tuiles réservées au propriétaire pendant que
/// `utilisateurCourantProvider` résout encore (voir la remarque dans
/// EcranAccueilProvisoire.build) — même forme que _CarteAction, pour que la
/// grille ne change pas brutalement de mise en page une fois le rôle connu.
class _CarteActionChargement extends StatelessWidget {
  const _CarteActionChargement();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
