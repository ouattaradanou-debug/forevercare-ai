import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/school/domain/school_year.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class YearsPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final years = ref.watch(yearsProvider(session.schoolId)).value ?? const [];
    final current = years.where((y) => y.id == school?.currentSchoolYearId);
    final repo = ref.read(schoolRepositoryProvider);
    return EcoleScaffold(
      title: 'Années scolaires',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (years.isEmpty)
            const InfoMessage('Aucune année scolaire pour le moment.'),
          for (final y in years)
            Card(
              child: ListTile(
                title: Text(y.label, style: const TextStyle(fontSize: 20)),
                subtitle: Text(
                  y.id == school?.currentSchoolYearId
                      ? 'Année en cours'
                      : y.archivedAt != null
                      ? 'Archivée — consultable'
                      : 'Préparée',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/annees/${y.id}'),
              ),
            ),
          const SizedBox(height: 16),
          if (current.isNotEmpty && school != null) ...[
            BigButton(
              icon: Icons.add,
              label: 'Préparer l’année ${anneeSuivante(current.first.label)}',
              onPressed: () async {
                await repo.prepareNextYear(school.id, current.first);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Année préparée. Les en-têtes ont été recopiés : '
                        'vérifiez-les.',
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            for (final y in years.where(
              (y) => y.id != school.currentSchoolYearId,
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: Text('Passer à l’année ${y.label}'),
                  onPressed: () =>
                      _switch(context, ref, school.id, current.first, y),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _switch(
    BuildContext context,
    WidgetRef ref,
    String schoolId,
    SchoolYearRow from,
    SchoolYearRow to,
  ) async {
    final ok = await confirmer(
      context,
      titre: 'Changer d’année scolaire ?',
      message:
          'L’année ${to.label} deviendra l’année en cours. L’année '
          '${from.label} sera archivée : elle restera consultable. '
          'Rien n’est supprimé.',
      bouton: 'Passer à ${to.label}',
    );
    if (ok) {
      await ref.read(schoolRepositoryProvider).switchToYear(schoolId, to.id);
    }
  }
}
