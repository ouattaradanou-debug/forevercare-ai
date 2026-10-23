import 'dart:async';
import 'dart:typed_data';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/export/xlsx_ecriture.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/data/grades_repository.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/grades/domain/tableau_classement.dart';
import 'package:ecoleplus/features/grades/pdf/pdf_classement.dart';
import 'package:ecoleplus/features/grades/presentation/grades_pages.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:share_plus/share_plus.dart';

/// Envoi d'un fichier (Excel) vers une autre application (remplacé dans les
/// tests).
typedef SortieFichier = Future<void> Function(
  Uint8List octets,
  String nom,
  String type,
);

final sortieFichierProvider = Provider<SortieFichier>(
  (ref) => (octets, nom, type) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(octets, name: nom, mimeType: type)],
        fileNameOverrides: [nom],
      ),
    );
  },
);

const typeXlsx =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

final StreamProviderFamily<List<AnnualResultRow>, String>
resultatsAnnuelsProvider = StreamProvider.family(
  (ref, classId) =>
      ref.watch(gradesRepositoryProvider).watchResultatsAnnuels(classId),
);

/// Classement d'une classe : par composition ou cumul de l'année.
class ClassementPage extends ConsumerStatefulWidget {
  const new(this.classId, {super.key});
  final String classId;

  @override
  ConsumerState<ClassementPage> createState() => _ClassementState();
}

class _ClassementState extends ConsumerState<ClassementPage> {
  /// 1, 2, 3 : trimestre ; 4 : l'année. null : dernier trimestre noté.
  int? _periode;
  bool _occupe = false;

  static const _annee = 4;

  String _periodeTexte(int p) => p == _annee ? 'Année' : trimestreTexte(p);

  List<(String, String)> _colonnes(DonneesClasse d, int p) =>
      p == _annee ? colonnesAnnee : colonnesMatieres(d.matieresCalcul);

  String _nomFichier(DonneesClasse d, int p, String ext) {
    final base = 'Classement_${d.classe.name}_${_periodeTexte(p)}'.replaceAll(
      RegExp(r'[^\p{L}\p{N}\-]+', unicode: true),
      '_',
    );
    return '$base.$ext';
  }

