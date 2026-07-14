import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/order_controller.dart';
import '../state/order_state.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderController Provider
/// ============================================================================
///
/// Provider officiel du contrôleur des commandes.
///
/// Toutes les pages du module Commandes doivent utiliser
/// ce provider pour accéder à l'état et aux actions.
///
final orderControllerProvider =
    NotifierProvider<OrderController, OrderState>(
  OrderController.new,
);