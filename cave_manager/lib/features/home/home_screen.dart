import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/profil.dart';
import '../cave_setup/configuration_cave_screen.dart';
import '../produits/produits_list_screen.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infosCave = ref.watch(infosCaveProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: profil.role.estResponsable
            ? IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Configuration de la cave',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ConfigurationCaveScreen(profil: profil),
                  ),
                ),
              )
            : null,
        title: Row(
          children: [
            if (infosCave?.logoUrl != null) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(infosCave!.logoUrl!),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                infosCave?.nom ?? 'Ma Cave',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => ref.read(authServiceProvider).seDeconnecter(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Police cursive (Google Fonts "Alex Brush", demandée sur le
          // modèle d'une calligraphie manuscrite) : téléchargée et mise
          // en cache au premier affichage avec réseau, réutilisée ensuite
          // hors ligne. Encart bleu ciel collé sous la barre du haut (pas
          // de marge au-dessus), compact, texte bordeaux (le blanc sur
          // bleu ciel manquait de lisibilité), toujours sur une seule
          // ligne grâce à FittedBox qui réduit la taille si le nom est
          // long.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF87CEEB),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Bienvenue, ${profil.nomComplet}',
                maxLines: 1,
                style: GoogleFonts.alexBrush(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Chip(label: Text(profil.role.libelle)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProduitsListScreen(profil: profil),
                      ),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('Produits'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Les écrans de vente, encaissement et clôture arrivent dans les prochaines phases.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
