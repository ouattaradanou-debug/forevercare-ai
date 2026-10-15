import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/categorie_vente.dart';
import '../providers/ventes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _rougeAlerte = Color(0xFFB3261E);

/// Point d'entrée de la gestion du stock : un gros bouton par catégorie,
/// même organisation que l'écran "Ventes" pour rester familière — un
/// tailleur qui sait déjà utiliser l'un sait utiliser l'autre.
///
/// Ouvert à tout utilisateur connecté (propriétaire ou apprenti) — le
/// compte d'un apprenti est identique à celui du propriétaire pour le
/// travail quotidien.
class EcranGestionStock extends ConsumerWidget {
  const EcranGestionStock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesDeLAtelierProvider).valueOrNull ?? const [];
    final articlesEnAlerte = articles.where((a) => a.stockBas).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du stock'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (articlesEnAlerte > 0) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE9E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined, color: _rougeAlerte),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        articlesEnAlerte == 1
                            ? '1 article va manquer, à surveiller ci-dessous'
                            : '$articlesEnAlerte articles vont manquer, à surveiller ci-dessous',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: _rougeAlerte),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            for (final categorie in CategorieVente.values) ...[
              _CarteCategorieStock(
                categorie: categorie,
                nombreEnAlerte: articles
                    .where((a) => a.categorie == categorie && a.stockBas)
                    .length,
                onTap: () => context.push(AppRoutes.stockCategorie(categorie)),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarteCategorieStock extends StatelessWidget {
  const _CarteCategorieStock({
    required this.categorie,
    required this.nombreEnAlerte,
    required this.onTap,
  });

  final CategorieVente categorie;
  final int nombreEnAlerte;
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
                  'Stock de ${categorie.libelle.toLowerCase()}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (nombreEnAlerte > 0)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.warning_amber_outlined, color: _rougeAlerte),
                ),
              const Icon(Icons.chevron_right, color: Color(0xFF6F6259)),
            ],
          ),
        ),
      ),
    );
  }
}
