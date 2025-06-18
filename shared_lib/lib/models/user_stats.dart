class UserStats {
  final String id;
  final String userId;
  final int totalSessions;
  final int totalMinutes;
  final int caloriesBurned;
  final Map<String, int> activityBreakdown;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int coursesAttended; // Ajouté pour correspondre à la BD
  final int trainingHours; // Ajouté pour correspondre à la BD
  final int totalBookings; // Ajouté pour correspondre à la BD
  final int totalHours; // Ajouté pour correspondre à la BD
  final String? favoriteActivity; // Ajouté pour correspondre à la BD
  final Map<String, dynamic>? coursesAttendedTrend; // Ajouté pour correspondre à la BD
  final Map<String, dynamic>? trainingHoursTrend; // Ajouté pour correspondre à la BD
  final Map<String, dynamic>? caloriesBurnedTrend; // Ajouté pour correspondre à la BD

  UserStats({
    required this.id,
    required this.userId,
    required this.totalSessions,
    required this.totalMinutes,
    required this.caloriesBurned,
    required this.activityBreakdown,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.coursesAttended = 0,
    this.trainingHours = 0,
    this.totalBookings = 0,
    this.totalHours = 0,
    this.favoriteActivity,
    this.coursesAttendedTrend,
    this.trainingHoursTrend,
    this.caloriesBurnedTrend,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> rawBreakdown = json['activity_breakdown'] ?? {};
    Map<String, int> activityBreakdown = {};
    
    rawBreakdown.forEach((key, value) {
      if (value is int) {
        activityBreakdown[key] = value;
      } else if (value is String) {
        activityBreakdown[key] = int.tryParse(value) ?? 0;
      }
    });

    return UserStats(
      id: json['id'],
      userId: json['user_id'],
      totalSessions: json['total_sessions'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      caloriesBurned: json['calories_burned'] ?? 0,
      activityBreakdown: activityBreakdown,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      coursesAttended: json['courses_attended'] ?? 0,
      trainingHours: json['training_hours'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalHours: json['total_hours'] ?? 0,
      favoriteActivity: json['favorite_activity'],
      coursesAttendedTrend: json['courses_attended_trend'],
      trainingHoursTrend: json['training_hours_trend'],
      caloriesBurnedTrend: json['calories_burned_trend'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'total_sessions': totalSessions,
    'total_minutes': totalMinutes,
    'calories_burned': caloriesBurned,
    'activity_breakdown': activityBreakdown,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'courses_attended': coursesAttended,
    'training_hours': trainingHours,
    'total_bookings': totalBookings,
    'total_hours': totalHours,
    'favorite_activity': favoriteActivity,
    'courses_attended_trend': coursesAttendedTrend,
    'training_hours_trend': trainingHoursTrend,
    'calories_burned_trend': caloriesBurnedTrend,
  };
  
  // Méthode pour accéder aux propriétés via l'opérateur []
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'user_id': return userId;
      case 'total_sessions': return totalSessions;
      case 'total_minutes': return totalMinutes;
      case 'calories_burned': return caloriesBurned;
      case 'activity_breakdown': return activityBreakdown;
      case 'start_date': return startDate;
      case 'end_date': return endDate;
      case 'created_at': return createdAt;
      case 'updated_at': return updatedAt;
      case 'courses_attended': return coursesAttended;
      case 'training_hours': return trainingHours;
      case 'total_bookings': return totalBookings;
      case 'total_hours': return totalHours;
      case 'favorite_activity': return favoriteActivity;
      case 'courses_attended_trend': return coursesAttendedTrend;
      case 'training_hours_trend': return trainingHoursTrend;
      case 'calories_burned_trend': return caloriesBurnedTrend;
      default: return null;
    }
  }
  
  // Méthode pour créer une copie modifiée de l'objet
  UserStats copyWith({
    String? id,
    String? userId,
    int? totalSessions,
    int? totalMinutes,
    int? caloriesBurned,
    Map<String, int>? activityBreakdown,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? coursesAttended,
    int? trainingHours,
    int? totalBookings,
    int? totalHours,
    String? favoriteActivity,
    Map<String, dynamic>? coursesAttendedTrend,
    Map<String, dynamic>? trainingHoursTrend,
    Map<String, dynamic>? caloriesBurnedTrend,
  }) {
    return UserStats(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activityBreakdown: activityBreakdown ?? this.activityBreakdown,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coursesAttended: coursesAttended ?? this.coursesAttended,
      trainingHours: trainingHours ?? this.trainingHours,
      totalBookings: totalBookings ?? this.totalBookings,
      totalHours: totalHours ?? this.totalHours,
      favoriteActivity: favoriteActivity ?? this.favoriteActivity,
      coursesAttendedTrend: coursesAttendedTrend ?? this.coursesAttendedTrend,
      trainingHoursTrend: trainingHoursTrend ?? this.trainingHoursTrend,
      caloriesBurnedTrend: caloriesBurnedTrend ?? this.caloriesBurnedTrend,
    );
  }
  
  // Getters pour faciliter l'accès aux propriétés
  int get sessionsCount => totalSessions;
  int get minutesCount => totalMinutes;
  int get calories => caloriesBurned;
}
