import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static const String usersTable = 'users';
  static const String coachesTable = 'coaches';
  static const String coursesTable = 'courses';
  static const String bookingsTable = 'bookings';
  static const String subscriptionsTable = 'subscriptions';
  static const String subscriptionTypesTable = 'subscription_types';
  static const String subscriptionPlansTable = 'subscription_plans';
  static const String schedulesTable = 'schedules';
  static const String notificationsTable = 'notifications';
  static const String userStatsTable = 'user_stats';
  static const String favoritesTable = 'favorites';
  static const String ratingsTable = 'ratings';
  static const String contactFormsTable = 'contact_forms';
  static const String timeSlotsTable = 'time_slots';
}