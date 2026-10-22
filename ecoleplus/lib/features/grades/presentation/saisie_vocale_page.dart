import 'dart:async';

import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/dictee/dictee.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/grades/domain/note_dictee.dart';
import 'package:ecoleplus/features/grades/presentation/grades_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saisie vocale guidée : un élève à la fois, en grand. La note entendue
/// est affichée et n'est enregistrée qu'après « Confirmer » : un « quinze »
/// compris « cinq » se voit avant d'être gardé. Le clavier reste disponible.
class SaisieVocalePage extends ConsumerStatefulWidget {
  const new(this.classId, this.assessmentId, this.subjectId, {super.key});
  final String classId;
  final String assessmentId;
  final String subjectId;

  @override
  ConsumerState<SaisieVocalePage> createState() => _SaisieVocaleState();
}

class _SaisieVocaleState extends ConsumerState<SaisieVocalePage> {
  int? _index;
  bool _ecoute = false;
  String? _entendu;
  NoteEntendue? _proposee;
  String? _erreur;
  final _clavier = TextEditingController();

  /// Dictée en cours d'utilisation (arrêtée en quittant l'écran).
  Dictee? _dictee;

  @override
  void dispose() {
    final d = _dictee;
    if (d != null) unawaited(d.arreter());
    _clavier.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    _entendu = null;
    _proposee = null;
    _erreur = null;
    _clavier.clear();
  }

  Future<void> _ecouter(int bareme) async {
    final dictee = ref.read(dicteeProvider);
    _dictee = dictee;
    setState(() {
      _reinitialiser();
      _ecoute = true;
    });
    if (!await dictee.preparer()) {
      if (!mounted) return;
      setState(() {
        _ecoute = false;
        _erreur =
            'Le micro n’est pas disponible sur ce téléphone. '
            'Tapez la note au clavier.';
      });
      return;
    }
    await dictee.ecouter(
      surTexte: (t) {
        if (mounted) setState(() => _entendu = t);
      },
      surFin: (erreur) {
        if (!mounted) return;
        setState(() {
          _ecoute = false;
          if (erreur != null && (_entendu ?? '').isEmpty) {
            _erreur = erreur;
            return;
          }
          _proposer(_entendu ?? '', bareme);
        });
      },
    );
  }

  /// Vérifie ce qui a été dit (ou tapé) ; rien n'est encore enregistré.
  void _proposer(String texte, int bareme) {
    final n = noteDictee(texte);
    _proposee = null;
    _erreur = null;
    switch (n) {
      case null:
        _erreur = texte.trim().isEmpty
            ? 'Rien n’a été compris. Réessayez ou tapez la note.'
            : 'Pas compris : « $texte ». Réessayez ou tapez la note.';
      case ValeurEntendue(:final centiemes) when centiemes > bareme:
        _erreur =
            'Hors barème : ${centiemesTexte(centiemes)} refusé '
            '(la note ne peut pas dépasser ${centiemesTexte(bareme)}).';
      case _:
        _proposee = n;
    }
  }

