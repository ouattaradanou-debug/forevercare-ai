import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/mesures/providers/gabarits_providers.dart';
import '../../features/mesures/utils/choix_gabarit.dart';

const Color _bleuSeda = Color(0xFF1B4FA0);

/// Carte de choix du sexe ("Homme"/"Femme") — partagée entre "Nouveau
/// client" et "Nouveau membre" (groupe d'uniformes).
class CarteSexe extends StatelessWidget {
  const CarteSexe({
    super.key,
    required this.icone,
    required this.libelle,
    required this.selectionne,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selectionne ? _bleuSeda : const Color(0xFFDDD3C8),
              width: selectionne ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icone, size: 28),
              const SizedBox(height: 8),
              Text(libelle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste fixe des champs de mesure selon le sexe choisi — pas de choix de
/// type de tenue à cette étape : affiche directement, dès le sexe choisi,
/// le gabarit par défaut (ou sa copie personnalisée pour l'atelier, voir
/// choisirGabaritPourSexe). Partagé entre "Nouveau client" et "Nouveau
/// membre" (groupe d'uniformes), afin que toute évolution future de la
/// prise de mesure à la création s'applique automatiquement aux deux.
class SectionMesuresParSexe extends ConsumerWidget {
  const SectionMesuresParSexe({super.key, required this.sexe, required this.controleurPour});

  final String sexe;
  final TextEditingController Function(String champId) controleurPour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilisateur = ref.watch(utilisateurCourantProvider).valueOrNull;
    final types = ref.watch(typesTenueVisiblesProvider);

    return types.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Impossible de charger les champs de mesure.'),
      data: (liste) {
        if (utilisateur == null) return const Center(child: CircularProgressIndicator());
        final gabarit = choisirGabaritPourSexe(liste, utilisateur.atelierId, sexe);
        if (gabarit == null) {
          return const Text(
            'Connectez-vous à internet une première fois pour récupérer les champs de mesure.',
            style: TextStyle(color: Color(0xFF6F6259)),
          );
        }

        final champs = ref.watch(champsActifsProvider(gabarit.id));
        return champs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Impossible de charger les champs de mesure.'),
          data: (champsListe) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final champ in champsListe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controleurPour(champ.id),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: '${champ.nom} (${champ.unite})'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
