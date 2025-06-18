import 'course.dart';

class Booking {
  final String id;
  final String userId;
  final String courseId;
  final DateTime bookingDate;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt; // Ajouté pour correspondre à la BD
  final String? timeSlotId; // Modifié de timeSlot (String) à timeSlotId (UUID)
  final String? scheduleId; // Ajouté pour correspondre à la BD
  final String? location;
  final int? rating;
  final Course? course;

  Booking({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.bookingDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.timeSlotId,
    this.scheduleId,
    this.location,
    this.rating,
    this.course,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      bookingDate: DateTime.parse(json['booking_date']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.parse(json['created_at']),
      timeSlotId: json['time_slot_id'],
      scheduleId: json['schedule_id'],
      location: json['location'],
      rating: json['rating'],
      course: json['course'] != null ? Course.fromJson(json['course']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'course_id': courseId,
    'booking_date': bookingDate.toIso8601String(),
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'time_slot_id': timeSlotId,
    'schedule_id': scheduleId,
    'location': location,
    'rating': rating,
    'course': course?.toJson(),
  };
  
  // Getters pour faciliter l'accès aux propriétés
  DateTime get date => bookingDate;
  
  // Méthode pour créer une copie modifiée de l'objet
  Booking copyWith({
    String? id,
    String? userId,
    String? courseId,
    DateTime? bookingDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? timeSlotId,
    String? scheduleId,
    String? location,
    int? rating,
    Course? course,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      scheduleId: scheduleId ?? this.scheduleId,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      course: course ?? this.course,
    );
  }
}