import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../clients/domain/entities/client.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../state/order_state.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderController
/// ============================================================================
///
/// Contrôleur de création / modification d'une commande.
///
class OrderController extends Notifier<OrderState> {
  @override
  OrderState build() {
    return OrderState.initial();
  }

  //==========================================================================
  // CLIENT
  //==========================================================================

  /// Sélectionne un client.
  void selectClient(Client client) {
    state = state.copyWith(
      clientId: client.id,
      clientName: client.fullName,
      clientPhone: client.phone,
      clearError: true,
    );
  }

  /// Désélectionne le client.
  void clearClient() {
    state = state.copyWith(
      clearClient: true,
      clearError: true,
    );
  }

  //==========================================================================
  // PRODUITS
  //==========================================================================

  void addItem({
    required String productId,
    required String productCode,
    required String productName,
    required double unitPrice,
    int quantity = 1,
  }) {
    final index = state.items.indexWhere(
      (item) => item.productId == productId,
    );

    final items = [...state.items];

    if (index >= 0) {
      final current = items[index];

      items[index] = current.copyWith(
        quantity: current.quantity + quantity,
      );
    } else {
      items.add(
        OrderItem(
          id: IdGenerator.next(prefix: 'ITM'),
          orderId: '',
          productId: productId,
          productCode: productCode,
          productName: productName,
          unitPrice: unitPrice,
          quantity: quantity,
        ),
      );
    }

    state = state.copyWith(
      items: items,
      clearError: true,
    );
  }

  void removeItem(String itemId) {
    final items = state.items
        .where((item) => item.id != itemId)
        .toList();

    state = state.copyWith(items: items);
  }

  void updateQuantity(
    String itemId,
    int quantity,
  ) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final items = state.items.map((item) {
      if (item.id != itemId) {
        return item;
      }

      return item.copyWith(
        quantity: quantity,
      );
    }).toList();

    state = state.copyWith(items: items);
  }

  //==========================================================================
  // REMISE
  //==========================================================================

  void setDiscount(double discount) {
    state = state.copyWith(
      discount: discount < 0 ? 0 : discount,
    );
  }

  //==========================================================================
  // NOTES
  //==========================================================================

  void setNotes(String notes) {
    state = state.copyWith(
      notes: notes,
    );
  }

  //==========================================================================
  // RESET
  //==========================================================================

  void reset() {
    state = OrderState.initial();
  }

  //==========================================================================
  // VALIDATION
  //==========================================================================

  bool validate() {
    if (!state.hasClient) {
      state = state.copyWith(
        errorMessage:
            'Veuillez sélectionner un client.',
      );
      return false;
    }

    if (!state.hasItems) {
      state = state.copyWith(
        errorMessage:
            'Veuillez ajouter au moins un produit.',
      );
      return false;
    }

    return true;
  }

  //==========================================================================
  // CONSTRUCTION DE LA COMMANDE
  //==========================================================================

  Order buildOrder({
    String? orderId,
    String? orderNumber,
    OrderStatus status = OrderStatus.draft,
  }) {
    final now = DateTime.now();

    final id = orderId ??
        IdGenerator.next(prefix: 'CMD');

    final items = state.items
        .map(
          (item) => item.copyWith(
            orderId: id,
          ),
        )
        .toList();

    return Order(
      id: id,
      orderNumber:
          orderNumber ??
          IdGenerator.next(prefix: 'CMD'),
      clientId: state.clientId!,
      orderDate: now,
      status: status,
      items: items,
      discount: state.discount,
      notes: state.notes,
      createdAt: now,
      updatedAt: now,
    );
  }
}