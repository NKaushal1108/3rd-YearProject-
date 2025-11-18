/// User model representing the current logged-in user
/// Compatible with Firestore serialization
class User {
  final String id;
  final String name;
  final String email;
  final int paddyFieldCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? passwordHash;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.paddyFieldCount = 0,
    this.createdAt,
    this.updatedAt,
    this.passwordHash,
  });

  // Convert to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'paddyFieldCount': paddyFieldCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'passwordHash': passwordHash,
    };
  }

  // Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'paddyFieldCount': paddyFieldCount,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
      if (passwordHash != null) 'passwordHash': passwordHash,
    };
  }

  // Create from Firestore document
  factory User.fromFirestore(Map<String, dynamic> json, String id) {
    DateTime? parseTimestamp(dynamic ts) {
      if (ts == null) return null;
      // Firestore Timestamp
      try {
        // Avoid importing cloud_firestore here directly by checking common fields
        if (ts is DateTime) return ts;
        // If ts has toDate() (Timestamp), call it
        final toDate = ts.toDate;
        if (toDate is Function) {
          return toDate();
        }
      } catch (_) {}

      // Fallback: try parsing ISO string
      if (ts is String) return DateTime.tryParse(ts);
      return null;
    }

    return User(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      paddyFieldCount: json['paddyFieldCount'] ?? 0,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
      passwordHash: json['passwordHash'] as String?,
    );
  }

  // Create from JSON (for backward compatibility)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      paddyFieldCount: json['paddyFieldCount'] ?? 0,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      passwordHash: json['passwordHash'] as String?,
    );
  }

  // Copy with method for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    int? paddyFieldCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? passwordHash,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      paddyFieldCount: paddyFieldCount ?? this.paddyFieldCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}

