import 'package:test/test.dart';
import 'package:cave_manager/core/cave/infos_cave.dart';
import 'package:cave_manager/core/constants/type_cave.dart';
import 'package:cave_manager/core/ventes/client.dart';
import 'package:cave_manager/core/ventes/commande.dart';
import 'package:cave_manager/core/ventes/commande_ligne.dart';
import 'package:cave_manager/core/ventes/facture_texte.dart';
import 'package:cave_manager/core/ventes/statut_commande.dart';

void main() {
  final commande = Commande(
    id: 'c1',
    caveId: 'cave1',
    clientId: 'cl1',
    statut: StatutCommande.validee,
    total: 15000,
    montantEncaisseEspeces: 10000,
    montantEncaisseMobile: 0,
    createdBy: 'u1',
    createdAt: DateTime.utc(2026, 1, 15, 10, 30),
  );

  final lignes = [
    const CommandeLigne(
      id: 'l1',
      commandeId: 'c1',
      produitId: 'p1',
      produitNom: 'Brakina',
      quantiteCartons: 2,
      quantiteBouteilles: 0,
      prixGrosUnitaire: 6000,
      prixDetailUnitaire: 700,
      sousTotal: 12000,
    ),
  ];

  group('genererTexteFacture', () {
    test('inclut le nom de la cave, les lignes et le total', () {
      final texte = genererTexteFacture(
        cave: const InfosCave(
          nom: 'Cave du Centre',
          telephone: '70000000',
          localisation: 'Ouaga',
          typeCave: TypeCave.vin,
        ),
        commande: commande,
        lignes: lignes,
      );

      expect(texte, contains('Cave du Centre'));
      expect(texte, contains('Brakina x2'));
      expect(texte, contains('12 000'));
      expect(texte, contains('Total'));
      expect(texte, contains('15 000'));
    });

    test('affiche le reste à payer en cas de paiement partiel', () {
      final texte = genererTexteFacture(
        cave: null,
        commande: commande,
        lignes: lignes,
      );

      expect(texte, contains('Reste à payer'));
      expect(texte, contains('5 000'));
    });

    test('cache le reste à payer quand la commande est soldée', () {
      final soldee = Commande(
        id: 'c2',
        caveId: 'cave1',
        clientId: null,
        statut: StatutCommande.validee,
        total: 15000,
        montantEncaisseEspeces: 15000,
        montantEncaisseMobile: 0,
        createdBy: 'u1',
        createdAt: DateTime.utc(2026, 1, 15),
      );

      final texte = genererTexteFacture(
        cave: null,
        commande: soldee,
        lignes: lignes,
      );

      expect(texte, isNot(contains('Reste à payer')));
    });

    test('inclut le nom du client quand fourni', () {
      final texte = genererTexteFacture(
        cave: null,
        commande: commande,
        lignes: lignes,
        client: const Client(id: 'cl1', caveId: 'cave1', nom: 'Awa Traoré'),
      );

      expect(texte, contains('Client : Awa Traoré'));
    });
  });
}
