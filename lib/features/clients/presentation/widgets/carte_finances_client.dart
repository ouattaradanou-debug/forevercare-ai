import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/commande.dart';
import '../../../../data/models/paiement.dart';
import '../providers/finances_providers.dart';
import 'section_titre.dart';

final NumberFormat _formatMontant = NumberFormat.decimalPattern('fr_FR');

String _fcfa(double montant) => '${_formatMontant.format(montant)} FCFA';

/// Carte "Finances" de la fiche client : montant convenu, déjà payé, reste
/// à payer, historique des paiements et bouton pour en enregistrer un
/// nouveau. À n'afficher QUE si le propriétaire consulte la fiche — voir
/// ClientDetailPage (un apprenti n'a jamais accès aux finances, même en
/// lecture seule, voir PermissionsApprenti et supabase/schema.sql).
class CarteFinancesClient extends ConsumerWidget {
  const CarteFinancesClient({super.key, required this.clientId});

  final String clientId;

  Future<void> _ouvrirDialoguePaiement(
    BuildContext context,
    WidgetRef ref,
    Commande commande,
  ) async {
    final TextEditingController controleur = TextEditingController();
    final String? resultat = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reste à payer : ${_fcfa(commande.resteAPayer)}'),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: controleur,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Montant reçu (FCFA)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controleur.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    final double? montant = resultat == null ? null : double.tryParse(resultat);
    if (montant == null || montant <= 0) return;

    try {
      await ref
          .read(financesRepositoryProvider)
          .ajouterPaiement(clientId: clientId, montant: montant);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Commande? commande = ref
        .watch(commandeClientProvider(clientId))
        .asData
        ?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitre(
          icone: Icons.savings_outlined,
          titre: 'Finances',
          couleur: AppColors.succes,
        ),
        const SizedBox(height: AppSpacing.m),
        if (commande == null)
          const Text(
            "Aucun montant convenu n'a encore été renseigné pour ce "
            'client.',
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ligne(context, 'Montant convenu', commande.montantTotal),
                  _ligne(context, 'Déjà payé', commande.avance),
                  _ligne(
                    context,
                    'Reste à payer',
                    commande.resteAPayer,
                    accent: true,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Tenue retirée'),
                    value: commande.tenueRetiree,
                    onChanged: (valeur) => ref
                        .read(financesRepositoryProvider)
                        .definirTenueRetiree(
                          clientId: clientId,
                          retiree: valeur ?? false,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  if (commande.resteAPayer > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _ouvrirDialoguePaiement(context, ref, commande),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un paiement'),
                      ),
                    )
                  else
                    Text(
                      'Entièrement payé.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.succes,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.m),
                  _HistoriquePaiements(commandeId: commande.id),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _ligne(
    BuildContext context,
    String libelle,
    double montant, {
    bool accent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            _fcfa(montant),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: accent ? AppColors.terracotta600 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoriquePaiements extends ConsumerWidget {
  const _HistoriquePaiements({required this.commandeId});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Paiement> paiements =
        ref.watch(paiementsCommandeProvider(commandeId)).asData?.value ??
        const [];

    if (paiements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des paiements',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final Paiement p in paiements)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMM yyyy', 'fr_FR').format(p.datePaiement),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(_fcfa(p.montant)),
              ],
            ),
          ),
      ],
    );
  }
}
