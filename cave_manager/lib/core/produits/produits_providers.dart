import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../database/daos/stock_dao.dart';
import 'categorie_produit.dart';
import 'produit.dart';
import 'produits_service.dart';

final produitsServiceProvider = Provider<ProduitsService>((ref) {
  return ProduitsService(ref.watch(supabaseClientProvider));
});

final stockDaoProvider = Provider<StockDao>((ref) {
  return ref.watch(appDatabaseProvider).stockDao;
});

/// Catalogue de la cave courante. `autoDispose` : pas besoin de garder ce
/// cache une fois qu'on quitte les écrans produits.
final produitsProvider =
    FutureProvider.autoDispose<List<Produit>>((ref) async {
  final profil = await ref.watch(profilActuelProvider.future);
  if (profil == null) return const [];
  return ref.watch(produitsServiceProvider).listerProduits(profil.caveId);
});

/// Catégories de la cave courante, y compris masquées (chaque écran décide
/// s'il les affiche — `CategoriesProduitsScreen` les montre toutes pour la
/// gestion, `ProduitsListScreen` filtre les masquées pour l'Agent).
final categoriesProduitsProvider =
    FutureProvider.autoDispose<List<CategorieProduit>>((ref) async {
  final profil = await ref.watch(profilActuelProvider.future);
  if (profil == null) return const [];
  return ref.watch(produitsServiceProvider).listerCategories(profil.caveId);
});
