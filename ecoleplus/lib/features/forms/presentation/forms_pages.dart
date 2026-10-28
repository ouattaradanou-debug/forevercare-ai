import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/app/router.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/core/widgets/form_fields.dart';
import 'package:ecoleplus/features/bibliotheque/presentation/copie_signee.dart';
import 'package:ecoleplus/features/forms/data/forms_repository.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/forms/presentation/apercu_pdf_page.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/domain/anciennete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:printing/printing.dart';

final formsRepositoryProvider = Provider<FormsRepository>(
  (ref) => FormsRepository(ref.watch(localStoreProvider)),
);

final FutureProvider<PolicesPdf> policesPdfProvider = FutureProvider(
  (ref) async => PolicesPdf(
    normale: await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    grasse: await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    italique: await rootBundle.load('assets/fonts/Roboto-Italic.ttf'),
  ),
);

/// Aperçu / impression et partage du PDF (remplacés dans les tests).
class SortiePdf {
  const new({required this.imprimer, required this.partager});
  final Future<void> Function(Uint8List pdf, String nom) imprimer;
  final Future<void> Function(Uint8List pdf, String nom) partager;
}

final sortiePdfProvider = Provider<SortiePdf>(
  (ref) => SortiePdf(
    // « Aperçu et impression » : d'abord l'aperçu qu'on peut agrandir.
    imprimer: (pdf, nom) async {
      await ref
          .read(routerProvider)
          .push('/apercu', extra: ApercuPdf(pdf, nom));
    },
    partager: (pdf, nom) => Printing.sharePdf(bytes: pdf, filename: nom),
  ),
);

final StreamProviderFamily<OfficialFormRow?, (String, String)>
formulaireProvider = StreamProvider.family(
  (ref, k) => ref.watch(formsRepositoryProvider).watchFormulaire(k.$1, k.$2),
);

const formulairesPhase2 = {
  'B1': 'Fiche de renseignement du personnel',
  'B2': 'Registre matricule des élèves',
  'B3': 'Registre du personnel enseignant',
};

const etats = {
  'a_completer': 'À compléter',
  'complet': 'Complet',
  'imprime': 'Imprimé',
  'signe_archive': 'Signé et archivé',
};

/// Un formulaire : réglages modifiables avant impression, ce qui manque,
/// aperçu, impression et partage.
class FormulairePage extends ConsumerStatefulWidget {
  const new(this.code, {super.key});
  final String code;

  @override
  ConsumerState<FormulairePage> createState() => _FormulaireState();
}

class _FormulaireState extends ConsumerState<FormulairePage> {
  List<String>? _manques;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifier());
  }

  Future<void> _verifier() async {
    final session = ref.read(sessionProvider).value!;
    final m = await ref
        .read(formsRepositoryProvider)
        .manques(widget.code, session.schoolId);
    if (mounted) setState(() => _manques = m);
  }

  Future<void> _sortir(
    SchoolRow ecole,
    SchoolYearRow annee, {
    required bool partager,
  }) async {
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final repo = ref.read(formsRepositoryProvider);
      final pdf = await repo.pdf(
        widget.code,
        ecole: ecole,
        annee: annee,
        polices: await ref.read(policesPdfProvider.future),
      );
      final nom = '${widget.code}_${annee.label}.pdf';
      final sortie = ref.read(sortiePdfProvider);
      await (partager ? sortie.partager : sortie.imprimer)(pdf, nom);
      final actuel = await repo.watchFormulaire(annee.id, widget.code).first;
      if (actuel?.status != 'signe_archive') {
        await repo.enregistrer(ecole.id, annee.id, widget.code, {
          'status': 'imprime',
        });
      }
    });
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final ecole = ref.watch(schoolProvider(session.schoolId)).value;
    final annees = ref.watch(yearsProvider(session.schoolId)).value ?? [];
    final annee = annees
        .where((y) => y.id == ecole?.currentSchoolYearId)
        .firstOrNull;
    final titre = formulairesPhase2[widget.code] ?? widget.code;
    if (ecole == null || annee == null) {
      return EcoleScaffold(
        title: titre,
        body: const InfoMessage('Année scolaire introuvable.'),
      );
    }
    final f = ref.watch(formulaireProvider((annee.id, widget.code))).value;
    final repo = ref.read(formsRepositoryProvider);
    Future<void> save(String col, Object? v) =>
        repo.enregistrer(ecole.id, annee.id, widget.code, {col: v});
    return EcoleScaffold(
      title: '${widget.code} — $titre',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Année scolaire ${annee.label}'),
          const SizedBox(height: 12),
          if (_manques != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _manques!.isEmpty
                          ? 'Rien ne manque.'
                          : 'À compléter dans les fiches :',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    for (final m in _manques!) Text('• $m'),
                  ],
                ),
              ),
            ),
          const SectionTitle('Avant d’imprimer'),
          if (widget.code == 'B1')
            AutoSaveDateField(
              label: 'Anciennetés calculées au',
              initial:
                  f?.referenceDate ??
                  AutoSaveDateField.iso(referenceParDefaut(DateTime.now())),
              helper: 'Date de référence (à valider avec la circonscription).',
              onSave: (v) => save('reference_date', v),
            ),
          if (widget.code == 'B2') ...[
            AutoSaveDateField(
              label: 'Élèves admis à l’école du (couverture)',
              initial: f?.registerPeriodFrom,
              onSave: (v) => save('register_period_from', v),
            ),
            AutoSaveDateField(
              label: '… au',
              initial: f?.registerPeriodTo,
              onSave: (v) => save('register_period_to', v),
            ),
          ],
          AutoSaveField(
            key: ValueKey('fait-a-${f?.id}'),
            label: 'Fait à',
            initial: f?.signedPlace ?? ecole.commune,
            onSave: (v) => save('signed_place', v),
          ),
          AutoSaveDateField(
            label: 'Le',
            initial: f?.signedOn,
            onSave: (v) => save('signed_on', v),
          ),
          AutoSaveField(
            key: ValueKey('directeur-${f?.id}'),
            label: 'Nom du directeur',
            initial: f?.directorName ?? ecole.directorName,
            onSave: (v) => save('director_name', v),
          ),
          ChoiceField(
            label: 'État du formulaire',
            value: f?.status ?? 'a_completer',
            options: etats,
            onChanged: (v) {
              if (v != null) unawaited(save('status', v));
            },
          ),
          const SizedBox(height: 8),
          BigButton(
            icon: Icons.print,
            label: 'Aperçu et impression',
            onPressed: _occupe
                ? null
                : () => _sortir(ecole, annee, partager: false),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Partager le PDF (WhatsApp, e-mail…)'),
            onPressed: _occupe
                ? null
                : () => _sortir(ecole, annee, partager: true),
          ),
          const SizedBox(height: 12),
          CopieSignee(
            titre: '${widget.code} ${annee.label}',
            anneeId: annee.id,
            documentId: f?.signedScanDocumentId,
            onArchivee: (id) => repo.enregistrer(
              ecole.id,
              annee.id,
              widget.code,
              {'signed_scan_document_id': id, 'status': 'signe_archive'},
            ),
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
