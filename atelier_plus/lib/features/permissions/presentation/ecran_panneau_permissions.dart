import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/permissions_apprenti.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/permissions_providers.dart';

/// Panneau de permissions d'un apprenti — accessible depuis l'écran "Gérer
/// mes apprentis", déjà réservé au propriétaire (la RLS `permissions_update`
/// refuse de toute façon toute écriture par quelqu'un d'autre que le
/// propriétaire de l'atelier). Vérifié ICI aussi en défense en profondeur,
/// comme les autres écrans réservés au propriétaire : cette route reste
/// atteignable directement (lien profond), pas seulement via la navigation.
///
/// Le compte d'un apprenti est désormais identique à celui du propriétaire
/// pour tout le travail quotidien (clients, mesures, photos, rendez-vous,
/// ventes, stock, dépenses) — ces droits ne sont donc plus réglables ici
/// individuellement. Seul "Modifier les gabarits" reste un interrupteur,
/// réservé à un usage futur : il ne donne actuellement aucun droit
/// d'écriture réel sur les gabarits côté RLS (voir supabase/README.md), ce
/// qui est signalé explicitement à l'écran pour ne pas induire le
/// propriétaire en erreur.
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
    final estProprietaire = ref.watch(estProprietaireProvider);

    if (!estProprietaire) {
      return Scaffold(
        appBar: AppBar(title: Text('Permissions — ${widget.nomApprenti}')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Seul le propriétaire de l\'atelier peut gérer les permissions.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

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
                    'Cet apprenti a accès à tout le travail quotidien (clients, '
                    'mesures, photos, rendez-vous, ventes, stock, dépenses), comme '
                    'vous. Il n\'a en revanche jamais accès au suivi des finances '
                    '(ni les commandes/paiements d\'un client, ni le récapitulatif '
                    'global de l\'atelier).',
                  ),
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
              ],
            ),
    );
  }
}
