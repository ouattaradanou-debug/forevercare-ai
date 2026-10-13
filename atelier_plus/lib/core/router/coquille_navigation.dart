import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/finances/providers/finances_providers.dart';
import '../../features/permissions/providers/permissions_providers.dart';

const _bleuSedaFonce = Color(0xFF0F3570);
const _orangeSeda = Color(0xFFF5821F);

/// Index des onglets "Accueil" et "Suivi des finances" dans
/// [_BarreNavigationBasse] — doivent rester synchronisés avec l'ordre des
/// `StatefulShellBranch` dans app_router.dart.
const _indexAccueil = 0;
const _indexSuiviFinances = 2;

/// Coquille de navigation commune aux 4 destinations principales (Accueil,
/// Mesures des uniformes, Suivi des finances, Plus) : une barre de
/// navigation fixe en bas de l'écran, partagée par toute l'application.
/// Les écrans atteints depuis ces destinations (fiche client, détail d'un
/// groupe, prise de mesure…) restent des routes normales, empilées
/// au-dessus — la barre du bas disparaît alors le temps de la consultation,
/// comme dans la plupart des applications à onglets, et réapparaît au
/// retour sur l'une des 4 destinations.
class EcranCoquilleNavigation extends ConsumerWidget {
  const EcranCoquilleNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BarreNavigationBasse(
        indexActuel: navigationShell.currentIndex,
        onTap: (index) async {
          // `StatefulShellRoute.indexedStack` garde chaque onglet monté en
          // arrière-plan plutôt que de le recréer (c'est tout l'intérêt :
          // conserver le défilement, les champs en cours...). Mais
          // `recapitulatifGlobalProvider`/`recapitulatifMensuelProvider`
          // (FutureProvider, calculés une seule fois) ne se recalculent
          // alors jamais tout seuls après une écriture financière faite
          // depuis un autre onglet (vente, nouveau paiement, suppression
          // d'un client/groupe ancien...) : on force leur recalcul à chaque
          // fois que l'onglet "Suivi des finances" est sélectionné, pour ne
          // jamais y afficher un total périmé.
          if (index == _indexSuiviFinances) {
            ref.invalidate(recapitulatifGlobalProvider);
            ref.invalidate(recapitulatifMensuelProvider);
          }
          // Même principe pour les permissions d'un apprenti : l'écran
          // d'accueil ne les rafraîchit qu'à son tout premier montage
          // (`initState`, voir EcranAccueilProvisoire), jamais lors d'un
          // simple retour sur l'onglet depuis un autre — sans quoi un
          // changement de permission fait par le propriétaire pendant que
          // l'apprenti navigue ailleurs dans l'app resterait invisible tant
          // qu'il ne se déconnecte pas.
          if (index == _indexAccueil) {
            final utilisateur = ref.read(utilisateurCourantProvider).valueOrNull;
            if (utilisateur != null && !utilisateur.estProprietaire) {
              try {
                await ref.read(permissionsRepositoryProvider).lire(utilisateur.id);
              } catch (e) {
                // Hors-ligne (ou autre échec best-effort) : le cache déjà
                // présent reste utilisable. Affiché en console (jamais à
                // l'écran) uniquement pour le diagnostic.
                debugPrint('Échec rafraîchissement permissions (onglet Accueil) : $e');
              }
              ref.invalidate(mesPermissionsProvider);
            }
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _BarreNavigationBasse extends StatelessWidget {
  const _BarreNavigationBasse({required this.indexActuel, required this.onTap});

  final int indexActuel;
  final ValueChanged<int> onTap;

  static const _elements = [
    (icone: Icons.home_outlined, iconeActif: Icons.home, libelle: 'Accueil'),
    (icone: Icons.straighten_outlined, iconeActif: Icons.straighten, libelle: 'Mesures des uniformes'),
    (icone: Icons.bar_chart_outlined, iconeActif: Icons.bar_chart, libelle: 'Suivi des finances'),
    (icone: Icons.menu, iconeActif: Icons.menu, libelle: 'Plus'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(color: _bleuSedaFonce),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            for (var i = 0; i < _elements.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        i == indexActuel ? _elements[i].iconeActif : _elements[i].icone,
                        color: i == indexActuel ? _orangeSeda : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _elements[i].libelle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: i == indexActuel ? _orangeSeda : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
