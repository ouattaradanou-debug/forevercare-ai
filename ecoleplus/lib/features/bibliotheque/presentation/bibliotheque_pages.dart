import 'dart:async';
import 'dart:io';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/app/router.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/bibliotheque/data/bibliotheque_repository.dart';
import 'package:ecoleplus/features/bibliotheque/data/documents_en_ligne.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:ecoleplus/features/forms/presentation/apercu_pdf_page.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

/// Part envoyée, en pour cent.
int pourcentEnvoi(DocumentUploadRow e) =>
    (e.sentBytes * 100 / (e.sizeBytes == 0 ? 1 : e.sizeBytes)).round();

final documentsEnLigneProvider = Provider<DocumentsEnLigne>(
  (ref) => SupabaseDocumentsEnLigne(ref.watch(supabaseClientProvider)),
);

/// Choix de fichiers (plusieurs à la fois). Remplacé dans les tests.
final choisirFichiersProvider =
    Provider<Future<List<FichierChoisi>> Function()>(
      (ref) => () async {
        final r = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: const [
            'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'odt', 'ods', //
            'txt', 'jpg', 'jpeg', 'png',
          ],
        );
        return [
          for (final f in r)
            if (f.path != null) FichierChoisi(f.name, f.path!),
        ];
      },
    );

final StreamProviderFamily<List<DocumentRow>, (String, Espace, bool)>
documentsProvider = StreamProvider.family(
  (ref, k) => ref
      .watch(bibliothequeRepositoryProvider)
      .watchDocuments(k.$1, k.$2, corbeille: k.$3),
);

final StreamProviderFamily<DocumentRow?, String> documentProvider =
    StreamProvider.family(
      (ref, id) => ref.watch(bibliothequeRepositoryProvider).watchDocument(id),
    );

final StreamProvider<Map<String, DocumentUploadRow>> envoisProvider =
    StreamProvider(
      (ref) => ref
          .watch(bibliothequeRepositoryProvider)
          .watchEnvois()
          .map((l) => {for (final e in l) e.documentId: e}),
    );

final StreamProvider<Map<String, DocumentFileRow>> fichiersLocauxProvider =
    StreamProvider(
      (ref) => ref
          .watch(bibliothequeRepositoryProvider)
          .watchFichiers()
          .map((l) => {for (final f in l) f.documentId: f}),
    );

/// La personne gère cet espace (directeur ; délégué « archives » pour les
/// archives).
bool gereEspace(WidgetRef ref, Espace e) {
  final droits = ref.watch(mesDroitsProvider);
  final role = ref.watch(sessionProvider).value?.role;
  return e == Espace.archives
      ? droits.contains('archives')
      : role == 'directeur';
}

/// Ouvre un document : aperçu des PDF et des images dans l'application,
/// sinon dans l'application de lecture du téléphone (Word, Excel…).
Future<void> ouvrirDocument(
  BuildContext context,
  WidgetRef ref,
  DocumentRow d,
) => avecMessage(context, () async {
  final repo = ref.read(bibliothequeRepositoryProvider);
  File f;
  try {
    f = await repo.obtenir(d);
  } on Object {
    throw const UserMessage(
      'Ce document n’est pas sur le téléphone : connectez-vous à Internet '
      'pour l’ouvrir, ou touchez « Garder sur mon téléphone » quand vous êtes '
      'en ligne.',
    );
  }
  final octets = await f.readAsBytes();
  final nom = d.originalName ?? '${d.title}.pdf';
  if (d.mimeType == 'application/pdf') {
    await ref
        .read(routerProvider)
        .push('/apercu', extra: ApercuPdf(octets, nom));
  } else if (d.mimeType?.startsWith('image/') ?? false) {
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EcoleScaffold(
          title: d.title,
          showSync: false,
          body: InteractiveViewer(
            maxScale: 6,
            child: Center(child: Image.memory(octets)),
          ),
        ),
      ),
    );
  } else {
    final type = d.mimeType ?? 'application/octet-stream';
    if (await ref.read(ouvrirFichierProvider)(f.path, type)) return;
    // Aucune application de lecture pour ce type de fichier.
    if (!context.mounted) return;
    final partager = await confirmer(
      context,
      titre: 'Aucune application pour l’ouvrir',
      message:
          'Ce téléphone n’a pas d’application pour lire ce type de fichier '
          '($nom). Installez par exemple WPS Office ou Microsoft Word, ou '
          'partagez le fichier.',
      bouton: 'Partager',
    );
    if (partager) await ref.read(sortieFichierProvider)(octets, nom, type);
  }
});

