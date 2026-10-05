import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/calcul_solde.dart';
import '../providers/finances_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Contenu financier d'un client : montant total, avance, reste à payer
/// calculé automatiquement, case "Tenue retirée" et historique des
/// paiements.
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

  Future<void> _ouvrirFormulaireCommande({double? montantActuel, double? avanceActuelle}) async {
    final montantCtrl = TextEditingController(text: montantActuel?.toStringAsFixed(0) ?? '');
    final avanceCtrl = TextEditingController(text: avanceActuelle?.toStringAsFixed(0) ?? '');

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(montantActuel == null ? 'Nouvelle commande' : 'Modifier la commande'),
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

    if (confirme != true) return;
    final montant = double.tryParse(montantCtrl.text.replaceAll(',', '.')) ?? 0;
    final avance = double.tryParse(avanceCtrl.text.replaceAll(',', '.')) ?? 0;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    await executerAvecErreurAffichee(
      context,
      () => ref.read(financesRepositoryProvider).definirCommande(
            atelierId: utilisateur!.atelierId,
            clientId: widget.clientId,
            montantTotal: montant,
            avance: avance,
          ),
    );
    ref.invalidate(commandeDuClientProvider(widget.clientId));
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

  Future<void> _basculerTenueRetiree(bool? valeur) async {
    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    await executerAvecErreurAffichee(
      context,
      () => ref.read(financesRepositoryProvider).definirTenueRetiree(
            atelierId: utilisateur!.atelierId,
            clientId: widget.clientId,
            tenueRetiree: valeur ?? false,
          ),
    );
    ref.invalidate(commandeDuClientProvider(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    final commandeAsync = ref.watch(commandeDuClientProvider(widget.clientId));

    return commandeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
      data: (commande) {
        if (commande == null) {
          return Center(
            child: ElevatedButton.icon(
              onPressed: () => _ouvrirFormulaireCommande(),
              style: ElevatedButton.styleFrom(backgroundColor: _orangeSeda, foregroundColor: Colors.white),
              icon: const Icon(Icons.add),
              label: const Text('Créer une commande'),
            ),
          );
        }

        final paiements = ref.watch(paiementsDeLaCommandeProvider(commande.id));
        final sommePaiements =
            paiements.valueOrNull?.fold<double>(0, (total, p) => total + p.montant) ?? 0;
        final reste = resteAPayer(
          montantTotal: commande.montantTotal,
          avance: commande.avance,
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
                    _LigneMontant('Montant total', commande.montantTotal),
                    _LigneMontant('Avance', commande.avance),
                    _LigneMontant('Paiements reçus', sommePaiements),
                    const Divider(),
                    _LigneMontant(
                      reste > 0 ? 'Reste à payer' : 'Trop-perçu',
                      reste.abs(),
                      accent: true,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _ouvrirFormulaireCommande(
                        montantActuel: commande.montantTotal,
                        avanceActuelle: commande.avance,
                      ),
                      style: OutlinedButton.styleFrom(foregroundColor: _bleuSeda, side: const BorderSide(color: _bleuSeda)),
                      child: const Text('Modifier montant / avance'),
                    ),
                    CheckboxListTile(
                      value: commande.tenueRetiree,
                      activeColor: _bleuSeda,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tenue retirée'),
                      onChanged: _basculerTenueRetiree,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _ajouterPaiement(commande.id),
              style: ElevatedButton.styleFrom(backgroundColor: _orangeSeda, foregroundColor: Colors.white),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Ajouter un paiement'),
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
