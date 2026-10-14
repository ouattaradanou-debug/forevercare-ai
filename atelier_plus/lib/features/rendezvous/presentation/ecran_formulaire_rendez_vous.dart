import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_providers.dart';
import '../../clients/providers/clients_providers.dart';
import '../../../data/models/client.dart';
import '../providers/rendezvous_providers.dart';

/// Création d'un rendez-vous. [clientPreselectionne] est fourni quand
/// l'écran est ouvert depuis la fiche d'un client ; sinon un champ de
/// recherche permet de choisir le client.
class EcranFormulaireRendezVous extends ConsumerStatefulWidget {
  const EcranFormulaireRendezVous({super.key, this.clientPreselectionne});

  final Client? clientPreselectionne;

  @override
  ConsumerState<EcranFormulaireRendezVous> createState() => _EcranFormulaireRendezVousState();
}

class _EcranFormulaireRendezVousState extends ConsumerState<EcranFormulaireRendezVous> {
  Client? _client;
  final _rechercheCtrl = TextEditingController();
  String _requeteRecherche = '';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _heure = const TimeOfDay(hour: 9, minute: 0);
  String _type = AppConstants.rdvEssayage;
  bool _chargement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _client = widget.clientPreselectionne;
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  /// Enchaîne directement sur le choix de l'heure une fois la date choisie,
  /// pour un tailleur qui sait lire/écrire et préfère les sélecteurs
  /// manuels (calendrier puis horloge) à la dictée vocale.
  Future<void> _choisirDate() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (choisie == null) return;
    setState(() => _date = choisie);
    if (mounted) await _choisirHeure();
  }

  Future<void> _choisirHeure() async {
    final choisie = await showTimePicker(context: context, initialTime: _heure);
    if (choisie != null) setState(() => _heure = choisie);
  }

  Future<void> _enregistrer() async {
    if (_client == null) {
      setState(() => _erreur = 'Choisissez un client.');
      return;
    }
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final dateHeure =
          DateTime(_date.year, _date.month, _date.day, _heure.hour, _heure.minute);
      final utilisateur = await utilisateurCourantRequis(ref);
      await ref.read(rendezVousRepositoryProvider).creerRendezVous(
            atelierId: utilisateur.atelierId,
            clientId: _client!.id,
            dateHeure: dateHeure,
            type: _type,
            nomClientPourRappel: _client!.nomComplet,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau rendez-vous')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_client != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(_client!.nomComplet),
                    trailing: widget.clientPreselectionne == null
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _client = null),
                          )
                        : null,
                  ),
                )
              else ...[
                TextField(
                  controller: _rechercheCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Rechercher un client',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (valeur) => setState(() => _requeteRecherche = valeur),
                ),
                const SizedBox(height: 8),
                if (_requeteRecherche.isNotEmpty) _ResultatsRecherche(
                  requete: _requeteRecherche,
                  onSelection: (client) => setState(() {
                    _client = client;
                    _requeteRecherche = '';
                    _rechercheCtrl.clear();
                  }),
                ),
              ],
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(Formatters.dateLongue(_date)),
                onTap: _choisirDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: Text(_heure.format(context)),
                onTap: _choisirHeure,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: AppConstants.rdvEssayage, label: Text('Essayage')),
                  ButtonSegment(value: AppConstants.rdvLivraison, label: Text('Livraison')),
                ],
                selected: {_type},
                onSelectionChanged: (selection) => setState(() => _type = selection.first),
              ),
              if (_erreur != null) ...[
                const SizedBox(height: 8),
                Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _chargement ? null : _enregistrer,
                child: _chargement
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer le rendez-vous'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultatsRecherche extends ConsumerWidget {
  const _ResultatsRecherche({required this.requete, required this.onSelection});

  final String requete;
  final void Function(Client) onSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultats = ref.watch(rechercheClientsProvider(requete));
    return resultats.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (clients) => Column(
        children: clients
            .take(5)
            .map(
              (client) => ListTile(
                title: Text(client.nomComplet),
                onTap: () => onSelection(client),
              ),
            )
            .toList(),
      ),
    );
  }
}