/// Ouvre un fichier du téléphone dans l'application de lecture choisie
/// par le téléphone (Word, WPS Office, Excel…) ; faux si aucune ne sait le
/// lire. Remplacé dans les tests.
final ouvrirFichierProvider =
    Provider<Future<bool> Function(String chemin, String type)>(
      (ref) =>
          (chemin, type) async =>
              (await OpenFilex.open(chemin, type: type)).type ==
              ResultType.done,
    );

/// Bibliothèque pédagogique ou archives administratives.
class BibliothequePage extends ConsumerStatefulWidget {
  const new(this.espace, {this.corbeille = false, super.key});
  final Espace espace;
  final bool corbeille;

  @override
  ConsumerState<BibliothequePage> createState() => _BibliothequeState();
}

class _BibliothequeState extends ConsumerState<BibliothequePage> {
  String _recherche = '';

  /// « tout », « commun » ou un identifiant de classe.
  String _filtre = 'tout';
  List<Trouvaille>? _trouvailles;
  bool _cherche = false;

  Future<void> _chercherTexte(String schoolId) async {
    if (_recherche.trim().length < 2) return;
    setState(() => _cherche = true);
    final r = await avecMessage(
      context,
      () => ref.read(documentsEnLigneProvider).rechercher(schoolId, _recherche),
    );
    if (mounted) {
      setState(() {
        _cherche = false;
        _trouvailles = r;
      });
    }
  }

