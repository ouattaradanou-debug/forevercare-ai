import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Fichier choisi sur le téléphone pour l'ajout.
class FichierChoisi {
  const new(this.nom, this.chemin);
  final String nom;
  final String chemin;
}

/// Résultat d'un ajout en lot.
class ResultatAjout {
  const new(this.ajoutes, this.doublons, {this.ids = const []});
  final int ajoutes;

  /// Fiches des fichiers du lot (nouvelles ou déjà présentes), dans l'ordre.
  final List<String> ids;

  /// Fichiers déjà présents (même empreinte) : titres existants.
  final List<String> doublons;
}

/// Bibliothèque pédagogique et archives : le catalogue est synchronisé ;
/// les fichiers sont envoyés par morceaux (reprenable) et ne sont
/// téléchargés qu'à la demande ou s'ils sont épinglés.
class BibliothequeRepository {
  new(this.store, {required this.remote, required this.mediaDir});

  final LocalStore store;
  final SyncRemote remote;
  final Directory? mediaDir;
  AppDatabase get db => store.db;

  static const compartiment = 'documents';
  static const _uuid = Uuid();

  // ------------------------------ Catalogue ------------------------------

  Stream<List<DocumentRow>> watchDocuments(
    String schoolId,
    Espace espace, {
    bool corbeille = false,
  }) =>
      (db.select(db.documents)
            ..where(
              (d) =>
                  d.schoolId.equals(schoolId) &
                  d.space.equals(espace.code) &
                  d.deletedAt.isNull() &
                  (corbeille ? d.trashedAt.isNotNull() : d.trashedAt.isNull()),
            )
            ..orderBy([(d) => OrderingTerm.asc(d.title)]))
          .watch();

  Stream<DocumentRow?> watchDocument(String id) => (db.select(
    db.documents,
  )..where((d) => d.id.equals(id))).watchSingleOrNull();

  Stream<List<DocumentUploadRow>> watchEnvois() =>
      db.select(db.documentUploads).watch();

  Stream<List<DocumentFileRow>> watchFichiers() =>
      db.select(db.documentFiles).watch();

  // -------------------------------- Ajout --------------------------------

  static Future<String> empreinte(File f) async =>
      (await sha256.bind(f.openRead()).first).toString();

