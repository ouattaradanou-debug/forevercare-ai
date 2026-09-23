import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/profil.dart';
import '../../core/database/app_database.dart';
import '../../core/produits/produit.dart';
import '../../core/produits/produits_providers.dart';
import '../../core/utils/fcfa_formatter.dart';
import 'produit_form_screen.dart';

/// Détail d'un produit : informations de vente pour tous, stock,
/// modification du produit et prix d'achat pour Propriétaire/Propriétaire-
/// Gérant/Gérant (`estResponsable`) — jamais pour l'Agent de vente.
class ProduitDetailScreen extends ConsumerStatefulWidget {
  const ProduitDetailScreen(
      {super.key, required this.produit, required this.profil});

  final Produit produit;
  final Profil profil;

  @override
  ConsumerState<ProduitDetailScreen> createState() =>
      _ProduitDetailScreenState();
}

class _ProduitDetailScreenState extends ConsumerState<ProduitDetailScreen> {
  int? _prixAchat;
  bool _chargement = true;
  Stream<LocalStockData?>? _stockStream;

  @override
  void initState() {
    super.initState();
    if (widget.profil.role.estResponsable) {
      _stockStream = ref.read(stockDaoProvider).observerStock(widget.produit.id);
    }
    _charger();
  }

  Future<void> _charger() async {
    try {
      if (widget.profil.role.estResponsable) {
        final stockDao = ref.read(stockDaoProvider);
        final dejaEnCache = await stockDao.stockActuel(widget.produit.id);
        if (dejaEnCache == null) {
          final stockServeur = await ref
              .read(produitsServiceProvider)
              .stockServeur(widget.produit.id);
          await stockDao.initialiserSiAbsent(
            produitId: widget.produit.id,
            caveId: widget.produit.caveId,
            quantiteCartons: stockServeur.cartons,
            quantiteBouteilles: stockServeur.bouteilles,
          );
        }
        _prixAchat = await ref
            .read(produitsServiceProvider)
            .obtenirPrixAchat(widget.produit.id);
      }
    } catch (_) {
      // Pas de réseau : on affiche quand même le reste de l'écran (les
      // prix de vente/nom viennent déjà de la liste, sans requête
      // supplémentaire) — seuls le stock/prix d'achat resteront vides.
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  /// Libellé pluriel du type d'emballage de ce produit (ex : "cartons",
  /// "casiers"), utilisé pour tous les libellés liés au stock.
  String get _libelleEmballagePluriel =>
      '${widget.produit.typeEmballage.libelle.toLowerCase()}s';

  Future<void> _ajusterStock() async {
    final deltaCartonsCtrl = TextEditingController(text: '0');
    final deltaBouteillesCtrl = TextEditingController(text: '0');
    final motifCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuster le stock'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Entrez une variation (positive pour une entrée, négative '
                'pour une sortie). Ex : -2 pour retirer 2 $_libelleEmballagePluriel.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deltaCartonsCtrl,
                decoration: InputDecoration(
                    labelText: 'Variation ($_libelleEmballagePluriel)'),
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                validator: (v) =>
                    int.tryParse(v?.trim() ?? '') == null ? 'Nombre invalide' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deltaBouteillesCtrl,
                decoration: const InputDecoration(
                    labelText: 'Variation (bouteilles)'),
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                validator: (v) =>
                    int.tryParse(v?.trim() ?? '') == null ? 'Nombre invalide' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: motifCtrl,
                decoration: const InputDecoration(
                    labelText: 'Motif (ex : réception, casse, inventaire)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref.read(stockDaoProvider).ajusterStock(
                    produitId: widget.produit.id,
                    caveId: widget.produit.caveId,
                    deltaCartons: int.parse(deltaCartonsCtrl.text.trim()),
                    deltaBouteilles:
                        int.parse(deltaBouteillesCtrl.text.trim()),
                    motif: motifCtrl.text.trim(),
                    creePar: widget.profil.id,
                  );
              // Tentative de synchronisation immédiate si le réseau est
              // déjà disponible (sans quoi le mouvement resterait en file
              // jusqu'au prochain retour de connexion détecté par
              // `app.dart` — ici on ne veut pas attendre une coupure puis
              // une reconnexion pour synchroniser un appareil qui n'a en
              // fait jamais perdu le réseau). Échec silencieux accepté :
              // le mouvement reste dans la file, rien n'est perdu.
              unawaited(ref.read(syncServiceProvider).synchroniser());
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;
    return Scaffold(
      appBar: AppBar(title: Text(produit.nom)),
      body: SafeArea(
        child: _chargement
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _ligne('Prix de vente au détail',
                      formaterFcfa(produit.prixVenteDetail)),
                  _ligne('Prix de vente en gros',
                      formaterFcfa(produit.prixVenteGros)),
                  _ligne('Bouteilles par ${produit.typeEmballage.libelle.toLowerCase()}',
                      '${produit.bouteillesParEmballage}'),
                  if (!produit.actif) _ligne('Statut', 'Inactif'),
                  if (widget.profil.role.estResponsable) ...[
                    const Divider(height: 32),
                    StreamBuilder<LocalStockData?>(
                      stream: _stockStream,
                      builder: (context, snapshot) {
                        final stock = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ligne('Stock ($_libelleEmballagePluriel)',
                                '${stock?.quantiteCartons ?? 0}'),
                            _ligne('Stock (bouteilles)',
                                '${stock?.quantiteBouteilles ?? 0}'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _ajusterStock,
                      child: const Text('Ajuster le stock'),
                    ),
                    const Divider(height: 32),
                    _ligne('Prix d\'achat',
                        _prixAchat != null ? formaterFcfa(_prixAchat!) : '—'),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProduitFormScreen(
                            produit: produit,
                            caveId: produit.caveId,
                          ),
                        ),
                      ),
                      child: const Text('Modifier le produit'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _ligne(String libelle, String valeur) {
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
