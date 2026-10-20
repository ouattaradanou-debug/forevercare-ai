import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/options/domain/module_rules.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Module 0 : options de l'école (réservé au directeur).
class OptionsPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final modules =
        ref.watch(modulesProvider(session.schoolId)).value ?? const [];
    if (school == null) {
      return const EcoleScaffold(title: 'Options de l’école', body: SizedBox());
    }
    bool on(String k) => modules.any((m) => m.$1.key == k && m.$2);
    final maternelle = modules.where((m) => m.$1.key == 'maternelle');
    return EcoleScaffold(
      title: 'Options de l’école',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('Niveaux gérés'),
          SwitchListTile(
            key: const Key('niveau-primaire'),
            title: const Text('Primaire (CP1 à CM2)'),
            value: school.managesPrimary,
            onChanged: (v) =>
                _setPrimary(context, ref, school, on('maternelle'), v),
          ),
          if (maternelle.isNotEmpty)
            _ModuleSwitch(
              schoolId: school.id,
              module: maternelle.first.$1,
              enabled: maternelle.first.$2,
              title: 'Activer la maternelle',
              otherLevelActive: school.managesPrimary,
            ),
          const SectionTitle('Modules'),
          for (final m in modules.where((m) => m.$1.key != 'maternelle'))
            _ModuleSwitch(
              schoolId: school.id,
              module: m.$1,
              enabled: m.$2,
              title: 'Activer : ${m.$1.label.toLowerCase()}',
              otherLevelActive: true,
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Désactiver un module le cache partout, sans rien effacer : '
              'vos données réapparaissent si vous le réactivez.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setPrimary(
    BuildContext context,
    WidgetRef ref,
    SchoolRow school,
    bool maternelleOn,
    bool value,
  ) async {
    if (!niveauxValides(primaire: value, maternelle: maternelleOn)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Au moins un niveau doit rester actif : activez d’abord la '
            'maternelle.',
          ),
        ),
      );
      return;
    }
    if (!value) {
      final ok = await confirmer(
        context,
        titre: 'Ne plus gérer le primaire ?',
        message:
            'Seront masqués : les classes du primaire, les notes, les '
            'classements, les fiches de scolarité et le registre matricule.'
            '\n\nVos données sont conservées.',
        bouton: 'Masquer le primaire',
      );
      if (!ok) return;
    }
    await ref.read(schoolRepositoryProvider).updateSchool(school.id, {
      'manages_primary': value,
    });
  }
}

class _ModuleSwitch extends ConsumerWidget {
  const new({
    required this.schoolId,
    required this.module,
    required this.enabled,
    required this.title,
    required this.otherLevelActive,
  });

  final String schoolId;
  final ModuleCatalogRow module;
  final bool enabled;
  final String title;
  final bool otherLevelActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SwitchListTile(
    key: Key('module-${module.key}'),
    title: Text(title),
    subtitle: Text(module.description),
    value: enabled,
    onChanged: (v) async {
      if (!v) {
        if (module.key == 'maternelle' && !otherLevelActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Au moins un niveau doit rester actif : activez d’abord le '
                'primaire.',
              ),
            ),
          );
          return;
        }
        final masques = elementsMasques[module.key] ?? const [];
        final ok = await confirmer(
          context,
          titre: 'Désactiver : ${module.label.toLowerCase()} ?',
          message:
              'Seront masqués partout :\n'
              '${masques.map((e) => '• $e').join('\n')}'
              '\n\nVos données sont conservées.',
          bouton: 'Désactiver',
        );
        if (!ok) return;
      } else if (module.key == 'medico_scolaire') {
        final ok = await confirmer(
          context,
          titre: 'Données de santé',
          message: avertissementMedical,
          bouton: 'J’ai compris, activer',
        );
        if (!ok) return;
      }
      await ref
          .read(schoolRepositoryProvider)
          .setModule(schoolId, module.key, on: v);
    },
  );
}
