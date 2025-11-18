class PaddyField {
  final String id;
  final String name;
  final String location;
  final double areaSize; // in acres
  final DateTime createdAt;

  PaddyField({
    required this.id,
    required this.name,
    required this.location,
    required this.areaSize,
    required this.createdAt,
  });

  // Convert to JSON for potential future storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'areaSize': areaSize,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory PaddyField.fromJson(Map<String, dynamic> json) {
    return PaddyField(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      areaSize: json['areaSize'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

