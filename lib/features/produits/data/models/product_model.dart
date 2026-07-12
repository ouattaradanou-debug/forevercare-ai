import '../../../../core/database/constants/product_constants.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.code,
    required super.name,
    required super.category,
    required super.description,
    required super.purchasePrice,
    required super.salePrice,
    required super.stock,
    required super.alertStock,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[ProductConstants.id] as String,
      code: map[ProductConstants.code] as String,
      name: map[ProductConstants.name] as String,
      category: map[ProductConstants.category] as String,
      description: map[ProductConstants.description] as String? ?? '',
      purchasePrice:
          (map[ProductConstants.purchasePrice] as num).toDouble(),
      salePrice:
          (map[ProductConstants.salePrice] as num).toDouble(),
      stock: map[ProductConstants.stock] as int,
      alertStock: map[ProductConstants.alertStock] as int,
      isActive: (map[ProductConstants.isActive] as int) == 1,
      createdAt: DateTime.parse(
        map[ProductConstants.createdAt] as String,
      ),
      updatedAt: DateTime.parse(
        map[ProductConstants.updatedAt] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ProductConstants.id: id,
      ProductConstants.code: code,
      ProductConstants.name: name,
      ProductConstants.category: category,
      ProductConstants.description: description,
      ProductConstants.purchasePrice: purchasePrice,
      ProductConstants.salePrice: salePrice,
      ProductConstants.stock: stock,
      ProductConstants.alertStock: alertStock,
      ProductConstants.isActive: isActive ? 1 : 0,
      ProductConstants.createdAt: createdAt.toIso8601String(),
      ProductConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      code: product.code,
      name: product.name,
      category: product.category,
      description: product.description,
      purchasePrice: product.purchasePrice,
      salePrice: product.salePrice,
      stock: product.stock,
      alertStock: product.alertStock,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      code: code,
      name: name,
      category: category,
      description: description,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      stock: stock,
      alertStock: alertStock,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}