class SubscriptionType {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationInDays;
  final bool isActive;
  final Map<String, dynamic>? features; // Ajouté pour correspondre à la BD
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionType({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInDays,
    this.isActive = true,
    this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionType.fromJson(Map<String, dynamic> json) {
    return SubscriptionType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      durationInDays: json['duration_in_days'],
      isActive: json['is_active'] ?? true,
      features: json['features'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'duration_in_days': durationInDays,
    'is_active': isActive,
    'features': features,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}