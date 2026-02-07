// data/models/cart_item_model.dart
// Immutable cart item

class CartItem {
  final String productId;
  final String name;
  final int priceCents;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.priceCents,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      priceCents: priceCents,
      quantity: quantity ?? this.quantity,
    );
  }
}