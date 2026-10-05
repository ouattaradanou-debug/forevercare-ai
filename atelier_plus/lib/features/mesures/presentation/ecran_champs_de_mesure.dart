import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../data/models/champ_mesure.dart';
import '../../../data/models/type_tenue.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/gabarits_providers.dart';

const _navyAjouter = Color(0xFF141B3E);

/// "Champs de mesure" tel que dans l'ancienne application : un choix
/// Homme/Femme, puis la liste des champs de ce gabarit avec un
/// interrupteur pour désactiver ceux qui ne concernent pas l'atelier, et
/// un bouton pour en ajouter un qui ne figure pas dans la liste.
///
/// Contrairement à "Mes types de tenue", cet écran ne montre jamais le
/// gabarit par défaut partagé lui-même (lecture seule entre ateliers) :
/// il résout (et duplique si besoin, de façon transparente) la copie
/// propre à CET atelier — voir GabaritsRepository.gabaritModifiablePourSexe.
class EcranChampsDeMesure extends ConsumerStatefulWidget {
  const EcranChampsDeMesure({super.key});

  @override
  ConsumerState<EcranChampsDeMesure> createState() => _EcranChampsDeMesureState();
}

class _EcranChampsDeMesureState extends ConsumerState<EcranChampsDeMesure> {
  String _sexe = 'Homme';

  Future<void> _ajouterChamp(TypeTenue gabarit) async {
    final controleur = TextEditingController();
    final nom = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau champ de mesure'),
        content: TextField(
          controller: controleur,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom du champ (ex : Tour de mollet)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controleur.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (nom != null && nom.isNotEmpty && mounted) {
      await ref.read(gabaritsRepositoryProvider).ajouterChamp(
            typeTenueId: gabarit.id,
            nom: nom,
            atelierId: gabarit.atelierId,
          );
    }
  }

  Future<void> _demanderMasquage(TypeTenue gabarit, ChampMesure champ) async {
    final repo = ref.read(gabaritsRepositoryProvider);
    final utilise = await repo.champUtiliseParDesMesures(champ);
    if (!mounted) return;

    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Désactiver "${champ.nom}" ?'),
        content: Text(
          utilise
              ? 'Ce champ a déjà été utilisé dans des mesures existantes. '
                  'Le désactiver ne supprime pas cet historique, mais il '
                  'n\'apparaîtra plus dans les nouvelles prises de mesure.'
              : 'Ce champ n\'apparaîtra plus dans les nouvelles prises de mesure. '
                  'Il pourra être réactivé plus tard.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Désactiver')),
        ],
      ),
    );

    if (confirmer == true && mounted) {
      await executerAvecErreurAffichee(
        context,
        () => repo.masquerChamp(champ, atelierId: gabarit.atelierId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = ref.watch(utilisateurCourantProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Champs de mesure')),
      body: utilisateur == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _BasculeSexe(
                      sexe: _sexe,
                      onChange: (valeur) => setState(() => _sexe = valeur),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      'Désactive les champs qui ne concernent pas ton atelier, '
                      'ou ajoute-en un qui ne figure pas dans la liste.',
                      style: TextStyle(color: Color(0xFF6F6259)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<TypeTenue>(
                      future: ref
                          .read(gabaritsRepositoryProvider)
                          .gabaritModifiablePourSexe(
                            atelierId: utilisateur.atelierId,
                            sexe: _sexe,
                          ),
                      builder: (context, snapshotGabarit) {
                        if (snapshotGabarit.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshotGabarit.hasError || !snapshotGabarit.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Connectez-vous à internet une première fois pour '
                                'récupérer les champs de mesure.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final gabarit = snapshotGabarit.data!;
                        final champs = ref.watch(tousLesChampsProvider(gabarit.id));

                        return champs.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
                          data: (liste) => Stack(
                            children: [
                              ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: liste.length,
                                itemBuilder: (context, index) {
                                  final champ = liste[index];
                                  final actif = champ.statut == StatutChamp.actif;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: const [
                                          BoxShadow(color: Color(0x14000000), blurRadius: 4),
                                        ],
                                      ),
                                      child: SwitchListTile(
                                        title: Text('${champ.nom} (${champ.unite})'),
                                        value: actif,
                                        activeColor: AppColors.primaire,
                                        onChanged: (valeur) async {
                                          if (valeur) {
                                            await executerAvecErreurAffichee(
                                              context,
                                              () => ref
                                                  .read(gabaritsRepositoryProvider)
                                                  .reactiverChamp(
                                                    champ,
                                                    atelierId: gabarit.atelierId,
                                                  ),
                                            );
                                          } else {
                                            await _demanderMasquage(gabarit, champ);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                right: 20,
                                bottom: 16,
                                child: FloatingActionButton.extended(
                                  onPressed: () => _ajouterChamp(gabarit),
                                  backgroundColor: _navyAjouter,
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  label: const Text(
                                    'Ajouter un champ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Sélecteur pilule Homme/Femme fidèle à l'ancienne application : moitié
/// sélectionnée en terre cuite avec coche blanche, moitié non sélectionnée
/// blanche avec simple bordure.
class _BasculeSexe extends StatelessWidget {
  const _BasculeSexe({required this.sexe, required this.onChange});

  final String sexe;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDD3C8)),
      ),
      child: Row(
        children: [
          Expanded(child: _option(context, 'Homme')),
          Expanded(child: _option(context, 'Femme')),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String valeur) {
    final selectionne = sexe == valeur;
    return GestureDetector(
      onTap: () => onChange(valeur),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectionne ? AppColors.primaire : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectionne) ...[
              const Icon(Icons.check, color: Colors.white, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              valeur,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectionne ? Colors.white : const Color(0xFF231A14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
