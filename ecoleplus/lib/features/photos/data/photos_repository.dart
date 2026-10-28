import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:path/path.dart' as p;

/// Photos des élèves et logo de l'école : copie locale immédiate, envoi au
/// serveur (compartiment privé) dès que le réseau le permet ; un nouveau
/// nom à chaque remplacement pour que les autres téléphones la reçoivent.
class PhotosRepository {
  new(this.store, {required this.mediaDir});

  final LocalStore store;
  final Directory? mediaDir;
  AppDatabase get db => store.db;

  static const compartiment = 'ecole-medias';

  File? fichier(String? objectPath) {
    if (objectPath == null || mediaDir == null) return null;
    final f = File(p.join(mediaDir!.path, objectPath));
    return f.existsSync() ? f : null;
  }

  Future<String> _deposer(String objectPath, Uint8List jpeg) async {
    final local = File(p.join(mediaDir!.path, objectPath));
    await local.parent.create(recursive: true);
    await local.writeAsBytes(jpeg, flush: true);
    await db
        .into(db.fileUploads)
        .insert(
          FileUploadsCompanion.insert(
            localPath: local.path,
            bucket: compartiment,
            objectPath: objectPath,
            contentType: 'image/jpeg',
            createdAt: store.clock.nowIso(),
          ),
        );
    return objectPath;
  }

  Future<void> _effacerAncien(String? ancien, String nouveau) async {
    final f = fichier(ancien);
    if (f != null && ancien != nouveau) {
      // La photo remplacée ne reste pas sur le téléphone ; un envoi encore
      // en attente pour elle est abandonné.
      await (db.delete(
        db.fileUploads,
      )..where((u) => u.objectPath.equals(ancien!))).go();
      await f.delete();
    }
  }

  Future<void> enregistrerPhoto(StudentRow eleve, Uint8List jpeg) async {
    final now = store.clock.now();
    final chemin =
        '${eleve.schoolId}/eleves/${eleve.id}-${now.millisecondsSinceEpoch}.jpg';
    await db.transaction(() async {
      await _deposer(chemin, jpeg);
      await store.save('students', {
        'id': eleve.id,
        'photo_path': chemin,
        'photo_updated_at': now.toIso8601String(),
      });
    });
    await _effacerAncien(eleve.photoPath, chemin);
  }

  Future<void> retirerPhoto(StudentRow eleve) async {
    await store.save('students', {
      'id': eleve.id,
      'photo_path': null,
      'photo_updated_at': store.clock.nowIso(),
    });
    await _effacerAncien(eleve.photoPath, '');
  }

  Future<void> enregistrerLogo(SchoolRow ecole, Uint8List jpeg) async {
    final chemin =
        '${ecole.id}/logo/logo-${store.clock.now().millisecondsSinceEpoch}.jpg';
    await db.transaction(() async {
      await _deposer(chemin, jpeg);
      await store.save('schools', {'id': ecole.id, 'logo_path': chemin});
    });
    await _effacerAncien(ecole.logoPath, chemin);
  }

  Future<void> retirerLogo(SchoolRow ecole) async {
    await store.save('schools', {'id': ecole.id, 'logo_path': null});
    await _effacerAncien(ecole.logoPath, '');
  }
}
