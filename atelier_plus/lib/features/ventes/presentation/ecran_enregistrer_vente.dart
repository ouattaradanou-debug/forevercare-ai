import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/categorie_vente.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/ventes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Enregistre une vente directe (prêt-à-porter, tissu ou article de
/// couture) : les libellés et l'unité de quantité s'adaptent à [categorie],
/// pour un formulaire pertinent dans chaque cas sans dupliquer l'écran.
class EcranEnregistrerVente extends ConsumerStatefulWidget {
  const EcranEnregistrerVente({super.key, required this.categorie});

  final CategorieVente categorie;

  @override
  ConsumerState<EcranEnregistrerVente> createState() => _EcranEnregistrerVenteState();
}

class _EcranEnregistrerVenteState extends ConsumerState<EcranEnregistrerVente> {
  final _designationCtrl = TextEditingController();
  final _quantiteCtrl = TextEditingController(text: '1');
  final _prixUnitaireCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _chargement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _quantiteCtrl.addListener(() => setState(() {}));
    _prixUnitaireCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _designationCtrl.dispose();
    _quantiteCtrl.dispose();
    _prixUnitaireCtrl.dispose();
    super.dispose();
  }

  double get _quantite => double.tryParse(_quantiteCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _prixUnitaire => double.tryParse(_prixUnitaireCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _montantTotal => _quantite * _prixUnitaire;

  Future<void> _choisirDate() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (choisie != null) setState(() => _date = choisie);
  }

  Future<void> _enregistrer() async {
    final designation = _designationCtrl.text.trim();
    if (designation.isEmpty) {
      setState(() => _erreur = 'Entrez une désignation.');
      return;
    }
    if (_quantite <= 0) {
      setState(() => _erreur = 'Entrez une quantité valide.');
      return;
    }
    if (_prixUnitaire <= 0) {
      setState(() => _erreur = 'Entrez un prix unitaire valide.');
      return;
    }
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      await ref.read(ventesRepositoryProvider).enregistrerVente(
            atelierId: utilisateur!.atelierId,
            categorie: widget.categorie,
            designation: designation,
            quantite: _quantite,
            prixUnitaire: _prixUnitaire,
            date: _date,
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Vente enregistrée.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorie = widget.categorie;
    return Scaffold(
      appBar: AppBar(
        title: Text('Vente de ${categorie.libelle.toLowerCase()}'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _designationCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Désignation',
                  hintText: categorie.exempleDesignation,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantiteCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantité (${categorie.uniteLabel})',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _prixUnitaireCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Prix par ${categorie.uniteLabel} (FCFA)',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, color: _bleuSeda),
                title: const Text('Date de la vente'),
                subtitle: Text(Formatters.dateLongue(_date)),
                onTap: _choisirDate,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _bleuSeda,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Montant total', style: TextStyle(color: Colors.white)),
                    Text(
                      Formatters.montant(_montantTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: _orangeSeda),
                    ),
                  ],
                ),
              ),
              if (_erreur != null) ...[
                const SizedBox(height: 8),
                Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _chargement ? null : _enregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orangeSeda,
                  foregroundColor: Colors.white,
                ),
                child: _chargement
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer la vente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
