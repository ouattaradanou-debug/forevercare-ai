import 'dart:io';
import 'dart:typed_data';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/import/analyse_import.dart';
import 'package:ecoleplus/core/import/tableur.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/domain/import_enseignants.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/students/data/import_service.dart';
import 'package:ecoleplus/features/students/domain/import_eleves.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Choix du fichier à importer (remplacé dans les tests).
final choisirTableurProvider = Provider<Future<Uint8List?> Function()>(
  (ref) => () async {
    final r = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'csv'],
    );
    final chemin = r.isEmpty ? null : r.first.path;
    return chemin == null ? null : await File(chemin).readAsBytes();
  },
);

enum TypeImport { eleves, enseignants }

/// Import Excel : choix du fichier, rapport lisible, puis confirmation.
class ImportPage extends ConsumerStatefulWidget {
  const new(this.type, {super.key});
  final TypeImport type;

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  AnalyseImport? _analyse;
  String? _erreur;
  int? _importes;
  bool _occupe = false;

  bool get _eleves => widget.type == TypeImport.eleves;

  List<Colonne> get _colonnes => _eleves ? colonnesEleves : colonnesEnseignants;

  Future<void> _choisir(String schoolId, List<ClassRow> classes) async {
    final octets = await ref.read(choisirTableurProvider)();
    if (octets == null) return;
    setState(() {
      _occupe = true;
      _erreur = null;
      _analyse = null;
      _importes = null;
    });
    try {
      final lignes = lireTableur(octets);
      final connues = {for (final c in classes) normaliser(c.name)};
      final db = ref.read(databaseProvider);
      final Set<String> existants;
      if (_eleves) {
        final tous = await (db.select(
          db.students,
        )..where((s) => s.schoolId.equals(schoolId))).get();
        existants = {
          for (final s in tous) cleEleve(s.lastName, s.firstNames, s.birthDate),
        };
      } else {
        final tous = await (db.select(
          db.teachers,
        )..where((t) => t.schoolId.equals(schoolId))).get();
        existants = {
          for (final t in tous)
            cleEnseignant(t.lastName, t.firstNames, t.birthDate, t.matricule),
        };
      }
      final a = analyserImport(
        lignes,
        colonnes: _colonnes,
        valider: _eleves ? validerEleve(connues) : validerEnseignant(connues),
        cleDoublon: _eleves ? cleDoublonEleve : cleDoublonEnseignant,
        existants: existants,
      );
      setState(() => _analyse = a);
    } on TableurIllisible catch (e) {
      setState(() => _erreur = e.message);
    } on Object {
      setState(() => _erreur = 'Ce fichier n’a pas pu être lu.');
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _importer(
    String schoolId,
    String? yearId,
    List<ClassRow> classes,
  ) async {
    final a = _analyse!;
    setState(() => _occupe = true);
    final n = _eleves
        ? await importerEleves(
            ref.read(studentsRepositoryProvider),
            a,
            schoolId: schoolId,
            classes: classes,
          )
        : await importerEnseignants(
            ref.read(staffRepositoryProvider),
            a,
            schoolId: schoolId,
            yearId: yearId,
            classes: classes,
          );
    if (mounted) {
      setState(() {
        _occupe = false;
        _importes = n;
        _analyse = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    final classes = yearId == null
        ? const <ClassRow>[]
        : ref.watch(classesProvider(yearId)).value ?? const <ClassRow>[];
    final quoi = _eleves ? 'élèves' : 'enseignants';
    final a = _analyse;
    return EcoleScaffold(
      title: 'Importer des $quoi',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Fichier Excel (.xlsx) ou CSV. La première ligne contient les '
            'titres des colonnes, une ligne par '
            '${_eleves ? 'élève' : 'enseignant'}. '
            'Colonnes reconnues :',
          ),
          const SizedBox(height: 8),
          for (final c in _colonnes)
            Text('• ${c.libelle}${c.obligatoire ? ' (obligatoire)' : ''}'),
          if (_eleves)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'La classe doit déjà exister (même nom, ex. « CM1 A »). Les '
                'lignes vides sont ignorées, les doublons écartés.',
              ),
            ),
          const SizedBox(height: 16),
          BigButton(
            icon: Icons.upload_file,
            label: 'Choisir le fichier',
            onPressed: _occupe
                ? null
                : () => _choisir(session.schoolId, classes),
          ),
          if (_occupe) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_erreur != null) InfoMessage(_erreur!, icon: Icons.error_outline),
          if (_importes != null)
            InfoMessage(
              '$_importes fiche${_importes! > 1 ? 's' : ''} '
              'créée${_importes! > 1 ? 's' : ''}. Elles seront envoyées au '
              'serveur à la prochaine synchronisation.',
              icon: Icons.check_circle_outline,
            ),
          if (a != null) ...[
            const SizedBox(height: 16),
            const SectionTitle('Rapport'),
            Text(
              a.valides.isEmpty
                  ? 'Rien à importer : toutes les lignes sont déjà '
                        'enregistrées ou à corriger.'
                  : '${a.valides.length} $quoi prêt${_s(a.valides.length)} à '
                        'importer.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (a.erreurs.isNotEmpty)
              _Liste(
                titre:
                    '${a.erreurs.length} ligne${_s(a.erreurs.length)} à '
                    'corriger dans le fichier (non '
                    'importée${_s(a.erreurs.length)}) :',
                lignes: a.erreurs,
                couleur: Theme.of(context).colorScheme.error,
              ),
            if (a.doublons.isNotEmpty)
              _Liste(
                titre:
                    '${a.doublons.length} doublon${_s(a.doublons.length)} '
                    'écarté${_s(a.doublons.length)} :',
                lignes: a.doublons,
              ),
            if (a.vides > 0)
              Text(
                '${a.vides} ligne${_s(a.vides)} vide${_s(a.vides)} '
                'ignorée${_s(a.vides)}.',
              ),
            if (a.colonnesIgnorees.isNotEmpty)
              Text(
                'Colonnes non utilisées : ${a.colonnesIgnorees.join(', ')}.',
              ),
            const SizedBox(height: 16),
            BigButton(
              icon: Icons.check,
              label: 'Importer ${a.valides.length} $quoi',
              onPressed: _occupe || a.valides.isEmpty
                  ? null
                  : () => _importer(session.schoolId, yearId, classes),
            ),
          ],
        ],
      ),
    );
  }
}

String _s(int n) => n > 1 ? 's' : '';

class _Liste extends StatelessWidget {
  const new({required this.titre, required this.lignes, this.couleur});
  final String titre;
  final List<Remarque> lignes;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre, style: TextStyle(color: couleur)),
        for (final l in lignes.take(50)) Text('• $l'),
        if (lignes.length > 50) Text('… et ${lignes.length - 50} autres.'),
      ],
    ),
  );
}
