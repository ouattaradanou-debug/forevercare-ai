import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';

import '../providers/auth_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Capture de la signature manuscrite du tailleur (une fois), réutilisée
/// ensuite sur chaque facture PDF. Réservé au propriétaire : `EcranParametres`
/// cache déjà ce point d'entrée à un apprenti, mais la route reste
/// atteignable directement (lien profond) — vérifié ICI aussi en défense en
/// profondeur, comme les autres écrans réservés au propriétaire.
class EcranSignatureAtelier extends ConsumerStatefulWidget {
  const EcranSignatureAtelier({super.key});

  @override
  ConsumerState<EcranSignatureAtelier> createState() => _EcranSignatureAtelierState();
}

class _EcranSignatureAtelierState extends ConsumerState<EcranSignatureAtelier> {
  late final SignatureController _controleur;
  bool _enregistrementEnCours = false;

  @override
  void initState() {
    super.initState();
    _controleur = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_controleur.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez dessiner votre signature avant d\'enregistrer.')),
      );
      return;
    }

    final octets = await _controleur.toPngBytes();
    if (octets == null) return;

    setState(() => _enregistrementEnCours = true);
    try {
      final atelier = await ref.read(atelierCourantProvider.future);
      if (atelier == null) return;

      await ref.read(authRepositoryProvider).enregistrerSignatureAtelier(
            atelierActuel: atelier,
            signaturePng: octets,
          );
      ref.invalidate(atelierCourantProvider);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Signature enregistrée.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Échec de l\'enregistrement : $e')));
      }
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estProprietaire = ref.watch(estProprietaireProvider);

    if (!estProprietaire) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ma signature')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Seul le propriétaire de l\'atelier peut modifier la signature.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final atelierAsync = ref.watch(atelierCourantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma signature'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dessinez votre signature ci-dessous avec le doigt. Elle sera '
                'imprimée sur chaque facture, à côté du nom de l\'atelier.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              atelierAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (atelier) {
                  final signatureActuelle = atelier?.signatureUrl;
                  if (signatureActuelle == null) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Signature actuellement enregistrée :',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD8D2C8)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: signatureActuelle,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              const Text(
                'Nouvelle signature :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: _bleuSeda, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: _controleur,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _controleur.clear(),
                style: OutlinedButton.styleFrom(foregroundColor: _bleuSeda),
                icon: const Icon(Icons.refresh),
                label: const Text('Effacer'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _enregistrementEnCours ? null : _enregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orangeSeda,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _enregistrementEnCours
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer ma signature'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
