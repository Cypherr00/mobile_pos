// data/models/transaction_model.dart
// Sales transaction entity

class PosTransaction {
  final String id;
  final int totalAmountCents;
  final int totalItems;
  final String createdAt;
  final String? cashierId;

  PosTransaction({
    required this.id,
    required this.totalAmountCents,
    required this.totalItems,
    required this.createdAt,
    this.cashierId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_amount_cents': totalAmountCents,
      'total_items': totalItems,
      'created_at': createdAt,
      'is_synced': 0,
      'cashier_id': cashierId,
    };
  }
}