import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/categorie_vente.dart';

const _bleuSeda = Color(0xFF1B4FA0);

/// Point d'entrée de l'historique des ventes : un gros bouton par
/// catégorie, même organisation que les écrans "Ventes" et "Gestion du
/// stock" — pour que le tailleur voie toujours une seule catégorie à la
/// fois plutôt que les trois mélangées sur un même écran.
class EcranHistoriqueVentesMenu extends StatelessWidget {
  const EcranHistoriqueVentesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des ventes'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final categorie in CategorieVente.values) ...[
              _CarteHistorique(
                categorie: categorie,
                onTap: () => context.push(AppRoutes.historiqueVentesCategorie(categorie)),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarteHistorique extends StatelessWidget {
  const _CarteHistorique({required this.categorie, required this.onTap});

  final CategorieVente categorie;
  final VoidCallback onTap;

  IconData get _icone => switch (categorie) {
        CategorieVente.pretAPorter => Icons.checkroom_outlined,
        CategorieVente.tissu => Icons.content_cut_outlined,
        CategorieVente.articleCouture => Icons.shopping_bag_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE3EAF7),
                child: Icon(_icone, color: _bleuSeda, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Historique - ${categorie.libelle}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6F6259)),
            ],
          ),
        ),
      ),
    );
  }
}
