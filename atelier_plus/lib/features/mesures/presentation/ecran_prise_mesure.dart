import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/gabarits_providers.dart';
import '../providers/mesures_providers.dart';

/// Formulaire dynamique de prise de mesure, généré à partir des champs
/// actifs du gabarit sélectionné. Pré-rempli avec les dernières valeurs
/// connues pour ce client et ce type de tenue ; l'enregistrement crée
/// toujours une nouvelle ligne historisée (jamais d'écrasement).
class EcranPriseMesure extends ConsumerStatefulWidget {
  const EcranPriseMesure({super.key, required this.clientId, required this.typeTenueId});

  final String clientId;
  final String typeTenueId;

  @override
  ConsumerState<EcranPriseMesure> createState() => _EcranPriseMesureState();
}

class _EcranPriseMesureState extends ConsumerState<EcranPriseMesure> {
  final Map<String, TextEditingController> _controleurs = {};
  DateTime? _dateDerniereMesure;
  bool _chargement = false;
  bool _modifie = false;
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
    final repo = ref.read(mesuresRepositoryProvider);
    final valeurs = await repo.dernieresValeurs(widget.clientId, widget.typeTenueId);
    final date = await repo.dateDerniereMesure(widget.clientId, widget.typeTenueId);

    if (mounted) {
      setState(() {
        _dateDerniereMesure = date;
        valeurs?.forEach((champId, valeur) => _controleurPour(champId).text = valeur);
      });
    }
  }

  /// Enregistre la mesure si au moins un champ a été modifié depuis le
  /// préremplissage, puis quitte l'écran — y compris quand on revient en
  /// arrière sans avoir appuyé sur "Enregistrer la mesure" (voir
  /// `PopScope` dans `build`) : les modifications ne doivent jamais se
  /// perdre silencieusement. Ne crée pas de nouvelle ligne historisée si
  /// rien n'a changé (juste consulté puis quitté), pour ne pas polluer
  /// l'historique de doublons identiques.
  Future<void> _enregistrerEtQuitter() async {
    if (!_modifie) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

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
      await ref.read(mesuresRepositoryProvider).enregistrerNouvellePrise(
            atelierId: utilisateur.atelierId,
            clientId: widget.clientId,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _enregistrerEtQuitter();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Prise de mesure')),
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
                        onChanged: (_) => _modifie = true,
                      ),
                    ),
                  if (_erreur != null) ...[
                    Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed: _chargement ? null : _enregistrerEtQuitter,
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
      ),
    );
  }
}
