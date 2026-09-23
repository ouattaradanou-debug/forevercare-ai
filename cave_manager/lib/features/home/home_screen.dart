import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/profil.dart';
import '../../core/constants/type_cave.dart';

/// Accueil minimal post-connexion pour la Phase 1.
///
/// Ne contient volontairement PAS encore les écrans "Vendre" / "Mes
/// commandes" (Phase 3) ni le tableau de bord Propriétaire (point 28,
/// Phase 2+) : ce sont des fonctionnalités hors périmètre de cette phase.
/// Son seul rôle ici est de prouver que le routage par rôle fonctionne et
/// qu'aucune donnée financière n'apparaît pour un Agent de vente — c'est
/// le critère d'acceptation testable de la Phase 1, pas une maquette
/// définitive du tableau de bord.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.profil});

  final Profil profil;

  Future<void> _ouvrirConfigurationCave(
      BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final typeActuel = await authService.typeCaveActuel(profil.caveId);
    if (!context.mounted) return;

    var typeChoisi = typeActuel;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Configuration de la cave'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type de cave',
                  style: Theme.of(context).textTheme.titleMedium),
              RadioGroup<TypeCave>(
                groupValue: typeChoisi,
                onChanged: (v) => setDialogState(() => typeChoisi = v!),
                child: Column(
                  children: TypeCave.values
                      .map((type) => RadioListTile<TypeCave>(
                          title: Text(type.libelle), value: type))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Text('Votre profil',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(profil.role.libelle),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await authService.modifierTypeCave(
                      caveId: profil.caveId, typeCave: typeChoisi);
                  if (context.mounted) Navigator.of(context).pop();
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Impossible d\'enregistrer.')));
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: profil.role.estResponsable
            ? IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Configuration de la cave',
                onPressed: () => _ouvrirConfigurationCave(context, ref),
              )
            : null,
        title: const Text('Ma Cave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => ref.read(authServiceProvider).seDeconnecter(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                child: Text(
                  profil.prenom.isNotEmpty
                      ? profil.prenom[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text('Bienvenue, ${profil.nomComplet}',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Chip(label: Text(profil.role.libelle)),
              const SizedBox(height: 24),
              Text(
                'Les écrans de vente, stock et clôture arrivent dans les prochaines phases.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
