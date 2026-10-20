import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/sync/sync_engine.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SyncPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value;
    final db = ref.watch(databaseProvider);
    final session = ref.watch(sessionProvider).value;
    final last = session?.lastSyncAt;
    return EcoleScaffold(
      title: 'Synchronisation',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            status?.label ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            last == null
                ? 'Jamais synchronisé sur ce téléphone.'
                : 'Dernier échange avec le serveur : ${_date(last)}',
          ),
          if (status?.state.phase == SyncPhase.offline) ...[
            const SizedBox(height: 8),
            const Text(
              'Pas de connexion pour l’instant. Vous pouvez continuer à '
              'travailler : tout sera envoyé au retour du réseau.',
            ),
          ],
          const SizedBox(height: 24),
          BigButton(
            icon: Icons.sync,
            label: 'Synchroniser maintenant',
            onPressed: () => ref.read(syncEngineProvider).syncNow(),
          ),
          const SizedBox(height: 24),
          StreamBuilder(
            stream: (db.select(
              db.outbox,
            )..where((o) => o.status.equals('refuse'))).watch(),
            builder: (context, snap) {
              final refused = snap.data ?? const [];
              if (refused.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Modifications refusées'),
                  const Text(
                    'Le serveur a refusé ces modifications. Le téléphone a '
                    'repris la version du serveur.',
                  ),
                  for (final e in refused)
                    ListTile(
                      leading: const Icon(Icons.error_outline),
                      title: Text(e.message ?? 'Modification refusée.'),
                    ),
                  OutlinedButton(
                    onPressed: () => (db.delete(
                      db.outbox,
                    )..where((o) => o.status.equals('refuse'))).go(),
                    child: const Text('J’ai compris, effacer cette liste'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

String _date(String iso) => DateFormat(
  "dd/MM/yyyy 'à' HH:mm",
  'fr',
).format(DateTime.parse(iso).toLocal());
