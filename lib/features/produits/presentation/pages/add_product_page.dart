import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/foundations/spacing/app_spacing.dart';
import '../../../../shared/presentation/widgets/buttons/fc_button.dart';
import '../../../../shared/presentation/widgets/cards/fc_card.dart';
import '../../domain/entities/product.dart';
import '../controllers/product_form_controller.dart';
import '../forms/product_form.dart';
import '../providers/product_providers.dart';

/// Page de création / modification d'un produit.
class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({
    super.key,
    this.product,
  });

  /// Null = création
  /// Non null = modification
  final Product? product;

  @override
  ConsumerState<AddProductPage> createState() =>
      _AddProductPageState();
}

class _AddProductPageState
    extends ConsumerState<AddProductPage> {
  late final ProductFormController controller;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    controller = ProductFormController();

    if (widget.product != null) {
      controller.load(widget.product!);
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
      final isEdit = widget.product != null;

      final product = Product(
        id: isEdit
            ? widget.product!.id
            : DateTime.now().microsecondsSinceEpoch.toString(),
        code: controller.code,
        name: controller.name,
        category: controller.category,
        description: controller.description,
        purchasePrice: controller.purchasePrice,
        salePrice: controller.salePrice,
        stock: controller.stock,
        alertStock: controller.alertStock,
        isActive: controller.isActive,
        createdAt:
            isEdit ? widget.product!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEdit) {
        final updateProduct =
            ref.read(updateProductUseCaseProvider);

        await updateProduct(product);
      } else {
        final createProduct =
            ref.read(createProductUseCaseProvider);

        await createProduct(product);
      }

      ref.invalidate(productsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? '${product.name} a été mis à jour avec succès.'
                : '${product.name} a été enregistré avec succès.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'enregistrement : $e',
          ),
        ),
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
          widget.product == null
              ? 'Nouveau produit'
              : 'Modifier le produit',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FCCard(
                child: ProductForm(
                  controller: controller,
                ),
              ),
              const SizedBox(
                height: AppSpacing.xxl,
              ),
              FCButton(
                label: widget.product == null
                    ? 'Enregistrer'
                    : 'Mettre à jour',
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