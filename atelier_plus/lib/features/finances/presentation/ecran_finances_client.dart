import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../auth/providers/auth_providers.dart';
import '../../clients/providers/clients_providers.dart';
import '../data/calcul_solde.dart';
import '../providers/finances_providers.dart';

/// Finances d'un client : montant total, avance, reste à payer calculé
/// automatiquement, historique des paiements.
///
/// Réservé au rôle propriétaire. Le rôle est vérifié ICI, avant même de
/// solliciter la moindre donnée financière — pas seulement au moment
/// d'une action d'écriture — conformément à l'exigence du cahier des
/// charges. La RLS Supabase applique la même règle indépendamment, en
/// défense en profondeur.
class EcranFinancesClient extends ConsumerWidget {
  const EcranFinancesClient({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estProprietaire = ref.watch(estProprietaireProvider);

    if (!estProprietaire) {
      return Scaffold(
        appBar: AppBar(title: const Text('Finances')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Seul le propriétaire de l\'atelier peut consulter les finances.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return _ContenuFinances(clientId: clientId);
  }
}

class _ContenuFinances extends ConsumerStatefulWidget {
  const _ContenuFinances({required this.clientId});

  final String clientId;

  @override
  ConsumerState<_ContenuFinances> createState() => _ContenuFinancesState();
}

class _ContenuFinancesState extends ConsumerState<_ContenuFinances> {
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enregistrer')),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ajouter')),
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

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(clientParIdProvider(widget.clientId));
    final commandeAsync = ref.watch(commandeDuClientProvider(widget.clientId));

    return Scaffold(
      appBar: AppBar(title: Text('Finances — ${client.valueOrNull?.nomComplet ?? ''}')),
      body: commandeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (commande) {
          if (commande == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => _ouvrirFormulaireCommande(),
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

          return ListView(
            padding: const EdgeInsets.all(16),
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
                        child: const Text('Modifier montant / avance'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _ajouterPaiement(commande.id),
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
      ),
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
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
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
