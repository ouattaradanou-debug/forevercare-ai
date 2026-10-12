import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../data/models/commande_groupe.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/calcul_solde.dart';
import '../providers/finances_groupe_providers.dart';
import 'dialogue_montants.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Contenu financier d'un groupe d'uniformes : commande globale en cours
/// (montant total convenu, avance payée, reste à payer calculé
/// automatiquement), avec ajout de paiement et correction en cas d'erreur
/// — même principe que SectionFinancesClient, mais sur les tables dédiées
/// commandes_groupe/paiements_groupe (voir FinancesGroupeRepository) : un
/// groupe a une seule commande, pas d'historique de commandes précédentes
/// ni de facture PDF ; le statut "tenue terminée" reste propre à chaque
/// membre (voir EcranFicheMembre).
///
/// Réservé au propriétaire : l'appelant est responsable de vérifier le
/// rôle avant d'afficher ce widget, comme pour SectionFinancesClient.
class SectionFinancesGroupe extends ConsumerStatefulWidget {
  const SectionFinancesGroupe({super.key, required this.groupeId});

  final String groupeId;

  @override
  ConsumerState<SectionFinancesGroupe> createState() => _SectionFinancesGroupeState();
}

class _SectionFinancesGroupeState extends ConsumerState<SectionFinancesGroupe> {
  // Même garde que SectionFinancesClient : un cache local encore vide ne
  // veut rien dire tant que le rapatriement serveur n'est pas terminé.
  bool _chargementInitial = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(financesGroupeRepositoryProvider).chargerDepuisServeur(widget.groupeId);
      if (mounted) setState(() => _chargementInitial = false);
    });
  }

  Future<void> _creerNouvelleCommande() async {
    final valeurs = await demanderMontantsCommande(context: context, titre: 'Commande du groupe');
    if (valeurs == null) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    await executerAvecErreurAffichee(
      context,
      () => ref.read(financesGroupeRepositoryProvider).creerNouvelleCommande(
            atelierId: utilisateur!.atelierId,
            groupeId: widget.groupeId,
            montantTotal: valeurs.montant,
            avance: valeurs.avance,
          ),
    );
    ref.invalidate(commandesDuGroupeProvider(widget.groupeId));
  }

  /// Corrige le montant total, l'avance et le paiement reçu de la commande
  /// en cours (erreur de saisie) — même principe que
  /// SectionFinancesClient._modifierCommandeCourante.
  Future<void> _modifierCommandeCourante(
    CommandeGroupe courante,
    double sommePaiementsActuelle,
  ) async {
    final montantCtrl = TextEditingController(text: courante.montantTotal.toStringAsFixed(0));
    final avanceCtrl = TextEditingController(text: courante.avance.toStringAsFixed(0));
    final paiementCtrl = TextEditingController(text: sommePaiementsActuelle.toStringAsFixed(0));

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Modifier Montant/Avance/Paiement',
          style: TextStyle(color: _bleuSeda, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montantCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Montant total convenu (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),
            TextField(
              controller: avanceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Avance payée (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),
            TextField(
              controller: paiementCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Paiement reçu (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
              ),
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
    final paiement = double.tryParse(paiementCtrl.text.replaceAll(',', '.')) ?? 0;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    await executerAvecErreurAffichee(context, () async {
      final repo = ref.read(financesGroupeRepositoryProvider);
      await repo.modifierCommande(
        atelierId: utilisateur!.atelierId,
        commande: courante,
        montantTotal: montant,
        avance: avance,
      );
      if (paiement != sommePaiementsActuelle) {
        await repo.definirPaiementTotal(
          atelierId: utilisateur.atelierId,
          commande: courante,
          nouveauTotal: paiement,
        );
      }
    });
    ref.invalidate(commandesDuGroupeProvider(widget.groupeId));
  }

  Future<void> _ajouterPaiement(String commandeId) async {
    final montantCtrl = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un paiement', style: TextStyle(color: _bleuSeda)),
        content: TextField(
          controller: montantCtrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Montant reçu (FCFA)',
            labelStyle: TextStyle(fontSize: 13),
          ),
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
      () => ref.read(financesGroupeRepositoryProvider).ajouterPaiement(
            atelierId: utilisateur!.atelierId,
            commandeId: commandeId,
            montant: montant,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commandesAsync = ref.watch(commandesDuGroupeProvider(widget.groupeId));

    return commandesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
      data: (commandes) {
        if (commandes.isEmpty) {
          if (_chargementInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: OutlinedButton.icon(
              onPressed: _creerNouvelleCommande,
              style: OutlinedButton.styleFrom(
                foregroundColor: _bleuSeda,
                side: const BorderSide(color: _bleuSeda),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Créer une commande pour ce groupe'),
            ),
          );
        }

        final courante = commandes.first;
        final paiements = ref.watch(paiementsDeLaCommandeGroupeProvider(courante.id));
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
            _LigneMontant('Montant total convenu', courante.montantTotal),
            // Avance + tous les paiements ajoutés depuis — augmente donc
            // visiblement à chaque nouveau paiement, plutôt que de rester
            // figée sur le montant initial.
            _LigneMontant('Avance payée', courante.avance + sommePaiements),
            _LigneMontant('Reste à payer', reste > 0 ? reste : 0, accent: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _ajouterPaiement(courante.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orangeSeda,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Ajouter un paiement'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _modifierCommandeCourante(courante, sommePaiements),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _bleuSeda,
                      side: const BorderSide(color: _bleuSeda),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Modifier Montant/Avance/Paiement', textAlign: TextAlign.center),
                  ),
                ),
              ],
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
        ? const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _orangeSeda)
        : const TextStyle(fontSize: 14, color: Color(0xFF231A14));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
