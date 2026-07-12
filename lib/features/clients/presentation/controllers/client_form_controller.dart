import 'package:flutter/material.dart';
import '../../domain/entities/client.dart';

/// Contrôleur officiel du formulaire Client.
///
/// Ce contrôleur centralise :
///
/// - les TextEditingController
/// - les validateurs
/// - le cycle de vie (dispose)
/// - la récupération des données
///
/// Il ne contient aucune logique métier
/// ni aucun accès à la base de données.
class ClientFormController {
  ClientFormController();

  //---------------------------------------------------------------------------
  // Form
  //---------------------------------------------------------------------------

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //---------------------------------------------------------------------------
  // Text Controllers
  //---------------------------------------------------------------------------

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  //---------------------------------------------------------------------------
  // Values
  //---------------------------------------------------------------------------

  String? gender;

  DateTime? birthDate;

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

  void setGender(String? value) {
    gender = value;
  }

  void setBirthDate(DateTime? value) {
    birthDate = value;
  }

  //---------------------------------------------------------------------------
  // Helpers
  //---------------------------------------------------------------------------

  String get firstName => firstNameController.text.trim();

  String get lastName => lastNameController.text.trim();

  String get phone => phoneController.text.trim();

  String? get email {
    final value = emailController.text.trim();

    if (value.isEmpty) {
      return null;
    }

    return value;
  }

  //--------------------------------------------------------------------------
  // Initialisation
  //--------------------------------------------------------------------------

  void load(Client client) {
    firstNameController.text = client.firstName;

    lastNameController.text = client.lastName;

    phoneController.text = client.phone;

    emailController.text = client.email ?? '';

    gender = client.gender;

    birthDate = client.birthDate;
  }

  //---------------------------------------------------------------------------
  // Validators
  //---------------------------------------------------------------------------

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le prénom est obligatoire.';
    }

    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire.';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le téléphone est obligatoire.';
    }

    if (value.trim().length < 8) {
      return 'Numéro de téléphone invalide.';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Adresse email invalide.';
    }

    return null;
  }

  //---------------------------------------------------------------------------
  // Dispose
  //---------------------------------------------------------------------------

  void dispose() {
    firstNameController.dispose();

    lastNameController.dispose();

    phoneController.dispose();

    emailController.dispose();
  }
}
