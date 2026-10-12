import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _bleuSedaFonce = Color(0xFF0F3570);
const _orangeSeda = Color(0xFFF5821F);

/// Coquille de navigation commune aux 4 destinations principales (Accueil,
/// Mesures des uniformes, Suivi des finances, Plus) : une barre de
/// navigation fixe en bas de l'écran, partagée par toute l'application.
/// Les écrans atteints depuis ces destinations (fiche client, détail d'un
/// groupe, prise de mesure…) restent des routes normales, empilées
/// au-dessus — la barre du bas disparaît alors le temps de la consultation,
/// comme dans la plupart des applications à onglets, et réapparaît au
/// retour sur l'une des 4 destinations.
class EcranCoquilleNavigation extends StatelessWidget {
  const EcranCoquilleNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BarreNavigationBasse(
        indexActuel: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _elements[i].libelle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: i == indexActuel ? FontWeight.bold : FontWeight.normal,
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
