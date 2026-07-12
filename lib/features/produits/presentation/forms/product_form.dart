import 'package:flutter/material.dart';

import '../../../../design_system/components/form/fc_dropdown_field.dart';
import '../../../../design_system/components/form/fc_text_field.dart';
import '../controllers/product_form_controller.dart';

/// Formulaire officiel de création / modification d'un produit.
///
/// Toute la logique est déléguée au ProductFormController.
class ProductForm extends StatelessWidget {
  const ProductForm({
    super.key,
    required this.controller,
  });

  final ProductFormController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FCTextField(
            label: 'Code produit',
            hint: 'Ex : FLP-001',
            controller: controller.codeController,
            textInputAction: TextInputAction.next,
            validator: controller.requiredValidator,
          ),

          FCTextField(
            label: 'Nom du produit',
            hint: 'Nom du produit',
            controller: controller.nameController,
            textInputAction: TextInputAction.next,
            validator: controller.requiredValidator,
          ),

          FCTextField(
            label: 'Catégorie',
            hint: 'Ex : Nutrition',
            controller: controller.categoryController,
            textInputAction: TextInputAction.next,
            validator: controller.requiredValidator,
          ),

          FCTextField(
            label: 'Description',
            hint: 'Description du produit',
            controller: controller.descriptionController,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          ),

          FCTextField(
            label: 'Prix d\'achat',
            hint: '0',
            controller: controller.purchasePriceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textInputAction: TextInputAction.next,
            validator: controller.numberValidator,
          ),

          FCTextField(
            label: 'Prix de vente',
            hint: '0',
            controller: controller.salePriceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textInputAction: TextInputAction.next,
            validator: controller.numberValidator,
          ),

          FCTextField(
            label: 'Stock',
            hint: '0',
            controller: controller.stockController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: controller.numberValidator,
          ),

          FCTextField(
            label: 'Seuil d\'alerte',
            hint: '0',
            controller: controller.alertStockController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: controller.numberValidator,
          ),

          FCDropdownField<bool>(
            label: 'Statut',
            hint: 'Choisissez le statut',
            value: controller.isActive,
            items: const [true, false],
            itemLabelBuilder: (value) =>
                value ? 'Actif' : 'Inactif',
            onChanged: (value) {
              if (value != null) {
                controller.setIsActive(value);
              }
            },
          ),
        ],
      ),
    );
  }
}