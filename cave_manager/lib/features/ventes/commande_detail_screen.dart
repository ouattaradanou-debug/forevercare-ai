import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/profil.dart';
import '../../core/utils/fcfa_formatter.dart';
import '../../core/utils/paiement_calculator.dart';
import '../../core/ventes/commande.dart';
import '../../core/ventes/commande_ligne.dart';
import '../../core/ventes/statut_commande.dart';
import '../../core/ventes/ventes_providers.dart';

/// Détail d'une commande : un tableau (boisson, quantité, prix unitaire,
/// total par produit), avec correction possible (modifier la quantité,
/// retirer un produit dont le client a renoncé) tant qu'elle est encore
/// en attente, par son créateur ou un responsable — mêmes règles que
/// côté serveur (`commande_lignes_update`/`_delete`, migration 0013).
/// Contrôle/validation/encaissement (Phase 4) : un responsable peut
/// valider une commande en attente (décrémente le stock automatiquement,
/// côté serveur) et enregistrer un ou plusieurs encaissements (espèces/
/// Mobile Money, paiement partiel possible).
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
  bool _enCoursValidation = false;
  bool _enCoursEncaissement = false;

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

  Future<void> _valider() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valider cette commande ?'),
        content: const Text(
            'Le stock des produits vendus sera décrémenté automatiquement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, valider'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    setState(() => _enCoursValidation = true);
    try {
      await ref.read(ventesDaoProvider).validerCommande(_commande.id);
      await ref.read(syncServiceProvider).synchroniser();
      ref.invalidate(commandesProvider);
      await _rafraichir();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _enCoursValidation = false);
    }
  }

  ResultatPaiement get _paiement => calculerResteAPayer(
        totalACharger: _commande.total,
        montantEspeces: _commande.montantEncaisseEspeces,
        montantMobileMoney: _commande.montantEncaisseMobile,
      );

  Future<void> _ouvrirDialogueEncaissement() async {
    final especesCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final resteActuel = _paiement.resteAPayer;

    int lireMontant(TextEditingController ctrl) =>
        int.tryParse(ctrl.text.trim()) ?? 0;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final saisiEspeces = lireMontant(especesCtrl);
          final saisiMobile = lireMontant(mobileCtrl);
          final apercu = calculerResteAPayer(
            totalACharger: resteActuel,
            montantEspeces: saisiEspeces,
            montantMobileMoney: saisiMobile,
          );
          return AlertDialog(
            title: const Text('Enregistrer un encaissement'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Reste à payer avant : ${formaterFcfa(resteActuel)}'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: especesCtrl,
                    autofocus: true,
                    decoration:
                        const InputDecoration(labelText: 'Espèces (FCFA)'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mobileCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Mobile Money (FCFA)'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    apercu.estSolde
                        ? 'Soldé après cet encaissement.'
                        : 'Reste à payer après : ${formaterFcfa(apercu.resteAPayer)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: (saisiEspeces + saisiMobile) > 0
                    ? () => Navigator.of(context).pop(true)
                    : null,
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
    );
    if (confirme != true) return;

    setState(() => _enCoursEncaissement = true);
    try {
      await ref.read(ventesDaoProvider).enregistrerEncaissement(
            caveId: _commande.caveId,
            commandeId: _commande.id,
            creePar: widget.profil.id,
            montantEspeces: lireMontant(especesCtrl),
            montantMobileMoney: lireMontant(mobileCtrl),
          );
      await ref.read(syncServiceProvider).synchroniser();
      ref.invalidate(commandesProvider);
      await _rafraichir();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _enCoursEncaissement = false);
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
            if (_peutValider) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _enCoursValidation ? null : _valider,
                child: _enCoursValidation
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Valider la commande'),
              ),
            ],
            if (_peutAnnuler) ...[
              const SizedBox(height: 12),
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
            if (_peutEncaisser) ...[
              const Divider(height: 32),
              Text('Encaissement',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _ligneInfo('Total', formaterFcfa(_commande.total)),
              _ligneInfo('Encaissé', formaterFcfa(_commande.montantEncaisse)),
              _ligneInfo('Reste à payer', formaterFcfa(_paiement.resteAPayer)),
              const SizedBox(height: 12),
              if (_paiement.estSolde)
                const Chip(label: Text('Soldé'))
              else
                OutlinedButton(
                  onPressed:
                      _enCoursEncaissement ? null : _ouvrirDialogueEncaissement,
                  child: _enCoursEncaissement
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enregistrer un encaissement'),
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

  bool get _peutValider =>
      widget.profil.role.estResponsable &&
      _commande.statut == StatutCommande.enAttente;

  /// Un encaissement reste possible tant que la commande n'est pas annulée
  /// (un dépôt avant validation est autorisé — voir migration 0014).
  bool get _peutEncaisser =>
      widget.profil.role.estResponsable &&
      _commande.statut != StatutCommande.annulee;

  Widget _tableauLignes(List<CommandeLigne> lignes) {
    final bordure = BorderSide(color: Theme.of(context).dividerColor);
    return Table(
      border: TableBorder(horizontalInside: bordure, verticalInside: bordure),
      columnWidths: {
        0: const FlexColumnWidth(2.2),
        1: const FlexColumnWidth(0.8),
        2: const FlexColumnWidth(1.3),
        3: const FlexColumnWidth(1.3),
        if (_peutModifier) 4: const FlexColumnWidth(0.6),
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
              _celluleChiffre(ligne.quantiteCartons > 0
                  ? '${ligne.quantiteCartons}'
                  : '${ligne.quantiteBouteilles}'),
              _celluleChiffre(formaterMontantSansDevise(
                  ligne.quantiteCartons > 0
                      ? ligne.prixGrosUnitaire
                      : ligne.prixDetailUnitaire)),
              _celluleChiffre(formaterMontantSansDevise(ligne.sousTotal)),
              if (_peutModifier)
                _cellule(PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 20),
                  tooltip: 'Actions',
                  onSelected: (choix) {
                    if (choix == 'modifier') {
                      _modifierQuantite(ligne);
                    } else if (choix == 'retirer') {
                      _supprimerLigne(ligne);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'modifier',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Modifier la quantité'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'retirer',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Retirer'),
                      ),
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

  /// Comme [_cellule], mais garantit que le chiffre tient sur une seule
  /// ligne (rétrécit légèrement la police plutôt que de couper le nombre
  /// en deux lignes si la colonne est trop étroite).
  Widget _celluleChiffre(String texte) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(texte, maxLines: 1, softWrap: false),
      ),
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
