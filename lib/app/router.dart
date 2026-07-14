import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';

import '../features/clients/presentation/pages/add_client_page.dart';
import '../features/clients/presentation/pages/clients_page.dart';

import '../features/produits/presentation/pages/add_product_page.dart';
import '../features/produits/presentation/pages/products_page.dart';

import '../features/commandes/presentation/pages/orders_page.dart';
import '../features/commandes/presentation/pages/add_order_page.dart';

/// ============================================================================
/// ForeverCare AI
/// Routeur officiel
/// ============================================================================
///
/// Toutes les routes de l'application sont centralisées ici.
///
/// Convention :
///
/// /
/// /clients
/// /clients/new
///
/// /products
/// /products/new
///
/// Les pages de détail continuent d'être ouvertes
/// via MaterialPageRoute.
///
/// ============================================================================
abstract final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      //----------------------------------------------------------------------
      // Dashboard
      //----------------------------------------------------------------------

      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      //----------------------------------------------------------------------
      // Clients
      //----------------------------------------------------------------------

      GoRoute(
        path: '/clients',
        name: 'clients',
        builder: (context, state) => const ClientsPage(),
      ),

      GoRoute(
        path: '/clients/new',
        name: 'add-client',
        builder: (context, state) => const AddClientPage(),
      ),

      //----------------------------------------------------------------------
      // Produits
      //----------------------------------------------------------------------

      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductsPage(),
      ),

      GoRoute(
        path: '/products/new',
        name: 'add-product',
        builder: (context, state) => const AddProductPage(),
      ),

            //----------------------------------------------------------------------
      // Commandes
      //----------------------------------------------------------------------

      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersPage(),
      ),

      GoRoute(
        path: '/orders/new',
        name: 'add-order',
        builder: (context, state) => const AddOrderPage(),
      ),
    ],
  );
}