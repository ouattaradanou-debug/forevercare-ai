import 'package:flutter/foundation.dart';

import 'order_item.dart';

/// ============================================================================
/// ForeverCare AI
/// Entité Commande
/// ============================================================================
///
/// Représente une commande complète.
///
/// Une commande est composée :
///
/// - d'informations générales
/// - d'un client
/// - d'une liste de lignes (OrderItem)
///
@immutable
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.clientId,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.discount,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Identifiant unique.
  final String id;

  /// Numéro de commande.
  final String orderNumber;

  /// Client concerné.
  final String clientId;

  /// Date de la commande.
  final DateTime orderDate;

  /// Statut.
  final OrderStatus status;

  /// Lignes de commande.
  final List<OrderItem> items;

  /// Remise globale.
  final double discount;

  /// Notes.
  final String notes;

  /// Date de création.
  final DateTime createdAt;

  /// Dernière modification.
  final DateTime updatedAt;

  /// Total avant remise.
  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.total);

  /// Total après remise.
  double get total => subtotal - discount;

  bool get isCompleted => status == OrderStatus.completed;

  bool get isCancelled => status == OrderStatus.cancelled;

  Order copyWith({
    String? id,
    String? orderNumber,
    String? clientId,
    DateTime? orderDate,
    OrderStatus? status,
    List<OrderItem>? items,
    double? discount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      clientId: clientId ?? this.clientId,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Order &&
        other.id == id &&
        other.orderNumber == orderNumber &&
        other.clientId == clientId &&
        other.orderDate == orderDate &&
        other.status == status &&
        listEquals(other.items, items) &&
        other.discount == discount &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        orderNumber,
        clientId,
        orderDate,
        status,
        Object.hashAll(items),
        discount,
        notes,
        createdAt,
        updatedAt,
      );

  @override
  String toString() {
    return 'Order('
        'number: $orderNumber, '
        'items: ${items.length}, '
        'total: $total'
        ')';
  }
}

/// Statuts officiels d'une commande.
enum OrderStatus {
  draft,
  confirmed,
  completed,
  cancelled,
}