import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/widgets/en_tete_section.dart';
import '../../../shared/widgets/selection_sexe_et_mesures.dart';
import '../../auth/providers/auth_providers.dart';
import '../../mesures/providers/gabarits_providers.dart';
import '../../mesures/utils/choix_gabarit.dart';
import '../providers/uniformes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Création d'un membre de groupe en un seul écran : nom/prénom, sexe, puis
/// immédiatement les champs de mesure du gabarit par défaut de ce sexe —
/// même principe que "Nouveau client" (voir SectionMesuresParSexe, partagé
/// entre les deux écrans), au lieu d'un petit formulaire suivi d'un choix
/// manuel du type de tenue.
class EcranNouveauMembre extends ConsumerStatefulWidget {
  const EcranNouveauMembre({super.key, required this.groupeId});

  final String groupeId;

  @override
  ConsumerState<EcranNouveauMembre> createState() => _EcranNouveauMembreState();
}

class _EcranNouveauMembreState extends ConsumerState<EcranNouveauMembre> {
  final _nomCtrl = TextEditingController();
  final Map<String, TextEditingController> _controleursMesure = {};
  final _dicteeVocale = stt.SpeechToText();

  String? _sexe;
  bool _dicteeDisponible = false;
  bool _enEcoute = false;
  bool _enregistrementEnCours = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(gabaritsRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    for (final c in _controleursMesure.values) {
      c.dispose();
    }
    _dicteeVocale.stop();
    super.dispose();
  }

  TextEditingController _controleurMesure(String champId) {
    return _controleursMesure.putIfAbsent(champId, () => TextEditingController());
  }

  Future<void> _basculerDictee() async {
    if (_enEcoute) {
      await _dicteeVocale.stop();
      if (mounted) setState(() => _enEcoute = false);
      return;
    }

    if (!_dicteeDisponible) {
      _dicteeDisponible = await _dicteeVocale.initialize(
        onStatus: (statut) {
          if ((statut == 'done' || statut == 'notListening') && mounted) {
            setState(() => _enEcoute = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _enEcoute = false);
        },
      );
      if (!_dicteeDisponible) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dictée vocale indisponible sur cet appareil.')),
          );
        }
        return;
      }
    }

    setState(() => _enEcoute = true);
    await _dicteeVocale.listen(
      localeId: 'fr_FR',
      onResult: (resultat) {
        _nomCtrl.text = resultat.recognizedWords;
        _nomCtrl.selection = TextSelection.collapsed(offset: _nomCtrl.text.length);
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _enregistrer() async {
    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) {
      setState(() => _erreur = 'Renseignez le nom et prénom du membre.');
      return;
    }

    setState(() {
      _enregistrementEnCours = true;
      _erreur = null;
    });
    try {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      final membre = await ref.read(membresGroupeUniformeRepositoryProvider).ajouterMembre(
            atelierId: utilisateur!.atelierId,
            groupeId: widget.groupeId,
            nom: nom,
            prenom: null,
            sexe: _sexe,
          );

      if (_sexe != null) {
        final valeurs = <String, String>{};
        for (final entree in _controleursMesure.entries) {
          final texte = entree.value.text.trim();
          if (texte.isNotEmpty) valeurs[entree.key] = texte;
        }
        if (valeurs.isNotEmpty) {
          final gabarits = await ref.read(typesTenueVisiblesProvider.future);
          final gabarit = choisirGabaritPourSexe(gabarits, utilisateur.atelierId, _sexe!);
          if (gabarit != null) {
            await ref.read(mesuresUniformeRepositoryProvider).enregistrerNouvellePrise(
                  atelierId: utilisateur.atelierId,
                  membreId: membre.id,
                  typeTenueId: gabarit.id,
                  valeurs: valeurs,
                  prisePar: utilisateur.id,
                );
          }
        }
      }

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      appBar: AppBar(
        title: const Text('Nouveau membre'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EnTeteSection(
                    icone: Icons.badge_outlined,
                    couleurFond: const Color(0xFFE3E1F5),
                    couleurIcone: const Color(0xFF3B3470),
                    titre: 'Informations du membre',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nom et prénom',
                      prefixIcon: IconButton(
                        icon: Icon(_enEcoute ? Icons.mic : Icons.mic_none),
                        color: _enEcoute ? Colors.red : _bleuSeda,
                        tooltip: 'Dicter le nom',
                        onPressed: _basculerDictee,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Sexe', style: TextStyle(color: Color(0xFF6F6259))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CarteSexe(
                          icone: Icons.male,
                          libelle: 'Homme',
                          selectionne: _sexe == 'Homme',
                          onTap: () => setState(() => _sexe = 'Homme'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CarteSexe(
                          icone: Icons.female,
                          libelle: 'Femme',
                          selectionne: _sexe == 'Femme',
                          onTap: () => setState(() => _sexe = 'Femme'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  EnTeteSection(
                    icone: Icons.straighten_outlined,
                    couleurFond: const Color(0xFFF5DCD3),
                    couleurIcone: const Color(0xFF8A4B24),
                    titre: 'Mesures',
                  ),
                  const SizedBox(height: 12),
                  if (_sexe == null)
                    const Text(
                      'Choisissez le sexe ci-dessus pour afficher les champs de mesure.',
                      style: TextStyle(color: Color(0xFF6F6259)),
                    )
                  else
                    SectionMesuresParSexe(
                      sexe: _sexe!,
                      controleurPour: _controleurMesure,
                    ),
                  if (_erreur != null) ...[
                    const SizedBox(height: 12),
                    Text(_erreur!, style: const TextStyle(color: Color(0xFFB3261E))),
                  ],
                ],
              ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6F1),
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: FilledButton(
            onPressed: _enregistrementEnCours ? null : _enregistrer,
            style: FilledButton.styleFrom(
              backgroundColor: _orangeSeda,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            child: _enregistrementEnCours
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Ajouter le membre'),
          ),
        ),
      ),
    );
  }
}
