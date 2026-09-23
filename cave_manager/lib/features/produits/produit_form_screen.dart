import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/produits/produit.dart';
import '../../core/produits/produits_providers.dart';

/// Création ou modification d'un produit (point 5 du cahier des charges).
/// Accessible à Propriétaire/Propriétaire-Gérant/Gérant (`estResponsable`)
/// — jamais à l'Agent de vente. Un seul bouton principal : "Enregistrer".
class ProduitFormScreen extends ConsumerStatefulWidget {
  const ProduitFormScreen({super.key, this.produit, required this.caveId});

  /// `null` pour une création ; renseigné pour une modification.
  final Produit? produit;
  final String caveId;

  @override
  ConsumerState<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends ConsumerState<ProduitFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nomCtrl =
      TextEditingController(text: widget.produit?.nom ?? '');
  late final _prixDetailCtrl = TextEditingController(
      text: widget.produit?.prixVenteDetail.toString() ?? '');
  late final _prixGrosCtrl = TextEditingController(
      text: widget.produit?.prixVenteGros.toString() ?? '');
  late final _bouteillesParCartonCtrl = TextEditingController(
      text: widget.produit?.bouteillesParCarton.toString() ?? '1');
  final _prixAchatCtrl = TextEditingController();

  bool _actif = true;
  bool _chargement = false;
  bool _enCours = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _actif = widget.produit?.actif ?? true;
    if (widget.produit != null) _chargerPrixAchat();
  }

  Future<void> _chargerPrixAchat() async {
    setState(() => _chargement = true);
    try {
      final prixAchat = await ref
          .read(produitsServiceProvider)
          .obtenirPrixAchat(widget.produit!.id);
      if (prixAchat != null) _prixAchatCtrl.text = prixAchat.toString();
    } catch (_) {
      // Pas de réseau ou rôle sans accès (ne devrait pas arriver ici, cet
      // écran étant déjà réservé à estResponsable) : champ laissé vide
      // plutôt que de bloquer l'affichage du reste du formulaire.
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prixDetailCtrl.dispose();
    _prixGrosCtrl.dispose();
    _bouteillesParCartonCtrl.dispose();
    _prixAchatCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      final service = ref.read(produitsServiceProvider);
      final nom = _nomCtrl.text.trim();
      final prixDetail = int.parse(_prixDetailCtrl.text.trim());
      final prixGros = int.parse(_prixGrosCtrl.text.trim());
      final bouteillesParCarton =
          int.parse(_bouteillesParCartonCtrl.text.trim());

      String produitId;
      if (widget.produit == null) {
        final cree = await service.creerProduit(
          caveId: widget.caveId,
          nom: nom,
          prixVenteDetail: prixDetail,
          prixVenteGros: prixGros,
          bouteillesParCarton: bouteillesParCarton,
        );
        produitId = cree.id;
      } else {
        produitId = widget.produit!.id;
        await service.modifierProduit(
          produitId: produitId,
          nom: nom,
          prixVenteDetail: prixDetail,
          prixVenteGros: prixGros,
          bouteillesParCarton: bouteillesParCarton,
          actif: _actif,
        );
      }

      if (_prixAchatCtrl.text.trim().isNotEmpty) {
        await service.modifierPrixAchat(
          produitId: produitId,
          caveId: widget.caveId,
          prixAchat: int.parse(_prixAchatCtrl.text.trim()),
        );
      }

      ref.invalidate(produitsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit enregistré.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _erreur = 'Impossible d\'enregistrer : $e');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produit == null
            ? 'Nouveau produit'
            : 'Modifier le produit'),
      ),
      body: SafeArea(
        child: _chargement
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nomCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Nom du produit'),
                        validator: _valideurObligatoire,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _prixDetailCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Prix de vente au détail (FCFA)'),
                        keyboardType: TextInputType.number,
                        validator: _valideurEntierPositif,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _prixGrosCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Prix de vente en gros (FCFA)'),
                        keyboardType: TextInputType.number,
                        validator: _valideurEntierPositif,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bouteillesParCartonCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Bouteilles par carton'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || int.tryParse(v.trim()) == null || int.parse(v.trim()) < 1)
                                ? 'Au moins 1'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _prixAchatCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Prix d\'achat (FCFA) — facultatif'),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v != null &&
                                v.trim().isNotEmpty &&
                                int.tryParse(v.trim()) == null)
                            ? 'Nombre invalide'
                            : null,
                      ),
                      if (widget.produit != null) ...[
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Produit actif'),
                          value: _actif,
                          onChanged: (v) => setState(() => _actif = v),
                        ),
                      ],
                      if (_erreur != null) ...[
                        const SizedBox(height: 12),
                        Text(_erreur!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _enCours ? null : _enregistrer,
                        child: _enCours
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String? _valideurObligatoire(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

  String? _valideurEntierPositif(String? v) {
    if (v == null || v.trim().isEmpty) return 'Champ obligatoire';
    final n = int.tryParse(v.trim());
    if (n == null || n < 0) return 'Nombre invalide';
    return null;
  }
}
