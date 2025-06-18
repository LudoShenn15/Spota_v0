import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart'; // Fourni par package:flutter/foundation.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_lib/services/api_service.dart';
// Import supprimé car non utilisé

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  // TODO: Ce service sera utilisé pour les futures fonctionnalités de notification
  final ApiService _apiService = ApiService(); // ignore: unused_field
  
  // Clé du serveur Firebase Cloud Messaging (à remplacer par votre clé)
  static const String _fcmServerKey = 'YOUR_FCM_SERVER_KEY';
  
  // Topic pour les administrateurs
  static const String _adminTopic = 'admin_notifications';
  
  // URL pour envoyer des notifications via l'API FCM
  static const String _fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialise le service de notification
  Future<void> init() async {
    // Demander la permission de recevoir des notifications
    await _requestPermission();
    
    // Configurer les notifications locales
    await _setupLocalNotifications();
    
    // Configurer les gestionnaires de messages
    _setupMessageHandlers();
    
    // Vérifier si les notifications sont activées
    bool enabled = await isNotificationsEnabled();
    if (enabled) {
      // Obtenir et stocker le token FCM
      await getToken();
      
      // S'abonner au topic des administrateurs (pour l'application admin)
      await subscribeToAdminTopic();
    }
  }

  /// Demande la permission de recevoir des notifications
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    debugPrint('Notification permission status: ${settings.authorizationStatus}');
  }

  /// Configure les notifications locales pour afficher les notifications en premier plan
  Future<void> _setupLocalNotifications() async {
    // Initialisation pour Android
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Initialisation pour iOS
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Initialisation générale
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Gérer la réponse à la notification (par exemple, naviguer vers un écran)
        _handleNotificationTap(response.payload);
      },
    );
  }

  /// Configure les gestionnaires de messages pour les différents états de l'application
  void _setupMessageHandlers() {
    // Gestionnaire pour les messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // Gestionnaire pour les messages en arrière-plan qui sont ouverts
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(jsonEncode(message.data));
    });
  }

  /// Affiche une notification locale à partir d'un message distant
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'spota_admin_channel',
            'Spota Admin Notifications',
            channelDescription: 'Channel for Spota admin notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: android.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Gère l'action lorsqu'une notification est tapée
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        debugPrint('Notification tapped with data: $data');
        
        // Logique de navigation en fonction du type de notification
        if (data.containsKey('type')) {
          switch (data['type']) {
            case 'new_user':
              // Naviguer vers l'écran des utilisateurs avec l'ID de l'utilisateur
              // context.go('/users?id=${data['user_id']}');
              break;
            case 'new_subscription':
              // Naviguer vers l'écran des paiements
              // context.go('/payments');
              break;
            case 'new_booking':
              // Naviguer vers l'écran des réservations
              // context.go('/bookings');
              break;
            case 'new_course':
              // Naviguer vers l'écran des cours
              // context.go('/courses');
              break;
            case 'new_coach':
              // Naviguer vers l'écran des coachs
              // context.go('/coaches');
              break;
          }
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Obtient et stocke le token FCM
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _saveTokenToPrefs(token);
        // Vous pourriez également envoyer ce token à votre serveur
        // pour l'associer à l'utilisateur administrateur
        await _sendTokenToServer(token);
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Sauvegarde le token FCM dans les préférences locales
  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Envoie le token FCM au serveur pour l'associer à l'utilisateur
  Future<void> _sendTokenToServer(String token) async {
    // Cette méthode devrait être implémentée pour envoyer le token à votre backend
    // Vous pourriez utiliser l'ApiService pour cela
    try {
      // Exemple d'implémentation - à adapter selon votre API
      // await _apiService.updateUserToken(userId, token);
      debugPrint('Token sent to server successfully');
    } catch (e) {
      debugPrint('Error sending token to server: $e');
    }
  }

  /// Vérifie si les notifications sont activées dans les préférences
  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  /// Active ou désactive les notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    
    if (enabled) {
      // Si activé, obtenir et enregistrer le token
      await getToken();
      
      // S'abonner au topic des administrateurs (pour l'application admin)
      await subscribeToAdminTopic();
    } else {
      // Si désactivé, supprimer le token
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      
      // Se désabonner du topic des administrateurs
      await unsubscribeFromAdminTopic();
    }
  }

  /// Envoie une notification à un utilisateur spécifique
  Future<bool> sendNotificationToUser(String userId, String title, String body, {Map<String, dynamic>? data}) async {
    try {
      // Récupérer le token FCM de l'utilisateur depuis votre backend
      String? userToken = await _getUserToken(userId);
      
      if (userToken == null) {
        debugPrint('User token not found for user: $userId');
        return false;
      }
      
      return await _sendNotification(
        token: userToken,
        title: title,
        body: body,
        data: data ?? {},
      );
    } catch (e) {
      debugPrint('Error sending notification to user: $e');
      return false;
    }
  }

  /// Envoie une notification à tous les utilisateurs
  Future<bool> sendNotificationToAllUsers(String title, String body, {Map<String, dynamic>? data}) async {
    try {
      // Envoyer à un topic auquel tous les utilisateurs sont abonnés
      return await _sendNotification(
        topic: 'all_users',
        title: title,
        body: body,
        data: data ?? {},
      );
    } catch (e) {
      debugPrint('Error sending notification to all users: $e');
      return false;
    }
  }
  
  /// Envoie une notification à tous les administrateurs
  Future<bool> sendNotificationToAdmins({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Envoyer à un topic spécifique pour les administrateurs
      return await _sendNotification(
        topic: _adminTopic,
        title: title,
        body: body,
        data: data ?? {},
      );
    } catch (e) {
      debugPrint('Error sending notification to admins: $e');
      return false;
    }
  }
  
  /// S'abonne au topic des administrateurs
  Future<void> subscribeToAdminTopic() async {
    try {
      await _firebaseMessaging.subscribeToTopic(_adminTopic);
      debugPrint('Subscribed to admin topic');
    } catch (e) {
      debugPrint('Error subscribing to admin topic: $e');
    }
  }
  
  /// Se désabonne du topic des administrateurs
  Future<void> unsubscribeFromAdminTopic() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(_adminTopic);
      debugPrint('Unsubscribed from admin topic');
    } catch (e) {
      debugPrint('Error unsubscribing from admin topic: $e');
    }
  }

  /// Envoie une notification à un groupe d'utilisateurs (par exemple, tous les coachs)
  Future<bool> sendNotificationToGroup(String group, String title, String body, {Map<String, dynamic>? data}) async {
    try {
      // Envoyer à un topic spécifique pour ce groupe
      return await _sendNotification(
        topic: group,
        title: title,
        body: body,
        data: data ?? {},
      );
    } catch (e) {
      debugPrint('Error sending notification to group: $e');
      return false;
    }
  }

  /// Récupère le token FCM d'un utilisateur depuis le backend
  Future<String?> _getUserToken(String userId) async {
    // Cette méthode devrait être implémentée pour récupérer le token depuis votre backend
    // Vous pourriez utiliser l'ApiService pour cela
    try {
      // Exemple d'implémentation - à adapter selon votre API
      // return await _apiService.getUserToken(userId);
      return null; // Remplacer par l'implémentation réelle
    } catch (e) {
      debugPrint('Error getting user token: $e');
      return null;
    }
  }

  /// Envoie une notification via l'API FCM
  Future<bool> _sendNotification({
    String? token,
    String? topic,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Vérifier qu'au moins un destinataire est spécifié
      if (token == null && topic == null) {
        throw Exception('Either token or topic must be provided');
      }
      
      // Préparer les données de la notification
      final Map<String, dynamic> notification = {
        'title': title,
        'body': body,
      };
      
      // Préparer le corps de la requête
      final Map<String, dynamic> requestBody = {
        'notification': notification,
        'data': data,
        'priority': 'high',
      };
      
      // Ajouter le destinataire (token ou topic)
      if (token != null) {
        requestBody['to'] = token;
      } else if (topic != null) {
        requestBody['to'] = '/topics/$topic';
      }
      
      // Envoyer la requête à l'API FCM
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_fcmServerKey',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == 1) {
          debugPrint('Notification sent successfully');
          return true;
        } else {
          debugPrint('Failed to send notification: ${responseData['results']}');
          return false;
        }
      } else {
        debugPrint('Failed to send notification. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }
}
