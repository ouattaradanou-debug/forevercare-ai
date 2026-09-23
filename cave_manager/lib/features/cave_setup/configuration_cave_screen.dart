import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/profil.dart';
import '../../core/constants/type_cave.dart';

/// Configuration de la cave après création (icône ⚙️ en haut à gauche de
/// l'écran d'accueil, visible pour Propriétaire, Propriétaire/Gérant et
/// Gérant — `RoleUtilisateur.estResponsable`, pas l'Agent de vente).
///
/// Permet de revoir : nom de la cave, téléphone, ville, type de cave,
/// logo, et son propre nom/prénom. Le rôle reste volontairement non
/// modifiable ici (voir PHASE1.md, risque d'élévation de privilège
/// auto-administrée).
class ConfigurationCaveScreen extends ConsumerStatefulWidget {
  const ConfigurationCaveScreen({super.key, required this.profil});

  final Profil profil;

  @override
  ConsumerState<ConfigurationCaveScreen> createState() =>
      _ConfigurationCaveScreenState();
}

class _ConfigurationCaveScreenState
    extends ConsumerState<ConfigurationCaveScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomCaveCtrl = TextEditingController();
  final _telephoneCaveCtrl = TextEditingController();
  final _localisationCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();

  TypeCave _typeCave = TypeCave.vin;
  String? _logoUrlActuel;
  XFile? _nouveauLogo;

  bool _chargement = true;
  bool _enCours = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _prenomCtrl.text = widget.profil.prenom;
    _nomCtrl.text = widget.profil.nom;
    _chargerInfosCave();
  }

  Future<void> _chargerInfosCave() async {
    try {
      final infos = await ref
          .read(authServiceProvider)
          .informationsCaveActuelles(widget.profil.caveId);
      _nomCaveCtrl.text = infos.nom;
      _telephoneCaveCtrl.text = infos.telephone;
      _localisationCtrl.text = infos.localisation;
      _typeCave = infos.typeCave;
      _logoUrlActuel = infos.logoUrl;
    } catch (e) {
      _erreur = 'Impossible de charger les informations de la cave : $e';
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  void dispose() {
    _nomCaveCtrl.dispose();
    _telephoneCaveCtrl.dispose();
    _localisationCtrl.dispose();
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirLogo() async {
    final image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _nouveauLogo = image);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      await authService.modifierInformationsCave(
        caveId: widget.profil.caveId,
        nom: _nomCaveCtrl.text.trim(),
        telephone: _telephoneCaveCtrl.text.trim(),
        localisation: _localisationCtrl.text.trim(),
        typeCave: _typeCave,
      );

      if (_nouveauLogo != null) {
        final octets = await _nouveauLogo!.readAsBytes();
        final extension = _nouveauLogo!.path.split('.').last;
        await authService.televerserLogoCave(
          caveId: widget.profil.caveId,
          octets: octets,
          extension: extension,
        );
      }

      await authService.modifierMonProfil(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
      );

      ref.invalidate(profilActuelProvider);
      ref.invalidate(infosCaveProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration enregistrée.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _erreur = 'Impossible d\'enregistrer : $e');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration de la cave')),
      body: SafeArea(
        child: _chargement
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _choisirLogo,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: _nouveauLogo != null
                                ? FileImage(File(_nouveauLogo!.path))
                                : (_logoUrlActuel != null
                                    ? NetworkImage(_logoUrlActuel!)
                                    : null) as ImageProvider?,
                            child: _nouveauLogo == null &&
                                    _logoUrlActuel == null
                                ? const Icon(Icons.add_a_photo, size: 32)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _choisirLogo,
                          child: const Text('Changer le logo'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Type de cave',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      RadioGroup<TypeCave>(
                        groupValue: _typeCave,
                        onChanged: (v) => setState(() => _typeCave = v!),
                        child: Column(
                          children: TypeCave.values
                              .map((type) => RadioListTile<TypeCave>(
                                  title: Text(type.libelle), value: type))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomCaveCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Nom de la cave'),
                        validator: _valideurObligatoire,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _telephoneCaveCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Numéro de téléphone de la cave'),
                        keyboardType: TextInputType.phone,
                        validator: _valideurObligatoire,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _localisationCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Ville'),
                        validator: _valideurObligatoire,
                      ),
                      const SizedBox(height: 24),
                      Text('Votre profil',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _prenomCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Votre prénom'),
                        validator: _valideurObligatoire,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nomCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Votre nom'),
                        validator: _valideurObligatoire,
                      ),
                      if (_erreur != null) ...[
                        const SizedBox(height: 12),
                        Text(_erreur!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _enCours ? null : _enregistrer,
                        child: _enCours
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String? _valideurObligatoire(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;
}
