// data/models/transaction_item_model.dart
// Snapshot of items sold per transaction

class TransactionItem {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final int priceCents;
  final int quantity;

  TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.priceCents,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'price_cents': priceCents,
      'quantity': quantity,
    };
  }
}