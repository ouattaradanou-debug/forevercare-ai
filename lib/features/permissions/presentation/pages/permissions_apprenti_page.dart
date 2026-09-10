import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/permissions_apprenti.dart';
import '../../../../data/models/utilisateur.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/apprentis_providers.dart';

/// Panneau de permissions d'un apprenti : cinq interrupteurs, aucun ne
/// concernant jamais l'argent (voir supabase/schema.sql :
/// permissions_apprenti n'a aucune colonne financière par conception).
class PermissionsApprentiPage extends ConsumerStatefulWidget {
  const PermissionsApprentiPage({super.key, required this.apprenti});

  final Utilisateur apprenti;

  @override
  ConsumerState<PermissionsApprentiPage> createState() =>
      _PermissionsApprentiPageState();
}

class _PermissionsApprentiPageState
    extends ConsumerState<PermissionsApprentiPage> {
  bool _chargementInitial = true;

  @override
  void initState() {
    super.initState();
    // S'assure que la ligne de permissions est bien en cache local avant
    // d'afficher les interrupteurs (elle a été créée par l'Edge Function
    // au moment de la création du compte apprenti).
    Future.microtask(() async {
      await ref
          .read(utilisateurRepositoryProvider)
          .recupererPermissions(widget.apprenti.id);
      if (mounted) setState(() => _chargementInitial = false);
    });
  }

  Future<void> _basculer(PermissionsApprenti misAJour) async {
    await ref
        .read(utilisateurRepositoryProvider)
        .mettreAJourPermissions(misAJour);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PermissionsApprenti?> permissionsAsync = ref.watch(
      permissionsApprentiProvider(widget.apprenti.id),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Permissions de ${widget.apprenti.nom}')),
      body: _chargementInitial
          ? const Center(child: CircularProgressIndicator())
          : permissionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erreur : $e')),
              data: (permissions) {
                if (permissions == null) {
                  return const Center(
                    child: Text('Permissions introuvables.'),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    Text(
                      "Par défaut, un apprenti ne peut rien faire : active "
                      "ici uniquement ce dont il a besoin. Il n'aura jamais "
                      "accès aux finances de l'atelier, quels que soient "
                      "ces réglages.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _InterrupteurPermission(
                      titre: 'Créer une fiche client',
                      valeur: permissions.creerClient,
                      onChanged: (v) =>
                          _basculer(permissions.copierAvec(creerClient: v)),
                    ),
                    _InterrupteurPermission(
                      titre: 'Modifier une fiche client',
                      valeur: permissions.modifierClient,
                      onChanged: (v) => _basculer(
                        permissions.copierAvec(modifierClient: v),
                      ),
                    ),
                    _InterrupteurPermission(
                      titre: 'Prendre des mesures',
                      valeur: permissions.prendreMesures,
                      onChanged: (v) => _basculer(
                        permissions.copierAvec(prendreMesures: v),
                      ),
                    ),
                    _InterrupteurPermission(
                      titre: 'Ajouter des photos',
                      valeur: permissions.ajouterPhotos,
                      onChanged: (v) => _basculer(
                        permissions.copierAvec(ajouterPhotos: v),
                      ),
                    ),
                    _InterrupteurPermission(
                      titre: 'Modifier les champs de mesure',
                      valeur: permissions.modifierGabarits,
                      onChanged: (v) => _basculer(
                        permissions.copierAvec(modifierGabarits: v),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _InterrupteurPermission extends StatelessWidget {
  const _InterrupteurPermission({
    required this.titre,
    required this.valeur,
    required this.onChanged,
  });

  final String titre;
  final bool valeur;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        title: Text(titre),
        value: valeur,
        onChanged: onChanged,
      ),
    );
  }
}
