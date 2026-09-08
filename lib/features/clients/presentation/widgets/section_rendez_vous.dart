import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/brouillon_client.dart';
import 'section_titre.dart';

/// Section "Rendez-vous" : planification d'un ou plusieurs rendez-vous
/// (essayage, livraison) pour ce client, directement pendant la création
/// de sa fiche. Aucun rendez-vous n'est obligatoire.
///
/// Les rendez-vous ajoutés ici restent dans le brouillon (voir
/// `RendezVousBrouillon`) jusqu'à la finalisation de la fiche client, qui
/// les transforme en vraies lignes `rendez_vous` — un rendez-vous ne peut
/// pas exister avant que le client lui-même n'existe (voir schema.sql,
/// `rendez_vous.client_id` obligatoire).
class SectionRendezVous extends StatelessWidget {
  const SectionRendezVous({
    super.key,
    required this.rendezVous,
    required this.onAjouter,
    required this.onSupprimer,
  });

  final List<RendezVousBrouillon> rendezVous;
  final void Function(DateTime dateHeure, String type) onAjouter;
  final ValueChanged<int> onSupprimer;

  Future<void> _choisirRendezVous(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !context.mounted) return;

    final TimeOfDay? heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (heure == null || !context.mounted) return;

    final String? type = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.checkroom_outlined),
              title: const Text('Essayage'),
              onTap: () => Navigator.of(ctx).pop('essayage'),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Livraison'),
              onTap: () => Navigator.of(ctx).pop('livraison'),
            ),
          ],
        ),
      ),
    );
    if (type == null) return;

    final DateTime dateHeure = DateTime(
      date.year,
      date.month,
      date.day,
      heure.hour,
      heure.minute,
    );
    onAjouter(dateHeure, type);
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat format = DateFormat("EEEE d MMMM 'à' HH'h'mm", 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitre(
          icone: Icons.event_available,
          titre: 'Rendez-vous',
          couleur: AppColors.or600,
        ),
        const SizedBox(height: AppSpacing.m),
        for (int i = 0; i < rendezVous.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(
                  rendezVous[i].type == 'livraison'
                      ? Icons.local_shipping_outlined
                      : Icons.checkroom_outlined,
                  color: AppColors.or600,
                ),
                title: Text(format.format(rendezVous[i].dateHeure)),
                subtitle: Text(
                  rendezVous[i].type == 'livraison' ? 'Livraison' : 'Essayage',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onSupprimer(i),
                ),
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => _choisirRendezVous(context),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un rendez-vous'),
        ),
      ],
    );
  }
}
