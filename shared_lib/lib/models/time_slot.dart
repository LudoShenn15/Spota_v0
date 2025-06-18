import 'package:intl/intl.dart';

class TimeSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String? courseId;
  final String? coachId;
  final bool isAvailable;
  final int? maxParticipants;
  final int? currentParticipants;
  final DateTime createdAt; // Ajouté pour correspondre à la BD
  final DateTime updatedAt; // Ajouté pour correspondre à la BD

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.courseId,
    this.coachId,
    this.isAvailable = true,
    this.maxParticipants,
    this.currentParticipants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      courseId: json['course_id'],
      coachId: json['coach_id'],
      isAvailable: json['is_available'] ?? true,
      maxParticipants: json['max_participants'],
      currentParticipants: json['current_participants'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'course_id': courseId,
      'coach_id': coachId,
      'is_available': isAvailable,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedStartTime => DateFormat('HH:mm').format(startTime);
  String get formattedEndTime => DateFormat('HH:mm').format(endTime);
  String get formattedDate => DateFormat('dd/MM/yyyy').format(startTime);
  String get formattedTimeRange => '$formattedStartTime - $formattedEndTime';
  
  // Méthode pour accéder aux propriétés via l'opérateur []
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'start_time': return startTime;
      case 'end_time': return endTime;
      case 'course_id': return courseId;
      case 'coach_id': return coachId;
      case 'is_available': return isAvailable;
      case 'max_participants': return maxParticipants;
      case 'current_participants': return currentParticipants;
      case 'created_at': return createdAt;
      case 'updated_at': return updatedAt;
      case 'formatted_start_time': return formattedStartTime;
      case 'formatted_end_time': return formattedEndTime;
      case 'formatted_date': return formattedDate;
      case 'formatted_time_range': return formattedTimeRange;
      default: return null;
    }
  }
  
  // Méthode pour créer une copie modifiée de l'objet
  TimeSlot copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    String? courseId,
    String? coachId,
    bool? isAvailable,
    int? maxParticipants,
    int? currentParticipants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      courseId: courseId ?? this.courseId,
      coachId: coachId ?? this.coachId,
      isAvailable: isAvailable ?? this.isAvailable,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  String get timeRange => '$formattedStartTime - $formattedEndTime';
  bool get isFull => maxParticipants != null && currentParticipants != null && currentParticipants! >= maxParticipants!;
}
