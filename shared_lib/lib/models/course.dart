class Course {
  final String id;
  final String title;
  final String? description;
  final int capacity;
  final String coachId;
  final String? coachName;
  final String? imageUrl;
  final double? price;
  final double? rating;
  final int? reviewCount;
  final int? duration; // en minutes
  final String? level; // 'débutant', 'intermédiaire', 'avancé'
  final String? category;
  final bool isActive; // Ajouté pour correspondre à la BD
  final int enrolled; // Ajouté pour correspondre à la BD
  final DateTime? startTime; // Ajouté pour correspondre à la BD
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.title,
    this.description,
    required this.capacity,
    required this.coachId,
    this.coachName,
    this.imageUrl,
    this.price,
    this.rating,
    this.reviewCount,
    this.duration,
    this.level,
    this.category,
    this.isActive = true,
    this.enrolled = 0,
    this.startTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      capacity: json['capacity'],
      coachId: json['coach_id'],
      coachName: json['coach_name'],
      imageUrl: json['image_url'],
      price: json['price']?.toDouble(),
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      duration: json['duration'],
      level: json['level'],
      category: json['category'],
      isActive: json['is_active'] ?? true,
      enrolled: json['enrolled'] ?? 0,
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'capacity': capacity,
    'coach_id': coachId,
    'coach_name': coachName,
    'image_url': imageUrl,
    'price': price,
    'rating': rating,
    'review_count': reviewCount,
    'duration': duration,
    'level': level,
    'category': category,
    'is_active': isActive,
    'enrolled': enrolled,
    'start_time': startTime?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  
  // Méthode pour accéder aux propriétés via l'opérateur []
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'title': return title;
      case 'description': return description;
      case 'capacity': return capacity;
      case 'coach_id': return coachId;
      case 'coach_name': return coachName;
      case 'image_url': return imageUrl;
      case 'price': return price;
      case 'rating': return rating;
      case 'review_count': return reviewCount;
      case 'duration': return duration;
      case 'level': return level;
      case 'category': return category;
      case 'is_active': return isActive;
      case 'enrolled': return enrolled;
      case 'start_time': return startTime;
      case 'created_at': return createdAt;
      case 'updated_at': return updatedAt;
      default: return null;
    }
  }
}