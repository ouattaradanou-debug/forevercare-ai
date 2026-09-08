import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_dimens.dart';
import 'section_titre.dart';

/// Section "Informations du client" : Nom, Prénom, Contact, Date de prise
/// des mesures, Sexe — dans cet ordre, sans aucun champ obligatoire.
class SectionInfosClient extends StatelessWidget {
  const SectionInfosClient({
    super.key,
    required this.nomCtrl,
    required this.prenomCtrl,
    required this.telephoneCtrl,
    required this.datePriseMesures,
    required this.onDateChange,
    required this.sexe,
    required this.onSexeChange,
  });

  final TextEditingController nomCtrl;
  final TextEditingController prenomCtrl;
  final TextEditingController telephoneCtrl;
  final DateTime? datePriseMesures;
  final ValueChanged<DateTime?> onDateChange;
  final String? sexe;
  final ValueChanged<String?> onSexeChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitre(
          icone: Icons.badge_outlined,
          titre: 'Informations du client',
        ),
        const SizedBox(height: AppSpacing.m),
        TextFormField(
          controller: nomCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        const SizedBox(height: AppSpacing.m),
        TextFormField(
          controller: prenomCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Prénom'),
        ),
        const SizedBox(height: AppSpacing.m),
        TextFormField(
          controller: telephoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Contact (téléphone)'),
        ),
        const SizedBox(height: AppSpacing.m),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.champ),
          onTap: () async {
            final DateTime? choisie = await showDatePicker(
              context: context,
              initialDate: datePriseMesures ?? DateTime.now(),
              firstDate: DateTime(2015),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            onDateChange(choisie);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date de prise des mesures',
              suffixIcon: datePriseMesures != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onDateChange(null),
                    )
                  : const Icon(Icons.calendar_today_outlined),
            ),
            child: Text(
              datePriseMesures != null
                  ? DateFormat.yMMMMd('fr_FR').format(datePriseMesures!)
                  : 'Non renseignée',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('Sexe', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Homme'),
              selected: sexe == 'Homme',
              onSelected: (selectionne) =>
                  onSexeChange(selectionne ? 'Homme' : null),
            ),
            const SizedBox(width: AppSpacing.s),
            ChoiceChip(
              label: const Text('Femme'),
              selected: sexe == 'Femme',
              onSelected: (selectionne) =>
                  onSexeChange(selectionne ? 'Femme' : null),
            ),
          ],
        ),
      ],
    );
  }
}
