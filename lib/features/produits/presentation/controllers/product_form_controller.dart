import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

/// Contrôleur officiel du formulaire Produit.
///
/// Ce contrôleur centralise :
///
/// - les TextEditingController
/// - les validateurs
/// - le cycle de vie
/// - la récupération des données
///
/// Aucune logique métier ici.
class ProductFormController {
  ProductFormController();

  //---------------------------------------------------------------------------
  // Form
  //---------------------------------------------------------------------------

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //---------------------------------------------------------------------------
  // Controllers
  //---------------------------------------------------------------------------

  final TextEditingController codeController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController categoryController = TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController purchasePriceController =
      TextEditingController();

  final TextEditingController salePriceController =
      TextEditingController();

  final TextEditingController stockController =
      TextEditingController();

  final TextEditingController alertStockController =
      TextEditingController();

  //---------------------------------------------------------------------------
  // Etat
  //---------------------------------------------------------------------------

  bool isActive = true;

  //---------------------------------------------------------------------------
  // Validation
  //---------------------------------------------------------------------------

  bool validate() {
    final form = formKey.currentState;

    if (form == null) {
      return false;
    }

    return form.validate();
  }

  //---------------------------------------------------------------------------
  // Setters
  //---------------------------------------------------------------------------

  void setIsActive(bool value) {
    isActive = value;
  }

  //---------------------------------------------------------------------------
  // Helpers
  //---------------------------------------------------------------------------

  String get code => codeController.text.trim();

  String get name => nameController.text.trim();

  String get category => categoryController.text.trim();

  String get description => descriptionController.text.trim();

  double get purchasePrice =>
      double.parse(purchasePriceController.text.trim());

  double get salePrice =>
      double.parse(salePriceController.text.trim());

  int get stock =>
      int.parse(stockController.text.trim());

  int get alertStock =>
      int.parse(alertStockController.text.trim());

  //---------------------------------------------------------------------------
  // Chargement
  //---------------------------------------------------------------------------

  void load(Product product) {
    codeController.text = product.code;
    nameController.text = product.name;
    categoryController.text = product.category;
    descriptionController.text = product.description;
    purchasePriceController.text =
        product.purchasePrice.toString();
    salePriceController.text =
        product.salePrice.toString();
    stockController.text =
        product.stock.toString();
    alertStockController.text =
        product.alertStock.toString();

    isActive = product.isActive;
  }

  //---------------------------------------------------------------------------
  // Validators
  //---------------------------------------------------------------------------

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ obligatoire.';
    }

    return null;
  }

  String? numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ obligatoire.';
    }

    if (double.tryParse(value) == null) {
      return 'Nombre invalide.';
    }

    return null;
  }

  //---------------------------------------------------------------------------
  // Dispose
  //---------------------------------------------------------------------------

  void dispose() {
    codeController.dispose();
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    stockController.dispose();
    alertStockController.dispose();
  }
}