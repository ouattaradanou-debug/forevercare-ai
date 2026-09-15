import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database_provider.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../../../../data/models/membre_groupe_uniforme.dart';
import '../../../../data/models/mesure_uniforme.dart';
import '../../../../data/models/photo_groupe_uniforme.dart';
import '../../../../data/repositories/uniforme_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final Provider<UniformeRepository> uniformeRepositoryProvider =
    Provider<UniformeRepository>(
      (ref) => UniformeRepository(
        ref.watch(supabaseClientProvider),
        ref.watch(appDatabaseProvider),
      ),
    );

/// Groupes d'uniformes de l'atelier, du plus récent au plus ancien.
final StreamProvider<List<GroupeUniforme>> groupesUniformesProvider =
    StreamProvider<List<GroupeUniforme>>((ref) {
      final atelier = ref.watch(atelierCourantProvider).asData?.value;
      if (atelier == null) return Stream<List<GroupeUniforme>>.value(const []);
      return ref.watch(uniformeRepositoryProvider).observerGroupes(atelier.id);
    });

/// Fiche d'un groupe, à jour en direct.
final groupeUniformeDetailProvider =
    StreamProvider.family<GroupeUniforme?, String>((ref, groupeId) {
      return ref.watch(uniformeRepositoryProvider).observerGroupe(groupeId);
    });

/// Photos (modèles + tissus) d'un groupe.
final photosGroupeUniformeProvider =
    StreamProvider.family<List<PhotoGroupeUniforme>, String>((ref, groupeId) {
      return ref
          .watch(uniformeRepositoryProvider)
          .observerPhotosGroupe(groupeId);
    });

/// Membres d'un groupe.
final membresGroupeUniformeProvider =
    StreamProvider.family<List<MembreGroupeUniforme>, String>((
      ref,
      groupeId,
    ) {
      return ref
          .watch(uniformeRepositoryProvider)
          .observerMembresGroupe(groupeId);
    });

/// Historique des mesures d'un membre (la plus récente en premier).
final mesuresMembreUniformeProvider =
    StreamProvider.family<List<MesureUniforme>, String>((ref, membreId) {
      return ref
          .watch(uniformeRepositoryProvider)
          .observerMesuresMembre(membreId);
    });
