class Favorite {
  final String id;
  final String userId;
  final String itemId;
  final String itemType; // 'course' ou 'coach'
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['user_id'],
      itemId: json['item_id'],
      itemType: json['item_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'item_id': itemId,
    'item_type': itemType,
    'created_at': createdAt.toIso8601String(),
  };
}
