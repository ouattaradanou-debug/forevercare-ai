import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/cartes/data/cartes_repository.dart';
import 'package:ecoleplus/features/cartes/domain/carte_scolaire.dart';
import 'package:ecoleplus/features/cartes/pdf/pdf_cartes.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final cartesRepositoryProvider = Provider<CartesRepository>(
  (ref) => CartesRepository(
    ref.watch(localStoreProvider),
    mediaDir: ref.watch(mediaDirProvider),
  ),
);

final StreamProviderFamily<CardTemplateRow?, String> modeleCarteProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(cartesRepositoryProvider).watchModele(schoolId),
    );

/// Imprime les cartes d'un lot (ou d'un seul élève).
Future<void> imprimerCartes(
  BuildContext context,
  WidgetRef ref,
  Lot lot, {
  required String nomFichier,
  String? studentId,
}) => avecMessage(context, () async {
  final session = ref.read(sessionProvider).value!;
  final store = ref.read(localStoreProvider);
  final ecole = await (store.db.select(
    store.db.schools,
  )..where((s) => s.id.equals(session.schoolId))).getSingle();
  final annee = await (store.db.select(
    store.db.schoolYears,
  )..where((y) => y.id.equals(ecole.currentSchoolYearId!))).getSingle();
  final (e, cartes) = await ref
      .read(cartesRepositoryProvider)
      .cartes(ecole, annee, lot, studentId: studentId);
  if (cartes.isEmpty) {
    throw const UserMessage('Aucun élève inscrit dans ce choix.');
  }
  final pdf = await pdfCartes(
    await ref.read(policesPdfProvider.future),
    e,
    cartes,
  );
  await ref.read(sortiePdfProvider).imprimer(pdf, nomFichier);
});

/// Imprime un texte d'une page (information des parents).
Future<void> imprimerTexte(
  WidgetRef ref, {
  required String titre,
  required String texte,
  required String nomFichier,
}) async {
  final polices = await ref.read(policesPdfProvider.future);
  final doc = pw.Document(theme: polices.theme, title: titre)
    ..addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 48,
          marginRight: 48,
          marginTop: 48,
          marginBottom: 48,
        ),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                titre.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              texte,
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 5),
            ),
          ],
        ),
      ),
    );
  await ref.read(sortiePdfProvider).imprimer(await doc.save(), nomFichier);
}

/// Cartes scolaires : choix du lot, couleur, élèves sans photo,
/// génération en planches A4.
class CartesPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CartesPage> createState() => _CartesState();
}

class _CartesState extends ConsumerState<CartesPage> {
  /// « ecole », « classe:`id` » ou « niveau:`code` ».
  String _choix = 'ecole';
  bool _occupe = false;

  Lot get _lot => switch (_choix.split(':')) {
    ['classe', final id] => Lot.classe(id),
    ['niveau', final code] => Lot.niveau(code),
    _ => const Lot.ecole(),
  };

  Future<void> _generer(String yearId) async {
    final repo = ref.read(cartesRepositoryProvider);
    final manquent = await repo.sansPhoto(yearId, _lot);
    if (manquent.isNotEmpty && mounted) {
      final ok = await confirmer(
        context,
        titre: '${manquent.length} élève(s) sans photo',
        message:
            'Leur carte aura un cadre vide « PHOTO ». Générer quand même ?',
        bouton: 'Générer',
      );
      if (!ok) return;
    }
    if (!mounted) return;
    setState(() => _occupe = true);
    await imprimerCartes(
      context,
      ref,
      _lot,
      nomFichier: 'Cartes_scolaires.pdf',
    );
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    final yearId = ecole?.currentSchoolYearId;
    if (ecole == null || yearId == null) {
      return const EcoleScaffold(
        title: 'Cartes scolaires',
        body: InfoMessage('Année scolaire introuvable.'),
      );
    }
    final classes = ref.watch(classesProvider(yearId)).value ?? const [];
    final niveaux = ref.watch(levelsProvider).value ?? const <LevelRow>[];
    final codes = {for (final c in classes) c.levelCode};
    final couleur =
        ref.watch(modeleCarteProvider(ecole.id)).value?.primaryColor ??
        '#1B6E3C';
    final repo = ref.read(cartesRepositoryProvider);
    return EcoleScaffold(
      title: 'Cartes scolaires',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Cartes au format carte bancaire (85,6 × 54 mm), 10 par feuille '
            'A4, recto puis verso. Imprimez à 100 % (« taille réelle »), en '
            'recto-verso retourné sur le grand côté.',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('lot-cartes'),
            initialValue: _choix,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Pour qui ?',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: 'ecole',
                child: Text('Toute l’école'),
              ),
              for (final n in niveaux)
                if (codes.contains(n.code))
                  DropdownMenuItem(
                    value: 'niveau:${n.code}',
                    child: Text('Niveau : ${n.label}'),
                  ),
              for (final c in classes)
                DropdownMenuItem(
                  value: 'classe:${c.id}',
                  child: Text('Classe : ${c.name}'),
                ),
            ],
            onChanged: (v) => setState(() => _choix = v ?? 'ecole'),
          ),
          const SectionTitle('Couleur du bandeau'),
          Wrap(
            spacing: 6,
            children: [
              for (final MapEntry(key: hex, value: nom)
                  in couleursCartes.entries)
                ChoiceChip(
                  avatar: Icon(
                    Icons.circle,
                    color: Color(
                      0xFF000000 | int.parse(hex.substring(1), radix: 16),
                    ),
                  ),
                  label: Text(nom),
                  selected: couleur.toUpperCase() == hex,
                  onSelected: (_) => repo.choisirCouleur(ecole.id, hex),
                ),
            ],
          ),
          if (ecole.logoPath == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Pas de logo : ajoutez-le dans « Mon école » si l’école en a '
                'un (facultatif).',
              ),
            ),
          const SectionTitle('Élèves sans photo'),
          FutureBuilder(
            key: ValueKey(_choix),
            future: repo.sansPhoto(yearId, _lot),
            builder: (context, snap) {
              final l = snap.data;
              if (l == null) return const LinearProgressIndicator();
              if (l.isEmpty) {
                return const Text('✓ Tous les élèves ont leur photo.');
              }
              return ExpansionTile(
                key: const Key('sans-photo'),
                tilePadding: EdgeInsets.zero,
                title: Text(
                  '${l.length} élève${l.length > 1 ? 's' : ''} sans photo '
                  '(cadre vide sur la carte)',
                ),
                children: [
                  for (final (s, c) in l)
                    ListTile(
                      dense: true,
                      title: Text('${s.lastName} ${s.firstNames}'),
                      subtitle: Text(c.name),
                      trailing: const Icon(Icons.photo_camera_outlined),
                      onTap: () => context.push('/eleves/${s.id}'),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          BigButton(
            icon: Icons.badge_outlined,
            label: 'Générer les cartes (PDF)',
            onPressed: _occupe ? null : () => _generer(yearId),
          ),
          if (_occupe) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.family_restroom),
            label: const Text('Information des parents (photos)'),
            onPressed: () => imprimerTexte(
              ref,
              titre: 'Photo pour la carte scolaire — information des parents',
              texte: texteInformationPhotos(ecole.name),
              nomFichier: 'Information_parents_photos.pdf',
            ),
          ),
        ],
      ),
    );
  }
}
