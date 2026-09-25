import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/profil.dart';
import '../../core/cloture/cloture.dart';
import '../../core/cloture/cloture_providers.dart';
import '../../core/cloture/historique_correction.dart';
import '../../core/utils/fcfa_formatter.dart';

/// Détail d'une clôture : totaux figés au moment de la clôture (jamais
/// recalculés), et — pour le Propriétaire/Propriétaire-Gérant uniquement,
/// même un Gérant qui peut clôturer ne peut pas corriger — la possibilité
/// d'ajouter une correction exceptionnelle (voir `corriger_cloture`,
/// migration 0015 : la ligne `clotures` elle-même n'est jamais modifiée).
class ClotureDetailScreen extends ConsumerStatefulWidget {
  const ClotureDetailScreen(
      {super.key, required this.cloture, required this.profil});

  final Cloture cloture;
  final Profil profil;

  @override
  ConsumerState<ClotureDetailScreen> createState() =>
      _ClotureDetailScreenState();
}

class _ClotureDetailScreenState extends ConsumerState<ClotureDetailScreen> {
  List<HistoriqueCorrection>? _corrections;
  String? _erreur;
  bool _enCours = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final corrections = await ref
          .read(clotureServiceProvider)
          .listerCorrections(widget.cloture.id);
      if (mounted) setState(() => _corrections = corrections);
    } catch (e) {
      if (mounted) setState(() => _erreur = '$e');
    }
  }

  bool get _peutCorriger => widget.profil.role.estAdministrateur;

  int get _totalCorrections =>
      (_corrections ?? const []).fold(0, (s, c) => s + c.montantCorrection);

  Future<void> _ajouterCorrection() async {
    final montantCtrl = TextEditingController();
    final motifCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Corriger cette clôture'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Entrez un delta (positif pour ajouter, négatif pour '
                  'retirer) — la clôture d\'origine n\'est jamais modifiée.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: montantCtrl,
                  autofocus: true,
                  decoration:
                      const InputDecoration(labelText: 'Montant (FCFA)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  validator: (v) => int.tryParse(v?.trim() ?? '') == null
                      ? 'Nombre invalide'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: motifCtrl,
                  decoration: const InputDecoration(labelText: 'Motif'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Champ obligatoire'
                      : null,
                ),
              ],
            ),
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
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    setState(() => _enCours = true);
    try {
      await ref.read(clotureServiceProvider).corrigerCloture(
            clotureId: widget.cloture.id,
            montantCorrection: int.parse(montantCtrl.text.trim()),
            motif: motifCtrl.text.trim(),
          );
      await _charger();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  String _formaterDate(DateTime d) {
    String deuxChiffres(int n) => n.toString().padLeft(2, '0');
    return '${deuxChiffres(d.day)}/${deuxChiffres(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cloture = widget.cloture;
    return Scaffold(
      appBar: AppBar(
          title: Text('Clôture du ${_formaterDate(cloture.dateCloture)}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ligne('Nombre de commandes', '${cloture.nombreCommandes}'),
            _ligne('Total des ventes', formaterFcfa(cloture.totalVentes)),
            _ligne('Espèces encaissées', formaterFcfa(cloture.totalEspeces)),
            _ligne('Mobile Money encaissé',
                formaterFcfa(cloture.totalMobileMoney)),
            _ligne('Total encaissé', formaterFcfa(cloture.totalEncaisse)),
            const Divider(height: 32),
            Text('Corrections', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_erreur != null)
              Text('Impossible de charger les corrections : $_erreur')
            else if (_corrections == null)
              const Center(child: CircularProgressIndicator())
            else if (_corrections!.isEmpty)
              const Text('Aucune correction enregistrée.')
            else ...[
              for (final c in _corrections!)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(c.motif)),
                      Text(formaterFcfa(c.montantCorrection),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const Divider(),
              _ligne('Total corrigé',
                  formaterFcfa(cloture.totalVentes + _totalCorrections)),
            ],
            if (_peutCorriger) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _enCours ? null : _ajouterCorrection,
                child: _enCours
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Ajouter une correction'),
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
