import 'dart:io';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// En-têtes administratifs d'une année (jamais codés en dur, R12).
class HeadersPage extends ConsumerWidget {
  const new({required this.yearId, super.key});
  final String yearId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final header = ref.watch(headerProvider(yearId)).value;
    final years = ref.watch(yearsProvider(session.schoolId)).value ?? const [];
    final label = years.where((y) => y.id == yearId).map((y) => y.label);
    final editable = session.role == 'directeur';
    if (header == null) {
      return const EcoleScaffold(
        title: 'En-têtes administratifs',
        body: InfoMessage('Aucun en-tête pour cette année.'),
      );
    }
    final repo = ref.read(schoolRepositoryProvider);
    Widget f(String col, String text, String? value) => AutoSaveField(
      key: Key('$yearId-$col'),
      label: text,
      initial: value,
      enabled: editable,
      onSave: (v) => repo.saveHeader(header.id, {col: v}),
    );
    return EcoleScaffold(
      title: 'En-têtes ${label.isEmpty ? '' : label.first}',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Ces informations apparaissent en haut des documents officiels '
            'de cette année. Chaque année garde les siennes.',
          ),
          const SizedBox(height: 16),
          _Emblem(header: header, editable: editable),
          const SizedBox(height: 16),
          f('country', 'Pays', header.country),
          f('motto', 'Devise', header.motto),
          f('ministry', 'Ministère', header.ministry),
          f('region', 'Région', header.region),
          f(
            'regional_direction',
            'Direction régionale',
            header.regionalDirection,
          ),
          f(
            'provincial_direction',
            'Direction provinciale',
            header.provincialDirection,
          ),
          f('ceb', 'Circonscription d’éducation de base (CEB)', header.ceb),
          f('province', 'Province', header.province),
          f('departement', 'Département', header.departement),
          f('commune', 'Commune', header.commune),
          f(
            'school_label',
            'Nom de l’école sur les documents',
            header.schoolLabel,
          ),
        ],
      ),
    );
  }
}

class _Emblem extends ConsumerWidget {
  const new({required this.header, required this.editable});
  final AdminHeaderRow header;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(schoolRepositoryProvider);
    final path = header.emblemPath;
    final local = path == null || repo.mediaDir == null
        ? null
        : repo.localMediaFile(path);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Image d’en-tête (emblème)'),
            const SizedBox(height: 8),
            if (local != null && local.existsSync())
              Image.file(local, height: 96)
            else
              Text(
                path == null
                    ? 'Aucune image.'
                    : 'Image enregistrée (visible sur le téléphone qui l’a '
                          'ajoutée).',
              ),
            if (editable) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: const Text('Choisir une image'),
                onPressed: () async {
                  final r = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: const ['png', 'jpg', 'jpeg'],
                  );
                  final p = r.isEmpty ? null : r.first.path;
                  if (p != null) await repo.setEmblem(header, File(p));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
