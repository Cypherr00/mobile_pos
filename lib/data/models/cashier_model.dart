// data/models/cashier_model.dart

class Cashier {
  final String id;
  final String name;
  final String pinHash;
  final String role;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Cashier({
    required this.id,
    required this.name,
    required this.pinHash,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cashier.fromMap(Map<String, dynamic> map) {
    return Cashier(
      id: map['id'] as String,
      name: map['name'] as String,
      pinHash: map['pin_hash'] as String,
      role: map['role'] as String,
      isActive: (map['is_active'] is int)
          ? (map['is_active'] as int) == 1
          : (map['is_active'] as bool? ?? true),
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pin_hash': pinHash,
      'role': role,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isAdmin => role == 'admin';
}
