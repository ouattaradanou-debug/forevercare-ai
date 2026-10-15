import 'package:flutter/material.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Demande le montant total convenu et l'avance payée dans un dialogue
/// simple — partagé entre SectionFinancesGroupe (commande déjà existante)
/// et EcranNouveauGroupe (toute première commande, créée en même temps que
/// le groupe), afin que toute évolution future de ce formulaire s'applique
/// aux deux.
Future<({double montant, double avance})?> demanderMontantsCommande({
  required BuildContext context,
  required String titre,
  double? montantActuel,
  double? avanceActuelle,
}) async {
  final montantCtrl = TextEditingController(text: montantActuel?.toStringAsFixed(0) ?? '');
  final avanceCtrl = TextEditingController(text: avanceActuelle?.toStringAsFixed(0) ?? '');

  final confirme = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titre, style: const TextStyle(color: _bleuSeda)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: montantCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Montant total convenu (FCFA)',
              labelStyle: TextStyle(fontSize: 13),
            ),
          ),
          TextField(
            controller: avanceCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Avance payée (FCFA)',
              labelStyle: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: _bleuSeda),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );
  if (confirme != true) return null;
  return (
    montant: double.tryParse(montantCtrl.text.replaceAll(',', '.')) ?? 0,
    avance: double.tryParse(avanceCtrl.text.replaceAll(',', '.')) ?? 0,
  );
}
