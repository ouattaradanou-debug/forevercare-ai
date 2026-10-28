import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/documents/data/documents_repository.dart';
import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/documents/pdf/pdf_documents.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => DocumentsRepository(ref.watch(localStoreProvider)),
);

/// Code de la fiche de scolarité dans le choix de l'élève.
const codeB4 = 'B4';

/// Tous les documents du directeur sous un seul bouton (A17) : Enseignants,
/// Élèves, École.
class DocumentsPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    String? etat(String code) => yearId == null
        ? null
        : texteEtat(ref.watch(formulaireProvider((yearId, code))).value);
    Widget ligne(
      String titre,
      String route, {
      String? sousTitre,
      IconData icone = Icons.description_outlined,
    }) => Card(
      child: ListTile(
        key: Key('doc-$route'),
        leading: Icon(icone),
        title: Text(titre),
        subtitle: sousTitre == null ? null : Text(sousTitre),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
    return EcoleScaffold(
      title: 'Documents',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Les documents se remplissent tout seuls à partir des fiches. '
            'Vérifiez, puis imprimez ou partagez.',
          ),
          const SectionTitle('Enseignants'),
          ligne(
            'Fiche de renseignement du personnel (B1)',
            '/registres/B1',
            sousTitre: etat('B1'),
          ),
          ligne(
            'Registre du personnel enseignant (B3)',
            '/registres/B3',
            sousTitre: etat('B3'),
          ),
          ligne(
            CodeDocument.priseService.titre,
            '/documents/choisir/${CodeDocument.priseService.code}',
            icone: Icons.badge_outlined,
          ),
          const SectionTitle('Élèves'),
          ligne(
            'Registre matricule (B2)',
            '/registres/B2',
            sousTitre: etat('B2'),
          ),
          ligne(
            'Fiche de scolarité (B4)',
            '/documents/choisir/$codeB4',
            icone: Icons.school_outlined,
          ),
          for (final c in const [
            CodeDocument.certificatScolarite,
            CodeDocument.attestationNiveau,
            CodeDocument.nonRedevance,
          ])
            ligne(
              c.titre,
              '/documents/choisir/${c.code}',
              icone: Icons.school_outlined,
            ),
          ligne(
            'Bulletins',
            '/notes',
            sousTitre: 'Par classe, dans « Notes et classement »',
            icone: Icons.grading,
          ),
          const SectionTitle('École'),
          ligne(
            'Programme d’activités (B6)',
            '/programme/B6',
            sousTitre: etat('B6'),
            icone: Icons.event_note,
          ),
          ligne(
            'Bilan annuel des activités (B7)',
            '/programme/B7',
            sousTitre: etat('B7'),
            icone: Icons.fact_check_outlined,
          ),
          ligne(
            'Mes formulaires de l’année',
            '/formulaires',
            sousTitre: 'Où en est chaque formulaire',
            icone: Icons.checklist,
          ),
        ],
      ),
    );
  }
}

/// État d'un formulaire en une phrase : « Complet • version finale 2
/// verrouillée ».
String texteEtat(OfficialFormRow? f) {
  final etat = etats[f?.status ?? 'a_completer'] ?? 'À compléter';
  final v = f?.lockedVersion;
  return v == null ? etat : '$etat • version finale $v verrouillée';
}

/// « Mes formulaires de l'année » (17.3) : l'état de chaque formulaire.
class FormulairesAnneePage extends ConsumerWidget {
  const new({super.key});

