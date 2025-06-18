class Schedule {
  final String id;
  final String courseId;
  final String day;
  final DateTime startTime; // Modifié de String à DateTime pour correspondre à la BD
  final DateTime endTime; // Modifié de String à DateTime pour correspondre à la BD
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.courseId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      courseId: json['course_id'],
      day: json['day'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'day': day,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  
  // Méthode pour accéder aux propriétés via l'opérateur []
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'course_id': return courseId;
      case 'day': return day;
      case 'start_time': return startTime;
      case 'end_time': return endTime;
      case 'created_at': return createdAt;
      case 'updated_at': return updatedAt;
      default: return null;
    }
  }
  
  // Méthode pour créer une copie modifiée de l'objet
  Schedule copyWith({
    String? id,
    String? courseId,
    String? day,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}