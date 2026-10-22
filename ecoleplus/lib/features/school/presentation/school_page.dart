import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SchoolPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    if (school == null) {
      return const EcoleScaffold(
        title: 'Mon école',
        body: InfoMessage('Les informations de l’école arrivent…'),
      );
    }
    final repo = ref.read(schoolRepositoryProvider);
    Future<void> save(String col, String? v) =>
        repo.updateSchool(school.id, {col: v});
    return EcoleScaffold(
      title: 'Mon école',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Tout est enregistré automatiquement.'),
          const SizedBox(height: 16),
          AutoSaveField(
            label: 'Nom de l’école',
            initial: school.name,
            onSave: (v) async {
              if (v != null) await save('name', v);
            },
          ),
          AutoSaveField(
            label: 'Nom du directeur ou de la directrice',
            initial: school.directorName,
            onSave: (v) => save('director_name', v),
          ),
          AutoSaveField(
            label: 'Commune',
            initial: school.commune,
            onSave: (v) => save('commune', v),
          ),
          AutoSaveField(
            label: 'Département',
            initial: school.departement,
            onSave: (v) => save('departement', v),
          ),
          AutoSaveField(
            label: 'Province',
            initial: school.province,
            onSave: (v) => save('province', v),
          ),
          AutoSaveField(
            label: 'Région',
            initial: school.region,
            onSave: (v) => save('region', v),
          ),
          AutoSaveField(
            label: 'Téléphone',
            initial: school.phone,
            keyboardType: TextInputType.phone,
            onSave: (v) => save('phone', v),
          ),
          AutoSaveField(
            label: 'E-mail',
            initial: school.email,
            keyboardType: TextInputType.emailAddress,
            onSave: (v) => save('email', v),
          ),
          AutoSaveField(
            label: 'Adresse',
            initial: school.address,
            onSave: (v) => save('address', v),
          ),
          const Text('Type d’école'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'publique', label: Text('Publique')),
              ButtonSegment(value: 'privee', label: Text('Privée')),
            ],
            selected: {school.schoolType},
            onSelectionChanged: (s) =>
                repo.updateSchool(school.id, {'school_type': s.first}),
          ),
          const SizedBox(height: 24),
          BigButton(
            icon: Icons.calendar_month,
            label: 'Années scolaires',
            onPressed: () => context.push('/annees'),
          ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.tune,
            label: 'Options de l’école',
            onPressed: () => context.push('/options'),
          ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.save_alt,
            label: 'Sauvegarde',
            onPressed: () => context.push('/sauvegarde'),
          ),
          const SizedBox(height: 12),
          if (school.currentSchoolYearId != null)
            OutlinedButton.icon(
              icon: const Icon(Icons.article_outlined),
              label: const Text('En-têtes administratifs de l’année en cours'),
              onPressed: () =>
                  context.push('/annees/${school.currentSchoolYearId}'),
            ),
        ],
      ),
    );
  }
}
