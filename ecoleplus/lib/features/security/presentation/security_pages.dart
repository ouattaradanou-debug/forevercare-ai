import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/security/domain/journal.dart';
import 'package:ecoleplus/features/security/presentation/security_providers.dart';
import 'package:ecoleplus/features/sync/domain/sync_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

String dateCourte(String? iso) => iso == null
    ? 'jamais'
    : DateFormat(
        "dd/MM/yyyy 'à' HH:mm",
        'fr',
      ).format(DateTime.parse(iso).toLocal());

/// Regroupe la sécurité pour le directeur (accueil limité à 8 boutons).
class SecurityPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: 'Sécurité',
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        BigButton(
          icon: Icons.smartphone,
          label: 'Téléphones de l’école',
          onPressed: () => context.push('/securite/telephones'),
        ),
        const SizedBox(height: 12),
        BigButton(
          icon: Icons.history,
          label: 'Journal d’activité',
          onPressed: () => context.push('/securite/journal'),
        ),
        const SizedBox(height: 12),
        BigButton(
          icon: Icons.person,
          label: 'Mon compte',
          onPressed: () => context.push('/compte'),
        ),
      ],
    ),
  );
}

class DevicesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider).value ?? const [];
    final names = ref.watch(namesByUserProvider).value ?? const {};
    final session = ref.watch(sessionProvider).value;
    return EcoleScaffold(
      title: 'Téléphones de l’école',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Si un téléphone est perdu, volé ou remplacé, déconnectez-le : '
            'il ne pourra plus rien voir ni envoyer. La personne retrouve '
            'toutes ses données en se connectant sur son nouveau téléphone.',
          ),
          const SizedBox(height: 12),
          if (devices.isEmpty)
            const InfoMessage(
              'La liste arrive à la prochaine synchronisation.',
            ),
          for (final d in devices)
            _DeviceCard(
              device: d,
              owner: names[d.userId] ?? 'Personne inconnue',
              isThisPhone: d.id == session?.deviceId,
            ),
        ],
      ),
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  const new({
    required this.device,
    required this.owner,
    required this.isThisPhone,
  });
  final DeviceRow device;
  final String owner;
  final bool isThisPhone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerte = device.revokedAt != null || device.lastSyncAt == null
        ? null
        : alerteSynchronisation(
            enAttente: device.pendingCount,
            maintenant: DateTime.now().toUtc(),
            plusAncienneAttente: device.pendingCount > 0
                ? DateTime.parse(device.lastSyncAt!)
                : null,
            derniereSynchro: DateTime.parse(device.lastSyncAt!),
          );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${device.label} — $owner${isThisPhone ? ' (ce téléphone)' : ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Série ${device.seriesCode}'),
            if (device.revokedAt != null)
              Text('Déconnecté le ${dateCourte(device.revokedAt)}')
            else ...[
              Text(
                'Dernière synchronisation : ${dateCourte(device.lastSyncAt)}',
              ),
              Text(
                device.pendingCount == 0
                    ? 'Aucun élément en attente'
                    : '${device.pendingCount} élément(s) pas encore envoyé(s)',
              ),
              if (alerte != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    alerte,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (!isThisPhone)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.phonelink_erase),
                    label: const Text('Déconnecter ce téléphone'),
                    onPressed: () => _revoquer(context, ref),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _revoquer(BuildContext context, WidgetRef ref) async {
    final ok = await confirmer(
      context,
      titre: 'Déconnecter « ${device.label} » ?',
      message:
          'Ce téléphone ne pourra plus rien voir ni envoyer, et effacera les '
          'données de l’école dès qu’il retrouvera le réseau. '
          '${device.pendingCount > 0 ? 'Attention : ${device.pendingCount} '
                    'élément(s) non envoyés seront perdus. ' : ''}'
          '$owner devra se reconnecter (sur son nouveau téléphone). '
          'Cette action a besoin d’Internet.',
      bouton: 'Déconnecter',
    );
    if (!ok || !context.mounted) return;
    await avecMessage(context, () async {
      await ref.read(authApiProvider).revokeDevice(device.id);
      await ref.read(syncEngineProvider).syncNow();
    });
  }
}

class JournalPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  @override
  void initState() {
    super.initState();
    // Ouvrir le journal vaut lecture des alertes de sécurité.
    final db = ref.read(databaseProvider);
    unawaited(
      db
          .update(db.localSession)
          .write(
            LocalSessionCompanion(
              journalSeenAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(journalProvider).value ?? const [];
    final names = ref.watch(namesByUserProvider).value ?? const {};
    return EcoleScaffold(
      title: 'Journal d’activité',
      body: rows.isEmpty
          ? const InfoMessage('Aucune activité pour le moment.')
          : ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final r = rows[i];
                final e = decrireEvenement(
                  action: r.action,
                  table: r.affectedTable,
                  detailsJson: r.details,
                  acteur: r.actorId == null
                      ? 'Le système'
                      : names[r.actorId] ?? 'Une personne',
                );
                return ListTile(
                  leading: Icon(
                    e.securite ? Icons.shield_outlined : Icons.edit_note,
                    color: e.securite
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  title: Text(e.phrase),
                  subtitle: Text(dateCourte(r.occurredAt)),
                );
              },
            ),
    );
  }
}
