import 'dart:io';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/backup/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupState();
}

class _BackupState extends ConsumerState<BackupPage> {
  File? _last;

  Future<void> _create() async {
    final dir = Directory(
      '${(await getTemporaryDirectory()).path}/sauvegardes',
    );
    final file = await BackupService(
      ref.read(databaseProvider),
      dir,
    ).createBackup(DateTime.now());
    setState(() => _last = file);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Sauvegarde EcolePlus — à garder en lieu sûr',
      ),
    );
  }

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: 'Sauvegarde',
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Les données envoyées au serveur y sont déjà sauvegardées. Ce '
          'bouton crée en plus un fichier avec tout ce qui est sur ce '
          'téléphone, y compris ce qui n’est pas encore envoyé.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Attention : ce fichier contient les informations de l’école. '
          'Gardez-le pour vous (clé USB, ordinateur de l’école) et ne le '
          'partagez pas dans un groupe.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        BigButton(
          icon: Icons.save_alt,
          label: 'Créer une sauvegarde',
          onPressed: () => avecMessage(context, _create),
        ),
        if (_last != null) ...[
          const SizedBox(height: 16),
          Text('Dernière sauvegarde : ${_last!.uri.pathSegments.last}'),
        ],
      ],
    ),
  );
}
