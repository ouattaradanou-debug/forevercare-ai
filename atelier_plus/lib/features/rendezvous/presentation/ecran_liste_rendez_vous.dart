import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../data/models/rendez_vous.dart';
import '../../../data/models/rendez_vous_groupe.dart';
import '../../auth/providers/auth_providers.dart';
import '../../clients/providers/clients_providers.dart';
import '../../uniformes/providers/uniformes_providers.dart';
import '../providers/rendez_vous_groupe_providers.dart';
import '../providers/rendezvous_providers.dart';

/// Représentation unifiée d'un rendez-vous de client ou de groupe
/// d'uniformes, pour que l'écran "Rendez-vous" les affiche et les gère
/// ensemble dans une seule liste triée par date — les deux viennent de
/// tables séparées (`rendez_vous`/`rendez_vous_groupe`, voir
/// RendezVousGroupeEntries) donc de deux repositories séparés, vers
/// lesquels les actions (changer de statut, modifier) sont redirigées
/// selon `estGroupe`.
class _RdvUnifie {
  const _RdvUnifie.client(RendezVous rdv)
      : _rdv = rdv,
        _rdvGroupe = null;

  const _RdvUnifie.groupe(RendezVousGroupe rdvGroupe)
      : _rdv = null,
        _rdvGroupe = rdvGroupe;

  final RendezVous? _rdv;
  final RendezVousGroupe? _rdvGroupe;

  bool get estGroupe => _rdvGroupe != null;
  RendezVous get rdv => _rdv!;
  RendezVousGroupe get rdvGroupe => _rdvGroupe!;

  String get id => _rdv?.id ?? _rdvGroupe!.id;
  DateTime get dateHeure => _rdv?.dateHeure ?? _rdvGroupe!.dateHeure;
  String get statut => _rdv?.statut ?? _rdvGroupe!.statut;
  bool get urgent => _rdv?.urgent ?? _rdvGroupe!.urgent;
}

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);
const _rougeAlerte = Color(0xFFB3261E);

/// Liste des rendez-vous de l'atelier, triée par date — lecture locale
/// (hors-ligne au quotidien), sous forme de tableau (Nom / Date et heure)
/// avec un bouton "+" orange pour corriger un rendez-vous (date, heure,
/// type, urgence) directement depuis la liste.
class EcranListeRendezVous extends ConsumerStatefulWidget {
  const EcranListeRendezVous({super.key});

  @override
  ConsumerState<EcranListeRendezVous> createState() => _EcranListeRendezVousState();
}