  Future<void> _confirmer(AssessmentRow compo, StudentRow eleve) async {
    final n = _proposee;
    if (n == null) return;
    final ok = await avecMessage(context, () async {
      await ref
          .read(gradesRepositoryProvider)
          .enregistrerNote(
            composition: compo,
            studentId: eleve.id,
            subjectId: widget.subjectId,
            centiemes: n is ValeurEntendue ? n.centiemes : null,
            statut: n is AbsenceEntendue ? StatutNote.absent : StatutNote.note,
          );
      return true;
    });
    if (!(ok ?? false) || !mounted) return;
    setState(() {
      _reinitialiser();
      _index = (_index ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(donneesClasseProvider(widget.classId)).value;
    final compo = d?.compositions
        .where((c) => c.id == widget.assessmentId)
        .firstOrNull;
    final matiere = d?.matieres
        .where((m) => m.matiere.id == widget.subjectId)
        .firstOrNull;
    if (d == null || compo == null || matiere == null) {
      return const EcoleScaffold(
        title: 'Saisie vocale',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final notes = {
      for (final g in d.notes)
        if (g.assessmentId == compo.id && g.subjectId == widget.subjectId)
          g.studentId: g,
    };
    // Au départ : le premier élève sans note.
    final i = _index ??= () {
      final k = d.eleves.indexWhere((s) => !notes.containsKey(s.id));
      return k < 0 ? 0 : k;
    }();
    final bareme = (compo.maxScore * 100).round();
    final titre = '${matiere.matiere.name} — ${compo.label}';
    if (i >= d.eleves.length) {
      return EcoleScaffold(
        title: titre,
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const InfoMessage('Tous les élèves ont été vus.'),
            const SizedBox(height: 16),
            Text('${notes.length}/${d.eleves.length} notes saisies.'),
            const SizedBox(height: 16),
            BigButton(
              icon: Icons.replay,
              label: 'Revoir depuis le début',
              onPressed: () => setState(() {
                _reinitialiser();
                _index = 0;
              }),
            ),
          ],
        ),
      );
    }
    final eleve = d.eleves[i];
    final actuelle = notes[eleve.id];
    final grand = Theme.of(context).textTheme;
    final proposee = _proposee;
    return EcoleScaffold(
      title: titre,
      body: ListView(
        key: const Key('saisie-vocale'),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Élève ${i + 1} sur ${d.eleves.length} · note sur '
            '${centiemesTexte(bareme)}',
          ),
          const SizedBox(height: 8),
          Text(
            '${eleve.lastName} ${eleve.firstNames}',
            key: const Key('vocal-eleve'),
            style: grand.headlineMedium,
          ),
          if (actuelle != null)
            Text(
              actuelle.status == 'absent'
                  ? 'Déjà saisie : absent'
                  : 'Déjà saisie : '
                        '${centiemesTexte((actuelle.score! * 100).round())}',
            ),
          const SizedBox(height: 16),
          if (_ecoute)
            Text(
              _entendu == null ? 'J’écoute…' : '« $_entendu »',
              style: grand.titleLarge,
            ),
          if (proposee != null) ...[
            Text('Note comprise :', style: grand.titleMedium),
            Text(
              switch (proposee) {
                ValeurEntendue(:final centiemes) => centiemesTexte(centiemes),
                AbsenceEntendue() => 'Absent',
              },
              key: const Key('vocal-proposee'),
              style: grand.displayLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_entendu != null) Text('Entendu : « $_entendu »'),
            const SizedBox(height: 12),
            BigButton(
              key: const Key('vocal-confirmer'),
              icon: Icons.check,
              label: 'Confirmer',
              onPressed: () => _confirmer(compo, eleve),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('vocal-recommencer'),
              icon: const Icon(Icons.replay),
              label: const Text('Ce n’est pas ça : recommencer'),
              onPressed: () => setState(_reinitialiser),
            ),
          ],
          if (_erreur != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _erreur!,
                key: const Key('vocal-erreur'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (proposee == null && !_ecoute) ...[
            const SizedBox(height: 12),
            BigButton(
              key: const Key('vocal-parler'),
              icon: Icons.mic,
              label: 'Dire la note',
              onPressed: () => _ecouter(bareme),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('vocal-clavier'),
              controller: _clavier,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Ou tapez la note',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (v) => setState(() {
                _entendu = null;
                _proposer(v, bareme);
              }),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.person_off_outlined),
                label: const Text('Absent'),
                onPressed: () => setState(() {
                  _reinitialiser();
                  _proposee = const AbsenceEntendue();
                }),
              ),
              if (i > 0)
                TextButton(
                  onPressed: () => setState(() {
                    _reinitialiser();
                    _index = i - 1;
                  }),
                  child: const Text('Précédent'),
                ),
              TextButton(
                key: const Key('vocal-passer'),
                onPressed: () => setState(() {
                  _reinitialiser();
                  _index = i + 1;
                }),
                child: const Text('Passer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
