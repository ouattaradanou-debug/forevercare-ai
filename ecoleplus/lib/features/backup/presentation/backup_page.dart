import 'dart:io';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/backup/backup_service.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Dossier des sauvegardes (remplacé dans les tests).
final dossierSauvegardesProvider = Provider<Future<Directory> Function()>(
  (ref) =>
      () async =>
          Directory('${(await getTemporaryDirectory()).path}/sauvegardes'),
);

/// Choix d'un fichier de sauvegarde (remplacé dans les tests).
final choisirSauvegardeProvider = Provider<Future<String?> Function()>(
  (ref) => () async {
    final r = await FilePicker.pickFiles();
    return r.isEmpty ? null : r.first.path;
  },
);

class BackupPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupState();
}

class _BackupState extends ConsumerState<BackupPage> {
  File? _last;
  String? _repris;

  /// Mot de passe demandé deux fois (création) ou une fois (restauration).
  /// Jamais de micro sur un mot de passe.
  Future<String?> _motDePasse({required bool creation}) async {
    final a = TextEditingController();
    final b = TextEditingController();
    String? erreur;
    final r = await showDialog<String>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text(
            creation ? 'Mot de passe de la sauvegarde' : 'Mot de passe',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  creation
                      ? 'Il protège le fichier : sans lui, personne ne peut '
                            'le lire. Notez-le dans un endroit sûr ; il sera '
                            'demandé pour restaurer.'
                      : 'Le mot de passe choisi lors de la sauvegarde.',
                ),
                TextField(
                  key: const Key('sauvegarde-mdp'),
                  controller: a,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                ),
                if (creation)
                  TextField(
                    key: const Key('sauvegarde-mdp2'),
                    controller: b,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Le même, une deuxième fois',
                    ),
                  ),
                if (erreur != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      erreur!,
                      style: TextStyle(color: Theme.of(c).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final e = creation
                    ? BackupService.verifierMotDePasse(a.text) ??
                          (a.text == b.text
                              ? null
                              : 'Les deux mots de passe sont différents.')
                    : null;
                if (e != null) {
                  set(() => erreur = e);
                } else {
                  Navigator.pop(c, a.text);
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
    // Libérés après la fermeture animée du dialogue.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(seconds: 1), () {
        a.dispose();
        b.dispose();
      });
    });
    return r;
  }

  Future<void> _create() async {
    final mdp = await _motDePasse(creation: true);
    if (mdp == null || !mounted) return;
    final file = await BackupService(
      ref.read(databaseProvider),
      await ref.read(dossierSauvegardesProvider)(),
      cle: ref.read(cleBaseProvider),
    ).createBackup(DateTime.now(), motDePasse: mdp);
    setState(() => _last = file);
    await ref.read(sortieFichierProvider)(
      await file.readAsBytes(),
      file.uri.pathSegments.last,
      'application/octet-stream',
    );
  }

  Future<void> _restaurer() async {
    final chemin = await ref.read(choisirSauvegardeProvider)();
    if (chemin == null || !mounted) return;
    final mdp = await _motDePasse(creation: false);
    if (mdp == null || !mounted) return;
    final ContenuSauvegarde contenu;
    try {
      contenu = lireSauvegarde(chemin, mdp);
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
      return;
    }
    final session = ref.read(sessionProvider).value;
    if (session == null || !mounted) return;
    if (contenu.schoolId != session.schoolId) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Autre école'),
          content: Text(
            'Cette sauvegarde est celle de « ${contenu.ecole} ». Elle ne '
            'peut être restaurée que sur un téléphone connecté à cette école.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Compris'),
            ),
          ],
        ),
      );
      return;
    }
    final n = contenu.elements.length;
    final ok = await confirmer(
      context,
      titre: 'Restaurer la sauvegarde ?',
      message: n == 0
          ? 'Tout ce que contient cette sauvegarde est déjà sur le serveur : '
                'ce téléphone le reçoit par la synchronisation. Rien à '
                'reprendre.'
          : '$n élément(s) n’avaient pas encore été envoyés depuis l’ancien '
                'téléphone. Ils vont être repris sur celui-ci, puis envoyés. '
                'Si une donnée a été modifiée depuis ailleurs, la '
                'modification la plus récente est gardée.'
                '${_photos(contenu.photosNonEnvoyees)}',
      bouton: n == 0 ? 'Fermer' : 'Reprendre',
    );
    if (!ok || n == 0 || !mounted) return;
    final store = ref.read(localStoreProvider);
    final connues = {
      for (final t in store.tables)
        if (t.pushable) t.name,
    };
    var repris = 0;
    for (final (table, cle, donnees) in contenu.elements) {
      // Table inconnue de cette version : ignorée.
      if (!connues.contains(table)) continue;
      await store.reprendre(table, cle, donnees);
      repris++;
    }
    setState(
      () => _repris =
          '$repris élément(s) repris : ils seront envoyés '
          'à la prochaine synchronisation.',
    );
  }

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: 'Sauvegarde',
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Les données envoyées au serveur y sont déjà sauvegardées chaque '
          'nuit. Ce bouton crée en plus un fichier avec tout ce qui est sur '
          'ce téléphone, y compris ce qui n’est pas encore envoyé.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Le fichier est chiffré avec un mot de passe que vous choisissez. '
          'Gardez-le pour vous (clé USB, ordinateur de l’école) et ne le '
          'partagez pas dans un groupe.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        BigButton(
          icon: Icons.save_alt,
          label: 'Créer une sauvegarde',
          onPressed: () => avecMessage(context, _create),
        ),
        if (_last != null) ...[
          const SizedBox(height: 16),
          Text(
            'Dernière sauvegarde : ${_last!.uri.pathSegments.last}',
            key: const Key('derniere-sauvegarde'),
          ),
        ],
        const SizedBox(height: 32),
        const SectionTitle('Nouveau téléphone'),
        const Text(
          'Sur un nouveau téléphone, connectez-vous : les données de l’école '
          'reviennent du serveur. Si l’ancien téléphone avait des éléments '
          'non envoyés, restaurez sa sauvegarde ici.',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.restore),
          label: const Text('Restaurer une sauvegarde'),
          onPressed: () => avecMessage(context, _restaurer),
        ),
        if (_repris != null) ...[
          const SizedBox(height: 12),
          Text(_repris!, key: const Key('restauration-resultat')),
        ],
      ],
    ),
  );
}

String _photos(int n) => n == 0
    ? ''
    : '\n\n$n photo(s) ou fichier(s) non envoyés ne sont pas dans la '
          'sauvegarde : il faudra les reprendre.';
