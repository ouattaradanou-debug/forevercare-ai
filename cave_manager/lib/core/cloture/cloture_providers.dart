import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'cloture.dart';
import 'cloture_service.dart';

final clotureServiceProvider = Provider<ClotureService>((ref) {
  return ClotureService(ref.watch(supabaseClientProvider));
});

final clotureHistoriqueProvider =
    FutureProvider.autoDispose<List<Cloture>>((ref) async {
  final profil = await ref.watch(profilActuelProvider.future);
  if (profil == null) return const [];
  return ref.watch(clotureServiceProvider).listerClotures(profil.caveId);
});

final clotureApercuProvider =
    FutureProvider.autoDispose<PrevisionCloture>((ref) async {
  final profil = await ref.watch(profilActuelProvider.future);
  if (profil == null) {
    return const PrevisionCloture(
        totalVentes: 0, totalEspeces: 0, totalMobileMoney: 0, nombreCommandes: 0);
  }
  return ref.watch(clotureServiceProvider).previsualiser(profil.caveId);
});
