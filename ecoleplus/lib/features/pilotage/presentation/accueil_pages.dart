import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/app/theme.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/cantine/presentation/cantine_providers.dart';
import 'package:ecoleplus/features/maternelle/presentation/maternelle_pages.dart';
import 'package:ecoleplus/features/pilotage/domain/accueil.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Ce que la personne connectée peut voir (droits, modules actifs).
final Provider<ProfilAccueil?> profilAccueilProvider = Provider((ref) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) return null;
  final ecole = ref.watch(schoolProvider(s.schoolId)).value;
  return ProfilAccueil(
    role: s.role,
    droits: ref.watch(mesDroitsProvider),
    primaire: ecole?.managesPrimary ?? true,
    maternelle: ref.watch(maternelleActiveProvider(s.schoolId)),
    cantine: ref.watch(cantineActiveProvider(s.schoolId)),
  );
});

/// Thèmes de l'accueil de la personne connectée.
final Provider<List<ThemeAccueil>> themesProvider = Provider((ref) {
  final p = ref.watch(profilAccueilProvider);
  return p == null ? const [] : themesAccueil(p);
});

/// Un module de l'accueil : ses écrans en cartes (icône à la couleur du
/// module, titre, explication), dans l'ordre d'usage.
class ThemePage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themesProvider).where((t) => t.id == id).firstOrNull;
    if (t == null) {
      return const EcoleScaffold(
        title: 'Accueil',
        body: InfoMessage('Cette rubrique n’est pas disponible.'),
      );
    }
    final c = CouleurModule.duTheme(t.id);
    return EcoleScaffold(
      title: t.label,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Charte.marge,
          Charte.marge,
          Charte.marge,
          24,
        ),
        children: [
          Text(
            '${t.entrees.length} écran${t.entrees.length > 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (final e in t.entrees)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Charte.blanc,
                borderRadius: BorderRadius.circular(Charte.rayon),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Charte.rayon),
                  onTap: () => context.push(e.route),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Charte.blanc,
                      borderRadius: BorderRadius.circular(Charte.rayon),
                      border: Border.all(color: Charte.bordure),
                      boxShadow: Charte.ombre,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: c.fond,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(e.icone, color: c.couleur),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.label,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (e.sousTitre != null)
                                Text(
                                  e.sousTitre!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Charte.texteSecondaire,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
