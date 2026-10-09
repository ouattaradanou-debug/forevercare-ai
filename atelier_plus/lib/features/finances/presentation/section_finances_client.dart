import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../data/models/commande.dart';
import '../../../data/models/paiement.dart';
import '../../auth/providers/auth_providers.dart';
import '../../branding/providers/branding_providers.dart';
import '../../clients/providers/clients_providers.dart';
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
  bool _historiqueVisible = false;

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
        title: Text(titre, style: const TextStyle(color: _bleuSeda)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montantCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Montant total (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),
            TextField(
              controller: avanceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Avance reçue (FCFA)',
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

  /// Corrige le montant total, l'avance et le paiement reçu de la commande
  /// en cours (erreur de saisie) — ne crée jamais une nouvelle commande.
  /// Corriger le paiement reçu remplace l'historique détaillé des
  /// paiements individuels par une seule ligne correspondant au nouveau
  /// total (voir FinancesRepository.definirPaiementTotal).
  Future<void> _modifierCommandeCourante(Commande courante, double sommePaiementsActuelle) async {
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
                labelText: 'Montant total (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),
            TextField(
              controller: avanceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Avance reçue (FCFA)',
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
      final repo = ref.read(financesRepositoryProvider);
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
    ref.invalidate(commandesDuClientProvider(widget.clientId));
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
      () => ref.read(financesRepositoryProvider).ajouterPaiement(
            atelierId: utilisateur!.atelierId,
            commandeId: commandeId,
            montant: montant,
          ),
    );
  }

  /// Ouvre l'aperçu d'impression/partage du système avec la facture de la
  /// commande en cours (montants, QR code de vérification, signature du
  /// tailleur).
  Future<void> _imprimerFacture(Commande courante, List<Paiement> paiements) async {
    final atelier = await ref.read(atelierCourantProvider.future);
    final client = await ref.read(clientParIdProvider(widget.clientId).future);
    if (!mounted || atelier == null || client == null) return;

    await Printing.layoutPdf(
      onLayout: (_) => ref.read(pdfExportServiceProvider).genererFacturePdf(
            atelier: atelier,
            client: client,
            commande: courante,
            paiements: paiements,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _orangeSeda,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
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

        // Historique complet : tous les paiements de toutes les commandes du
        // client (actuelle et précédentes), numérotées par ordre
        // chronologique (la toute première commande du client est le n°1,
        // peu importe l'ordre d'affichage ci-dessus qui va du plus récent
        // au plus ancien) — voir EcranNouveauClient pour la même logique de
        // tri inversé.
        final commandesParAnciennete = [...commandes]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final numeroCommande = {
          for (final entree in commandesParAnciennete.asMap().entries)
            entree.value.id: entree.key + 1,
        };
        final historiqueComplet = <(int numero, Paiement paiement)>[];
        for (final c in commandes) {
          final paiementsCommande =
              c.id == courante.id ? paiements.valueOrNull : ref.watch(paiementsDeLaCommandeProvider(c.id)).valueOrNull;
          for (final p in paiementsCommande ?? const <Paiement>[]) {
            historiqueComplet.add((numeroCommande[c.id]!, p));
          }
        }
        historiqueComplet.sort((a, b) => b.$2.datePaiement.compareTo(a.$2.datePaiement));

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
                    // Avance + tous les paiements ajoutés depuis — augmente
                    // donc visiblement à chaque nouveau paiement, plutôt que
                    // de rester figée sur le montant initial.
                    _LigneMontant('Avance', courante.avance + sommePaiements),
                    _LigneMontant(
                      'Reste à payer',
                      reste > 0 ? reste : 0,
                      accent: true,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _modifierCommandeCourante(courante, sommePaiements),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _bleuSeda,
                        side: const BorderSide(color: _bleuSeda),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Modifier Montant/Avance/Paiement', textAlign: TextAlign.center),
                    ),
                    CheckboxListTile(
                      value: courante.tenueRetiree,
                      activeColor: _bleuSeda,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Tenue retirée',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orangeSeda,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Ajouter un paiement'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _creerNouvelleCommande,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _bleuSeda,
                      side: const BorderSide(color: _bleuSeda),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Nouvelle commande'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  _imprimerFacture(courante, paiements.valueOrNull ?? const []),
              style: OutlinedButton.styleFrom(
                foregroundColor: _bleuSeda,
                side: const BorderSide(color: _bleuSeda),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Imprimer la facture'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _historiqueVisible = !_historiqueVisible),
              style: OutlinedButton.styleFrom(
                foregroundColor: _bleuSeda,
                side: const BorderSide(color: _bleuSeda),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              icon: Icon(_historiqueVisible ? Icons.expand_less : Icons.expand_more),
              label: const Text('Historique des paiements'),
            ),
            if (_historiqueVisible) ...[
              const SizedBox(height: 12),
              _TableauHistoriquePaiements(lignes: historiqueComplet),
            ],
            if (precedentes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Commandes précédentes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _bleuSeda),
              ),
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
        ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _orangeSeda)
        : const TextStyle(fontSize: 15, color: Color(0xFF231A14));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

/// Tableau de l'historique des paiements, toutes commandes confondues (voir
/// le bouton "Historique des paiements") — numéro de commande (1 = la toute
/// première commande du client, par ordre chronologique), date et montant
/// de chaque paiement, du plus récent au plus ancien.
class _TableauHistoriquePaiements extends StatelessWidget {
  const _TableauHistoriquePaiements({required this.lignes});

  final List<(int numero, Paiement paiement)> lignes;

  @override
  Widget build(BuildContext context) {
    if (lignes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('Aucun paiement enregistré.', style: TextStyle(fontSize: 14)),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bleuSeda, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10)],
        ),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: _bleuSeda),
              children: const [
                _CelluleTableau('N° commande', entete: true),
                _CelluleTableau('Date', entete: true),
                _CelluleTableau('Montant', entete: true),
              ],
            ),
            for (final entree in lignes.asMap().entries)
              TableRow(
                decoration: BoxDecoration(
                  color: entree.key.isEven ? Colors.white : const Color(0xFFF6F3EE),
                ),
                children: [
                  _CelluleTableau('N°${entree.value.$1}'),
                  _CelluleTableau(Formatters.dateCourte(entree.value.$2.datePaiement)),
                  _CelluleTableau(Formatters.montant(entree.value.$2.montant)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CelluleTableau extends StatelessWidget {
  const _CelluleTableau(this.texte, {this.entete = false});

  final String texte;
  final bool entete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: entete ? FontWeight.bold : FontWeight.w600,
          color: entete ? Colors.white : const Color(0xFF231A14),
          fontSize: entete ? 13 : 14,
        ),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _bleuSeda),
                    ),
                    Text(
                      Formatters.montant(commande.montantTotal),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  reste > 0 ? 'Reste à payer : ${Formatters.montant(reste)}' : 'Soldée',
                  style: TextStyle(
                    fontSize: 13,
                    color: reste > 0 ? _orangeSeda : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (commande.tenueRetiree)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Tenue retirée',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6F6259)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
