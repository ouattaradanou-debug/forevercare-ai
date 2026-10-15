import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../clients/providers/clients_providers.dart';
import 'section_finances_client.dart';

const _bleuSeda = Color(0xFF1B4FA0);

/// Finances d'un client : montant total, avance, reste à payer calculé
/// automatiquement, historique des paiements.
///
/// Réservé au rôle propriétaire. Le rôle est vérifié ICI, avant même de
/// solliciter la moindre donnée financière — pas seulement au moment
/// d'une action d'écriture — conformément à l'exigence du cahier des
/// charges. La RLS Supabase applique la même règle indépendamment, en
/// défense en profondeur.
class EcranFinancesClient extends ConsumerWidget {
  const EcranFinancesClient({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estProprietaire = ref.watch(estProprietaireProvider);
    final client = ref.watch(clientParIdProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Finances — ${client.valueOrNull?.nomComplet ?? ''}'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: !estProprietaire
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Seul le propriétaire de l\'atelier peut consulter les finances.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [SectionFinancesClient(clientId: clientId)],
            ),
    );
  }
}
