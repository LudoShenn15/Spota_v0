class Coach {
  final String id;
  final String userId;
  final String speciality;
  final String description;
  final List<String> availableDays;
  final String? name;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final String? bio;
  final String? email;
  final String? phone;
  final String? experience; // Ajouté pour correspondre à la BD
  final DateTime createdAt;
  final DateTime updatedAt;

  Coach({
    required this.id,
    required this.userId,
    required this.speciality,
    required this.description,
    required this.availableDays,
    this.name,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.bio,
    this.email,
    this.phone,
    this.experience,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'],
      userId: json['user_id'],
      speciality: json['speciality'],
      description: json['description'],
      availableDays: List<String>.from(json['available_days']),
      name: json['name'],
      imageUrl: json['image_url'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      bio: json['bio'],
      email: json['email'],
      phone: json['phone'],
      experience: json['experience'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'speciality': speciality,
    'description': description,
    'available_days': availableDays,
    'name': name,
    'image_url': imageUrl,
    'rating': rating,
    'review_count': reviewCount,
    'bio': bio,
    'email': email,
    'phone': phone,
    'experience': experience,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  
  // Méthode pour accéder aux propriétés via l'opérateur []
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'user_id': return userId;
      case 'speciality': return speciality;
      case 'description': return description;
      case 'available_days': return availableDays;
      case 'name': return name;
      case 'image_url': return imageUrl;
      case 'rating': return rating;
      case 'review_count': return reviewCount;
      case 'bio': return bio;
      case 'email': return email;
      case 'phone': return phone;
      case 'experience': return experience;
      case 'created_at': return createdAt;
      case 'updated_at': return updatedAt;
      default: return null;
    }
  }
}