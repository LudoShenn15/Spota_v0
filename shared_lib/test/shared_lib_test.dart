import 'package:flutter_test/flutter_test.dart';
import 'package:shared_lib/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_lib/models/schedule.dart';
import 'package:shared_lib/models/user.dart';
import 'package:shared_lib/models/coach.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/booking.dart';
import 'package:shared_lib/models/subscription.dart';
import 'package:shared_lib/models/subscription_type.dart';

void main() {
  late ApiService apiService;

  setUpAll(() async {
    // Chargement des variables d'environnement
    await dotenv.load();
    
    // Initialisation de Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );

    // Mock Supabase pour les tests
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Création de l'instance ApiService
    apiService = ApiService();
  });

  group('Tests de connexion Supabase', () {
    test('Récupération des utilisateurs', () async {
      try {
        final users = await apiService.getAllUsers();
        expect(users, isA<List<User>>());
      } catch (e) {
        fail('Erreur lors de la récupération des utilisateurs : $e');
      }
    });

    test('Récupération des coachs', () async {
      try {
        final coaches = await apiService.getAllCoaches();
        expect(coaches, isA<List<Coach>>());
      } catch (e) {
        fail('Erreur lors de la récupération des coachs : $e');
      }
    });

    test('Récupération des cours', () async {
      try {
        final courses = await apiService.getAllCourses();
        expect(courses, isA<List<Course>>());
      } catch (e) {
        fail('Erreur lors de la récupération des cours : $e');
      }
    });

    test('Récupération des horaires', () async {
      try {
        final schedules = await apiService.getAllSchedules();
        expect(schedules, isA<List<Schedule>>());
      } catch (e) {
        fail('Erreur lors de la récupération des horaires : $e');
      }
    });

    test('Récupération des réservations', () async {
      try {
        final bookings = await apiService.getAllBookings();
        expect(bookings, isA<List<Booking>>());
      } catch (e) {
        fail('Erreur lors de la récupération des réservations : $e');
      }
    });

    test('Récupération des abonnements', () async {
      try {
        final subscriptions = await apiService.getAllSubscriptions();
        expect(subscriptions, isA<List<Subscription>>());
      } catch (e) {
        fail('Erreur lors de la récupération des abonnements : $e');
      }
    });

    test('Récupération des types d\'abonnement', () async {
      try {
        final subscriptionTypes = await apiService.getAllSubscriptionTypes();
        expect(subscriptionTypes, isA<List<SubscriptionType>>());
      } catch (e) {
        fail('Erreur lors de la récupération des types d\'abonnement : $e');
      }
    });
  });
}
