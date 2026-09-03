import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/local/database.dart';
import '../../../data/models/abonnement.dart';

/// Lecture de l'abonnement de l'atelier. Aucune méthode d'écriture : la
/// ligne est gérée entièrement côté serveur (déclencheur SQL à la création
/// de l'atelier, puis — hors périmètre de cette application, non spécifié
/// au cahier des charges — une fonction Edge avec la clé `service_role`
/// après confirmation de paiement réel).
class AbonnementRepository {
  AbonnementRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;

  Future<void> chargerDepuisServeur(String atelierId) async {
    try {
      final ligne = await _client
          .from('abonnements')
          .select()
          .eq('atelier_id', atelierId)
          .maybeSingle();
      if (ligne == null) return;

      final abonnement = Abonnement.depuisJson(ligne);
      await _baseLocale.enregistrerAbonnement(
        id: abonnement.id,
        atelierId: abonnement.atelierId,
        statut: abonnement.statut,
        dateFinEssai: abonnement.dateFinEssai,
        dateRenouvellement: abonnement.dateRenouvellement,
      );
    } catch (_) {
      // Hors-ligne : le cache existant (ou son absence) reste la seule
      // source disponible — voir verifierEcritureAutorisee, qui n'échoue
      // jamais par excès de prudence en l'absence de cache.
    }
  }

  Stream<Abonnement?> observerAbonnement(String atelierId) {
    return _baseLocale.observerAbonnement(atelierId).map((ligne) {
      if (ligne == null) return null;
      return Abonnement(
        id: ligne.id,
        atelierId: ligne.atelierId,
        statut: ligne.statut,
        dateFinEssai: ligne.dateFinEssai,
        dateRenouvellement: ligne.dateRenouvellement,
      );
    });
  }
}