  Future<void> _ajouter(SchoolRow ecole) async {
    final fichiers = await ref.read(choisirFichiersProvider)();
    if (fichiers.isEmpty || !mounted) return;
    await context.push('/${widget.espace.code}/ajout', extra: fichiers);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    if (ecole == null) {
      return EcoleScaffold(title: widget.espace.titre, body: const SizedBox());
    }
    final docs =
        ref
            .watch(
              documentsProvider((ecole.id, widget.espace, widget.corbeille)),
            )
            .value ??
        const [];
    final envois = ref.watch(envoisProvider).value ?? const {};
    final locaux = ref.watch(fichiersLocauxProvider).value ?? const {};
    final gere = gereEspace(ref, widget.espace);
    final enseignant = session.role == 'enseignant';
    final peutAjouter =
        !widget.corbeille &&
        (gere ||
            (widget.espace == Espace.bibliotheque &&
                enseignant &&
                ecole.libraryTeacherMode != 'interdit'));
    final yearId = ecole.currentSchoolYearId;
    final classes = yearId == null
        ? const <ClassRow>[]
        : ref.watch(classesProvider(yearId)).value ?? const <ClassRow>[];
    final nomsClasses = {for (final c in classes) c.id: c.name};
    final q = sansAccents(_recherche.trim());
    final visibles = [
      for (final d in docs)
        if ((q.isEmpty || sansAccents(d.texteRecherche).contains(q)) &&
            switch (_filtre) {
              'tout' => true,
              'commun' => d.isCommon,
              final id => d.classes.contains(id),
            })
          d,
    ];
    final parId = {for (final d in docs) d.id: d};
    final titre = widget.corbeille
        ? 'Corbeille — ${widget.espace.titre.toLowerCase()}'
        : widget.espace.titre;
    return EcoleScaffold(
      title: titre,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!widget.corbeille) ...[
            _Occupation(ecole: ecole),
            if (widget.espace == Espace.archives)
              const InfoMessage(
                'Archives : réservées au directeur et aux personnes '
                'désignées ; jamais utilisées par l’assistant IA.',
                icon: Icons.lock_outline,
              ),
          ],
          TextField(
            key: const Key('recherche-documents'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: 'Rechercher (titre, type, mots-clés)',
              border: const OutlineInputBorder(),
              suffixIcon: _recherche.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer',
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _recherche = '';
                        _trouvailles = null;
                      }),
                    ),
            ),
            onChanged: (v) => setState(() {
              _recherche = v;
              _trouvailles = null;
            }),
          ),
          if (_recherche.trim().length >= 2 && !widget.corbeille)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('chercher-texte'),
                icon: const Icon(Icons.manage_search),
                label: Text('Chercher « ${_recherche.trim()} » dans le texte'),
                onPressed: _cherche ? null : () => _chercherTexte(ecole.id),
              ),
            ),
          if (_cherche) const LinearProgressIndicator(),
          if (_trouvailles != null) ...[
            SectionTitle(
              _trouvailles!.isEmpty
                  ? 'Rien trouvé dans le texte'
                  : 'Trouvé dans le texte (${_trouvailles!.length})',
            ),
            for (final t in _trouvailles!)
              if (parId[t.documentId] case final d?)
                Card(
                  child: ListTile(
                    key: Key('trouve-${t.documentId}-${t.page}'),
                    title: Text(d.title),
                    subtitle: Text(
                      [
                        if (t.page != null) 'Page ${t.page}',
                        t.extrait,
                      ].join(' : '),
                    ),
                    onTap: () => context.push('/document/${d.id}'),
                  ),
                ),
          ],
          if (widget.espace == Espace.bibliotheque && !widget.corbeille)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                children: [
                  for (final (v, l) in [
                    ('tout', 'Tout'),
                    ('commun', 'Commun à l’école'),
                    for (final c in classes) (c.id, c.name),
                  ])
                    ChoiceChip(
                      label: Text(l),
                      selected: _filtre == v,
                      onSelected: (_) => setState(() => _filtre = v),
                    ),
                ],
              ),
            ),
          if (envois.isNotEmpty && !widget.corbeille)
            Card(
              key: const Key('envois-en-cours'),
              child: ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: Text(
                  '${envois.length} fichier${envois.length > 1 ? 's' : ''} '
                  'à envoyer',
                ),
                subtitle: const Text(
                  'L’envoi reprend tout seul là où il s’est arrêté dès que '
                  'le réseau revient.',
                ),
                trailing: TextButton(
                  onPressed: () => ref.read(syncEngineProvider).syncNow(),
                  child: const Text('Envoyer'),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '${visibles.length} document${visibles.length > 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          for (final d in visibles)
            Card(
              child: ListTile(
                key: Key('document-${d.id}'),
                leading: Icon(_icone(d.mimeType)),
                title: Text(d.title),
                subtitle: Text(
                  [
                    ?d.docType,
                    if (d.isCommon) 'Commun',
                    for (final c in d.classes) ?nomsClasses[c],
                    if (d.sizeBytes != null) tailleTexte(d.sizeBytes!),
                    if (!d.approved) 'En attente de validation',
                    if (envois[d.id] case final e?)
                      'Envoi ${pourcentEnvoi(e)} %',
                  ].join(' · '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (locaux[d.id]?.pinned ?? false)
                      const Icon(Icons.push_pin, size: 18)
                    else if (locaux[d.id] != null)
                      const Icon(Icons.phone_android, size: 18),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => context.push('/document/${d.id}'),
              ),
            ),
          if (visibles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucun document.'),
            ),
          const SizedBox(height: 16),
          if (peutAjouter)
            BigButton(
              icon: Icons.upload_file,
              label: 'Ajouter des documents',
              onPressed: () => _ajouter(ecole),
            ),
          if (!widget.corbeille) ...[
            const SizedBox(height: 12),
            if (gere)
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Corbeille'),
                onPressed: () =>
                    context.push('/${widget.espace.code}/corbeille'),
              ),
            const _EspaceLocal(),
            if (widget.espace == Espace.bibliotheque &&
                session.role == 'directeur')
              ChoiceField(
                label: 'Ajout de documents par les enseignants',
                value: ecole.libraryTeacherMode,
                options: const {
                  'validation': 'Oui, après ma validation',
                  'libre': 'Oui, sans validation',
                  'interdit': 'Non',
                },
                onChanged: (v) {
                  if (v != null) {
                    unawaited(
                      ref.read(schoolRepositoryProvider).updateSchool(
                        ecole.id,
                        {'library_teacher_mode': v},
                      ),
                    );
                  }
                },
              ),
          ],
        ],
      ),
    );
  }

  static IconData _icone(String? mime) => switch (mime) {
    'application/pdf' => Icons.picture_as_pdf_outlined,
    final m? when m.startsWith('image/') => Icons.image_outlined,
    final m? when m.contains('sheet') || m.contains('excel') =>
      Icons.table_chart_outlined,
    final m? when m.contains('presentation') || m.contains('powerpoint') =>
      Icons.slideshow_outlined,
    _ => Icons.description_outlined,
  };
}

