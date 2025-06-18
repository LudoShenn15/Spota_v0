import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../config/supabase_config.dart';
import '../models/user.dart'; // Utilisation de la classe User mise à jour
import '../models/coach.dart';
import '../models/course.dart';
import '../models/booking.dart';
import '../models/subscription.dart';
import '../models/subscription_type.dart';
import '../models/schedule.dart';
import '../models/notification.dart';
import '../models/user_stats.dart';
import '../models/favorite.dart';
import '../models/rating.dart';
import '../models/time_slot.dart';

class ApiService {
  final SupabaseClient _supabaseClient;

  ApiService(this._supabaseClient);

  // Méthodes CRUD génériques
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final response = await _supabaseClient
        .from(table)
        .select()
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getById(String table, String id) async {
    final response =
        await _supabaseClient.from(table).select().eq('id', id).single();
    return response;
  }

  Future<Map<String, dynamic>> create(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response =
        await _supabaseClient.from(table).insert(data).select().single();
    return response;
  }

  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response =
        await _supabaseClient
            .from(table)
            .update(data)
            .eq('id', id)
            .select()
            .single();
    return response;
  }

  Future<void> delete(String table, String id) async {
    await _supabaseClient.from(table).delete().eq('id', id);
  }

  // Méthodes spécifiques pour User
  Future<List<User>> getAllUsers() async {
    final response = await getAll(SupabaseConfig.usersTable);
    return response.map((json) => User.fromJson(json)).toList();
  }

  Future<User> getUserById(String id) async {
    final response = await getById(SupabaseConfig.usersTable, id);
    return User.fromJson(response);
  }

  Future<User> createUser(User user) async {
    final response = await create(SupabaseConfig.usersTable, user.toJson());
    return User.fromJson(response);
  }

  Future<User> updateUser(String id, User user) async {
    final response = await update(SupabaseConfig.usersTable, id, user.toJson());
    return User.fromJson(response);
  }

  Future<void> deleteUser(String id) async {
    await delete(SupabaseConfig.usersTable, id);
  }

  // Méthodes spécifiques pour Schedule
  Future<List<Schedule>> getAllSchedules() async {
    final response = await getAll(SupabaseConfig.schedulesTable);
    return response.map((json) => Schedule.fromJson(json)).toList();
  }

  Future<Schedule> getScheduleById(String id) async {
    final response = await getById(SupabaseConfig.schedulesTable, id);
    return Schedule.fromJson(response);
  }

  Future<Schedule> createSchedule(Schedule schedule) async {
    final response = await create(
      SupabaseConfig.schedulesTable,
      schedule.toJson(),
    );
    return Schedule.fromJson(response);
  }

  Future<Schedule> updateSchedule(String id, Schedule schedule) async {
    final response = await update(
      SupabaseConfig.schedulesTable,
      id,
      schedule.toJson(),
    );
    return Schedule.fromJson(response);
  }

  Future<void> deleteSchedule(String id) async {
    await delete(SupabaseConfig.schedulesTable, id);
  }

  // Méthodes spécifiques pour Coach
  Future<List<Coach>> getAllCoaches() async {
    final response = await getAll(SupabaseConfig.coachesTable);
    return response.map((json) => Coach.fromJson(json)).toList();
  }

  Future<Coach> getCoachById(String id) async {
    final response = await getById(SupabaseConfig.coachesTable, id);
    return Coach.fromJson(response);
  }

  Future<Coach> createCoach(Coach coach) async {
    final response = await create(SupabaseConfig.coachesTable, coach.toJson());
    return Coach.fromJson(response);
  }

  Future<Coach> updateCoach(String id, Coach coach) async {
    final response = await update(
      SupabaseConfig.coachesTable,
      id,
      coach.toJson(),
    );
    return Coach.fromJson(response);
  }

  Future<void> deleteCoach(String id) async {
    await delete(SupabaseConfig.coachesTable, id);
  }

  // ... existing code ...

  // Méthodes spécifiques pour Course
  Future<List<Course>> getAllCourses() async {
    final response = await getAll(SupabaseConfig.coursesTable);
    return response.map((json) => Course.fromJson(json)).toList();
  }
  
  // Méthode pour récupérer les cours disponibles (actifs)
  Future<List<Course>> getAvailableCourses() async {
    try {
      final response = await _supabaseClient
          .from(SupabaseConfig.coursesTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cours disponibles: $e');
    }
  }
  
  // Méthode pour récupérer les cours par leurs IDs
  Future<List<Course>> getCoursesByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];
      
      final response = await _supabaseClient
          .from(SupabaseConfig.coursesTable)
          .select()
          .filter('id', 'in', ids);

      return (response as List).map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cours par IDs: $e');
    }
  }

  Future<Course> getCourseById(String id) async {
    final response = await getById(SupabaseConfig.coursesTable, id);
    return Course.fromJson(response);
  }

  Future<Course> createCourse(Course course) async {
    final response = await create(SupabaseConfig.coursesTable, course.toJson());
    return Course.fromJson(response);
  }

  Future<Course> updateCourse(String id, Course course) async {
    final response = await update(
      SupabaseConfig.coursesTable,
      id,
      course.toJson(),
    );
    return Course.fromJson(response);
  }

  Future<void> deleteCourse(String id) async {
    await delete(SupabaseConfig.coursesTable, id);
  }
  
  // Méthodes spécifiques pour TimeSlot
  Future<List<TimeSlot>> getAllTimeSlots() async {
    try {
      final response = await getAll(SupabaseConfig.timeSlotsTable);
      return response.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des créneaux horaires: $e');
    }
  }
  
  Future<TimeSlot> getTimeSlotById(String id) async {
    try {
      final response = await getById(SupabaseConfig.timeSlotsTable, id);
      return TimeSlot.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du créneau horaire: $e');
    }
  }
  
  Future<TimeSlot> createTimeSlot(TimeSlot timeSlot) async {
    try {
      final response = await create(
        SupabaseConfig.timeSlotsTable,
        timeSlot.toJson(),
      );
      return TimeSlot.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création du créneau horaire: $e');
    }
  }
  
  Future<TimeSlot> updateTimeSlot(String id, TimeSlot timeSlot) async {
    try {
      final response = await update(
        SupabaseConfig.timeSlotsTable,
        id,
        timeSlot.toJson(),
      );
      return TimeSlot.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du créneau horaire: $e');
    }
  }
  
  Future<void> deleteTimeSlot(String id) async {
    try {
      await delete(SupabaseConfig.timeSlotsTable, id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du créneau horaire: $e');
    }
  }
  
  // Méthode pour récupérer les créneaux horaires disponibles pour une date donnée
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date) async {
    try {
      // Convertir la date en format ISO pour la comparaison
      final dateString = date.toIso8601String().split('T')[0];
      
      final response = await _supabaseClient
          .from(SupabaseConfig.timeSlotsTable)
          .select()
          .eq('is_available', true)
          .lt('current_participants', 'max_participants') // Pas complet
          .ilike('start_time', '$dateString%') // Filtrer par date
          .order('start_time');

      return (response as List).map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des créneaux disponibles: $e');
    }
  }

  // Méthodes spécifiques pour Booking
  Future<List<Booking>> getAllBookings() async {
    final response = await getAll(SupabaseConfig.bookingsTable);
    return response.map((json) => Booking.fromJson(json)).toList();
  }

  Future<Booking> getBookingById(String id) async {
    final response = await getById(SupabaseConfig.bookingsTable, id);
    return Booking.fromJson(response);
  }

  Future<Booking> createBooking(Booking booking) async {
    final response = await create(
      SupabaseConfig.bookingsTable,
      booking.toJson(),
    );
    return Booking.fromJson(response);
  }

  Future<Booking> updateBooking(String id, Booking booking) async {
    final response = await update(
      SupabaseConfig.bookingsTable,
      id,
      booking.toJson(),
    );
    return Booking.fromJson(response);
  }

  Future<void> deleteBooking(String id) async {
    await delete(SupabaseConfig.bookingsTable, id);
  }

  // Méthodes spécifiques pour Subscription
  Future<List<Subscription>> getAllSubscriptions() async {
    final response = await getAll(SupabaseConfig.subscriptionsTable);
    return response.map((json) => Subscription.fromJson(json)).toList();
  }

  Future<Subscription> getSubscriptionById(String id) async {
    final response = await getById(SupabaseConfig.subscriptionsTable, id);
    return Subscription.fromJson(response);
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    final response = await create(
      SupabaseConfig.subscriptionsTable,
      subscription.toJson(),
    );
    return Subscription.fromJson(response);
  }

  Future<Subscription> updateSubscription(
    String id,
    Subscription subscription,
  ) async {
    final response = await update(
      SupabaseConfig.subscriptionsTable,
      id,
      subscription.toJson(),
    );
    return Subscription.fromJson(response);
  }

  Future<void> deleteSubscription(String id) async {
    await delete(SupabaseConfig.subscriptionsTable, id);
  }

  // Méthodes spécifiques pour SubscriptionType
  Future<List<SubscriptionType>> getAllSubscriptionTypes() async {
    final response = await getAll(SupabaseConfig.subscriptionTypesTable);
    return response.map((json) => SubscriptionType.fromJson(json)).toList();
  }

  Future<SubscriptionType> getSubscriptionTypeById(String id) async {
    final response = await getById(SupabaseConfig.subscriptionTypesTable, id);
    return SubscriptionType.fromJson(response);
  }

  Future<SubscriptionType> createSubscriptionType(
    SubscriptionType subscriptionType,
  ) async {
    final response = await create(
      SupabaseConfig.subscriptionTypesTable,
      subscriptionType.toJson(),
    );
    return SubscriptionType.fromJson(response);
  }

  Future<SubscriptionType> updateSubscriptionType(
    String id,
    SubscriptionType subscriptionType,
  ) async {
    final response = await update(
      SupabaseConfig.subscriptionTypesTable,
      id,
      subscriptionType.toJson(),
    );
    return SubscriptionType.fromJson(response);
  }

  Future<void> deleteSubscriptionType(String id) async {
    await delete(SupabaseConfig.subscriptionTypesTable, id);
  }

  // Méthodes d'authentification
  Future<User> signUp(String email, String password, User user) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      // Créer l'utilisateur dans la table users avec les données complètes
      final newUser = await create(
        SupabaseConfig.usersTable,
        {
          ...user.toJson(),
          'id': response.user!.id,
          'email': email,
        },
      );
      return User.fromJson(newUser);
    } else {
      throw Exception("Échec de l'inscription");
    }
  }

  Future<User> signIn(String email, String password) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      // Récupérer les données utilisateur complètes
      final userData = await getById(SupabaseConfig.usersTable, response.user!.id);
      return User.fromJson(userData);
    } else {
      throw Exception("Échec de la connexion");
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  Future<bool> isAuthenticated() async {
    return _supabaseClient.auth.currentUser != null;
  }

  Future<User?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user != null) {
      try {
        final userData = await getById(SupabaseConfig.usersTable, user.id);
        return User.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Méthodes pour les favoris
  Future<List<Favorite>> getAllFavorites() async {
    final response = await getAll(SupabaseConfig.favoritesTable);
    return response.map((json) => Favorite.fromJson(json)).toList();
  }

  Future<List<Favorite>> getUserFavorites(String userId) async {
    final response = await _supabaseClient
        .from(SupabaseConfig.favoritesTable)
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response)
        .map((json) => Favorite.fromJson(json))
        .toList();
  }

  Future<List<Course>> getUserFavoriteCourses(String userId) async {
    final favorites = await _supabaseClient
        .from(SupabaseConfig.favoritesTable)
        .select()
        .eq('user_id', userId)
        .eq('item_type', 'course');

    List<String> courseIds = List<Map<String, dynamic>>.from(favorites)
        .map((json) => json['item_id'] as String)
        .toList();

    if (courseIds.isEmpty) return [];

    final courses = await _supabaseClient
        .from(SupabaseConfig.coursesTable)
        .select()
        .filter('id', 'in', courseIds);

    return List<Map<String, dynamic>>.from(courses)
        .map((json) => Course.fromJson(json))
        .toList();
  }

  Future<List<Coach>> getUserFavoriteCoaches(String userId) async {
    final favorites = await _supabaseClient
        .from(SupabaseConfig.favoritesTable)
        .select()
        .eq('user_id', userId)
        .eq('item_type', 'coach');

    List<String> coachIds = List<Map<String, dynamic>>.from(favorites)
        .map((json) => json['item_id'] as String)
        .toList();

    if (coachIds.isEmpty) return [];

    final coaches = await _supabaseClient
        .from(SupabaseConfig.coachesTable)
        .select()
        .filter('id', 'in', coachIds);

    return List<Map<String, dynamic>>.from(coaches)
        .map((json) => Coach.fromJson(json))
        .toList();
  }
  
  Future<void> addFavoriteCourse(String courseId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    await _supabaseClient.from(SupabaseConfig.favoritesTable).insert({
      'user_id': user.id,
      'item_id': courseId,
      'item_type': 'course',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addFavoriteCoach(String coachId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    await _supabaseClient.from(SupabaseConfig.favoritesTable).insert({
      'user_id': user.id,
      'item_id': coachId,
      'item_type': 'coach',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavoriteCourse(String courseId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    await _supabaseClient
        .from(SupabaseConfig.favoritesTable)
        .delete()
        .eq('user_id', user.id)
        .eq('item_id', courseId)
        .eq('item_type', 'course');
  }

  Future<void> removeFavoriteCoach(String coachId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    await _supabaseClient
        .from(SupabaseConfig.favoritesTable)
        .delete()
        .eq('user_id', user.id)
        .eq('item_id', coachId)
        .eq('item_type', 'coach');
  }

  Future<void> addFavorite(String userId, String itemId, String itemType) async {
    await create(
      SupabaseConfig.favoritesTable,
      {
        'user_id': userId,
        'item_id': itemId,
        'item_type': itemType,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> removeFavorite(String userId, String itemId, String itemType) async {
    final response = await _supabaseClient
        .from(SupabaseConfig.favoritesTable)
        .select()
        .eq('user_id', userId)
        .eq('item_id', itemId)
        .eq('item_type', itemType);

    if (response.isNotEmpty) {
      final favoriteId = response[0]['id'];
      await delete(SupabaseConfig.favoritesTable, favoriteId);
    }
  }

  // Méthodes pour les notifications
  Future<List<Notification>> getAllNotifications() async {
    final response = await getAll(SupabaseConfig.notificationsTable);
    return response.map((json) => Notification.fromJson(json)).toList();
  }

  Future<Notification> getNotificationById(String id) async {
    final response = await getById(SupabaseConfig.notificationsTable, id);
    return Notification.fromJson(response);
  }

  Future<List<Notification>> getUserNotifications(String userId) async {
    final response = await _supabaseClient
        .from(SupabaseConfig.notificationsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response)
        .map((json) => Notification.fromJson(json))
        .toList();
  }
  
  Future<List<Notification>> getUserNotificationsForCurrentUser() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    return getUserNotifications(user.id);
  }

  Future<Notification> createNotification(Notification notification) async {
    final response = await create(
      SupabaseConfig.notificationsTable,
      notification.toJson(),
    );
    return Notification.fromJson(response);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await update(
      SupabaseConfig.notificationsTable,
      notificationId,
      {'is_read': true},
    );
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    await _supabaseClient
        .from(SupabaseConfig.notificationsTable)
        .update({'is_read': true})
        .eq('user_id', userId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await delete(SupabaseConfig.notificationsTable, notificationId);
  }

  Future<void> deleteAllUserNotifications(String userId) async {
    await _supabaseClient
        .from(SupabaseConfig.notificationsTable)
        .delete()
        .eq('user_id', userId);
  }

  // Méthodes pour les statistiques utilisateur
  Future<List<UserStats>> getAllUserStats() async {
    final response = await getAll(SupabaseConfig.userStatsTable);
    return response.map((json) => UserStats.fromJson(json)).toList();
  }

  Future<UserStats> getUserStatsById(String id) async {
    final response = await getById(SupabaseConfig.userStatsTable, id);
    return UserStats.fromJson(response);
  }

  Future<List<UserStats>> getUserStatsByUserId(String userId) async {
    final response = await _supabaseClient
        .from(SupabaseConfig.userStatsTable)
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: false);
    return List<Map<String, dynamic>>.from(response)
        .map((json) => UserStats.fromJson(json))
        .toList();
  }

  Future<UserStats> getUserStatsByPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabaseClient
        .from(SupabaseConfig.userStatsTable)
        .select()
        .eq('user_id', userId)
        .gte('start_date', startDate.toIso8601String())
        .lte('end_date', endDate.toIso8601String())
        .single();
    return UserStats.fromJson(response);
  }

  Future<UserStats> createUserStats(UserStats userStats) async {
    final response = await create(
      SupabaseConfig.userStatsTable,
      userStats.toJson(),
    );
    return UserStats.fromJson(response);
  }

  Future<UserStats> updateUserStats(String id, UserStats userStats) async {
    final response = await update(
      SupabaseConfig.userStatsTable,
      id,
      userStats.toJson(),
    );
    return UserStats.fromJson(response);
  }

  // Méthodes pour les évaluations (ratings)
  Future<List<Rating>> getAllRatings() async {
    final response = await getAll(SupabaseConfig.ratingsTable);
    return response.map((json) => Rating.fromJson(json)).toList();
  }

  Future<Rating> getRatingById(String id) async {
    final response = await getById(SupabaseConfig.ratingsTable, id);
    return Rating.fromJson(response);
  }

  Future<List<Rating>> getUserRatings(String userId) async {
    final response = await _supabaseClient
        .from(SupabaseConfig.ratingsTable)
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response)
        .map((json) => Rating.fromJson(json))
        .toList();
  }

  Future<List<Rating>> getItemRatings(String itemId, String itemType) async {
    final response = await _supabaseClient
        .from(SupabaseConfig.ratingsTable)
        .select()
        .eq('item_id', itemId)
        .eq('item_type', itemType);
    return List<Map<String, dynamic>>.from(response)
        .map((json) => Rating.fromJson(json))
        .toList();
  }

  Future<double> getAverageRating(String itemId, String itemType) async {
    final ratings = await getItemRatings(itemId, itemType);
    if (ratings.isEmpty) return 0.0;
    
    double sum = ratings.fold(0.0, (sum, rating) => sum + rating.rating);
    return sum / ratings.length;
  }

  Future<Rating> createRating(Rating rating) async {
    // Vérifier si l'utilisateur a déjà noté cet élément
    final existingRatings = await _supabaseClient
        .from(SupabaseConfig.ratingsTable)
        .select()
        .eq('user_id', rating.userId)
        .eq('item_id', rating.itemId)
        .eq('item_type', rating.itemType);

    if (existingRatings.isNotEmpty) {
      // Mettre à jour la note existante
      final existingId = existingRatings[0]['id'];
      final response = await update(
        SupabaseConfig.ratingsTable,
        existingId,
        rating.toJson(),
      );
      return Rating.fromJson(response);
    } else {
      // Créer une nouvelle note
      final response = await create(
        SupabaseConfig.ratingsTable,
        rating.toJson(),
      );
      return Rating.fromJson(response);
    }
  }

  Future<void> deleteRating(String id) async {
    await delete(SupabaseConfig.ratingsTable, id);
  }

  // Méthodes de recherche et filtrage
  Future<List<Course>> searchCourses({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? difficulty,
    String? location,
  }) async {
    var request = _supabaseClient.from(SupabaseConfig.coursesTable).select();

    if (query != null && query.isNotEmpty) {
      request = request.or('name.ilike.%$query%,description.ilike.%$query%');
    }

    if (category != null && category.isNotEmpty) {
      request = request.eq('category', category);
    }

    if (minPrice != null) {
      request = request.gte('price', minPrice);
    }

    if (maxPrice != null) {
      request = request.lte('price', maxPrice);
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      request = request.eq('difficulty', difficulty);
    }

    if (location != null && location.isNotEmpty) {
      request = request.eq('location', location);
    }

    final response = await request;
    return List<Map<String, dynamic>>.from(response)
        .map((json) => Course.fromJson(json))
        .toList();
  }

  Future<List<Coach>> searchCoaches({
    String? query,
    String? specialty,
    String? location,
    double? minRating,
  }) async {
    var request = _supabaseClient.from(SupabaseConfig.coachesTable).select();

    if (query != null && query.isNotEmpty) {
      request = request.or('name.ilike.%$query%,bio.ilike.%$query%');
    }

    if (specialty != null && specialty.isNotEmpty) {
      request = request.eq('specialty', specialty);
    }

    if (location != null && location.isNotEmpty) {
      request = request.eq('location', location);
    }

    final response = await request;
    List<Coach> coaches = List<Map<String, dynamic>>.from(response)
        .map((json) => Coach.fromJson(json))
        .toList();

    // Filtrer par note minimale si nécessaire
    if (minRating != null) {
      List<Coach> filteredCoaches = [];
      for (var coach in coaches) {
        double avgRating = await getAverageRating(coach.id, 'coach');
        if (avgRating >= minRating) {
          filteredCoaches.add(coach);
        }
      }
      return filteredCoaches;
    }

    return coaches;
  }

  // Méthode pour soumettre un formulaire de contact
  Future<Map<String, dynamic>> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Vérifier si la table existe avant d'insérer
      final response = await _supabaseClient
          .from(SupabaseConfig.contactFormsTable)
          .insert(data)
          .select()
          .single();
          
      return response;
    } catch (e) {
      print('Erreur lors de la soumission du formulaire de contact: $e');
      throw Exception("Échec de la soumission du formulaire de contact: $e");
    }
  }

  // Méthodes de gestion des notifications

  Future<void> nAsReadForCurrentUser(String notificationId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _supabaseClient
        .from(SupabaseConfig.notificationsTable)
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', user.id);
  }

  Future<void> markAllNotificationsAsReadForCurrentUser() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await markAllNotificationsAsRead(user.id);
  }

  Future<void> deleteNotificationForCurrentUser(String notificationId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _supabaseClient
        .from(SupabaseConfig.notificationsTable)
        .delete()
        .eq('id', notificationId)
        .eq('user_id', user.id);
  }

  // Méthodes pour les abonnements
  Future<Subscription?> getUserSubscription() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final response = await _supabaseClient
        .from(SupabaseConfig.subscriptionsTable)
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Subscription.fromJson(response);
  }

  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    final response = await _supabaseClient
        .from(SupabaseConfig.subscriptionPlansTable)
        .select()
        .order('price', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Subscription> updateSubscriptionPlan(String planId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    // Récupérer les détails du plan
    final planResponse = await _supabaseClient
        .from(SupabaseConfig.subscriptionPlansTable)
        .select()
        .eq('id', planId)
        .single();

    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30)); // Abonnement d'un mois par défaut

    // Vérifier si l'utilisateur a déjà un abonnement
    final currentSubscription = await getUserSubscription();

    Map<String, dynamic> subscriptionData = {
      'user_id': user.id,
      'type_id': planId,
      'start_date': now.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': 'active',
      'updated_at': now.toIso8601String(),
    };

    Map<String, dynamic> response;

    if (currentSubscription != null) {
      // Mettre à jour l'abonnement existant
      response = await _supabaseClient
          .from(SupabaseConfig.subscriptionsTable)
          .update(subscriptionData)
          .eq('id', currentSubscription.id)
          .select()
          .single();
    } else {
      // Créer un nouvel abonnement
      subscriptionData['created_at'] = now.toIso8601String();
      response = await _supabaseClient
          .from(SupabaseConfig.subscriptionsTable)
          .insert(subscriptionData)
          .select()
          .single();
    }

    return Subscription.fromJson(response);
  }

  Future<void> cancelSubscription() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final currentSubscription = await getUserSubscription();
    if (currentSubscription == null) {
      throw Exception("Aucun abonnement actif trouvé");
    }

    // Mettre à jour le statut de l'abonnement
    await _supabaseClient
        .from(SupabaseConfig.subscriptionsTable)
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', currentSubscription.id);
  }
  
  // Méthodes pour la gestion du profil utilisateur
  Future<Map<String, dynamic>> getUserProfile() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final userProfile = await _supabaseClient
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('id', user.id)
        .single();

    final subscription = await getUserSubscription();
    final stats = await getUserStats();

    return {
      'user': userProfile,
      'subscription': subscription,
      'stats': stats,
    };
  }

  Future<UserStats> getUserStats() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    // Récupérer les réservations de l'utilisateur
    final bookings = await getUserBookings();

    // Calculer les statistiques
    int totalBookings = bookings.length;
    int totalHours = 0;
    int totalMinutes = 0;
    int caloriesBurned = 0;
    int totalSessions = bookings.length;
    int coursesAttended = 0;
    int trainingHours = 0;
    Map<String, int> activityCounts = {};
    
    // Tendances sur les 6 derniers mois
    Map<String, dynamic> coursesAttendedTrend = {};
    Map<String, dynamic> trainingHoursTrend = {};
    Map<String, dynamic> caloriesBurnedTrend = {};
    
    // Obtenir les noms des mois pour les tendances
    List<String> monthNames = _getMonthNames();
    DateTime now = DateTime.now();
    
    // Initialiser les tendances avec des zéros
    for (int i = 5; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthKey = monthNames[month.month - 1];
      coursesAttendedTrend[monthKey] = 0;
      trainingHoursTrend[monthKey] = 0;
      caloriesBurnedTrend[monthKey] = 0;
    }

    for (var booking in bookings) {
      // Vérifier si la réservation est confirmée ou terminée
      if (booking.status == 'confirmed' || booking.status == 'completed') {
        coursesAttended++;
        
        // Ajouter la durée du cours (en heures et minutes)
        if (booking.course != null && booking.course!.duration != null) {
          int durationMinutes = booking.course!.duration!;
          totalMinutes += durationMinutes;
          totalHours += (durationMinutes / 60).ceil();
          trainingHours += (durationMinutes / 60).ceil();
          
          // Estimer les calories brûlées (approximation simple)
          caloriesBurned += (durationMinutes * 5); // ~5 calories par minute d'activité
        }

        // Compter les activités
        if (booking.course != null && booking.course!.category != null) {
          String category = booking.course!.category!;
          activityCounts[category] = (activityCounts[category] ?? 0) + 1;
        }
        
        // Ajouter aux tendances si la réservation est dans les 6 derniers mois
        if (booking.bookingDate != null) {
          DateTime bookingDate = booking.bookingDate!;
          if (bookingDate.isAfter(DateTime(now.year, now.month - 6, now.day))) {
            String monthKey = monthNames[bookingDate.month - 1];
            coursesAttendedTrend[monthKey] = (coursesAttendedTrend[monthKey] ?? 0) + 1;
            
            if (booking.course != null && booking.course!.duration != null) {
              int hours = (booking.course!.duration! / 60).ceil();
              trainingHoursTrend[monthKey] = (trainingHoursTrend[monthKey] ?? 0) + hours;
              caloriesBurnedTrend[monthKey] = (caloriesBurnedTrend[monthKey] ?? 0) + (booking.course!.duration! * 5);
            }
          }
        }
      }
    }

    // Trouver l'activité favorite
    String favoriteActivity = 'Aucune';
    int maxCount = 0;

    activityCounts.forEach((activity, count) {
      if (count > maxCount) {
        maxCount = count;
        favoriteActivity = activity;
      }
    });
    
    // Créer un ID unique pour les statistiques
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();

    return UserStats(
      id: id,
      userId: user.id,
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      caloriesBurned: caloriesBurned,
      activityBreakdown: activityCounts,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      coursesAttended: coursesAttended,
      trainingHours: trainingHours,
      totalBookings: totalBookings,
      totalHours: totalHours,
      favoriteActivity: favoriteActivity,
      coursesAttendedTrend: coursesAttendedTrend,
      trainingHoursTrend: trainingHoursTrend,
      caloriesBurnedTrend: caloriesBurnedTrend,
    );
  }

  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }

  // Méthode pour la recherche
  Future<Map<String, dynamic>> search(String query) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    // Recherche de cours
    final courses = await _supabaseClient
        .from(SupabaseConfig.coursesTable)
        .select()
        .or('title.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%')
        .order('title');

    // Recherche de coachs
    final coaches = await _supabaseClient
        .from(SupabaseConfig.coachesTable)
        .select()
        .or('name.ilike.%$query%,speciality.ilike.%$query%,bio.ilike.%$query%')
        .order('name');

    return {
      'courses': List<Map<String, dynamic>>.from(courses)
          .map((json) => Course.fromJson(json))
          .toList(),
      'coaches': List<Map<String, dynamic>>.from(coaches)
          .map((json) => Coach.fromJson(json))
          .toList(),
    };
  }

  // Méthode utilitaire pour obtenir les noms des mois
  List<String> _getMonthNames() {
    return ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
  }

  // Méthodes pour les réservations de cours
  Future<List<Booking>> getUserBookings() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final response = await _supabaseClient
        .from(SupabaseConfig.bookingsTable)
        .select('*, course:courses(*)')
        .eq('user_id', user.id)
        .order('booking_date', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .map((json) => Booking.fromJson(json))
        .toList();
  }

  Future<List<Booking>> getUpcomingUserBookings() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final now = DateTime.now();
    final response = await _supabaseClient
        .from(SupabaseConfig.bookingsTable)
        .select('*, course:courses(*)')
        .eq('user_id', user.id)
        .gte('booking_date', now.toIso8601String())
        .order('booking_date', ascending: true);

    return List<Map<String, dynamic>>.from(response)
        .map((json) => Booking.fromJson(json))
        .toList();
  }
  
  Future<List<Booking>> getPastUserBookings() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final now = DateTime.now();
    final response = await _supabaseClient
        .from(SupabaseConfig.bookingsTable)
        .select('*, course:courses(*)')
        .eq('user_id', user.id)
        .lt('booking_date', now.toIso8601String())
        .order('booking_date', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .map((json) => Booking.fromJson(json))
        .toList();
  }

  Future<void> cancelBooking(String bookingId) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    await _supabaseClient
        .from(SupabaseConfig.bookingsTable)
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId)
        .eq('user_id', user.id);
  }

  Future<void> rateBooking(String bookingId, int rating) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception("Utilisateur non authentifié");
    }

    await _supabaseClient
        .from(SupabaseConfig.bookingsTable)
        .update({
          'rating': rating,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId)
        .eq('user_id', user.id);
  }

  // Méthodes pour gérer les favoris
}
