import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date affichée « 14/03/2017 », enregistrée « 2017-03-14 » (comme le
/// serveur). Toucher le champ ouvre le calendrier ; la croix l'efface.
class AutoSaveDateField extends StatelessWidget {
  const new({
    required this.label,
    required this.initial,
    required this.onSave,
    this.helper,
    this.first,
    this.last,
    super.key,
  });

  final String label;
  final String? initial;
  final String? helper;
  final DateTime? first;
  final DateTime? last;
  final Future<void> Function(String? isoDate) onSave;

  static final _affichage = DateFormat('dd/MM/yyyy');

  static String? afficher(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso);
    return d == null ? null : _affichage.format(d);
  }

  static String iso(DateTime d) {
    String deux(int n) => n.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${deux(d.month)}-'
        '${deux(d.day)}';
  }

  Future<void> _choisir(BuildContext context) async {
    final actuelle = initial == null ? null : DateTime.tryParse(initial!);
    final d = await showDatePicker(
      context: context,
      locale: const Locale('fr'),
      initialDate: actuelle ?? DateTime.now(),
      firstDate: first ?? DateTime(1940),
      lastDate: last ?? DateTime(DateTime.now().year + 5),
      helpText: label,
    );
    if (d != null) await onSave(iso(d));
  }

  @override
  Widget build(BuildContext context) {
    final texte = afficher(initial);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _choisir(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            helperText: helper,
            helperMaxLines: 3,
            border: const OutlineInputBorder(),
            suffixIcon: texte == null
                ? const Icon(Icons.calendar_today)
                : IconButton(
                    tooltip: 'Effacer la date',
                    icon: const Icon(Icons.clear),
                    onPressed: () => onSave(null),
                  ),
          ),
          child: Text(texte ?? 'Toucher pour choisir'),
        ),
      ),
    );
  }
}

/// Choix parmi quelques valeurs (sexe, T/S…) : boutons visibles, pas de menu.
class ChoiceField extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String? value;

  /// valeur → libellé
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final e in options.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: value == e.key,
                onSelected: (on) => onChanged(on ? e.key : null),
              ),
          ],
        ),
      ],
    ),
  );
}

/// Rappel des champs libres du personnel et des élèves (17.8).
const rappelSante = 'N’indiquez pas d’informations médicales.';