/// « 60 % utilisé » (serveur en ligne ; sinon estimation du catalogue).
class _Occupation extends ConsumerWidget {
  const new({required this.ecole});
  final SchoolRow ecole;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref
        .read(documentsEnLigneProvider)
        .occupation(ecole.id)
        .catchError(
          (Object _) async => Occupation(
            utilise: await ref
                .read(bibliothequeRepositoryProvider)
                .espaceCatalogue(ecole.id),
            quota: ecole.storageQuotaBytes,
          ),
        ),
    builder: (context, snap) {
      final o = snap.data;
      if (o == null) return const LinearProgressIndicator();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${o.pourcent} % utilisé (${tailleTexte(o.utilise)} sur '
              '${tailleTexte(o.quota)})',
              key: const Key('occupation'),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (o.pourcent / 100).clamp(0, 1),
              color: o.pourcent >= 90 ? Colors.red : null,
            ),
          ],
        ),
      );
    },
  );
}

/// Espace des documents sur ce téléphone, avec « Libérer ».
class _EspaceLocal extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locaux = ref.watch(fichiersLocauxProvider).value ?? const {};
    final total = locaux.values.fold<int>(0, (s, f) => s + f.sizeBytes);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.phone_android),
      title: Text('Sur ce téléphone : ${tailleTexte(total)}'),
      subtitle: const Text(
        'Les documents épinglés restent ; les autres peuvent être retirés '
        'du téléphone (ils restent sur le serveur).',
      ),
      trailing: TextButton(
        key: const Key('liberer'),
        onPressed: total == 0
            ? null
            : () async {
                final libere = await ref
                    .read(bibliothequeRepositoryProvider)
                    .liberer();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${tailleTexte(libere)} libérés.')),
                  );
                }
              },
        child: const Text('Libérer'),
      ),
    );
  }
}

/// Fiche à remplir pour un lot de fichiers.
class AjoutDocumentsPage extends ConsumerStatefulWidget {
  const new(this.espace, this.fichiers, {super.key});
  final Espace espace;
  final List<FichierChoisi> fichiers;

  @override
  ConsumerState<AjoutDocumentsPage> createState() => _AjoutState();
}

