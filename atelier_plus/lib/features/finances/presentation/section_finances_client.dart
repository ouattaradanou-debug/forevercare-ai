import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../data/models/commande.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/calcul_solde.dart';
import '../providers/finances_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Contenu financier d'un client : commande en cours (montant total,
/// avance, reste à payer calculé automatiquement, case "Tenue retirée",
/// historique des paiements), et historique des commandes précédentes —
/// un client qui revient pour une nouvelle couture garde l'historique
/// complet de ses commandes passées, jamais écrasé.
///
/// Extrait en widget partagé pour être affiché à la fois par l'écran dédié
/// `EcranFinancesClient` et directement sur la fiche client — l'appelant
/// est responsable de vérifier que l'utilisateur est bien propriétaire
/// avant d'afficher ce widget (donnée financière, jamais montrée à un
/// apprenti).
class SectionFinancesClient extends ConsumerStatefulWidget {
  const SectionFinancesClient({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<SectionFinancesClient> createState() => _SectionFinancesClientState();
}

class _SectionFinancesClientState extends ConsumerState<SectionFinancesClient> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(financesRepositoryProvider).chargerDepuisServeur(widget.clientId),
    );
  }

  Future<({double montant, double avance})?> _demanderMontants({
    required String titre,
    double? montantActuel,
    double? avanceActuelle,
  }) async {
    final montantCtrl = TextEditingController(text: montantActuel?.toStringAsFixed(0) ?? '');
    final avanceCtrl = TextEditingController(text: avanceActuelle?.toStringAsFixed(0) ?? '');

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montantCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant total (FCFA)'),
            ),
            TextField(
              controller: avanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Avance reçue (FCFA)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (confirme != true) return null;
    return (
      montant: double.tryParse(montantCtrl.text.replaceAll(',', '.')) ?? 0,
      avance: double.tryParse(avanceCtrl.text.replaceAll(',', '.')) ?? 0,
    );
  }

  /// Nouvelle couture pour ce client : crée une commande distincte, sans
  /// toucher à la commande en cours ni à l'historique des précédentes.
  Future<void> _creerNouvelleCommande() async {
    final valeurs = await _demanderMontants(titre: 'Nouvelle commande');
    if (valeurs == null) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    await executerAvecErreurAffichee(
      context,
      () => ref.read(financesRepositoryProvider).creerNouvelleCommande(
            atelierId: utilisateur!.atelierId,
            clientId: widget.clientId,
            montantTotal: valeurs.montant,
            avance: valeurs.avance,
          ),
    );
    ref.invalidate(commandesDuClientProvider(widget.clientId));
  }

  /// Corrige le montant/l'avance de la commande en cours (erreur de
  /// saisie) — ne crée jamais une nouvelle commande.
  Future<void> _modifierCommandeCourante(Commande courante) async {
    final valeurs = await _demanderMontants(
      titre: 'Modifier la commande',
      montantActuel: courante.montantTotal,
      avanceActuelle: courante.avance,
    );
    if (valeurs == null) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    await executerAvecErreurAffichee(
      context,
      () => ref.read(financesRepositoryProvider).modifierCommande(
            atelierId: utilisateur!.atelierId,
            commande: courante,
            montantTotal: valeurs.montant,
            avance: valeurs.avance,
          ),
    );
    ref.invalidate(commandesDuClientProvider(widget.clientId));
  }

  Future<void> _ajouterPaiement(String commandeId) async {
    final montantCtrl = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un paiement'),
        content: TextField(
          controller: montantCtrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant reçu (FCFA)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (confirme != true) return;
    final montant = double.tryParse(montantCtrl.text.replaceAll(',', '.')) ?? 0;
    if (montant <= 0) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    await executerAvecErreurAffichee(
      context,
      () => ref.read(financesRepositoryProvider).ajouterPaiement(
            atelierId: utilisateur!.atelierId,
            commandeId: commandeId,
            montant: montant,
          ),
    );
  }

  Future<void> _basculerTenueRetiree(Commande courante, bool? valeur) async {
    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    await executerAvecErreurAffichee(
      context,
      () => ref.read(financesRepositoryProvider).definirTenueRetiree(
            atelierId: utilisateur!.atelierId,
            commande: courante,
            tenueRetiree: valeur ?? false,
          ),
    );
    ref.invalidate(commandesDuClientProvider(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    final commandesAsync = ref.watch(commandesDuClientProvider(widget.clientId));

    return commandesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
      data: (commandes) {
        if (commandes.isEmpty) {
          return Center(
            child: ElevatedButton.icon(
              onPressed: _creerNouvelleCommande,
              style: ElevatedButton.styleFrom(backgroundColor: _orangeSeda, foregroundColor: Colors.white),
              icon: const Icon(Icons.add),
              label: const Text('Créer une commande'),
            ),
          );
        }

        final courante = commandes.first;
        final precedentes = commandes.skip(1).toList();
        final paiements = ref.watch(paiementsDeLaCommandeProvider(courante.id));
        final sommePaiements =
            paiements.valueOrNull?.fold<double>(0, (total, p) => total + p.montant) ?? 0;
        final reste = resteAPayer(
          montantTotal: courante.montantTotal,
          avance: courante.avance,
          sommePaiements: sommePaiements,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LigneMontant('Montant total', courante.montantTotal),
                    _LigneMontant('Avance', courante.avance),
                    const Divider(),
                    _LigneMontant(
                      reste > 0 ? 'Reste à payer' : 'Paiement reçu',
                      reste > 0 ? reste : courante.avance + sommePaiements,
                      accent: true,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _modifierCommandeCourante(courante),
                      style: OutlinedButton.styleFrom(foregroundColor: _bleuSeda, side: const BorderSide(color: _bleuSeda)),
                      child: const Text('Modifier montant / avance'),
                    ),
                    CheckboxListTile(
                      value: courante.tenueRetiree,
                      activeColor: _bleuSeda,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tenue retirée'),
                      onChanged: (valeur) => _basculerTenueRetiree(courante, valeur),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _ajouterPaiement(courante.id),
                    style: ElevatedButton.styleFrom(backgroundColor: _orangeSeda, foregroundColor: Colors.white),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Ajouter un paiement'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _creerNouvelleCommande,
                    style: OutlinedButton.styleFrom(foregroundColor: _bleuSeda, side: const BorderSide(color: _bleuSeda)),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Nouvelle commande'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Historique des paiements', style: Theme.of(context).textTheme.titleSmall),
            paiements.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (erreur, _) => Text('Erreur : $erreur'),
              data: (liste) {
                if (liste.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aucun paiement enregistré.'),
                  );
                }
                return Column(
                  children: liste
                      .map(
                        (p) => ListTile(
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: Text(Formatters.montant(p.montant)),
                          subtitle: Text(Formatters.dateCourte(p.datePaiement)),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            if (precedentes.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Commandes précédentes', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final commande in precedentes) _CarteCommandePrecedente(commande: commande),
            ],
          ],
        );
      },
    );
  }
}

class _LigneMontant extends StatelessWidget {
  const _LigneMontant(this.libelle, this.montant, {this.accent = false});

  final String libelle;
  final double montant;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final style = accent
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: _orangeSeda)
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: style),
          Text(Formatters.montant(montant), style: style),
        ],
      ),
    );
  }
}

/// Résumé en lecture seule d'une commande passée : date, montant, reste à
/// payer (calculé à partir de ses propres paiements, jamais mélangés avec
/// la commande en cours).
class _CarteCommandePrecedente extends ConsumerWidget {
  const _CarteCommandePrecedente({required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<double>(
          future: ref.read(financesRepositoryProvider).sommePaiements(commande.id),
          builder: (context, snapshot) {
            final somme = snapshot.data ?? 0;
            final reste = resteAPayer(
              montantTotal: commande.montantTotal,
              avance: commande.avance,
              sommePaiements: somme,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Formatters.dateCourte(commande.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(Formatters.montant(commande.montantTotal)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reste > 0 ? 'Reste à payer : ${Formatters.montant(reste)}' : 'Soldée',
                  style: TextStyle(
                    color: reste > 0 ? _orangeSeda : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (commande.tenueRetiree)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Tenue retirée', style: TextStyle(color: Color(0xFF6F6259))),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
