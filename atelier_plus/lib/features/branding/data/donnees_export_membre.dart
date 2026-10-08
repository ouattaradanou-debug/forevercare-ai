import 'dart:convert';

import '../../../data/local/database.dart';
import 'donnees_export_client.dart';

/// Équivalent de [DonneesExportClient] pour un membre de groupe d'uniformes
/// (table `mesures_uniforme` au lieu de `mesures`) — un membre peut avoir
/// plusieurs types de tenue (contrairement à un client, toujours un seul
/// gabarit fixé par son sexe), donc chaque type de tenue avec au moins une
/// mesure donne son propre [GroupeMesureExport].
class DonneesExportMembre {
  DonneesExportMembre(this._baseLocale);

  final AppDatabase _baseLocale;

  Future<List<GroupeMesureExport>> dernieresMesuresParType(String membreId) async {
    final toutes = await _baseLocale.toutesMesuresDuMembre(membreId);

    final derniereParType = <String, MesureUniformeEntry>{};
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
