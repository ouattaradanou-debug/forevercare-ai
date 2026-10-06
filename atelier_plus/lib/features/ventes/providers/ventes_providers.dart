import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/article.dart';
import '../../../data/models/vente.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/articles_repository.dart';
import '../data/ventes_repository.dart';

final articlesRepositoryProvider = Provider<ArticlesRepository>((ref) {
  return ArticlesRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});

final ventesRepositoryProvider = Provider<VentesRepository>((ref) {
  return VentesRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
    articlesRepository: ref.watch(articlesRepositoryProvider),
  );
});

/// Historique des ventes de l'atelier, pour l'écran "Historique des
/// ventes" (filtré ensuite par période/catégorie côté écran).
final ventesDeLAtelierProvider = StreamProvider.autoDispose<List<Vente>>((ref) async* {
  final atelier = await ref.watch(atelierCourantProvider.future);
  if (atelier == null) {
    yield const [];
    return;
  }
  yield* ref.watch(ventesRepositoryProvider).observerVentes(atelier.id);
});

/// Catalogue d'articles de l'atelier, pour l'écran "Gestion du stock" et le
/// choix d'article dans le formulaire de vente.
final articlesDeLAtelierProvider = StreamProvider.autoDispose<List<Article>>((ref) async* {
  final atelier = await ref.watch(atelierCourantProvider.future);
  if (atelier == null) {
    yield const [];
    return;
  }
  yield* ref.watch(articlesRepositoryProvider).observerArticles(atelier.id);
});
