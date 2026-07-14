import 'package:flutter/foundation.dart';

/// ============================================================================
/// ForeverCare AI
/// Ligne de commande
/// ============================================================================
///
/// Représente une ligne d'une commande.
///
/// Une commande est composée d'une ou plusieurs lignes.
///
/// Cette entité appartient à la couche Domain.
@immutable
class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  /// Identifiant de la ligne.
  final String id;

  /// Identifiant de la commande.
  final String orderId;

  /// Identifiant du produit.
  final String productId;

  /// Code produit.
  final String productCode;

  /// Nom du produit.
  final String productName;

  /// Prix unitaire.
  final double unitPrice;

  /// Quantité.
  final int quantity;

  /// Montant total de la ligne.
  double get total => unitPrice * quantity;

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productCode,
    String? productName,
    double? unitPrice,
    int? quantity,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is OrderItem &&
        other.id == id &&
        other.orderId == orderId &&
        other.productId == productId &&
        other.productCode == productCode &&
        other.productName == productName &&
        other.unitPrice == unitPrice &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      orderId,
      productId,
      productCode,
      productName,
      unitPrice,
      quantity,
    );
  }

  @override
  String toString() {
    return 'OrderItem('
        'product: $productName, '
        'qty: $quantity, '
        'total: $total'
        ')';
  }
}