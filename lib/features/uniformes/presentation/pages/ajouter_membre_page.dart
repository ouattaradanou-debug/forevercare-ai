import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../../../../data/models/membre_groupe_uniforme.dart';
import '../../../../shared/widgets/selecteur_sexe.dart';
import '../providers/uniformes_providers.dart';

/// Ajout d'un membre à un groupe d'uniformes : identité minimale (nom,
/// prénom, sexe). Une fois enregistré, ouvre directement la prise de
/// mesures de ce membre — voir la demande : "Ajouter un membre ↓ Prendre
/// ses mesures ↓ Enregistrer les mesures ↓ Retour à la liste des membres".
class AjouterMembrePage extends ConsumerStatefulWidget {
  const AjouterMembrePage({super.key, required this.groupe});

  final GroupeUniforme groupe;

  @override
  ConsumerState<AjouterMembrePage> createState() => _AjouterMembrePageState();
}

class _AjouterMembrePageState extends ConsumerState<AjouterMembrePage> {
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  String? _sexe;
  bool _enregistrementEnCours = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    setState(() => _enregistrementEnCours = true);
    try {
      final MembreGroupeUniforme membre = await ref
          .read(uniformeRepositoryProvider)
          .ajouterMembre(
            groupeId: widget.groupe.id,
            nom: _texteOuNull(_nomCtrl.text),
            prenom: _texteOuNull(_prenomCtrl.text),
            sexe: _sexe,
          );
      if (mounted) {
        context.pushReplacement(
          '/uniformes/${widget.groupe.id}/membres/${membre.id}/mesures',
          extra: (groupe: widget.groupe, membre: membre),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'ajouter le membre : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  String? _texteOuNull(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un membre')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          TextFormField(
            controller: _nomCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: _prenomCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Prénom'),
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Sexe', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.s),
          SelecteurSexe(
            sexe: _sexe,
            onChange: (valeur) => setState(() => _sexe = valeur),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _enregistrementEnCours ? null : _enregistrer,
            child: _enregistrementEnCours
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Enregistrer et prendre les mesures'),
          ),
        ],
      ),
    );
  }
}
