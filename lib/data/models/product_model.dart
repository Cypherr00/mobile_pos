// data/models/product_model.dart
// Immutable product entity

class Product {
  final String id; // QR product ID
  final String name;
  final int priceCents; // INTEGER only
  final bool isDeleted;
  final int version;

  Product({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.isDeleted,
    this.version = 1,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      priceCents: map['price_cents'],
      isDeleted: map['is_deleted'] == 1,
      version: map['version'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now().toIso8601String();
    return {
      'id': id,
      'name': name,
      'price_cents': priceCents,
      'created_at': now,
      'version': version,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': 0,
    };
  }
}
