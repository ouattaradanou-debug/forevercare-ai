import 'package:flutter/material.dart';

/// Contrôleur de recherche des clients.
class ClientSearchController extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  String _query = '';

  String get query => _query;

  void update(String value) {
    _query = value.trim().toLowerCase();
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