  static const formulaires = [
    ('B1', 'Fiche de renseignement du personnel', '/registres/B1'),
    ('B2', 'Registre matricule des élèves', '/registres/B2'),
    ('B3', 'Registre du personnel enseignant', '/registres/B3'),
    ('B6', 'Programme d’activités', '/programme/B6'),
    ('B7', 'Bilan annuel des activités', '/programme/B7'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = school?.currentSchoolYearId;
    if (yearId == null) {
      return const EcoleScaffold(
        title: 'Mes formulaires de l’année',
        body: InfoMessage('Année scolaire introuvable.'),
      );
    }
    return EcoleScaffold(
      title: 'Mes formulaires de l’année',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Les fiches de scolarité (B4) se trouvent sur la fiche de '
            'chaque élève.',
          ),
          const SizedBox(height: 8),
          for (final (code, titre, route) in formulaires)
            Builder(
              builder: (context) {
                final f = ref.watch(formulaireProvider((yearId, code))).value;
                final fini = f?.status == 'signe_archive';
                return Card(
                  child: ListTile(
                    key: Key('formulaire-$code'),
                    leading: Icon(
                      f?.lockedVersion != null
                          ? Icons.lock
                          : fini
                          ? Icons.task_alt
                          : Icons.description_outlined,
                    ),
                    title: Text('$code — $titre'),
                    subtitle: Text(texteEtat(f)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(route),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Choix de l'élève ou de l'enseignant, avec recherche.
class ChoisirPersonnePage extends ConsumerStatefulWidget {
  const new(this.code, {super.key});

  /// Code du document ([CodeDocument.code]) ou [codeB4].
  final String code;

  @override
  ConsumerState<ChoisirPersonnePage> createState() => _ChoisirState();
}

class _ChoisirState extends ConsumerState<ChoisirPersonnePage> {
  String _recherche = '';

  static String _sansAccent(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ùûü]'), 'u')
      .replaceAll('ç', 'c');

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final doc = CodeDocument.depuis(widget.code);
    final enseignants = doc?.pourEnseignant ?? false;
    final titre = widget.code == codeB4
        ? 'Fiche de scolarité (B4)'
        : doc?.titre ?? 'Document';
    final yearId = school?.currentSchoolYearId;
    final personnes = <(String, String, String?)>[
      if (enseignants)
        for (final t
            in ref.watch(teachersProvider(session.schoolId)).value ??
                const <TeacherRow>[])
          (t.id, '${t.lastName} ${t.firstNames}', t.matricule)
      else if (yearId != null)
        for (final e
            in ref
                    .watch(elevesProvider((session.schoolId, yearId, true)))
                    .value ??
                const <EleveDansAnnee>[])
          (
            e.eleve.id,
            '${e.eleve.lastName} ${e.eleve.firstNames}',
            e.classe?.name ?? (e.eleve.exitDate != null ? 'parti(e)' : null),
          ),
    ];
    final q = _sansAccent(_recherche.trim());
    final visibles = [
      for (final p in personnes)
        if (q.isEmpty || _sansAccent('${p.$2} ${p.$3 ?? ''}').contains(q)) p,
    ];
    return EcoleScaffold(
      title: titre,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('recherche-personne'),
            decoration: InputDecoration(
              labelText: enseignants
                  ? 'Rechercher un enseignant'
                  : 'Rechercher un élève',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _recherche = v),
          ),
          const SizedBox(height: 8),
          if (visibles.isEmpty) const InfoMessage('Personne à afficher.'),
          for (final (id, nom, detail) in visibles)
            ListTile(
              key: Key('personne-$id'),
              title: Text(nom),
              subtitle: detail == null ? null : Text(detail),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(
                widget.code == codeB4
                    ? '/eleves/$id/fiche'
                    : '/documents/${widget.code}/$id',
              ),
            ),
        ],
      ),
    );
  }
}

/// Un document pour une personne : ce qui manque, réglages (lieu, date,
/// niveau, format), aperçu et impression, partage. Journalisé.
class DocumentPage extends ConsumerStatefulWidget {
  const new(this.code, this.personneId, {super.key});
  final CodeDocument code;
  final String personneId;

  @override
  ConsumerState<DocumentPage> createState() => _DocumentState();
}

class _DocumentState extends ConsumerState<DocumentPage> {
  late Future<DocumentDirecteur?> _doc = _charger();
  String? _lieu;
  String? _date;
  String? _niveau;
  bool _court = false;
  bool _occupe = false;

  Future<DocumentDirecteur?> _charger() {
    final session = ref.read(sessionProvider).value!;
    return ref
        .read(documentsRepositoryProvider)
        .document(
          widget.code,
          session.schoolId,
          widget.personneId,
          lieu: _lieu,
          date: _date,
          niveau: _niveau,
          court: _court,
        );
  }

  void _recharger() {
    final doc = _charger();
    setState(() {
      _doc = doc;
    });
  }

  Future<void> _sortir({required bool partager}) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final d = await _charger();
      if (d == null) return false;
      final pdf = await pdfDocumentDirecteur(
        await ref.read(policesPdfProvider.future),
        d,
      );
      final qui = d.eleve?.nom ?? d.enseignant?.nom ?? '';
      final nom = '${widget.code.titre}_$qui'.replaceAll(
        RegExp(r'[^\p{L}\p{N}\-]+', unicode: true),
        '_',
      );
      final sortie = ref.read(sortiePdfProvider);
      await (partager ? sortie.partager : sortie.imprimer)(pdf, '$nom.pdf');
      final session = ref.read(sessionProvider).value!;
      await ref
          .read(documentsRepositoryProvider)
          .journaliser(widget.code, session.schoolId, widget.personneId);
      return true;
    });
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: widget.code.titre,
    body: FutureBuilder<DocumentDirecteur?>(
      future: _doc,
      builder: (context, snap) {
        final d = snap.data;
        if (d == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final manques = manquesDocument(
          widget.code,
          signataire: d.signataire,
          eleve: d.eleve,
          enseignant: d.enseignant,
        );
        return ListView(
          key: const Key('document'),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              d.eleve?.nom ?? d.enseignant?.nom ?? '',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (d.eleve?.classe != null) Text('Classe : ${d.eleve!.classe}'),
            if (manques.isNotEmpty) ...[
              const SectionTitle('À compléter (sinon imprimé en pointillés)'),
              Text(manques.join(', '), key: const Key('manques')),
            ],
            const SectionTitle('Avant d’imprimer'),
            if (widget.code == CodeDocument.certificatScolarite)
              SegmentedButton<bool>(
                key: const Key('format-certificat'),
                segments: const [
                  ButtonSegment(value: false, label: Text('Page entière')),
                  ButtonSegment(value: true, label: Text('Demi-page')),
                ],
                selected: {_court},
                onSelectionChanged: (s) {
                  _court = s.first;
                  _recharger();
                },
              ),
            if (widget.code == CodeDocument.attestationNiveau)
              AutoSaveField(
                key: const Key('niveau'),
                label: 'A le niveau de la classe de',
                initial: d.niveau ?? d.eleve?.niveau,
                onSave: (v) async {
                  _niveau = v;
                  _recharger();
                },
              ),
            AutoSaveField(
              key: const Key('lieu'),
              label: 'Fait à',
              initial: d.lieu,
              onSave: (v) async {
                _lieu = v;
                _recharger();
              },
            ),
            AutoSaveDateField(
              label: 'Le',
              initial: _isoDepuis(d.date),
              onSave: (v) async {
                _date = v == null ? null : _jjmmaaaa(v);
                _recharger();
              },
            ),
            if (widget.code == CodeDocument.nonRedevance)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Les impayés seront vérifiés ici quand le module Finances '
                  'sera actif (un avertissement, vous décidez).',
                ),
              ),
            const SizedBox(height: 16),
            BigButton(
              key: const Key('document-imprimer'),
              icon: Icons.print,
              label: 'Aperçu et impression',
              onPressed: _occupe ? null : () => _sortir(partager: false),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('document-partager'),
              icon: const Icon(Icons.share),
              label: const Text('Partager le PDF'),
              onPressed: _occupe ? null : () => _sortir(partager: true),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chaque document délivré est inscrit au journal d’activité.',
            ),
          ],
        );
      },
    ),
  );

  static String? _isoDepuis(String? jjmmaaaa) {
    final p = jjmmaaaa?.split('/');
    return p == null || p.length != 3 ? null : '${p[2]}-${p[1]}-${p[0]}';
  }

  static String _jjmmaaaa(String iso) {
    final p = iso.split('-');
    return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
  }
}