class _AjoutState extends ConsumerState<AjoutDocumentsPage> {
  final _titre = TextEditingController();
  final _source = TextEditingController();
  final _motsCles = TextEditingController();
  bool _commun = false;
  final _classes = <String>{};
  String? _type;
  bool _sensible = false;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    if (widget.fichiers.length == 1) {
      _titre.text = titreDepuisNom(widget.fichiers.single.nom);
    }
  }

  @override
  void dispose() {
    _titre.dispose();
    _source.dispose();
    _motsCles.dispose();
    super.dispose();
  }

  Future<void> _ajouter(SchoolRow ecole) async {
    setState(() => _occupe = true);
    final r = await avecMessage(
      context,
      () => ref
          .read(bibliothequeRepositoryProvider)
          .ajouter(
            schoolId: ecole.id,
            espace: widget.espace,
            fichiers: widget.fichiers,
            gestionnaire: gereEspace(ref, widget.espace),
            fiche: FicheDocument(
              titre: _titre.text,
              commun: _commun,
              classes: [..._classes],
              type: _type,
              anneeId: ecole.currentSchoolYearId,
              source: _source.text.trim().isEmpty ? null : _source.text.trim(),
              motsCles: [
                for (final m in _motsCles.text.split(','))
                  if (m.trim().isNotEmpty) m.trim(),
              ],
              sensible: _sensible,
            ),
          ),
    );
    if (!mounted) return;
    setState(() => _occupe = false);
    if (r == null) return;
    unawaited(ref.read(syncEngineProvider).syncNow());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${r.ajoutes} document(s) ajouté(s)'
          '${r.doublons.isEmpty ? '' : ' ; ${r.doublons.length} déjà '
                    'présent(s) : ${r.doublons.join(', ')}'}.',
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    if (ecole == null) return const EcoleScaffold(title: '', body: SizedBox());
    final gere = gereEspace(ref, widget.espace);
    final bibliotheque = widget.espace == Espace.bibliotheque;
    final yearId = ecole.currentSchoolYearId;
    final classes = yearId == null
        ? const <ClassRow>[]
        : ref.watch(classesProvider(yearId)).value ?? const <ClassRow>[];
    final n = widget.fichiers.length;
    return EcoleScaffold(
      title: 'Ajouter $n document${n > 1 ? 's' : ''}',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoMessage(avertissementAjout, icon: Icons.warning_amber),
          const InfoMessage(rappelDroitAuteur, icon: Icons.copyright),
          if (!gere)
            const InfoMessage(
              'Vos documents seront visibles par les autres après validation '
              'du directeur.',
            ),
          const SizedBox(height: 8),
          if (n == 1)
            TextField(
              key: const Key('titre-document'),
              controller: _titre,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            )
          else
            Text(
              '$n fichiers : le titre de chacun sera son nom (modifiable '
              'ensuite).',
            ),
          if (bibliotheque) ...[
            if (gere)
              SwitchListTile(
                key: const Key('commun'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Commun à toute l’école'),
                value: _commun,
                onChanged: (v) => setState(() => _commun = v),
              ),
            if (!_commun) ...[
              const Text('Pour quelle(s) classe(s) ?'),
              Wrap(
                spacing: 6,
                children: [
                  for (final c in classes)
                    FilterChip(
                      label: Text(c.name),
                      selected: _classes.contains(c.id),
                      onSelected: (v) => setState(
                        () => v ? _classes.add(c.id) : _classes.remove(c.id),
                      ),
                    ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 8),
          const Text('Type'),
          Wrap(
            spacing: 6,
            children: [
              for (final t in bibliotheque ? typesBibliotheque : typesArchives)
                ChoiceChip(
                  label: Text(t),
                  selected: _type == t,
                  onSelected: (v) => setState(() => _type = v ? t : null),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _source,
            decoration: const InputDecoration(
              labelText: 'Source ou auteur (facultatif)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _motsCles,
            decoration: const InputDecoration(
              labelText: 'Mots-clés, séparés par des virgules (facultatif)',
              border: OutlineInputBorder(),
            ),
          ),
          if (bibliotheque)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Document sensible (jamais pour l’IA)'),
              value: _sensible,
              onChanged: (v) => setState(() => _sensible = v),
            ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.check,
            label: 'Ajouter',
            onPressed:
                _occupe ||
                    (bibliotheque && !_commun && _classes.isEmpty && !gere)
                ? null
                : () => _ajouter(ecole),
          ),
          if (_occupe) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

/// Fiche d'un document : ouvrir, garder sur le téléphone, indexation, IA,
/// validation, corbeille.
class FicheDocumentPage extends ConsumerWidget {
  const new(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(documentProvider(id)).value;
    final locaux = ref.watch(fichiersLocauxProvider).value ?? const {};
    if (d == null) {
      return const EcoleScaffold(
        title: 'Document',
        body: InfoMessage('Document introuvable.'),
      );
    }
    final espace = Espace.depuis(d.space);
    final gere = gereEspace(ref, espace);
    final uid = ref.watch(sessionProvider).value?.userId;
    final modifiable = gere || (d.uploadedBy == uid && !d.approved);
    final repo = ref.read(bibliothequeRepositoryProvider);
    final local = locaux[d.id];
    Future<void> save(String col, Object? v) => repo.modifier(d.id, {col: v});
    return EcoleScaffold(
      title: d.title,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!d.approved)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                leading: const Icon(Icons.hourglass_top),
                title: const Text('En attente de validation du directeur'),
                trailing:
                    espace == Espace.bibliotheque &&
                        ref.watch(sessionProvider).value?.role == 'directeur'
                    ? FilledButton(
                        key: const Key('valider-document'),
                        onPressed: () => repo.valider(d.id),
                        child: const Text('Valider'),
                      )
                    : null,
              ),
            ),
          BigButton(
            icon: Icons.open_in_new,
            label: 'Ouvrir',
            onPressed: () => ouvrirDocument(context, ref, d),
          ),
          SwitchListTile(
            key: const Key('epingler'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Garder sur mon téléphone'),
            subtitle: Text(
              local == null
                  ? 'Pas encore sur ce téléphone.'
                  : 'Sur ce téléphone (${tailleTexte(local.sizeBytes)}) : '
                        's’ouvre sans Internet.',
            ),
            value: local?.pinned ?? false,
            onChanged: (v) =>
                avecMessage(context, () => repo.epingler(d, garder: v)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.text_snippet_outlined),
            title: Text(texteIndexation(d)),
            subtitle: d.indexStatus == 'echec' && d.indexError != null
                ? Text(d.indexError!)
                : null,
          ),
          const SectionTitle('Fiche'),
          if (modifiable) ...[
            AutoSaveField(
              key: ValueKey('titre-${d.id}'),
              label: 'Titre',
              initial: d.title,
              onSave: (v) async {
                if ((v ?? '').trim().isNotEmpty) await save('title', v!.trim());
              },
            ),
            AutoSaveField(
              key: ValueKey('type-${d.id}'),
              label: 'Type',
              initial: d.docType,
              onSave: (v) => save('doc_type', v),
            ),
            AutoSaveField(
              key: ValueKey('source-${d.id}'),
              label: 'Source ou auteur',
              initial: d.sourceAuthor,
              onSave: (v) => save('source_author', v),
            ),
            AutoSaveField(
              key: ValueKey('mots-${d.id}'),
              label: 'Mots-clés (séparés par des virgules)',
              initial: d.motsCles.join(', '),
              onSave: (v) => save('keywords', [
                for (final m in (v ?? '').split(','))
                  if (m.trim().isNotEmpty) m.trim(),
              ]),
            ),
          ] else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Type'),
              subtitle: Text(d.docType ?? '—'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Source ou auteur'),
              subtitle: Text(d.sourceAuthor ?? '—'),
            ),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fichier'),
            subtitle: Text(
              [
                ?d.originalName,
                if (d.sizeBytes != null) tailleTexte(d.sizeBytes!),
                if (d.pageCount != null) '${d.pageCount} page(s)',
              ].join(' · '),
            ),
          ),
          if (espace == Espace.archives)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.block),
              title: Text('Jamais utilisé par l’assistant IA (archives)'),
            )
          else if (gere) ...[
            SwitchListTile(
              key: const Key('ia-autorisee'),
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Autoriser l’assistant IA à utiliser ce document',
              ),
              value: d.aiAllowed && !d.isSensitive,
              onChanged: d.isSensitive ? null : (v) => save('ai_allowed', v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Document sensible (jamais pour l’IA)'),
              value: d.isSensitive,
              onChanged: (v) => repo.modifier(d.id, {
                'is_sensitive': v,
                if (v) 'ai_allowed': false,
              }),
            ),
          ],
          const SizedBox(height: 12),
          if ((gere || modifiable) && d.enCorbeille)
            OutlinedButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text('Restaurer'),
              onPressed: () => repo.restaurer(d.id),
            ),
          if (gere && d.enCorbeille) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('effacer-document'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Effacer définitivement'),
              onPressed: () async {
                final ok = await confirmer(
                  context,
                  titre: 'Effacer définitivement ?',
                  message:
                      '« ${d.title} » sera effacé du serveur et de tous les '
                      'téléphones. Impossible de revenir en arrière.',
                  bouton: 'Effacer',
                );
                if (!ok || !context.mounted) return;
                final fait = await avecMessage(context, () async {
                  // La mise à la corbeille doit d'abord être connue du
                  // serveur.
                  await ref.read(syncEngineProvider).syncNow();
                  await ref
                      .read(documentsEnLigneProvider)
                      .effacer(d.id, d.storagePath);
                  await repo.oublier(d.id);
                  return true;
                });
                if ((fait ?? false) && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document effacé.')),
                  );
                  context.pop();
                }
              },
            ),
          ],
          if ((gere || modifiable) && !d.enCorbeille)
            OutlinedButton.icon(
              key: const Key('corbeille-document'),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Mettre à la corbeille'),
              onPressed: () async {
                final ok = await confirmer(
                  context,
                  titre: 'Mettre à la corbeille ?',
                  message:
                      'Le document reste 30 jours dans la corbeille '
                      '(restaurable), puis il est effacé du serveur.',
                  bouton: 'Mettre à la corbeille',
                );
                if (ok) {
                  await repo.mettreALaCorbeille(d.id);
                  if (context.mounted) context.pop();
                }
              },
            ),
        ],
      ),
    );
  }
}
