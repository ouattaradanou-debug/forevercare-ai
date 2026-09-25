import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/profil.dart';
import '../../core/cloture/cloture_providers.dart';
import '../../core/utils/fcfa_formatter.dart';
import 'cloture_detail_screen.dart';

/// Clôture de caisse (point 5, Phase 5 du cahier des charges) : aperçu de
/// ce qui n'est pas encore clôturé (tout ce qui n'a pas encore été
/// rattaché à une clôture précédente, jamais une plage de dates fixe —
/// voir le commentaire de `cloturer_caisse`, migration 0015), bouton pour
/// clôturer, et historique des clôtures passées.
class ClotureScreen extends ConsumerStatefulWidget {
  const ClotureScreen({super.key, required this.profil});

  final Profil profil;

  @override
  ConsumerState<ClotureScreen> createState() => _ClotureScreenState();
}

class _ClotureScreenState extends ConsumerState<ClotureScreen> {
  bool _enCours = false;

  Future<void> _cloturer() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clôturer la caisse ?'),
        content: const Text(
            'Cette action fige les totaux du jour. Une clôture ne peut plus '
            'être modifiée ensuite (seulement corrigée exceptionnellement).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, clôturer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    setState(() => _enCours = true);
    try {
      await ref.read(clotureServiceProvider).cloturerCaisse(widget.profil.caveId);
      ref.invalidate(clotureApercuProvider);
      ref.invalidate(clotureHistoriqueProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Caisse clôturée.')));
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

  String _formaterDate(DateTime d) {
    String deuxChiffres(int n) => n.toString().padLeft(2, '0');
    return '${deuxChiffres(d.day)}/${deuxChiffres(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final apercuAsync = ref.watch(clotureApercuProvider);
    final historiqueAsync = ref.watch(clotureHistoriqueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clôture de caisse')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Pas encore clôturé',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            apercuAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Indisponible (hors ligne ?) : $e'),
              data: (apercu) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ligne('Commandes validées', '${apercu.nombreCommandes}'),
                      _ligne('Total des ventes',
                          formaterFcfa(apercu.totalVentes)),
                      _ligne('Espèces encaissées',
                          formaterFcfa(apercu.totalEspeces)),
                      _ligne('Mobile Money encaissé',
                          formaterFcfa(apercu.totalMobileMoney)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _enCours ? null : _cloturer,
                        child: _enCours
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Clôturer la caisse'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 32),
            Text('Historique', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            historiqueAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text('Impossible de charger l\'historique : $e'),
              data: (clotures) => clotures.isEmpty
                  ? const Text('Aucune clôture pour le moment.')
                  : Column(
                      children: [
                        for (final cloture in clotures)
                          Card(
                            child: ListTile(
                              title: Text(_formaterDate(cloture.dateCloture)),
                              subtitle: Text(
                                  '${cloture.nombreCommandes} commande(s) — '
                                  '${formaterFcfa(cloture.totalVentes)}'),
                              trailing: Text(
                                  formaterFcfa(cloture.totalEncaisse)),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ClotureDetailScreen(
                                      cloture: cloture, profil: widget.profil),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ligne(String libelle, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
