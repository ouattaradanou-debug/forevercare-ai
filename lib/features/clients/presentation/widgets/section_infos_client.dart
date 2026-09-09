import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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
            Expanded(
              child: _SelecteurSexe(
                icone: Icons.man,
                libelle: 'Homme',
                selectionne: sexe == 'Homme',
                onTap: () => onSexeChange(sexe == 'Homme' ? null : 'Homme'),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: _SelecteurSexe(
                icone: Icons.woman,
                libelle: 'Femme',
                selectionne: sexe == 'Femme',
                onTap: () => onSexeChange(sexe == 'Femme' ? null : 'Femme'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Grand bouton visuel (icône + texte) pour choisir le sexe du client —
/// pensé pour les tailleurs et tailleuses ne sachant ni lire ni écrire :
/// le symbole homme/femme suffit à lui seul à faire le bon choix.
class _SelecteurSexe extends StatelessWidget {
  const _SelecteurSexe({
    required this.icone,
    required this.libelle,
    required this.selectionne,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.champ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        decoration: BoxDecoration(
          color: selectionne
              ? AppColors.indigo700.withValues(alpha: 0.12)
              : scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.champ),
          border: Border.all(
            color: selectionne ? AppColors.indigo700 : scheme.outline,
            width: selectionne ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icone,
              size: 48,
              color: selectionne ? AppColors.indigo700 : scheme.onSurface,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              libelle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selectionne ? AppColors.indigo700 : scheme.onSurface,
                fontWeight: selectionne ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
