import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);

/// Destination "Plus" de la barre de navigation : regroupe les écrans
/// secondaires non présents dans les 3 autres onglets ni dans les Actions
/// rapides de l'accueil (historiques, configuration des tenues, réglages).
class EcranPlus extends ConsumerWidget {
  const EcranPlus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estProprietaire = ref.watch(estProprietaireProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (estProprietaire) ...[
            _LienPlus(
              icone: Icons.storefront_outlined,
              libelle: 'Historique des ventes',
              onTap: () => context.push(AppRoutes.historiqueVentes),
            ),
            const SizedBox(height: 12),
            _LienPlus(
              icone: Icons.receipt_long_outlined,
              libelle: 'Historique des dépenses',
              onTap: () => context.push(AppRoutes.historiqueDepenses),
            ),
            const SizedBox(height: 12),
            _LienPlus(
              icone: Icons.checkroom_outlined,
              libelle: 'Types de tenue',
              onTap: () => context.push(AppRoutes.typesTenue),
            ),
            const SizedBox(height: 12),
          ],
          _LienPlus(
            icone: Icons.settings_outlined,
            libelle: 'Paramètres',
            onTap: () => context.push(AppRoutes.parametres),
          ),
        ],
      ),
    );
  }
}

class _LienPlus extends StatelessWidget {
  const _LienPlus({required this.icone, required this.libelle, required this.onTap});

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icone, color: _bleuSeda),
              const SizedBox(width: 12),
              Expanded(
                child: Text(libelle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6F6259)),
            ],
          ),
        ),
      ),
    );
  }
}
