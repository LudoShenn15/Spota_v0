import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_lib/models/notification.dart' as app_notification;
import '../providers/api_providers.dart';
import '../theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isLoading = true;
  List<app_notification.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Vérifier si l'utilisateur est connecté
      final currentUser = await apiService.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          context.go('/login');
        }
        return;
      }
      
      // Charger les notifications de l'utilisateur
      final notifications = await _safeApiCall<List<app_notification.Notification>>(
        () => apiService.getUserNotifications(currentUser.id),
      );
      
      if (!mounted) return;
      
      setState(() {
        _notifications = notifications ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des notifications: $e');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des notifications. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Méthode utilitaire pour effectuer des appels API avec gestion d'erreur
  Future<dynamic> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur API: $e');
      }
      // Retourner null en cas d'erreur, sera géré par l'appelant
      return null;
    }
  }

  Future<void> _markAllAsRead() async {
    if (_isLoading) return;
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Mise à jour optimiste de l'interface
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(
          isRead: true,
          updatedAt: DateTime.now(),
        )).toList();
      });
      
      // Appeler l'API pour marquer toutes les notifications comme lues
      final success = await _safeApiCall<bool>(
        () async {
        await apiService.markAllNotificationsAsReadForCurrentUser();
        return true;
      },
      );
      
      if (!mounted) return;
      
      if (success != true) {
        // En cas d'échec, recharger les notifications pour restaurer l'état précédent
        await _loadNotifications();
        throw Exception('Échec du marquage des notifications comme lues');
      }
      
      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toutes les notifications ont été marquées comme lues'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du marquage des notifications comme lues: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du marquage des notifications. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    if (_isLoading) return;
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Mise à jour optimiste de l'interface
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            updatedAt: DateTime.now(),
          );
        }
      });
      
      // Appeler l'API pour marquer la notification comme lue
      final success = await _safeApiCall<bool>(
        () async {
        await apiService.markNotificationAsRead(notificationId);
        return true;
      },
      );
      
      if (!mounted) return;
      
      if (success != true) {
        // En cas d'échec, recharger les notifications pour restaurer l'état précédent
        await _loadNotifications();
        throw Exception('Échec du marquage de la notification comme lue');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du marquage de la notification comme lue: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().split(':').last.trim()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () => _markAsRead(notificationId),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    if (_isLoading) return;
    
    // Demander confirmation à l'utilisateur
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette notification ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirmed) return;
    
    try {
      // Sauvegarder la notification pour pouvoir la restaurer en cas d'erreur
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      
      // Mise à jour optimiste de l'interface
      setState(() {
        _notifications.removeWhere((n) => n.id == notificationId);
      });
      
      // Appeler l'API pour supprimer la notification
      final apiService = ref.read(apiServiceProvider);
      final success = await _safeApiCall<bool>(
        () async {
          await apiService.deleteNotification(notificationId);
          return true;
        },
      );

      if (!mounted) return;

      if (success != true) {
        // En cas d'échec, restaurer la notification
        setState(() {
          _notifications.add(notification);
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
        throw Exception('Échec de la suppression de la notification');
      } else {
        // Afficher un message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification supprimée avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de la notification: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().split(':').last.trim()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () => _deleteNotification(notificationId),
            ),
          ),
        );
      }
    }
  }

  void _handleNotificationTap(app_notification.Notification notification) {
    // Marquer comme lue
    _markAsRead(notification.id);
    
    // Naviguer vers l'écran approprié en fonction du type d'action
    final actionType = notification.actionType;
    final actionId = notification.actionId;
    
    switch (actionType) {
      case 'booking':
        if (actionId != null) {
          context.go('/my-bookings');
        }
        break;
      case 'reminder':
        if (actionId != null) {
          context.go('/my-bookings');
        }
        break;
      case 'subscription':
        context.go('/subscription');
        break;
      case 'achievement':
        context.go('/stats');
        break;
      case 'cancellation':
        if (actionId != null) {
          context.go('/my-bookings');
        }
        break;
      default:
        // Ne rien faire
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: SpotaTheme.backgroundColor,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Marquer tout comme lu',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SpotaTheme.primaryColor,
              ),
            )
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: SpotaTheme.primaryColor,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez pas de notifications pour le moment',
            style: TextStyle(
              color: SpotaTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('ACTUALISER'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(app_notification.Notification notification) {
    final isRead = notification.isRead;
    final timestamp = notification.createdAt;
    final actionType = notification.actionType;
    
    // Déterminer l'icône en fonction du type d'action
    IconData icon;
    Color iconColor;
    
    switch (actionType) {
      case 'booking':
        icon = Icons.calendar_today;
        iconColor = Colors.blue;
        break;
      case 'reminder':
        icon = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case 'subscription':
        icon = Icons.card_membership;
        iconColor = Colors.purple;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case 'cancellation':
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        iconColor = SpotaTheme.primaryColor;
    }
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? null : SpotaTheme.surfaceColor.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade800,
              width: 0.5,
            ),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(
                  color: isRead
                      ? SpotaTheme.secondaryTextColor
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: SpotaTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          trailing: !isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: SpotaTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
