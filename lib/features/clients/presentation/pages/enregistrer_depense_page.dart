import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/finances_providers.dart';

/// Formulaire d'enregistrement d'une dépense de l'atelier (achat de tissu,
/// fournitures, réparation de machine...). Accessible depuis l'accueil,
/// juste à côté de "Champs de mesure" — propriétaire uniquement, comme le
/// reste des finances (voir SuiviFinancesPage, qui affiche ensuite ces
/// dépenses dans son tableau récapitulatif).
class EnregistrerDepensePage extends ConsumerStatefulWidget {
  const EnregistrerDepensePage({super.key});

  @override
  ConsumerState<EnregistrerDepensePage> createState() =>
      _EnregistrerDepensePageState();
}

class _EnregistrerDepensePageState
    extends ConsumerState<EnregistrerDepensePage> {
  final TextEditingController _montantCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _enCours = false;

  @override
  void dispose() {
    _montantCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final DateTime? choisie = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (choisie != null) {
      setState(
        () => _date = DateTime(
          choisie.year,
          choisie.month,
          choisie.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  Future<void> _enregistrer() async {
    final double? montant = double.tryParse(
      _montantCtrl.text.trim().replaceAll(',', '.'),
    );
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indique un montant valide.')),
      );
      return;
    }
    final String? atelierId =
        ref.read(atelierCourantProvider).asData?.value?.id;
    if (atelierId == null) return;

    setState(() => _enCours = true);
    try {
      await ref.read(financesRepositoryProvider).ajouterDepense(
            atelierId: atelierId,
            montant: montant,
            description: _descriptionCtrl.text.trim().isEmpty
                ? null
                : _descriptionCtrl.text.trim(),
            date: _date,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dépense enregistrée.')),
      );
      setState(() {
        _montantCtrl.clear();
        _descriptionCtrl.clear();
        _date = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'enregistrer : $e")),
      );
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enregistrer une dépense')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          TextField(
            controller: _montantCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _descriptionCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
              hintText: 'Ex. Achat de tissu, réparation machine...',
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Date'),
            subtitle: Text(
              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_date),
            ),
            onTap: _choisirDate,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _enCours ? null : _enregistrer,
            child: _enCours
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
