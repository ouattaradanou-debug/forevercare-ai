import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/profil.dart';
import '../../core/database/daos/ventes_dao.dart';
import '../../core/produits/produit.dart';
import '../../core/produits/produits_providers.dart';
import '../../core/utils/fcfa_formatter.dart';
import '../../core/ventes/ventes_providers.dart';

class _LigneCart {
  const _LigneCart({
    required this.produit,
    required this.quantiteCartons,
    required this.quantiteBouteilles,
  });

  final Produit produit;
  final int quantiteCartons;
  final int quantiteBouteilles;

  int get sousTotal =>
      quantiteCartons * produit.prixVenteGros +
      quantiteBouteilles * produit.prixVenteDetail;
}

/// "Vendre" (point 5, Phase 3 du cahier des charges) : constitue un panier
/// puis enregistre la vente. Seule action offline-first exigée par cette
/// phase — la création de la commande passe par [VentesDao] (file de
/// synchronisation locale), jamais par un appel réseau direct, pour
/// fonctionner même sans connexion (agent en tournée). Le choix d'un
/// client reste facultatif (vente comptoir anonyme) : le sélectionner
/// suppose le réseau, mais ne pas en choisir n'en empêche jamais.
class NouvelleCommandeScreen extends ConsumerStatefulWidget {
  const NouvelleCommandeScreen({super.key, required this.profil});

  final Profil profil;

  @override
  ConsumerState<NouvelleCommandeScreen> createState() =>
      _NouvelleCommandeScreenState();
}

class _NouvelleCommandeScreenState
    extends ConsumerState<NouvelleCommandeScreen> {
  String? _clientId;
  final List<_LigneCart> _panier = [];
  bool _enCours = false;

  int get _total => _panier.fold(0, (somme, l) => somme + l.sousTotal);

  Future<void> _ajouterClient() async {
    final nomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau client'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
                autofocus: true,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telCtrl,
                decoration: const InputDecoration(
                    labelText: 'Téléphone (facultatif)'),
                keyboardType: TextInputType.phone,
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    try {
      final client = await ref.read(ventesServiceProvider).creerClient(
            caveId: widget.profil.caveId,
            nom: nomCtrl.text.trim(),
            telephone: telCtrl.text.trim(),
          );
      ref.invalidate(clientsProvider);
      setState(() => _clientId = client.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _ajouterProduit() async {
    final produits = ref.read(produitsProvider).valueOrNull
            ?.where((p) => p.actif)
            .toList() ??
        [];
    if (produits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun produit actif au catalogue.')));
      return;
    }

    Produit produitChoisi = produits.first;
    final cartonsCtrl = TextEditingController(text: '0');
    final bouteillesCtrl = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    final ligne = await showDialog<_LigneCart>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter un produit'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Produit>(
                    value: produitChoisi,
                    decoration: const InputDecoration(labelText: 'Produit'),
                    items: [
                      for (final p in produits)
                        DropdownMenuItem(value: p, child: Text(p.nom)),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => produitChoisi = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cartonsCtrl,
                    decoration: InputDecoration(
                        labelText:
                            'Quantité (${produitChoisi.typeEmballage.libelle.toLowerCase()}s) — ${formaterFcfa(produitChoisi.prixVenteGros)} pièce'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                    validator: (v) => int.tryParse(v?.trim() ?? '') == null
                        ? 'Nombre invalide'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bouteillesCtrl,
                    decoration: InputDecoration(
                        labelText:
                            'Quantité (bouteilles) — ${formaterFcfa(produitChoisi.prixVenteDetail)} pièce'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                    validator: (v) => int.tryParse(v?.trim() ?? '') == null
                        ? 'Nombre invalide'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final cartons = int.parse(cartonsCtrl.text.trim());
                final bouteilles = int.parse(bouteillesCtrl.text.trim());
                if (cartons <= 0 && bouteilles <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Entrez au moins une quantité.')));
                  return;
                }
                Navigator.of(context).pop(_LigneCart(
                  produit: produitChoisi,
                  quantiteCartons: cartons,
                  quantiteBouteilles: bouteilles,
                ));
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (ligne != null) {
      setState(() => _panier.add(ligne));
    }
  }

  Future<void> _enregistrerVente() async {
    setState(() => _enCours = true);
    try {
      await ref.read(ventesDaoProvider).creerCommande(
            caveId: widget.profil.caveId,
            clientId: _clientId,
            creePar: widget.profil.id,
            lignes: [
              for (final l in _panier)
                LigneAVendre(
                  produitId: l.produit.id,
                  quantiteCartons: l.quantiteCartons,
                  quantiteBouteilles: l.quantiteBouteilles,
                  prixGrosUnitaire: l.produit.prixVenteGros,
                  prixDetailUnitaire: l.produit.prixVenteDetail,
                ),
            ],
          );
      unawaited(ref.read(syncServiceProvider).synchroniser());
      ref.invalidate(commandesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vente enregistrée.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vendre')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: clientsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) =>
                        Text('Clients indisponibles (hors ligne ?) : $e'),
                    data: (clients) => DropdownButtonFormField<String>(
                      value: _clientId,
                      decoration: const InputDecoration(
                          labelText: 'Client (facultatif)'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Vente comptoir')),
                        for (final c in clients)
                          DropdownMenuItem(value: c.id, child: Text(c.nom)),
                      ],
                      onChanged: (v) => setState(() => _clientId = v),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1),
                  tooltip: 'Nouveau client',
                  onPressed: _ajouterClient,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Panier', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_panier.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Aucun produit ajouté.'),
              )
            else
              for (var i = 0; i < _panier.length; i++)
                Card(
                  child: ListTile(
                    title: Text(_panier[i].produit.nom),
                    subtitle: Text(
                        '${_panier[i].quantiteCartons} ${_panier[i].produit.typeEmballage.libelle.toLowerCase()}(s)'
                        '  ·  ${_panier[i].quantiteBouteilles} bouteille(s)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formaterFcfa(_panier[i].sousTotal)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _panier.removeAt(i)),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _ajouterProduit,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un produit'),
            ),
            const SizedBox(height: 24),
            Text('Total : ${formaterFcfa(_total)}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_panier.isEmpty || _enCours)
                  ? null
                  : _enregistrerVente,
              child: _enCours
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enregistrer la vente'),
            ),
          ],
        ),
      ),
    );
  }
}
