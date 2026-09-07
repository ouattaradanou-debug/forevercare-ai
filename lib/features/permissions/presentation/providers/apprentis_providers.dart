import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/permissions_apprenti.dart';
import '../../../../data/models/utilisateur.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Équipe complète de l'atelier courant (propriétaire + apprentis), lue
/// depuis le cache local.
final StreamProvider<List<Utilisateur>> equipeAtelierProvider =
    StreamProvider<List<Utilisateur>>((ref) {
      final atelier = ref.watch(atelierCourantProvider).asData?.value;
      if (atelier == null) return Stream<List<Utilisateur>>.value(const []);
      return ref
          .watch(utilisateurRepositoryProvider)
          .observerEquipeLocale(atelier.id);
    });

/// Permissions d'un apprenti donné, lues depuis le cache local.
final permissionsApprentiProvider =
    StreamProvider.family<PermissionsApprenti?, String>((ref, utilisateurId) {
      return ref
          .watch(utilisateurRepositoryProvider)
          .observerPermissionsLocal(utilisateurId);
    });
