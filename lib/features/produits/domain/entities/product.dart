import 'package:flutter/foundation.dart';

@immutable
class Product {
  final String id;
  final String code;
  final String name;
  final String category;
  final String description;
  final double purchasePrice;
  final double salePrice;
  final int stock;
  final int alertStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.description,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
    required this.alertStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? code,
    String? name,
    String? category,
    String? description,
    double? purchasePrice,
    double? salePrice,
    int? stock,
    int? alertStock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      alertStock: alertStock ?? this.alertStock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => stock <= alertStock;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.code == code &&
        other.name == name &&
        other.category == category &&
        other.description == description &&
        other.purchasePrice == purchasePrice &&
        other.salePrice == salePrice &&
        other.stock == stock &&
        other.alertStock == alertStock &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      code,
      name,
      category,
      description,
      purchasePrice,
      salePrice,
      stock,
      alertStock,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, code: $code, name: $name, stock: $stock)';
  }
}