  /// Ajoute un lot de fichiers : copie sur le téléphone, fiche dans le
  /// catalogue, envoi programmé. Un fichier déjà présent (même empreinte)
  /// n'est pas ajouté une deuxième fois.
  Future<ResultatAjout> ajouter({
    required String schoolId,
    required Espace espace,
    required List<FichierChoisi> fichiers,
    required FicheDocument fiche,
    required bool gestionnaire,
  }) async {
    var ajoutes = 0;
    final doublons = <String>[];
    final ids = <String>[];
    for (final f in fichiers) {
      final source = File(f.chemin);
      final sha = await empreinte(source);
      final existe =
          await (db.select(db.documents)..where(
                (d) =>
                    d.schoolId.equals(schoolId) &
                    d.sha256.equals(sha) &
                    d.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (existe != null) {
        doublons.add(
          existe.trashedAt == null
              ? existe.title
              : '${existe.title} (dans la corbeille)',
        );
        ids.add(existe.id);
        continue;
      }
      final id = _uuid.v4();
      final nom = nomSur(f.nom);
      final chemin = '$schoolId/$id/$nom';
      final local = File(p.join(mediaDir!.path, compartiment, chemin));
      await local.parent.create(recursive: true);
      await source.copy(local.path);
      final taille = await local.length();
      final maintenant = store.clock.nowIso();
      await db.transaction(() async {
        await store.save('documents', {
          'id': id,
          'school_id': schoolId,
          'space': espace.code,
          'title': fichiers.length == 1 && (fiche.titre ?? '').trim().isNotEmpty
              ? fiche.titre!.trim()
              : titreDepuisNom(f.nom),
          'is_common': fiche.commun,
          'class_ids': fiche.classes,
          'level_codes': fiche.niveaux,
          'doc_type': fiche.type,
          'subject_id': fiche.matiereId,
          'school_year_id': fiche.anneeId,
          'source_author': fiche.source,
          'keywords': fiche.motsCles,
          'is_sensitive': fiche.sensible,
          'ai_allowed': espace == Espace.bibliotheque && !fiche.sensible,
          // Ajout d'un enseignant : en attente (le serveur décide).
          'approved': gestionnaire,
          'storage_path': chemin,
          'original_name': f.nom,
          'mime_type': typeMime(f.nom),
          'size_bytes': taille,
          'sha256': sha,
        });
        await db
            .into(db.documentFiles)
            .insertOnConflictUpdate(
              DocumentFilesCompanion.insert(
                documentId: id,
                localPath: local.path,
                sizeBytes: taille,
                savedAt: maintenant,
              ),
            );
        await db
            .into(db.documentUploads)
            .insertOnConflictUpdate(
              DocumentUploadsCompanion.insert(
                documentId: id,
                localPath: local.path,
                objectPath: chemin,
                contentType: typeMime(f.nom),
                sizeBytes: taille,
                createdAt: maintenant,
              ),
            );
      });
      ajoutes++;
      ids.add(id);
    }
    return ResultatAjout(ajoutes, doublons, ids: ids);
  }

  // -------------------------------- Envoi --------------------------------

  /// Envoie les fichiers en attente, morceau par morceau ; la position est
  /// gardée après chaque morceau : après une coupure, l'envoi reprend là
  /// où il s'était arrêté (aucun doublon : même fiche, même chemin).
  Future<void> envoyer() async {
    final envois = await db.select(db.documentUploads).get();
    for (final e in envois) {
      final doc = await (db.select(
        db.documents,
      )..where((d) => d.id.equals(e.documentId))).getSingleOrNull();
      if (doc == null) {
        // Fiche refusée par le serveur (espace plein, droits) : le fichier
        // n'est pas envoyé ; le refus est expliqué dans la synchronisation.
        await _retirerEnvoi(e.documentId);
        await _oublierFichier(e.documentId);
        continue;
      }
      // La fiche doit d'abord être acceptée par le serveur.
      if (doc.syncedAt == null) continue;
      final f = File(e.localPath);
      if (!f.existsSync()) {
        await _retirerEnvoi(e.documentId);
        continue;
      }
      try {
        var adresse = e.uploadUrl;
        var position = e.sentBytes;
        if (adresse == null) {
          adresse = await remote.debutEnvoi(
            compartiment,
            e.objectPath,
            e.sizeBytes,
            e.contentType,
          );
          position = 0;
          await _noter(e.documentId, adresse, 0);
        } else {
          position = await remote.positionEnvoi(adresse);
        }
        final raf = await f.open();
        try {
          while (position < e.sizeBytes) {
            await raf.setPosition(position);
            final morceau = await raf.read(remote.tailleMorceau);
            position = await remote.envoyerMorceau(
              adresse,
              position,
              Uint8List.fromList(morceau),
            );
            await _noter(e.documentId, adresse, position);
          }
        } finally {
          await raf.close();
        }
        await store.save('documents', {
          'id': e.documentId,
          'uploaded_at': store.clock.nowIso(),
        });
        await _retirerEnvoi(e.documentId);
      } on RemoteUnavailable {
        rethrow;
      } on SessionExpired {
        rethrow;
      } on Object catch (err) {
        // Adresse expirée, droits… : on recommence depuis le début.
        await (db.update(
          db.documentUploads,
        )..where((u) => u.documentId.equals(e.documentId))).write(
          DocumentUploadsCompanion(
            uploadUrl: const Value(null),
            sentBytes: const Value(0),
            attempts: Value(e.attempts + 1),
            lastError: Value('$err'),
          ),
        );
      }
    }
  }

  Future<void> _noter(String id, String adresse, int position) =>
      (db.update(
        db.documentUploads,
      )..where((u) => u.documentId.equals(id))).write(
        DocumentUploadsCompanion(
          uploadUrl: Value(adresse),
          sentBytes: Value(position),
        ),
      );

  Future<void> _retirerEnvoi(String id) => (db.delete(
    db.documentUploads,
  )..where((u) => u.documentId.equals(id))).go();

  // ------------------------------- Fichiers ------------------------------

  Future<void> _oublierFichier(String id) async {
    final f = await _fichier(id);
    if (f == null) return;
    final fichier = File(f.localPath);
    if (fichier.existsSync()) await fichier.delete();
    await (db.delete(
      db.documentFiles,
    )..where((x) => x.documentId.equals(id))).go();
  }

  Future<DocumentFileRow?> _fichier(String id) => (db.select(
    db.documentFiles,
  )..where((f) => f.documentId.equals(id))).getSingleOrNull();

  /// Le fichier sur ce téléphone, ou null.
  Future<File?> fichierLocal(String id) async {
    final f = await _fichier(id);
    if (f == null) return null;
    final fichier = File(f.localPath);
    return fichier.existsSync() ? fichier : null;
  }

  /// Ouvre un document : le fichier local, sinon téléchargé (Internet
  /// nécessaire).
  Future<File> obtenir(DocumentRow d) async {
    final local = await fichierLocal(d.id);
    if (local != null) return local;
    final octets = await remote.download(compartiment, d.storagePath!);
    final f = File(p.join(mediaDir!.path, compartiment, d.storagePath));
    await f.parent.create(recursive: true);
    await f.writeAsBytes(octets, flush: true);
    await db
        .into(db.documentFiles)
        .insertOnConflictUpdate(
          DocumentFilesCompanion.insert(
            documentId: d.id,
            localPath: f.path,
            sizeBytes: octets.length,
            savedAt: store.clock.nowIso(),
          ),
        );
    return f;
  }

  /// « Garder sur mon téléphone » : téléchargé maintenant, jamais libéré.
  Future<void> epingler(DocumentRow d, {required bool garder}) async {
    if (garder) await obtenir(d);
    await (db.update(db.documentFiles)..where((f) => f.documentId.equals(d.id)))
        .write(DocumentFilesCompanion(pinned: Value(garder)));
  }

  /// Espace des documents sur ce téléphone.
  Future<int> espaceLocal() async {
    final l = await db.select(db.documentFiles).get();
    return l.fold<int>(0, (s, f) => s + f.sizeBytes);
  }

  /// Libère l'espace : efface les fichiers non épinglés déjà envoyés.
  Future<int> liberer() async {
    final enAttente = {
      for (final e in await db.select(db.documentUploads).get()) e.documentId,
    };
    var libere = 0;
    for (final f in await db.select(db.documentFiles).get()) {
      if (f.pinned || enAttente.contains(f.documentId)) continue;
      final fichier = File(f.localPath);
      if (fichier.existsSync()) await fichier.delete();
      await (db.delete(
        db.documentFiles,
      )..where((x) => x.documentId.equals(f.documentId))).go();
      libere += f.sizeBytes;
    }
    return libere;
  }

  /// Retire un document de ce téléphone seulement : fiche, fichier, envoi
  /// en attente (effacé sur le serveur, ou plus accessible).
  Future<void> oublier(String id) async {
    await _retirerEnvoi(id);
    await _oublierFichier(id);
    await store.deleteLocal(store.table('documents'), {'id': id});
  }

  /// Après une synchronisation : retire du téléphone les documents que le
  /// serveur ne montre plus à cette personne (effacés définitivement, mis à
  /// la corbeille pour un enseignant, droits retirés).
  Future<int> reconcilier() async {
    final visibles = await remote.identifiants('documents');
    final t = store.table('documents');
    var retires = 0;
    for (final d in await db.select(db.documents).get()) {
      if (d.syncedAt == null || visibles.contains(d.id)) continue;
      if (await store.hasPending('documents', t.encodeKey({'id': d.id}))) {
        continue;
      }
      await oublier(d.id);
      retires++;
    }
    return retires;
  }

  // -------------------------------- Fiche --------------------------------

  Future<void> modifier(String id, Map<String, Object?> champs) =>
      store.save('documents', {'id': id, ...champs});

  Future<void> mettreALaCorbeille(String id) =>
      modifier(id, {'trashed_at': store.clock.nowIso()});

  Future<void> restaurer(String id) => modifier(id, {'trashed_at': null});

  Future<void> valider(String id) => modifier(id, {'approved': true});

  /// Espace utilisé d'après le catalogue du téléphone (le serveur donne
  /// le chiffre exact quand on est en ligne).
  Future<int> espaceCatalogue(String schoolId) async {
    final l = await (db.select(
      db.documents,
    )..where((d) => d.schoolId.equals(schoolId) & d.deletedAt.isNull())).get();
    return l.fold<int>(0, (s, d) => s + (d.sizeBytes ?? 0));
  }
}
