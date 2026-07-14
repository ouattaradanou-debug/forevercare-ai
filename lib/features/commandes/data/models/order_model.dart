import 'order_item_model.dart';

/// ============================================================================
/// ForeverCare AI
/// Data Model : Order
/// ============================================================================
///
/// Représentation SQLite d'une commande.
///
/// Ce modèle ne connaît ni Flutter,
/// ni Riverpod,
/// ni le Domain.
///
/// Il est uniquement responsable de la persistance.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.clientId,
    required this.orderDate,
    required this.status,
    required this.discount,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  final String id;

  final String orderNumber;

  final String clientId;

  final DateTime orderDate;

  /// draft / confirmed / completed / cancelled
  final String status;

  final double discount;

  final String notes;

  final DateTime createdAt;

  final DateTime updatedAt;

  /// Lignes de commande.
  ///
  /// Elles seront enregistrées dans une table
  /// indépendante (order_items).
  final List<OrderItemModel> items;

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? clientId,
    DateTime? orderDate,
    String? status,
    double? discount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemModel>? items,
    }) {
    return OrderModel(
        id: id ?? this.id,
        orderNumber: orderNumber ?? this.orderNumber,
        clientId: clientId ?? this.clientId,
        orderDate: orderDate ?? this.orderDate,
        status: status ?? this.status,
        discount: discount ?? this.discount,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        items: items ?? this.items,
    );
    }




  //---------------------------------------------------------------------------
  // SQLite
  //---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'client_id': clientId,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'discount': discount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(
    Map<String, dynamic> map, {
    List<OrderItemModel> items = const [],
  }) {
    return OrderModel(
      id: map['id'] as String,
      orderNumber: map['order_number'] as String,
      clientId: map['client_id'] as String,
      orderDate: DateTime.parse(
        map['order_date'] as String,
      ),
      status: map['status'] as String,
      discount: (map['discount'] as num).toDouble(),
      notes: (map['notes'] ?? '') as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
      items: items,
    );
  }
}