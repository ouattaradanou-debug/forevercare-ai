import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/forms/data/fiche_scolarite_repository.dart';
import 'package:ecoleplus/features/forms/domain/fiche_scolarite.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_b4.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/presentation/grades_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ficheScolariteRepositoryProvider = Provider<FicheScolariteRepository>(
  (ref) => FicheScolariteRepository(
    ref.watch(localStoreProvider),
    ref.watch(gradesRepositoryProvider),
  ),
);

/// Fiche de scolarité (B4) d'un élève : aperçu des cours suivis, ce qui
/// manque, copie conforme, impression. Chaque fiche générée est journalisée.
class FicheScolaritePage extends ConsumerStatefulWidget {
  const new(this.studentId, {super.key});
  final String studentId;

  @override
  ConsumerState<FicheScolaritePage> createState() => _FicheState();
}

class _FicheState extends ConsumerState<FicheScolaritePage> {
  bool _copie = false;
  bool _occupe = false;
  late Future<FicheScolarite?> _fiche = _charger();

  Future<FicheScolarite?> _charger() =>
      ref.read(ficheScolariteRepositoryProvider).fiche(widget.studentId);

  Future<void> _sortir({required bool partager}) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final repo = ref.read(ficheScolariteRepositoryProvider);
      // Toujours les données du moment (une note corrigée compte aussitôt).
      final f = await repo.fiche(widget.studentId, copieConforme: _copie);
      if (f == null) return false;
      final pdf = await pdfB4(await ref.read(policesPdfProvider.future), f);
      final nom = 'Fiche_scolarite_${f.nom}${_copie ? '_copie_conforme' : ''}'
          .replaceAll(RegExp(r'[^\p{L}\p{N}\-]+', unicode: true), '_');
      final sortie = ref.read(sortiePdfProvider);
      await (partager ? sortie.partager : sortie.imprimer)(pdf, '$nom.pdf');
      final session = ref.read(sessionProvider).value!;
      await repo.journaliser(
        session.schoolId,
        widget.studentId,
        copieConforme: _copie,
      );
      return true;
    });
    if (mounted) {
      setState(() {
        _occupe = false;
        _fiche = _charger();
      });
    }
  }

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: 'Fiche de scolarité',
    body: FutureBuilder<FicheScolarite?>(
      future: _fiche,
      builder: (context, snap) {
        final f = snap.data;
        if (f == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final manques = [
          if (f.neLe == null) 'date de naissance',
          if (f.lieuNaissance == null) 'lieu de naissance',
          if (f.pere == null && f.mere == null) 'parents',
          if (f.matricule == null) 'N° matricule (après synchronisation)',
          if (f.entreLe == null) 'date d’entrée',
        ];
        return ListView(
          key: const Key('fiche-scolarite'),
          padding: const EdgeInsets.all(16),
          children: [
            Text(f.nom, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const SectionTitle('Cours suivis'),
            if (f.cours.isEmpty)
              const InfoMessage(
                'Aucun résultat annuel : il apparaîtra quand les trois '
                'trimestres seront notés (ou quand le directeur aura gardé '
                'les résultats de l’année).',
              ),
            for (final n in niveauxB4)
              for (final e in const [1, 2])
                if (f.cours[(n, e)] case final c?)
                  ListTile(
                    key: Key('cours-$n-$e'),
                    dense: true,
                    title: Text(
                      e == 2
                          ? '${libellesNiveauxB4[n]} (redoublement)'
                          : libellesNiveauxB4[n]!,
                    ),
                    subtitle: Text(
                      'Moyenne ${c.moyenneTexte} · classement ${c.classement}',
                    ),
                  ),
            if (manques.isNotEmpty) ...[
              const SectionTitle('À compléter sur la fiche de l’élève'),
              Text(manques.join(', ')),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('copie-conforme'),
              title: const Text('Copie conforme'),
              subtitle: const Text(
                'Ajoute la mention « Copie conforme » et la date. La fiche '
                'originale n’est jamais remise à l’élève.',
              ),
              value: _copie,
              onChanged: (v) => setState(() => _copie = v),
            ),
            const SizedBox(height: 8),
            BigButton(
              key: const Key('b4-imprimer'),
              icon: Icons.print,
              label: 'Aperçu et impression',
              onPressed: _occupe ? null : () => _sortir(partager: false),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('b4-partager'),
              icon: const Icon(Icons.share),
              label: const Text('Partager le PDF'),
              onPressed: _occupe ? null : () => _sortir(partager: true),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chaque fiche générée est inscrite au journal d’activité '
              '(qui, quand, copie conforme ou non).',
            ),
          ],
        );
      },
    ),
  );
}
