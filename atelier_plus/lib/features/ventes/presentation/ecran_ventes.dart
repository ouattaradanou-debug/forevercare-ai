import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/categorie_vente.dart';
import '../providers/ventes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Point d'entrée des ventes directes : trois boutons (un par catégorie),
/// un récapitulatif du jour par catégorie, et l'accès à l'historique
/// complet (filtrable par période et par catégorie).
class EcranVentes extends ConsumerWidget {
  const EcranVentes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventes = ref.watch(ventesDeLAtelierProvider);
    final articles = ref.watch(articlesDeLAtelierProvider).valueOrNull ?? const [];
    final articlesEnAlerte = articles.where((a) => a.stockBas).length;
    final maintenant = DateTime.now();
    final debutJour = DateTime(maintenant.year, maintenant.month, maintenant.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventes'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (articlesEnAlerte > 0) ...[
              Material(
                color: const Color(0xFFFBE9E7),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push(AppRoutes.gestionStock),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined, color: Color(0xFFB3261E)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            articlesEnAlerte == 1
                                ? '1 article en stock bas'
                                : '$articlesEnAlerte articles en stock bas',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB3261E),
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFFB3261E)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Enregistrer une vente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _bleuSeda),
            ),
            const SizedBox(height: 12),
            for (final categorie in CategorieVente.values) ...[
              _CarteCategorie(
                categorie: categorie,
                onTap: () => context.push(AppRoutes.nouvelleVente, extra: categorie),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.historiqueVentes),
              style: OutlinedButton.styleFrom(
                foregroundColor: _bleuSeda,
                side: const BorderSide(color: _bleuSeda),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Historique des ventes'),
            ),
            const SizedBox(height: 28),
            const Text(
              'Aujourd\'hui, par catégorie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _bleuSeda),
            ),
            const SizedBox(height: 12),
            ventes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (erreur, _) => Text('Erreur : $erreur'),
              data: (liste) {
                final duJour = liste.where((v) => !v.date.isBefore(debutJour)).toList();
                return Column(
                  children: [
                    for (final categorie in CategorieVente.values)
                      _LigneTotalCategorie(
                        categorie: categorie,
                        total: duJour
                            .where((v) => v.categorie == categorie)
                            .fold<double>(0, (s, v) => s + v.montantTotal),
                        nombre: duJour.where((v) => v.categorie == categorie).length,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteCategorie extends StatelessWidget {
  const _CarteCategorie({required this.categorie, required this.onTap});

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
                  'Vente de ${categorie.libelle.toLowerCase()}',
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

class _LigneTotalCategorie extends StatelessWidget {
  const _LigneTotalCategorie({
    required this.categorie,
    required this.total,
    required this.nombre,
  });

  final CategorieVente categorie;
  final double total;
  final int nombre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${categorie.libelle} ($nombre vente${nombre > 1 ? 's' : ''})',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            Formatters.montant(total),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _orangeSeda),
          ),
        ],
      ),
    );
  }
}
