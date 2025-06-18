class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final String? actionType;
  final String? actionId;
  final DateTime createdAt;
  final DateTime updatedAt; // Ajouté pour correspondre à la BD

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    this.actionType,
    this.actionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      actionType: json['action_type'],
      actionId: json['action_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'message': message,
    'is_read': isRead,
    'action_type': actionType,
    'action_id': actionId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  
  // Méthode pour accéder aux propriétés via l'opérateur []
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'user_id': return userId;
      case 'title': return title;
      case 'message': return message;
      case 'is_read': return isRead;
      case 'action_type': return actionType;
      case 'action_id': return actionId;
      case 'created_at': return createdAt;
      case 'updated_at': return updatedAt;
      default: return null;
    }
  }
  
  // Méthode pour créer une copie modifiée de l'objet
  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    bool? isRead,
    String? actionType,
    String? actionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      actionType: actionType ?? this.actionType,
      actionId: actionId ?? this.actionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
