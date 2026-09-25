import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/profil.dart';
import '../../core/utils/fcfa_formatter.dart';
import '../../core/ventes/commande.dart';
import '../../core/ventes/commande_ligne.dart';
import '../../core/ventes/statut_commande.dart';
import '../../core/ventes/ventes_providers.dart';

/// Détail d'une commande : un tableau (boisson, quantité, prix unitaire,
/// total par produit), avec correction possible (modifier la quantité,
/// retirer un produit dont le client a renoncé) tant qu'elle est encore
/// en attente, par son créateur ou un responsable — mêmes règles que
/// côté serveur (`commande_lignes_update`/`_delete`, migration 0013). La
/// validation (Phase 4) reste hors de portée de cet écran.
class CommandeDetailScreen extends ConsumerStatefulWidget {
  const CommandeDetailScreen(
      {super.key, required this.commande, required this.profil});

  final Commande commande;
  final Profil profil;

  @override
  ConsumerState<CommandeDetailScreen> createState() =>
      _CommandeDetailScreenState();
}

class _CommandeDetailScreenState extends ConsumerState<CommandeDetailScreen> {
  late Commande _commande = widget.commande;
  List<CommandeLigne>? _lignes;
  String? _erreurChargement;
  bool _enCoursAnnulation = false;

  bool get _peutModifier =>
      _commande.statut == StatutCommande.enAttente &&
      (widget.profil.role.estResponsable ||
          _commande.createdBy == widget.profil.id);

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final lignes = await ref
          .read(ventesServiceProvider)
          .listerLignes(_commande.id);
      if (mounted) setState(() => _lignes = lignes);
    } catch (e) {
      if (mounted) setState(() => _erreurChargement = '$e');
    }
  }

  /// Relit la commande (total recalculé côté serveur) et ses lignes après
  /// une modification/suppression.
  Future<void> _rafraichir() async {
    try {
      final service = ref.read(ventesServiceProvider);
      final commande = await service.obtenirCommande(_commande.id);
      final lignes = await service.listerLignes(_commande.id);
      if (mounted) {
        setState(() {
          _commande = commande;
          _lignes = lignes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _modifierQuantite(CommandeLigne ligne) async {
    final parEmballage = ligne.quantiteCartons > 0;
    final quantiteActuelle =
        parEmballage ? ligne.quantiteCartons : ligne.quantiteBouteilles;
    final ctrl = TextEditingController(text: '$quantiteActuelle');
    final formKey = GlobalKey<FormState>();

    final nouvelleQuantite = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${ligne.produitNom}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(
                labelText: parEmballage ? 'Quantité (cartons)' : 'Quantité (bouteilles)'),
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = int.tryParse(v?.trim() ?? '');
              return (n == null || n < 1) ? 'Au moins 1' : null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(int.parse(ctrl.text.trim()));
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (nouvelleQuantite == null) return;

    try {
      await ref.read(ventesDaoProvider).modifierLigne(
            ligneId: ligne.id,
            commandeId: _commande.id,
            produitId: ligne.produitId,
            quantiteCartons: parEmballage ? nouvelleQuantite : 0,
            quantiteBouteilles: parEmballage ? 0 : nouvelleQuantite,
            prixGrosUnitaire: ligne.prixGrosUnitaire,
            prixDetailUnitaire: ligne.prixDetailUnitaire,
          );
      // Attendu (pas "unawaited" comme ailleurs) : cet écran a besoin de
      // relire l'état réellement synchronisé pour afficher le total à
      // jour, contrairement à la création d'une vente qui repart aussitôt
      // vers la liste.
      await ref.read(syncServiceProvider).synchroniser();
      ref.invalidate(commandesProvider);
      await _rafraichir();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _supprimerLigne(CommandeLigne ligne) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer ce produit ?'),
        content: Text('"${ligne.produitNom}" sera retiré de la commande.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    try {
      await ref.read(ventesDaoProvider).supprimerLigne(ligne.id);
      await ref.read(syncServiceProvider).synchroniser();
      ref.invalidate(commandesProvider);
      await _rafraichir();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _annuler() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler cette commande ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    setState(() => _enCoursAnnulation = true);
    try {
      await ref.read(ventesServiceProvider).annulerCommande(_commande.id);
      ref.invalidate(commandesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _enCoursAnnulation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la commande')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ligneInfo('Statut', _commande.statut.libelle),
            _ligneInfo('Total', formaterFcfa(_commande.total)),
            const Divider(height: 32),
            Text('Produits', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_erreurChargement != null)
              Text('Impossible de charger les lignes : $_erreurChargement')
            else if (_lignes == null)
              const Center(child: CircularProgressIndicator())
            else if (_lignes!.isEmpty)
              const Text('Aucun produit dans cette commande.')
            else
              _tableauLignes(_lignes!),
            if (_peutAnnuler) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _enCoursAnnulation ? null : _annuler,
                style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error),
                child: _enCoursAnnulation
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Annuler la commande'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _peutAnnuler =>
      widget.profil.role.estResponsable &&
      _commande.statut == StatutCommande.enAttente;

  Widget _tableauLignes(List<CommandeLigne> lignes) {
    final bordure = BorderSide(color: Theme.of(context).dividerColor);
    return Table(
      border: TableBorder(horizontalInside: bordure, verticalInside: bordure),
      columnWidths: {
        0: const FlexColumnWidth(2),
        1: const FlexColumnWidth(1),
        2: const FlexColumnWidth(1.2),
        3: const FlexColumnWidth(1.2),
        if (_peutModifier) 4: const FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          children: [
            _celluleEntete('Boisson'),
            _celluleEntete('Qté'),
            _celluleEntete('P.U.'),
            _celluleEntete('Total'),
            if (_peutModifier) _celluleEntete(''),
          ],
        ),
        for (final ligne in lignes)
          TableRow(
            children: [
              _cellule(Text(ligne.produitNom)),
              _cellule(Text(ligne.quantiteCartons > 0
                  ? '${ligne.quantiteCartons} cart.'
                  : '${ligne.quantiteBouteilles} bout.')),
              _cellule(Text(formaterMontantSansDevise(ligne.quantiteCartons > 0
                  ? ligne.prixGrosUnitaire
                  : ligne.prixDetailUnitaire))),
              _cellule(Text(formaterMontantSansDevise(ligne.sousTotal))),
              if (_peutModifier)
                _cellule(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Modifier la quantité',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _modifierQuantite(ligne),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Retirer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _supprimerLigne(ligne),
                    ),
                  ],
                )),
            ],
          ),
      ],
    );
  }

  Widget _cellule(Widget enfant) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: enfant,
    );
  }

  Widget _celluleEntete(String texte) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(texte,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _ligneInfo(String libelle, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle),
          Text(valeur, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
