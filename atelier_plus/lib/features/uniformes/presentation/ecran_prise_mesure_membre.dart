import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_providers.dart';
import '../../mesures/providers/gabarits_providers.dart';
import '../providers/uniformes_providers.dart';

/// Formulaire dynamique de prise de mesure pour un membre de groupe —
/// identique à EcranPriseMesure, mais écrit dans `mesures_uniforme`.
class EcranPriseMesureMembre extends ConsumerStatefulWidget {
  const EcranPriseMesureMembre({
    super.key,
    required this.membreId,
    required this.typeTenueId,
    required this.nomMembre,
  });

  final String membreId;
  final String typeTenueId;
  final String nomMembre;

  @override
  ConsumerState<EcranPriseMesureMembre> createState() => _EcranPriseMesureMembreState();
}

class _EcranPriseMesureMembreState extends ConsumerState<EcranPriseMesureMembre> {
  final Map<String, TextEditingController> _controleurs = {};
  DateTime? _dateDerniereMesure;
  bool _chargement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _preremplir();
  }

  @override
  void dispose() {
    for (final controleur in _controleurs.values) {
      controleur.dispose();
    }
    super.dispose();
  }

  TextEditingController _controleurPour(String champId) {
    return _controleurs.putIfAbsent(champId, () => TextEditingController());
  }

  Future<void> _preremplir() async {
    final repo = ref.read(mesuresUniformeRepositoryProvider);
    // Même raison que EcranPriseMesure._preremplir : sans ce rapatriement,
    // une mesure prise sur un autre appareil resterait invisible ici.
    await repo.chargerDepuisServeur(widget.membreId);
    final valeurs = await repo.dernieresValeurs(widget.membreId, widget.typeTenueId);
    final date = await repo.dateDerniereMesure(widget.membreId, widget.typeTenueId);

    if (mounted) {
      setState(() {
        _dateDerniereMesure = date;
        valeurs?.forEach((champId, valeur) => _controleurPour(champId).text = valeur);
      });
    }
  }

  Future<void> _enregistrer() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final valeurs = <String, String>{};
      for (final entree in _controleurs.entries) {
        final texte = entree.value.text.trim();
        if (texte.isNotEmpty) valeurs[entree.key] = texte;
      }

      final utilisateur = await utilisateurCourantRequis(ref);
      await ref.read(mesuresUniformeRepositoryProvider).enregistrerNouvellePrise(
            atelierId: utilisateur.atelierId,
            membreId: widget.membreId,
            typeTenueId: widget.typeTenueId,
            valeurs: valeurs,
            prisePar: utilisateur.id,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesure enregistrée.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final champs = ref.watch(champsActifsProvider(widget.typeTenueId));

    return Scaffold(
      appBar: AppBar(title: Text('Mesures — ${widget.nomMembre}')),
      body: champs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (liste) {
          if (liste.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Ce type de tenue n\'a aucun champ de mesure actif.'),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_dateDerniereMesure != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Dernière mesure le ${Formatters.dateCourte(_dateDerniereMesure!)} '
                      '(valeurs pré-remplies)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                for (final champ in liste)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _controleurPour(champ.id),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: '${champ.nom} (${champ.unite})'),
                    ),
                  ),
                if (_erreur != null) ...[
                  Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(
                  onPressed: _chargement ? null : _enregistrer,
                  child: _chargement
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Enregistrer la mesure'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
