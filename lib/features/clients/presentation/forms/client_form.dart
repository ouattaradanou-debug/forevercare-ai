import 'package:flutter/material.dart';

import '../../../../design_system/components/form/fc_date_field.dart';
import '../../../../design_system/components/form/fc_dropdown_field.dart';
import '../../../../design_system/components/form/fc_text_field.dart';
import '../controllers/client_form_controller.dart';

/// Formulaire officiel de création/modification d'un client.
///
/// Ce widget ne contient aucune logique métier.
/// Toute la logique est déléguée au ClientFormController.
class ClientForm extends StatelessWidget {
  const ClientForm({super.key, required this.controller});

  final ClientFormController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FCTextField(
            label: 'Prénom',
            hint: 'Saisissez le prénom',
            controller: controller.firstNameController,
            textInputAction: TextInputAction.next,
            validator: controller.validateFirstName,
          ),

          FCTextField(
            label: 'Nom',
            hint: 'Saisissez le nom',
            controller: controller.lastNameController,
            textInputAction: TextInputAction.next,
            validator: controller.validateLastName,
          ),

          FCTextField(
            label: 'Téléphone',
            hint: 'Saisissez le numéro',
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: controller.validatePhone,
          ),

          FCTextField(
            label: 'Adresse email',
            hint: 'exemple@email.com',
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: controller.validateEmail,
          ),

          FCDropdownField<String>(
            label: 'Sexe',
            hint: 'Sélectionnez le sexe',
            value: controller.gender,
            items: const ['Homme', 'Femme'],
            onChanged: controller.setGender,
          ),

          FCDateField(
            label: 'Date de naissance',
            hint: 'Sélectionnez une date',
            initialDate: controller.birthDate,
            lastDate: DateTime.now(),
            onChanged: controller.setBirthDate,
          ),
        ],
      ),
    );
  }
}
