class Subscription {
  final String id;
  final String userId;
  final String typeId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? name;
  final String? description;
  final double? price;
  final int? durationDays;
  final int? sessionsPerMonth;
  final Map<String, dynamic>? features;
  final bool autoRenew; // Ajouté pour correspondre à la BD
  final String? planName; // Ajouté pour correspondre à la BD
  final DateTime? expiresAt; // Ajouté pour correspondre à la BD

  Subscription({
    required this.id,
    required this.userId,
    required this.typeId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.description,
    this.price,
    this.durationDays,
    this.sessionsPerMonth,
    this.features,
    this.autoRenew = true,
    this.planName,
    this.expiresAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      typeId: json['type_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble(),
      durationDays: json['duration_days'],
      sessionsPerMonth: json['sessions_per_month'],
      features: json['features'],
      autoRenew: json['auto_renew'] ?? true,
      planName: json['plan_name'],
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type_id': typeId,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'name': name,
    'description': description,
    'price': price,
    'duration_days': durationDays,
    'sessions_per_month': sessionsPerMonth,
    'features': features,
    'auto_renew': autoRenew,
    'plan_name': planName,
    'expires_at': expiresAt?.toIso8601String(),
  };
  
  // Méthode pour accéder aux propriétés via l'opérateur []
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'user_id': return userId;
      case 'type_id': return typeId;
      case 'start_date': return startDate;
      case 'end_date': return endDate;
      case 'status': return status;
      case 'created_at': return createdAt;
      case 'updated_at': return updatedAt;
      case 'name': return name;
      case 'description': return description;
      case 'price': return price;
      case 'duration_days': return durationDays;
      case 'sessions_per_month': return sessionsPerMonth;
      case 'features': return features;
      case 'auto_renew': return autoRenew;
      case 'plan_name': return planName;
      case 'expires_at': return expiresAt;
      default: return null;
    }
  }
  
  // Méthode pour créer une copie modifiée de l'objet
  Subscription copyWith({
    String? id,
    String? userId,
    String? typeId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? description,
    double? price,
    int? durationDays,
    int? sessionsPerMonth,
    Map<String, dynamic>? features,
    bool? autoRenew,
    String? planName,
    DateTime? expiresAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      typeId: typeId ?? this.typeId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      sessionsPerMonth: sessionsPerMonth ?? this.sessionsPerMonth,
      features: features ?? this.features,
      autoRenew: autoRenew ?? this.autoRenew,
      planName: planName ?? this.planName,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
  
  // Getters pour faciliter l'accès aux propriétés
  bool get isActive => status == 'active';
  bool get isExpired => endDate.isBefore(DateTime.now());
  int get remainingDays => endDate.difference(DateTime.now()).inDays;
  String get formattedPrice => price != null ? '${price!.toStringAsFixed(2)} €' : '';
  String get formattedDuration => durationDays != null ? '$durationDays jours' : '';
  String get formattedSessions => sessionsPerMonth != null ? '$sessionsPerMonth sessions/mois' : '';

}