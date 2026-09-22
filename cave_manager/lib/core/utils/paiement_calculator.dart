/// Résultat du calcul d'un encaissement (point 13 du cahier des charges :
/// espèces, Mobile Money, ou paiement mixte avec calcul automatique du
/// reste à payer en cas de paiement partiel).
class ResultatPaiement {
  const ResultatPaiement({
    required this.totalACharger,
    required this.montantEspeces,
    required this.montantMobileMoney,
    required this.montantPaye,
    required this.resteAPayer,
    required this.estSolde,
  });

  final int totalACharger;
  final int montantEspeces;
  final int montantMobileMoney;
  final int montantPaye;
  final int resteAPayer;
  final bool estSolde;

  @override
  String toString() =>
      'ResultatPaiement(total: $totalACharger, payé: $montantPaye, reste: $resteAPayer, soldé: $estSolde)';
}

/// Calcule le reste à payer d'un encaissement.
///
/// Fonction pure (aucune dépendance UI/DB) pour rester testable
/// unitairement de façon fiable, conformément à l'exigence du prompt
/// ("1 test unitaire sur le calcul du reste à payer : mixte, partiel,
/// exact"). Utilisée par l'écran d'encaissement de la Phase 4.
///
/// Un éventuel trop-perçu n'est pas restitué comme "reste à payer" négatif :
/// le reste est plafonné à 0. La gestion de la monnaie à rendre n'est pas
/// demandée par le cahier des charges (point 31, périmètre V1) et n'est
/// donc pas ajoutée ici.
ResultatPaiement calculerResteAPayer({
  required int totalACharger,
  int montantEspeces = 0,
  int montantMobileMoney = 0,
}) {
  if (totalACharger < 0) {
    throw ArgumentError.value(totalACharger, 'totalACharger', 'ne peut pas être négatif');
  }
  if (montantEspeces < 0) {
    throw ArgumentError.value(montantEspeces, 'montantEspeces', 'ne peut pas être négatif');
  }
  if (montantMobileMoney < 0) {
    throw ArgumentError.value(montantMobileMoney, 'montantMobileMoney', 'ne peut pas être négatif');
  }

  final montantPaye = montantEspeces + montantMobileMoney;
  final ecart = totalACharger - montantPaye;
  final resteAPayer = ecart > 0 ? ecart : 0;

  return ResultatPaiement(
    totalACharger: totalACharger,
    montantEspeces: montantEspeces,
    montantMobileMoney: montantMobileMoney,
    montantPaye: montantPaye,
    resteAPayer: resteAPayer,
    estSolde: resteAPayer == 0,
  );
}
