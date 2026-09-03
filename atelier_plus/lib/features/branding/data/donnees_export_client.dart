import 'dart:convert';

import '../../../data/local/database.dart';

/// Une ligne du tableau de mesures pour un type de tenue donné.
class LigneMesureExport {
  const LigneMesureExport({required this.nomChamp, required this.valeur, required this.unite});

  final String nomChamp;
  final String valeur;
  final String unite;
}

/// Dernières mesures connues pour un type de tenue, prêtes à afficher
/// (noms de champs résolus, pas des identifiants techniques).
class GroupeMesureExport {
  const GroupeMesureExport({
    required this.nomTypeTenue,
    required this.datePrise,
    required this.lignes,
  });

  final String nomTypeTenue;
  final DateTime datePrise;
  final List<LigneMesureExport> lignes;
}

/// Compose les données de mesures d'un client pour l'export PDF (Phase 4) :
/// une seule "photo" par type de tenue (la dernière prise), avec les noms
/// de champs déjà résolus plutôt que leurs identifiants techniques.
class DonneesExportClient {
  DonneesExportClient(this._baseLocale);

  final AppDatabase _baseLocale;

  Future<List<GroupeMesureExport>> dernieresMesuresParType(String clientId) async {
    final toutes = await _baseLocale.toutesMesuresDuClient(clientId);

    final derniereParType = <String, MesureEntry>{};
    for (final mesure in toutes) {
      final existante = derniereParType[mesure.typeTenueId];
      if (existante == null || mesure.datePrise.isAfter(existante.datePrise)) {
        derniereParType[mesure.typeTenueId] = mesure;
      }
    }

    final resultats = <GroupeMesureExport>[];
    for (final entree in derniereParType.entries) {
      final type = await _baseLocale.typeTenueParId(entree.key);
      if (type == null) continue;

      final valeurs = jsonDecode(entree.value.valeursJson) as Map<String, dynamic>;
      final lignes = <LigneMesureExport>[];
      for (final valeurEntree in valeurs.entries) {
        final champ = await _baseLocale.champMesureParId(valeurEntree.key);
        if (champ == null) continue;
        lignes.add(
          LigneMesureExport(
            nomChamp: champ.nom,
            valeur: valeurEntree.value.toString(),
            unite: champ.unite,
          ),
        );
      }

      resultats.add(
        GroupeMesureExport(
          nomTypeTenue: type.nom,
          datePrise: entree.value.datePrise,
          lignes: lignes,
        ),
      );
    }

    resultats.sort((a, b) => a.nomTypeTenue.compareTo(b.nomTypeTenue));
    return resultats;
  }
}
