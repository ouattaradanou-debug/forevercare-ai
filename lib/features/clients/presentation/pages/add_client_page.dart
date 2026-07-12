import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/foundations/spacing/app_spacing.dart';
import '../../../../shared/presentation/widgets/buttons/fc_button.dart';
import '../../../../shared/presentation/widgets/cards/fc_card.dart';
import '../../domain/entities/client.dart';
import '../controllers/client_form_controller.dart';
import '../forms/client_form.dart';
import '../providers/client_providers.dart';

/// Page de création d'un client.
class AddClientPage extends ConsumerStatefulWidget {
  const AddClientPage({super.key, this.client});

  /// Null = création
  /// Non null = modification
  final Client? client;

  @override
  ConsumerState<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends ConsumerState<AddClientPage> {
  late final ClientFormController controller;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    controller = ClientFormController();

    if (widget.client != null) {
      controller.load(widget.client!);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!controller.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final isEdit = widget.client != null;

      final client = Client(
        id: isEdit
            ? widget.client!.id
            : DateTime.now().microsecondsSinceEpoch.toString(),
        firstName: controller.firstName,
        lastName: controller.lastName,
        phone: controller.phone,
        email: controller.email,
        gender: controller.gender,
        birthDate: controller.birthDate,
        createdAt: isEdit ? widget.client!.createdAt : DateTime.now(),
      );

      if (isEdit) {
        final updateClient = ref.read(updateClientUseCaseProvider);

        await updateClient(client);
      } else {
        final createClient = ref.read(createClientUseCaseProvider);

        await createClient(client);
      }

      ref.invalidate(clientsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? '${client.fullName} a été mis à jour avec succès.'
                : '${client.fullName} a été enregistré avec succès.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.client == null ? 'Nouveau client' : 'Modifier le client',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FCCard(child: ClientForm(controller: controller)),
              const SizedBox(height: AppSpacing.xxl),
              FCButton(
                label: widget.client == null ? 'Enregistrer' : 'Mettre à jour',
                icon: Icons.save_rounded,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
