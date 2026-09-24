import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/profil.dart';
import '../../core/utils/fcfa_formatter.dart';
import '../../core/ventes/commande.dart';
import '../../core/ventes/commande_ligne.dart';
import '../../core/ventes/statut_commande.dart';
import '../../core/ventes/ventes_providers.dart';

/// Détail d'une commande : ses lignes, son total, et pour les responsables
/// un bouton "Annuler la commande" tant qu'elle est encore en attente (la
/// validation, qui décrémente le stock, est réservée à la Phase 4 — voir
/// le commentaire de `commandes_update` dans la migration 0012).
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
  List<CommandeLigne>? _lignes;
  String? _erreurChargement;
  bool _enCoursAnnulation = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final lignes = await ref
          .read(ventesServiceProvider)
          .listerLignes(widget.commande.id);
      if (mounted) setState(() => _lignes = lignes);
    } catch (e) {
      if (mounted) setState(() => _erreurChargement = '$e');
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
      await ref
          .read(ventesServiceProvider)
          .annulerCommande(widget.commande.id);
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
    final commande = widget.commande;
    final peutAnnuler = widget.profil.role.estResponsable &&
        commande.statut == StatutCommande.enAttente;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la commande')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ligne('Statut', commande.statut.libelle),
            _ligne('Total', formaterFcfa(commande.total)),
            const Divider(height: 32),
            Text('Produits', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_erreurChargement != null)
              Text('Impossible de charger les lignes : $_erreurChargement')
            else if (_lignes == null)
              const Center(child: CircularProgressIndicator())
            else
              for (final ligne in _lignes!)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            '${ligne.produitNom} — ${ligne.quantiteCartons} carton(s), '
                            '${ligne.quantiteBouteilles} bouteille(s)'),
                      ),
                      Text(formaterFcfa(ligne.sousTotal)),
                    ],
                  ),
                ),
            if (peutAnnuler) ...[
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
