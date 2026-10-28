import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:ecoleplus/features/bibliotheque/presentation/bibliotheque_pages.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Copie signée et scannée d'un formulaire : rangée dans les archives,
/// reliée au formulaire, qui passe à « Signé et archivé ».
class CopieSignee extends ConsumerStatefulWidget {
  const new({
    required this.titre,
    required this.anneeId,
    required this.documentId,
    required this.onArchivee,
    super.key,
  });

  /// Titre du document d'archives, par exemple « B1 2026-2027 ».
  final String titre;
  final String anneeId;

  /// Copie déjà archivée, ou null.
  final String? documentId;
  final Future<void> Function(String documentId) onArchivee;

  @override
  ConsumerState<CopieSignee> createState() => _CopieSigneeState();
}

class _CopieSigneeState extends ConsumerState<CopieSignee> {
  bool _occupe = false;

  Future<void> _archiver() async {
    final fichiers = await ref.read(choisirFichiersProvider)();
    if (fichiers.isEmpty || !mounted) return;
    setState(() => _occupe = true);
    await avecMessage(context, () async {
      final session = ref.read(sessionProvider).value!;
      final r = await ref
          .read(bibliothequeRepositoryProvider)
          .ajouter(
            schoolId: session.schoolId,
            espace: Espace.archives,
            fichiers: [fichiers.first],
            fiche: FicheDocument(
              titre: '${widget.titre} — copie signée',
              type: 'Formulaire signé',
              anneeId: widget.anneeId,
            ),
            gestionnaire: true,
          );
      await widget.onArchivee(r.ids.first);
      unawaited(ref.read(syncEngineProvider).syncNow());
    });
    if (mounted) setState(() => _occupe = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(mesDroitsProvider).contains('archives')) {
      return const SizedBox.shrink();
    }
    final id = widget.documentId;
    if (id != null) {
      return Card(
        child: ListTile(
          key: const Key('copie-signee'),
          leading: const Icon(Icons.verified_outlined),
          title: const Text('Copie signée archivée'),
          subtitle: const Text('Dans les archives administratives'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/document/$id'),
        ),
      );
    }
    return OutlinedButton.icon(
      key: const Key('archiver-copie-signee'),
      icon: const Icon(Icons.inventory_2_outlined),
      label: const Text('Archiver la copie signée (scan PDF ou photo)'),
      onPressed: _occupe ? null : _archiver,
    );
  }
}
