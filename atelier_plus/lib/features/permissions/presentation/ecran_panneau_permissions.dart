import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/permissions_apprenti.dart';
import '../providers/permissions_providers.dart';

/// Panneau de permissions d'un apprenti — accessible uniquement depuis
/// l'écran "Gérer mes apprentis" (donc déjà réservé au propriétaire par la
/// navigation ; la RLS `permissions_update` refuse de toute façon toute
/// écriture par quelqu'un d'autre que le propriétaire de l'atelier).
///
/// Note : `modifierGabarits` est bien présent ici comme interrupteur, mais
/// ne donne actuellement aucun droit d'écriture réel sur les gabarits côté
/// RLS (voir supabase/README.md) — cette permission est réservée à un usage
/// UI futur, ce qui est signalé explicitement à l'écran pour ne pas induire
/// le propriétaire en erreur.
class EcranPanneauPermissions extends ConsumerStatefulWidget {
  const EcranPanneauPermissions({
    super.key,
    required this.utilisateurId,
    required this.nomApprenti,
  });

  final String utilisateurId;
  final String nomApprenti;

  @override
  ConsumerState<EcranPanneauPermissions> createState() => _EcranPanneauPermissionsState();
}

class _EcranPanneauPermissionsState extends ConsumerState<EcranPanneauPermissions> {
  PermissionsApprenti? _permissions;
  bool _chargementInitial = true;
  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final permissions = await ref.read(permissionsRepositoryProvider).lire(widget.utilisateurId);
    if (mounted) {
      setState(() {
        _permissions = permissions;
        _chargementInitial = false;
      });
    }
  }

  Future<void> _mettreAJour(PermissionsApprenti nouvelles) async {
    setState(() {
      _permissions = nouvelles;
      _enregistrement = true;
    });
    try {
      await ref.read(permissionsRepositoryProvider).mettreAJour(nouvelles);
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permissions — ${widget.nomApprenti}'),
        actions: [
          if (_enregistrement)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
      ),
      body: _chargementInitial
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Aucune permission n\'est activée par défaut. Cet apprenti '
                    'n\'a jamais accès aux commandes ni aux paiements, quels que '
                    'soient les réglages ci-dessous.',
                  ),
                ),
                SwitchListTile(
                  title: const Text('Créer une fiche client'),
                  value: _permissions!.creerClient,
                  onChanged: (valeur) =>
                      _mettreAJour(_permissions!.copierAvec(creerClient: valeur)),
                ),
                SwitchListTile(
                  title: const Text('Modifier une fiche client'),
                  value: _permissions!.modifierClient,
                  onChanged: (valeur) =>
                      _mettreAJour(_permissions!.copierAvec(modifierClient: valeur)),
                ),
                SwitchListTile(
                  title: const Text('Prendre des mesures'),
                  value: _permissions!.prendreMesures,
                  onChanged: (valeur) =>
                      _mettreAJour(_permissions!.copierAvec(prendreMesures: valeur)),
                ),
                SwitchListTile(
                  title: const Text('Ajouter des photos'),
                  value: _permissions!.ajouterPhotos,
                  onChanged: (valeur) =>
                      _mettreAJour(_permissions!.copierAvec(ajouterPhotos: valeur)),
                ),
                SwitchListTile(
                  title: const Text('Modifier les gabarits de mesure'),
                  subtitle: const Text(
                    'Réservé à un usage futur : la gestion des types de tenue '
                    'reste pour le moment accessible au propriétaire uniquement.',
                  ),
                  value: _permissions!.modifierGabarits,
                  onChanged: (valeur) =>
                      _mettreAJour(_permissions!.copierAvec(modifierGabarits: valeur)),
                ),
                const Divider(height: 24),
                SwitchListTile(
                  title: const Text('Enregistrer des dépenses'),
                  value: _permissions!.enregistrerDepenses,
                  onChanged: (valeur) =>
                      _mettreAJour(_permissions!.copierAvec(enregistrerDepenses: valeur)),
                ),
                SwitchListTile(
                  title: const Text('Ventes'),
                  subtitle: const Text(
                    'Inclut le total des ventes du jour, visible sur cet écran.',
                  ),
                  value: _permissions!.ventes,
                  onChanged: (valeur) => _mettreAJour(_permissions!.copierAvec(ventes: valeur)),
                ),
                SwitchListTile(
                  title: const Text('Stock'),
                  subtitle: const Text(
                    'Inclut les prix unitaires des articles, visibles sur cet écran.',
                  ),
                  value: _permissions!.stock,
                  onChanged: (valeur) => _mettreAJour(_permissions!.copierAvec(stock: valeur)),
                ),
              ],
            ),
    );
  }
}
