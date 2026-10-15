import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/constants/app_constants.dart';
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
  bool get tenueRetiree => _rdv?.tenueRetiree ?? _rdvGroupe!.tenueRetiree;
  // `tenueRetireeLe` est nullable (contrairement aux autres champs
  // ci-dessus) : utiliser `??` comme pour eux ferait croire, pour un
  // rendez-vous client sans "tenue retirée" (donc `tenueRetireeLe` null),
  // qu'aucun `_rdv` n'existe et irait lire `_rdvGroupe!` — qui est null
  // dans ce cas précis et provoque un plantage ("Null check operator used
  // on a null value"), ce qui arrivait dès l'ouverture de l'écran pour
  // n'importe quel rendez-vous client. D'où ce test explicite sur
  // `estGroupe` plutôt que sur la nullité de la valeur elle-même.
  DateTime? get tenueRetireeLe => estGroupe ? _rdvGroupe!.tenueRetireeLe : _rdv!.tenueRetireeLe;
}

/// Délai après lequel un rendez-vous marqué "tenue retirée" disparaît de la
/// liste (jamais supprimé en base, seulement masqué ici) — voir le filtre
/// `actifs` dans _EcranListeRendezVousState.build.
const _delaiMasquageTenueRetiree = Duration(minutes: 10);

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
  // Un rendez-vous marqué "tenue retirée" doit disparaître de la liste tout
  // seul 10 minutes plus tard, sans action de l'utilisateur ni nouvelle
  // écriture en base qui déclencherait un nouveau calcul du flux local —
  // seul le temps qui passe change le résultat du filtre, d'où ce
  // rafraîchissement périodique.
  Timer? _minuteur;

  final _rechercheCtrl = TextEditingController();
  final _dicteeVocale = stt.SpeechToText();
  String _requete = '';
  bool _dicteeDisponible = false;
  bool _enEcoute = false;

  @override
  void initState() {
    super.initState();
    _minuteur = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
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

  @override
  void dispose() {
    _minuteur?.cancel();
    _dicteeVocale.stop();
    _rechercheCtrl.dispose();
    super.dispose();
  }

  /// Dicter la recherche (nom du client ou du groupe) — même mécanisme de
  /// dictée vocale que l'écran "Mes clients".
  Future<void> _basculerDicteeRecherche() async {
    if (_enEcoute) {
      await _dicteeVocale.stop();
      if (mounted) setState(() => _enEcoute = false);
      return;
    }

    if (!_dicteeDisponible) {
      _dicteeDisponible = await _dicteeVocale.initialize(
        onStatus: (statut) {
          if ((statut == 'done' || statut == 'notListening') && mounted) {
            setState(() => _enEcoute = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _enEcoute = false);
        },
      );
      if (!_dicteeDisponible) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dictée vocale indisponible sur cet appareil.')),
          );
        }
        return;
      }
    }

    setState(() => _enEcoute = true);
    await _dicteeVocale.listen(
      localeId: 'fr_FR',
      onResult: (resultat) {
        _rechercheCtrl.text = resultat.recognizedWords;
        _rechercheCtrl.selection = TextSelection.collapsed(offset: _rechercheCtrl.text.length);
        setState(() => _requete = resultat.recognizedWords);
      },
    );
  }

  /// Nom affiché pour une ligne (client ou répondant du groupe), résolu via
  /// les caches locaux déjà en mémoire — utilisé à la fois pour l'affichage
  /// de chaque ligne et pour le filtrage par la recherche ci-dessus.
  String _nomPour(_RdvUnifie item) {
    if (item.estGroupe) {
      final groupe = ref.watch(groupeUniformeParIdProvider(item.rdvGroupe.groupeId));
      // Le nom du répondant (ex. "TINDANO Aboubacar") parle davantage au
      // tailleur que le nom interne du groupe (ex. "DPAERAH") — la pastille
      // "Uniforme" ci-dessous indique déjà qu'il s'agit d'un groupe.
      final g = groupe.valueOrNull;
      return g?.repondantNom ?? g?.nom ?? '…';
    }
    final client = ref.watch(clientParIdProvider(item.rdv.clientId));
    return client.valueOrNull?.nomComplet ?? '…';
  }

  /// Corrige un rendez-vous déjà enregistré (date, heure, type), permet de
  /// le marquer urgent et/ou "tenue retirée" — client ou groupe selon
  /// `item.estGroupe`.
  Future<void> _modifier(_RdvUnifie item, String nom) async {
    var date = item.dateHeure;
    var heure = TimeOfDay.fromDateTime(item.dateHeure);
    var urgent = item.urgent;
    var tenueRetiree = item.tenueRetiree;

    final resultat = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _bleuSeda.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_calendar_outlined, color: _bleuSeda),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MODIFIER LE RENDEZ-VOUS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Color(0xFF6F6259),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nom,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _bleuSeda,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColoredBox(
                      color: const Color(0xFFF6F3EE),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today_outlined, color: _bleuSeda),
                            title: Text(
                              Formatters.dateLongue(date),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Color(0xFF6F6259)),
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
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(Icons.access_time, color: _bleuSeda),
                            title: Text(
                              heure.format(context),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Color(0xFF6F6259)),
                            onTap: () async {
                              final choisie =
                                  await showTimePicker(context: context, initialTime: heure);
                              if (choisie != null) setStateDialog(() => heure = choisie);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColoredBox(
                      color: urgent ? _rougeAlerte.withOpacity(0.08) : const Color(0xFFF6F3EE),
                      child: SwitchListTile(
                        activeColor: _rougeAlerte,
                        value: urgent,
                        onChanged: (valeur) => setStateDialog(() => urgent = valeur),
                        secondary: const Icon(Icons.priority_high, color: _rougeAlerte),
                        title: const Text('Urgent', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColoredBox(
                      color: tenueRetiree ? _bleuSeda.withOpacity(0.08) : const Color(0xFFF6F3EE),
                      child: SwitchListTile(
                        activeColor: _bleuSeda,
                        value: tenueRetiree,
                        onChanged: (valeur) => setStateDialog(() => tenueRetiree = valeur),
                        secondary: const Icon(Icons.checkroom_outlined, color: _bleuSeda),
                        title: const Text(
                          'Tenue retirée',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Disparaît automatiquement de la liste 10 minutes après',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, 'terminer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _bleuSeda,
                        side: const BorderSide(color: _bleuSeda),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Marquer comme terminé'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, 'annuler_rdv'),
                          style: TextButton.styleFrom(foregroundColor: _rougeAlerte),
                          child: const Text('Annuler le rendez-vous'),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6F6259)),
                          child: const Text('Fermer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, 'enregistrer'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _orangeSeda,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                tenueRetiree: tenueRetiree,
                nomGroupePourRappel: nom,
              )
          : ref.read(rendezVousRepositoryProvider).modifierRendezVous(
                existant: item.rdv,
                dateHeure: dateHeure,
                type: item.rdv.type,
                urgent: urgent,
                tenueRetiree: tenueRetiree,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _rechercheCtrl,
              onChanged: (valeur) => setState(() => _requete = valeur),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(
                    _enEcoute ? Icons.mic : Icons.mic_none,
                    color: _enEcoute ? Colors.red : Colors.white70,
                  ),
                  tooltip: 'Rechercher à la voix',
                  onPressed: _basculerDicteeRecherche,
                ),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: rdvsClients.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
          data: (listeClients) => rdvsGroupes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
          data: (listeGroupes) {
            // Fusionne clients et groupes d'uniformes en une seule liste
            // triée par date — chaque source est déjà triée individuellement
            // (observerRendezVousTries/observerTousRendezVousGroupeTries),
            // donc un simple tri stable sur l'ensemble suffit.
            final liste = [
              ...listeClients.map(_RdvUnifie.client),
              ...listeGroupes.map(_RdvUnifie.groupe),
            ]..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
            // Un rendez-vous "tenue retirée" depuis plus de 10 minutes
            // disparaît de cette liste (jamais supprimé en base, voir
            // _delaiMasquageTenueRetiree) — recalculé à chaque minute grâce
            // à `_minuteur`, pas seulement quand les données changent.
            final requete = _requete.trim().toLowerCase();
            final actifs = liste
                .where((r) => r.statut != AppConstants.rdvAnnule)
                .where((r) {
                  final depuis = r.tenueRetireeLe;
                  if (!r.tenueRetiree || depuis == null) return true;
                  return DateTime.now().toUtc().difference(depuis) < _delaiMasquageTenueRetiree;
                })
                .where((r) => requete.isEmpty || _nomPour(r).toLowerCase().contains(requete))
                .toList();
            if (actifs.isEmpty) {
              return Center(
                child: Text(requete.isEmpty ? 'Aucun rendez-vous à venir.' : 'Aucun résultat.'),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Touchez une ligne (ou "+") pour modifier le rendez-vous.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6F6259)),
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
    );
  }

  TableRow _ligne(_RdvUnifie item, int index) {
    final nom = _nomPour(item);
    final fondLigne = item.urgent
        ? const Color(0xFFFBE4E1)
        : (index.isEven ? Colors.white : const Color(0xFFF6F3EE));
    final afficherBadges = item.estGroupe ||
        item.urgent ||
        item.tenueRetiree ||
        item.statut == AppConstants.rdvConfirme ||
        item.statut == AppConstants.rdvTermine;

    return TableRow(
      decoration: BoxDecoration(color: fondLigne),
      children: [
        GestureDetector(
          onTap: () => _modifier(item, nom),
          child: _Cellule(nom, tronquer: false),
        ),
        GestureDetector(
          onTap: () => _modifier(item, nom),
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
                      if (item.estGroupe) const _PuceUniforme(),
                      _PuceStatut(statut: item.statut),
                      if (item.urgent) const _PuceUrgent(),
                      if (item.tenueRetiree) const _PuceRetiree(),
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
        couleur = const Color(0xFF66BB6A);
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

/// Pastille "Uniforme" — distingue un rendez-vous de groupe d'uniformes
/// d'un rendez-vous client dans la liste fusionnée, le nom affiché
/// (répondant) ne le laissant pas deviner à lui seul. Même violet que
/// l'icône "groupes" de l'écran "Nouveau groupe"/"Mesures des uniformes".
class _PuceUniforme extends StatelessWidget {
  const _PuceUniforme();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3B3470),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Uniforme',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
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

/// Pastille "Retiré" — même violet que la pastille "Uniforme", pour
/// signaler que le client est venu récupérer sa tenue (voir
/// RendezVous.tenueRetiree).
class _PuceRetiree extends StatelessWidget {
  const _PuceRetiree();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3B3470),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Retiré',
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