class _EcranListeRendezVousState extends ConsumerState<EcranListeRendezVous> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur == null || !mounted) return;
      await ref.read(rendezVousRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      if (!mounted) return;
      await ref
          .read(rendezVousGroupeRepositoryProvider)
          .chargerTousDepuisServeur(utilisateur.atelierId);
    });
  }

  /// Corrige un rendez-vous déjà enregistré (date, heure, type) et permet
  /// de le marquer urgent — client ou groupe selon `item.estGroupe`.
  Future<void> _modifier(_RdvUnifie item, String nom) async {
    var date = item.dateHeure;
    var heure = TimeOfDay.fromDateTime(item.dateHeure);
    var urgent = item.urgent;

    final resultat = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          scrollable: true,
          title: Text('Modifier : $nom', style: const TextStyle(color: _bleuSeda)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, color: _bleuSeda),
                title: Text(Formatters.dateLongue(date)),
                onTap: () async {
                  final choisie = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (choisie != null) setStateDialog(() => date = choisie);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: _bleuSeda),
                title: Text(heure.format(context)),
                onTap: () async {
                  final choisie = await showTimePicker(context: context, initialTime: heure);
                  if (choisie != null) setStateDialog(() => heure = choisie);
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: _rougeAlerte,
                value: urgent,
                onChanged: (valeur) => setStateDialog(() => urgent = valeur),
                title: const Text('Urgent'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'annuler_rdv'),
              style: TextButton.styleFrom(foregroundColor: _rougeAlerte),
              child: const Text('Annuler le rendez-vous'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'terminer'),
              style: TextButton.styleFrom(foregroundColor: _bleuSeda),
              child: const Text('Marquer comme terminé'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: _bleuSeda),
              child: const Text('Fermer'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'enregistrer'),
              style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (resultat == null || !mounted) return;

    if (resultat == 'annuler_rdv' || resultat == 'terminer') {
      final nouveauStatut =
          resultat == 'annuler_rdv' ? AppConstants.rdvAnnule : AppConstants.rdvTermine;
      await executerAvecErreurAffichee(
        context,
        () => item.estGroupe
            ? ref.read(rendezVousGroupeRepositoryProvider).changerStatutParId(
                  item.id,
                  nouveauStatut,
                )
            : ref.read(rendezVousRepositoryProvider).changerStatutParId(
                  item.id,
                  nouveauStatut,
                ),
      );
      return;
    }

    final dateHeure = DateTime(date.year, date.month, date.day, heure.hour, heure.minute);
    await executerAvecErreurAffichee(
      context,
      () => item.estGroupe
          ? ref.read(rendezVousGroupeRepositoryProvider).modifierRendezVous(
                existant: item.rdvGroupe,
                dateHeure: dateHeure,
                type: item.rdvGroupe.type,
                urgent: urgent,
                nomGroupePourRappel: nom,
              )
          : ref.read(rendezVousRepositoryProvider).modifierRendezVous(
                existant: item.rdv,
                dateHeure: dateHeure,
                type: item.rdv.type,
                urgent: urgent,
                nomClientPourRappel: nom,
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rdvsClients = ref.watch(rendezVousTriesProvider);
    final rdvsGroupes = ref.watch(rendezVousGroupeTriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendez-vous'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: rdvsClients.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
          data: (listeClients) => rdvsGroupes.when(
          loading: () => const Center(child: Text('DIAGNOSTIC : groupes en chargement…')),
          error: (erreur, _) => Center(child: Text('DIAGNOSTIC erreur groupes : $erreur')),
          data: (listeGroupes) {
            // Fusionne clients et groupes d'uniformes en une seule liste
            // triée par date — chaque source est déjà triée individuellement
            // (observerRendezVousTries/observerTousRendezVousGroupeTries),
            // donc un simple tri stable sur l'ensemble suffit.
            final liste = [
              ...listeClients.map(_RdvUnifie.client),
              ...listeGroupes.map(_RdvUnifie.groupe),
            ]..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
            final actifs = liste.where((r) => r.statut != AppConstants.rdvAnnule).toList();
            if (actifs.isEmpty) {
              return const Center(child: Text('Aucun rendez-vous à venir.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Touchez une ligne pour changer le statut. '
                      'Touchez "+" pour corriger ou marquer urgent.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6F6259)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'DIAGNOSTIC : ${listeClients.length} clients, '
                      '${listeGroupes.length} groupes trouvés.',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _bleuSeda, width: 2),
                        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10)],
                      ),
                      child: Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          1: FixedColumnWidth(150),
                          2: FixedColumnWidth(56),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: _bleuSeda),
                            children: const [
                              _Cellule('Nom', entete: true),
                              _Cellule('Date et heure', entete: true),
                              SizedBox.shrink(),
                            ],
                          ),
                          for (final entree in actifs.asMap().entries)
                            _ligne(entree.value, entree.key),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.creationRendezVous),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau rendez-vous'),
      ),
    );
  }

  TableRow _ligne(_RdvUnifie item, int index) {
    final String nom;
    if (item.estGroupe) {
      final groupe = ref.watch(groupeUniformeParIdProvider(item.rdvGroupe.groupeId));
      nom = groupe.valueOrNull?.nom ?? '…';
    } else {
      final client = ref.watch(clientParIdProvider(item.rdv.clientId));
      nom = client.valueOrNull?.nomComplet ?? '…';
    }
    final fondLigne = item.urgent
        ? const Color(0xFFFBE4E1)
        : (index.isEven ? Colors.white : const Color(0xFFF6F3EE));
    final afficherBadges = item.urgent ||
        item.statut == AppConstants.rdvConfirme ||
        item.statut == AppConstants.rdvTermine;

    return TableRow(
      decoration: BoxDecoration(color: fondLigne),
      children: [
        GestureDetector(
          onTap: () => _afficherActions(context, ref, item),
          child: _Cellule(nom, tronquer: false),
        ),
        GestureDetector(
          onTap: () => _afficherActions(context, ref, item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Formatters.dateHeure(item.dateHeure),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (afficherBadges) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _PuceStatut(statut: item.statut),
                      if (item.urgent) const _PuceUrgent(),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: IconButton(
              onPressed: () => _modifier(item, nom),
              tooltip: 'Modifier',
              style: IconButton.styleFrom(
                backgroundColor: _orangeSeda,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.add, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _afficherActions(
    BuildContext context,
    WidgetRef ref,
    _RdvUnifie item,
  ) async {
    final nouveauStatut = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: _bleuSeda),
              title: const Text('Confirmer'),
              onTap: () => Navigator.pop(context, AppConstants.rdvConfirme),
            ),
            ListTile(
              leading: const Icon(Icons.done_all, color: _bleuSeda),
              title: const Text('Marquer comme terminé'),
              onTap: () => Navigator.pop(context, AppConstants.rdvTermine),
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: _rougeAlerte),
              title: const Text('Annuler ce rendez-vous'),
              onTap: () => Navigator.pop(context, AppConstants.rdvAnnule),
            ),
          ],
        ),
      ),
    );

    if (nouveauStatut != null && nouveauStatut != item.statut) {
      await executerAvecErreurAffichee(
        context,
        () => item.estGroupe
            ? ref.read(rendezVousGroupeRepositoryProvider).changerStatutParId(
                  item.id,
                  nouveauStatut,
                )
            : ref.read(rendezVousRepositoryProvider).changerStatutParId(
                  item.id,
                  nouveauStatut,
                ),
      );
    }
  }
}

