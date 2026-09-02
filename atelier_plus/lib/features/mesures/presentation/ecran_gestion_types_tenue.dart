import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/type_tenue.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/gabarits_providers.dart';

/// Écran réservé au propriétaire : seul lui peut créer/modifier les types
/// de tenue et leurs champs de mesure (voir supabase/README.md — la
/// permission `modifier_gabarits` n'accorde aucun droit d'écriture RLS).
/// La permission est vérifiée ici avant même d'afficher le contenu de
/// gestion, pas seulement au moment d'une action.
class EcranGestionTypesTenue extends ConsumerStatefulWidget {
  const EcranGestionTypesTenue({super.key});

  @override
  ConsumerState<EcranGestionTypesTenue> createState() => _EcranGestionTypesTenueState();
}

class _EcranGestionTypesTenueState extends ConsumerState<EcranGestionTypesTenue> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(gabaritsRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final estProprietaire = ref.watch(estProprietaireProvider);

    if (!estProprietaire) {
      return Scaffold(
        appBar: AppBar(title: const Text('Types de tenue')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Seul le propriétaire de l\'atelier peut gérer les types de tenue.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final types = ref.watch(typesTenueVisiblesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes types de tenue')),
      body: types.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (liste) {
          final femmes = liste.where((t) => t.sexe == 'femme').toList();
          final hommes = liste.where((t) => t.sexe == 'homme').toList();
          return ListView(
            children: [
              if (femmes.isNotEmpty) _EnTeteSection(titre: 'Femme'),
              ...femmes.map((t) => _LigneType(type: t)),
              if (hommes.isNotEmpty) _EnTeteSection(titre: 'Homme'),
              ...hommes.map((t) => _LigneType(type: t)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.creationTypeTenue),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau type'),
      ),
    );
  }
}

class _EnTeteSection extends StatelessWidget {
  const _EnTeteSection({required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(titre, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _LigneType extends StatelessWidget {
  const _LigneType({required this.type});

  final TypeTenue type;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(type.estGabaritParDefaut ? Icons.checkroom : Icons.checkroom_outlined),
      title: Text(type.nom),
      subtitle: type.estGabaritParDefaut ? const Text('Gabarit par défaut') : const Text('Personnalisé'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(AppRoutes.gestionChampsTypeTenue(type.id), extra: type),
    );
  }
}
