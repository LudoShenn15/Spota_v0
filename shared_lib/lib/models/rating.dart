class Rating {
  final String id;
  final String userId;
  final String itemId;
  final String itemType; // 'course' ou 'coach'
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['user_id'],
      itemId: json['item_id'],
      itemType: json['item_type'],
      rating: (json['rating'] is int) 
          ? (json['rating'] as int).toDouble() 
          : json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'item_id': itemId,
    'item_type': itemType,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
