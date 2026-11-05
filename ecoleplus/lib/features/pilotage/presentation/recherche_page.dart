import 'dart:convert';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/assistant/presentation/assistant_pages.dart';
import 'package:ecoleplus/features/pilotage/domain/recherche.dart';
import 'package:ecoleplus/features/pilotage/presentation/accueil_pages.dart';
import 'package:ecoleplus/features/pilotage/presentation/pilotage_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Recherche dans les données du téléphone (sans Internet) : élèves,
/// enseignants, classes, mes fiches de préparation, résultats. Jamais les
/// données de santé.
List<ResultatRecherche> rechercher(
  String q, {
  required List<EleveDansAnnee> eleves,
  required List<TeacherRow> enseignants,
  required List<ClassRow> classes,
  required List<LessonPrepRow> fiches,
  required bool notes,
}) {
  if (normaliser(q).length < 2) return const [];
  final out = <ResultatRecherche>[];
  for (final e in eleves) {
    final s = e.eleve;
    if (!correspond(q, [s.lastName, s.firstNames, s.studentCode])) continue;
    out.add(
      ResultatRecherche(
        TypeResultat.eleve,
        '${s.lastName} ${s.firstNames}',
        '/eleves/${s.id}',
        detail: [
          e.classe?.name ?? 'Sans classe',
          ?s.studentCode,
          if (s.archivedAt != null) 'sorti(e)',
        ].join(' • '),
      ),
    );
    if (notes && e.classe != null && s.archivedAt == null) {
      out.add(
        ResultatRecherche(
          TypeResultat.resultat,
          'Résultats de ${s.lastName} ${s.firstNames}',
          '/notes/${e.classe!.id}/classement',
          detail: 'Classement de la ${e.classe!.name}',
        ),
      );
    }
  }
  for (final t in enseignants) {
    if (!correspond(q, [t.lastName, t.firstNames, t.matricule])) continue;
    out.add(
      ResultatRecherche(
        TypeResultat.enseignant,
        '${t.lastName} ${t.firstNames}',
        '/enseignants/${t.id}',
        detail: t.matricule,
      ),
    );
  }
  for (final c in classes) {
    if (!correspond(q, [c.name, c.levelCode])) continue;
    out.add(ResultatRecherche(TypeResultat.classe, c.name, '/classes/${c.id}'));
    if (notes) {
      out.add(
        ResultatRecherche(
          TypeResultat.resultat,
          'Résultats de la ${c.name}',
          '/notes/${c.id}/classement',
        ),
      );
    }
  }
  for (final f in fiches) {
    var titre = f.theme ?? '';
    try {
      final c = jsonDecode(f.content);
      if (c is Map && c['titre'] is String) titre = c['titre'] as String;
    } on FormatException {
      // Contenu illisible : on garde le thème.
    }
    if (!correspond(q, [titre, f.theme])) continue;
    out.add(
      ResultatRecherche(
        TypeResultat.preparation,
        titre.isEmpty ? 'Fiche' : titre,
        '/assistant/fiches',
        detail: f.theme,
      ),
    );
  }
  return out;
}

class RecherchePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RecherchePage> createState() => _RechercheState();
}

class _RechercheState extends ConsumerState<RecherchePage> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider).value;
    final ctx = contexteEcole(ref);
    if (s == null || ctx == null) {
      return const EcoleScaffold(
        title: 'Rechercher',
        body: LinearProgressIndicator(),
      );
    }
    final (ecole, annee) = ctx;
    final droits = ref.watch(mesDroitsProvider);
    final notes =
        ecole.managesPrimary &&
        (s.role == 'enseignant' ||
            droits.contains('registres') ||
            droits.contains('formulaires'));
    final resultats = rechercher(
      _q.text,
      eleves:
          ref.watch(elevesProvider((ecole.id, annee.id, true))).value ??
          const [],
      enseignants: ref.watch(teachersProvider(ecole.id)).value ?? const [],
      classes: ref.watch(classesProvider(annee.id)).value ?? const [],
      fiches: s.role == 'enseignant' || s.role == 'directeur'
          ? ref.watch(fichesIaProvider(s.userId)).value ?? const []
          : const [],
      notes: notes,
    );
    // Écrans de l'accueil qui correspondent (« appel », « reçus »…).
    final ecrans = [
      for (final t in ref.watch(themesProvider))
        for (final e in t.entrees)
          if (correspond(_q.text, [e.label, e.sousTitre])) e,
    ];
    return EcoleScaffold(
      title: 'Rechercher',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('recherche'),
            controller: _q,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: 'Élève, enseignant, classe, fiche…',
              suffixIcon: MicButton(
                compact: true,
                texteActuel: () => _q.text,
                inserer: (t) => setState(() => _q.text = t),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          if (normaliser(_q.text).length < 2)
            const Text('Écrivez au moins 2 lettres (ou dictez).')
          else if (resultats.isEmpty && ecrans.isEmpty)
            const InfoMessage('Rien trouvé.', icon: Icons.search_off),
          if (ecrans.isNotEmpty) ...[
            const SectionTitle('Écrans'),
            for (final e in ecrans)
              ListTile(
                leading: Icon(e.icone),
                title: Text(e.label),
                onTap: () => context.push(e.route),
              ),
          ],
          for (final t in TypeResultat.values)
            if (resultats.any((r) => r.type == t)) ...[
              SectionTitle(t.titre),
              for (final r in resultats.where((r) => r.type == t).take(30))
                ListTile(
                  key: Key('resultat-${r.route}'),
                  title: Text(r.titre),
                  subtitle: r.detail == null ? null : Text(r.detail!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(r.route),
                ),
            ],
        ],
      ),
    );
  }
}
