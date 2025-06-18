class User {
  final String id;
  final String email;
  final String? fullName;
  final String? phone; // Renommé de phoneNumber à phone pour correspondre à la BD
  final String? photoUrl;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt; // Ajouté pour correspondre à la BD

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.photoUrl,
    this.isAdmin = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      photoUrl: json['photo_url'],
      isAdmin: json['is_admin'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'photo_url': photoUrl,
    'is_admin': isAdmin,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  
  // Méthode pour accéder aux propriétés via l'opérateur []
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'email': return email;
      case 'full_name': return fullName;
      case 'phone': return phone;
      case 'photo_url': return photoUrl;
      case 'is_admin': return isAdmin;
      case 'created_at': return createdAt;
      case 'updated_at': return updatedAt;
      default: return null;
    }
  }
  
  // Méthode pour créer une copie modifiée de l'objet
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? photoUrl,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// La classe AppUser a été supprimée et remplacée par la classe User mise à jour