import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Brouillon de fiche client en cours de saisie (voir BrouillonsClient dans
/// app_database.dart). Un seul brouillon actif par utilisateur.
class BrouillonClient {
  const BrouillonClient({
    required this.utilisateurId,
    required this.atelierId,
    this.nom,
    this.prenom,
    this.telephone,
    this.sexe,
    this.datePriseMesures,
    this.typeTenueId,
    Map<String, String>? valeursMesures,
    List<String>? photosTissu,
    List<String>? photosModele,
    required this.misAJourLe,
  }) : valeursMesures = valeursMesures ?? const {},
       photosTissu = photosTissu ?? const [],
       photosModele = photosModele ?? const [];

  final String utilisateurId;
  final String atelierId;
  final String? nom;
  final String? prenom;
  final String? telephone;
  final String? sexe;
  final DateTime? datePriseMesures;
  final String? typeTenueId;
  final Map<String, String> valeursMesures;
  final List<String> photosTissu;
  final List<String> photosModele;
  final DateTime misAJourLe;

  bool get aAuMoinsUneMesureRenseignee =>
      typeTenueId != null &&
      valeursMesures.values.any((v) => v.trim().isNotEmpty);

  bool get estCompletementVide =>
      (nom == null || nom!.trim().isEmpty) &&
      (prenom == null || prenom!.trim().isEmpty) &&
      (telephone == null || telephone!.trim().isEmpty) &&
      sexe == null &&
      datePriseMesures == null &&
      typeTenueId == null &&
      valeursMesures.values.every((v) => v.trim().isEmpty) &&
      photosTissu.isEmpty &&
      photosModele.isEmpty;

  static BrouillonClient vide({
    required String utilisateurId,
    required String atelierId,
  }) {
    return BrouillonClient(
      utilisateurId: utilisateurId,
      atelierId: atelierId,
      misAJourLe: DateTime.now(),
    );
  }

  factory BrouillonClient.depuisLigneLocale(BrouillonClientLocal ligne) {
    return BrouillonClient(
      utilisateurId: ligne.utilisateurId,
      atelierId: ligne.atelierId,
      nom: ligne.nom,
      prenom: ligne.prenom,
      telephone: ligne.telephone,
      sexe: ligne.sexe,
      datePriseMesures: ligne.datePriseMesures,
      typeTenueId: ligne.typeTenueId,
      valeursMesures: ligne.valeursMesuresJson != null
          ? (jsonDecode(ligne.valeursMesuresJson!) as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v.toString()))
          : const {},
      photosTissu: ligne.photosTissuJson != null
          ? List<String>.from(jsonDecode(ligne.photosTissuJson!) as List)
          : const [],
      photosModele: ligne.photosModeleJson != null
          ? List<String>.from(jsonDecode(ligne.photosModeleJson!) as List)
          : const [],
      misAJourLe: ligne.misAJourLe,
    );
  }

  BrouillonsClientCompanion versCompagnonLocal() {
    return BrouillonsClientCompanion(
      utilisateurId: Value(utilisateurId),
      atelierId: Value(atelierId),
      nom: Value(nom),
      prenom: Value(prenom),
      telephone: Value(telephone),
      sexe: Value(sexe),
      datePriseMesures: Value(datePriseMesures),
      typeTenueId: Value(typeTenueId),
      valeursMesuresJson: Value(jsonEncode(valeursMesures)),
      photosTissuJson: Value(jsonEncode(photosTissu)),
      photosModeleJson: Value(jsonEncode(photosModele)),
      misAJourLe: Value(misAJourLe),
    );
  }

  BrouillonClient copierAvec({
    Object? nom = _sentinelle,
    Object? prenom = _sentinelle,
    Object? telephone = _sentinelle,
    Object? sexe = _sentinelle,
    Object? datePriseMesures = _sentinelle,
    Object? typeTenueId = _sentinelle,
    Map<String, String>? valeursMesures,
    List<String>? photosTissu,
    List<String>? photosModele,
  }) {
    return BrouillonClient(
      utilisateurId: utilisateurId,
      atelierId: atelierId,
      nom: nom == _sentinelle ? this.nom : nom as String?,
      prenom: prenom == _sentinelle ? this.prenom : prenom as String?,
      telephone: telephone == _sentinelle
          ? this.telephone
          : telephone as String?,
      sexe: sexe == _sentinelle ? this.sexe : sexe as String?,
      datePriseMesures: datePriseMesures == _sentinelle
          ? this.datePriseMesures
          : datePriseMesures as DateTime?,
      typeTenueId: typeTenueId == _sentinelle
          ? this.typeTenueId
          : typeTenueId as String?,
      valeursMesures: valeursMesures ?? this.valeursMesures,
      photosTissu: photosTissu ?? this.photosTissu,
      photosModele: photosModele ?? this.photosModele,
      misAJourLe: DateTime.now(),
    );
  }
}

const Object _sentinelle = Object();
