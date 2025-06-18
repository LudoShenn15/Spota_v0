import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_lib/config/supabase_config.dart';
import 'package:shared_lib/models/user.dart';
import 'package:shared_lib/models/booking.dart';
import 'package:shared_lib/models/subscription.dart';
import 'notification_service.dart';

/// Service qui écoute les événements de la base de données Supabase
/// et déclenche des notifications en fonction des événements.
class EventListenerService {
  static final EventListenerService _instance = EventListenerService._internal();
  final NotificationService _notificationService = NotificationService();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Liste des abonnements aux canaux Supabase
  final List<RealtimeChannel> _channels = [];

  factory EventListenerService() {
    return _instance;
  }

  EventListenerService._internal();

  /// Initialise le service d'écoute des événements
  Future<void> init() async {
    // S'assurer que le service de notification est initialisé
    await _notificationService.init();
    
    // Écouter les événements de création de compte utilisateur
    _listenForNewUsers();
    
    // Écouter les événements d'abonnement
    _listenForSubscriptions();
    
    // Écouter les événements de réservation
    _listenForBookings();
    
    debugPrint('EventListenerService initialisé avec succès');
  }

  /// Arrête l'écoute de tous les canaux
  void dispose() {
    for (var channel in _channels) {
      channel.unsubscribe();
    }
    _channels.clear();
    debugPrint('EventListenerService arrêté');
  }

  /// Écoute les événements de création de compte utilisateur
  void _listenForNewUsers() {
    final channel = _supabase
        .channel('public:${SupabaseConfig.usersTable}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConfig.usersTable,
          callback: (payload) {
            _handleNewUser(payload.newRecord);
          },
        )
        .subscribe();
    
    _channels.add(channel);
    debugPrint('Écoute des nouveaux utilisateurs activée');
  }

  /// Écoute les événements d'abonnement
  void _listenForSubscriptions() {
    final channel = _supabase
        .channel('public:${SupabaseConfig.subscriptionsTable}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConfig.subscriptionsTable,
          callback: (payload) {
            _handleNewSubscription(payload.newRecord);
          },
        )
        .subscribe();
    
    _channels.add(channel);
    debugPrint('Écoute des nouveaux abonnements activée');
  }

  /// Écoute les événements de réservation
  void _listenForBookings() {
    final channel = _supabase
        .channel('public:${SupabaseConfig.bookingsTable}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConfig.bookingsTable,
          callback: (payload) {
            _handleNewBooking(payload.newRecord);
          },
        )
        .subscribe();
    
    _channels.add(channel);
    debugPrint('Écoute des nouvelles réservations activée');
  }

  /// Gère l'événement de création d'un nouvel utilisateur
  Future<void> _handleNewUser(Map<String, dynamic> payload) async {
    try {
      final userData = payload['new'] as Map<String, dynamic>;
      final user = AppUser.fromJson(userData);
      
      // Notifier l'administrateur
      await _notificationService.sendNotificationToAdmins(
        title: 'Nouvel utilisateur',
        body: 'Un nouvel utilisateur vient de créer un compte',
        data: {
          'type': 'new_user',
          'user_id': user.id,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      debugPrint('Notification envoyée pour le nouvel utilisateur: ${user.id}');
    } catch (e) {
      debugPrint('Erreur lors du traitement du nouvel utilisateur: $e');
    }
  }

  /// Gère l'événement de création d'un nouvel abonnement
  Future<void> _handleNewSubscription(Map<String, dynamic> payload) async {
    try {
      final subscriptionData = payload['new'] as Map<String, dynamic>;
      final subscription = Subscription.fromJson(subscriptionData);
      
      // Notifier l'administrateur
      await _notificationService.sendNotificationToAdmins(
        title: 'Nouvel abonnement',
        body: 'Un utilisateur a souscrit à un abonnement',
        data: {
          'type': 'new_subscription',
          'subscription_id': subscription.id,
          'user_id': subscription.userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      debugPrint('Notification envoyée pour le nouvel abonnement: ${subscription.id}');
    } catch (e) {
      debugPrint('Erreur lors du traitement du nouvel abonnement: $e');
    }
  }

  /// Gère l'événement de création d'une nouvelle réservation
  Future<void> _handleNewBooking(Map<String, dynamic> payload) async {
    try {
      final bookingData = payload['new'] as Map<String, dynamic>;
      final booking = Booking.fromJson(bookingData);
      
      // Notifier l'administrateur
      await _notificationService.sendNotificationToAdmins(
        title: 'Nouvelle réservation',
        body: 'Un utilisateur a réservé un cours',
        data: {
          'type': 'new_booking',
          'booking_id': booking.id,
          'user_id': booking.userId,
          'course_id': booking.courseId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      debugPrint('Notification envoyée pour la nouvelle réservation: ${booking.id}');
    } catch (e) {
      debugPrint('Erreur lors du traitement de la nouvelle réservation: $e');
    }
  }
}
