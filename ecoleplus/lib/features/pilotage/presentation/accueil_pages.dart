import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
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

/// Un thème de l'accueil : ses écrans en gros boutons.
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
    return EcoleScaffold(
      title: t.label,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          for (final e in t.entrees) ...[
            BigButton(
              icon: e.icone,
              label: e.label,
              onPressed: () => context.push(e.route),
            ),
            if (e.sousTitre != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  e.sousTitre!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