  Future<void> _pdf(DonneesClasse d, int p, Classement c) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final annee = ref
          .read(yearsProvider(d.ecole.id))
          .value
          ?.where((a) => a.id == d.classe.schoolYearId)
          .firstOrNull;
      final pdf = await pdfClassement(
        await ref.read(policesPdfProvider.future),
        ecole: d.ecole.name,
        classe: d.classe.name,
        annee: annee?.label ?? '',
        periode: _periodeTexte(p),
        tableau: tableauClassement(c, _colonnes(d, p), avecTotal: p != _annee),
        statistiques: statistiquesTexte(c.statistiques),
      );
      await ref.read(sortiePdfProvider).imprimer(pdf, _nomFichier(d, p, 'pdf'));
      return true;
    });
    if (mounted) setState(() => _occupe = false);
  }

  Future<void> _excel(DonneesClasse d, int p, Classement c) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final t = tableauClassement(c, _colonnes(d, p), avecTotal: p != _annee);
      final octets = ecrireXlsx('Classement', [
        t.entete,
        ...t.lignes,
        const [],
        for (final s in statistiquesTexte(c.statistiques)) [s],
      ]);
      await ref.read(sortieFichierProvider)(
        octets,
        _nomFichier(d, p, 'xlsx'),
        typeXlsx,
      );
      return true;
    });
    if (mounted) setState(() => _occupe = false);
  }

  Future<void> _garderAnnuel(DonneesClasse d, Classement c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Garder les résultats de l’année ?'),
        content: const Text(
          'La moyenne générale, le rang et l’effectif de chaque élève seront '
          'gardés pour sa fiche de scolarité. Vous pourrez recommencer si '
          'une note change.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Garder'),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || !mounted) return;
    final n = await avecMessage(
      context,
      () => ref
          .read(gradesRepositoryProvider)
          .enregistrerResultatsAnnuels(
            d,
            c,
            date: ref.read(clockProvider).nowIso().substring(0, 10),
          ),
    );
    if (n != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Résultats de l’année gardés ($n élèves).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(donneesClasseProvider(widget.classId)).value;
    final session = ref.watch(sessionProvider).value;
    if (session != null) ref.watch(yearsProvider(session.schoolId));
    if (d == null) {
      return const EcoleScaffold(
        title: 'Classement',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Par défaut : le dernier trimestre qui a des notes.
    final p = _periode ??= () {
      for (final t in const [3, 2, 1]) {
        final ids = {for (final e in d.epreuvesTrimestre(t)) e.id};
        if (d.notes.any((g) => ids.contains(g.assessmentId))) return t;
      }
      return 1;
    }();
    final annee = p == _annee;
    final c = annee ? d.annee() : d.trimestre(p);
    final s = c.statistiques;
    final directeur = session?.role == 'directeur';
    final annuels = annee && directeur
        ? ref.watch(resultatsAnnuelsProvider(widget.classId)).value
        : null;
    final dejaGardes = annuels
        ?.map((a) => a.resultDate)
        .nonNulls
        .fold<String?>(null, (a, b) => a == null || b.compareTo(a) > 0 ? b : a);
    final colonnes = _colonnes(d, p);
    return EcoleScaffold(
      title: 'Classement — ${d.classe.name}',
      body: ListView(
        key: const Key('classement'),
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in const [1, 2, 3, _annee])
                ChoiceChip(
                  key: Key('periode-$t'),
                  label: Text(_periodeTexte(t)),
                  selected: p == t,
                  onSelected: (_) => setState(() => _periode = t),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (annee)
                    const Text(
                      'Moyenne annuelle = (1er + 2e + 3e trimestre) ÷ 3, '
                      'seulement pour les élèves qui ont les trois.',
                    ),
                  for (final l in statistiquesTexte(s)) Text(l),
                  if (d.matieres.isEmpty)
                    const Text(
                      'Aucune matière : le directeur doit d’abord choisir '
                      'les matières de la classe.',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('export-pdf'),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
                onPressed: _occupe ? null : () => _pdf(d, p, c),
              ),
              OutlinedButton.icon(
                key: const Key('export-excel'),
                icon: const Icon(Icons.table_view),
                label: const Text('Excel'),
                onPressed: _occupe ? null : () => _excel(d, p, c),
              ),
            ],
          ),
          if (annee && directeur) ...[
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              key: const Key('garder-annuel'),
              icon: const Icon(Icons.save_alt),
              label: const Text('Garder les résultats de l’année'),
              onPressed: s.classes == 0 ? null : () => _garderAnnuel(d, c),
            ),
            if (dejaGardes != null)
              Text('Derniers résultats gardés le ${jjmmaaaa(dejaGardes)}.'),
          ],
          const SizedBox(height: 12),
          for (final r in c.resultats)
            Card(
              key: Key('rang-${r.eleve.id}'),
              child: ExpansionTile(
                leading: SizedBox(
                  width: 72,
                  child: Text(
                    r.rang == null
                        ? r.rangTexte
                        : '${r.rangTexte}/${s.effectif}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                title: Text(r.eleve.nom),
                subtitle: Text(_sousTitre(r, annee)),
                children: [
                  for (final (id, titre) in colonnes)
                    ListTile(
                      dense: true,
                      title: Text(titre),
                      subtitle: r.uneSeuleNote.contains(id)
                          ? const Text('Une seule note')
                          : null,
                      trailing: Text(centiemesTexte(r.moyennesMatieres[id])),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _sousTitre(Resultat r, bool annee) {
    final mention = r.mention == null ? '' : ' · ${r.mention}';
    if (annee) {
      return r.moyenne == null
          ? 'Il manque la moyenne d’un trimestre'
          : 'Moyenne annuelle ${centiemesTexte(r.moyenne)}$mention';
    }
    final seule = r.uneSeuleNote.isEmpty
        ? ''
        : ' · ${r.uneSeuleNote.length} matière(s) avec une seule note';
    return r.moyenne == null
        ? 'Aucune note comptée'
        : 'Moyenne ${centiemesTexte(r.moyenne)} · total '
              '${centiemesTexte(r.total)}$mention$seule';
  }
}
