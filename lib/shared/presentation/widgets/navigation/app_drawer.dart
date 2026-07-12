import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ForeverCare AI',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Votre assistant santé'),
                ],
              ),
            ),

            //------------------------------------------------------------------
            // Dashboard
            //------------------------------------------------------------------

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tableau de bord'),
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),

            //------------------------------------------------------------------
            // Clients
            //------------------------------------------------------------------

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Clients'),
              onTap: () {
                Navigator.pop(context);
                context.go('/clients');
              },
            ),

            //------------------------------------------------------------------
            // Produits
            //------------------------------------------------------------------

            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Produits'),
              onTap: () {
                Navigator.pop(context);
                context.go('/products');
              },
            ),

            const Divider(),

            //------------------------------------------------------------------
            // Futurs modules
            //------------------------------------------------------------------

            const ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Ventes'),
              enabled: false,
            ),

            const ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text('Rendez-vous'),
              enabled: false,
            ),

            const ListTile(
              leading: Icon(Icons.medication),
              title: Text('Protocoles'),
              enabled: false,
            ),

            const Divider(),

            //------------------------------------------------------------------
            // Paramètres
            //------------------------------------------------------------------

            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Paramètres'),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}