/// N'affiche une pastille que pour les statuts "confirme" et "termine" —
/// "planifie" (le statut par défaut de la quasi-totalité des rendez-vous)
/// n'apporte pas d'information utile au premier coup d'œil.
class _PuceStatut extends StatelessWidget {
  const _PuceStatut({required this.statut});

  final String statut;

  @override
  Widget build(BuildContext context) {
    final Color couleur;
    final String libelle;
    switch (statut) {
      case AppConstants.rdvConfirme:
        couleur = const Color(0xFF2E7D32);
        libelle = 'Confirmé';
        break;
      case AppConstants.rdvTermine:
        couleur = const Color(0xFF546E7A);
        libelle = 'Terminé';
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(20)),
      child: Text(
        libelle,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

/// Pastille "Urgent" — même code couleur que l'alerte de stock bas, pour
/// rester cohérent dans toute l'application.
class _PuceUrgent extends StatelessWidget {
  const _PuceUrgent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _rougeAlerte, borderRadius: BorderRadius.circular(20)),
      child: const Text(
        'Urgent',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule(
    this.texte, {
    this.entete = false,
    this.tronquer = true,
  });

  final String texte;
  final bool entete;
  final bool tronquer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: entete ? 14 : 12, horizontal: 8),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        maxLines: tronquer ? 1 : null,
        overflow: tronquer ? TextOverflow.ellipsis : TextOverflow.visible,
        style: TextStyle(
          fontWeight: entete ? FontWeight.bold : FontWeight.w600,
          color: entete ? Colors.white : const Color(0xFF231A14),
          fontSize: entete ? 13 : 14,
          letterSpacing: entete ? 0.3 : 0,
        ),
      ),
    );
  }
}
