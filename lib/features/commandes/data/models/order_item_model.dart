class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final String id;

  final String orderId;

  final String productId;

  final String productCode;

  final String productName;

  final double unitPrice;

  final int quantity;

  double get total => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_code': productCode,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrderItemModel(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      productCode: map['product_code'] as String,
      productName: map['product_name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}