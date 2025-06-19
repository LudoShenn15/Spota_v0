import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Added GetX import
import 'package:shared_lib/models/user.dart'; // User model
import 'package:shared_lib/services/api_service.dart';
import '../components/sidebar.dart';
import '../components/modern_button.dart';
import '../components/badge.dart' as app_badge;
import 'dart:js' as js;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = Get.find<ApiService>(); // Replaced with Get.find
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<User> users = []; // Changed AppUser to User
  List<String> selectedUsers = [];
  bool isLoading = true;
  bool isSending = false;
  String? error;
  String searchQuery = '';
  
  // Templates de notification
  final Map<String, Map<String, String>> notificationTemplates = {
    'Bienvenue': {
      'title': 'Bienvenue chez SPOTA',
      'message': 'Nous sommes ravis de vous accueillir dans notre communauté de fitness. Découvrez nos cours et commencez votre parcours fitness dès aujourd\'hui!',
    },
    'Rappel de cours': {
      'title': 'Rappel: Votre cours commence bientôt',
      'message': 'N\'oubliez pas votre cours qui commence dans 1 heure. Nous vous attendons!',
    },
    'Promotion': {
      'title': 'Offre spéciale: -20% sur les abonnements',
      'message': 'Profitez de notre offre spéciale: -20% sur tous nos abonnements jusqu\'à la fin du mois. Utilisez le code PROMO20 lors de votre inscription.',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _initEventListener();
  }
  
  Future<void> _initEventListener() async {
    // Initialiser le service d'écoute des événements
    try {
      // Utilisation de js.context.callMethod au lieu de import dynamique
      final eventListenerService = js.context.callMethod('require', ['../services/event_listener_service.dart']);
      if (eventListenerService != null) {
        eventListenerService.callMethod('init');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du service d\'écoute des événements: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final loadedUsers = await _apiService.getAllUsers();
      
      setState(() {
        users = loadedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des utilisateurs: $e';
        isLoading = false;
      });
    }
  }
  
  void _applyTemplate(String template) {
    final selectedTemplate = notificationTemplates[template];
    if (selectedTemplate != null) {
      setState(() {
        _titleController.text = selectedTemplate['title'] ?? '';
        _messageController.text = selectedTemplate['message'] ?? '';
      });
    }
  }
  
  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      setState(() {
        error = 'Veuillez remplir tous les champs';
      });
      return;
    }
    
    if (selectedUsers.isEmpty) {
      setState(() {
        error = 'Veuillez sélectionner au moins un utilisateur';
      });
      return;
    }
    
    setState(() {
      isSending = true;
      error = null;
    });
    
    try {
      // TODO: Implémenter l'envoi de notification
      await Future.delayed(const Duration(seconds: 2)); // Simulation d'envoi
      
      setState(() {
        isSending = false;
        _titleController.clear();
        _messageController.clear();
        selectedUsers = [];
      });
      
      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors de l\'envoi de la notification: $e';
        isSending = false;
      });
    }
  }
  
  void _toggleUserSelection(User user) { // Changed AppUser to User
    setState(() {
      if (selectedUsers.contains(user.id)) {
        selectedUsers.remove(user.id);
      } else {
        selectedUsers.add(user.id);
      }
    });
  }

  List<User> _getFilteredUsers() { // Changed AppUser to User
    if (searchQuery.isEmpty) {
      return users;
    }
    
    return users.where((user) {
      final name = user.fullName.toLowerCase(); // Changed user.name to user.fullName
      final email = user.email.toLowerCase();
      final query = searchQuery.toLowerCase();
      
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedIndex: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications Push',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Envoyez des notifications push aux utilisateurs de l\'application',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Formulaire de notification
                        Expanded(
                          flex: 2,
                          child: Card(
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Composer une notification',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Templates
                                  Text(
                                    'Templates',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: notificationTemplates.keys.map((template) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: OutlinedButton(
                                            onPressed: () => _applyTemplate(template),
                                            child: Text(template),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Titre
                                  TextField(
                                    controller: _titleController,
                                    decoration: const InputDecoration(
                                      labelText: 'Titre',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Message
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      maxLines: null,
                                      expands: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Message',
                                        border: OutlineInputBorder(),
                                        alignLabelWithHint: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Bouton d'envoi
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ModernButton(
                                        onPressed: _sendNotification,
                                        text: 'Envoyer la notification',
                                        icon: Icons.send,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  if (error != null)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withAlpha(26),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.withAlpha(77),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              error!,
                                              style: const TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        // Liste des utilisateurs
                        Expanded(
                          flex: 3,
                          child: Card(
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sélectionner les destinataires',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Barre de recherche
                                  TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      labelText: 'Rechercher un utilisateur',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Nombre d'utilisateurs sélectionnés
                                  Row(
                                    children: [
                                      app_badge.Badge(
                                        text: '${selectedUsers.length} sélectionné(s)',
                                        type: app_badge.BadgeType.info,
                                      ),
                                      const Spacer(),
                                      if (selectedUsers.isNotEmpty)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedUsers = [];
                                            });
                                          },
                                          child: const Text('Effacer la sélection'),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Liste des utilisateurs
                                  Expanded(
                                    child: isLoading
                                        ? const Center(child: CircularProgressIndicator())
                                        : _getFilteredUsers().isEmpty
                                            ? const Center(child: Text('Aucun utilisateur trouvé'))
                                            : ListView.builder(
                                                itemCount: _getFilteredUsers().length,
                                                itemBuilder: (context, index) {
                                                  final user = _getFilteredUsers()[index];
                                                  final isSelected = selectedUsers.contains(user.id);
                                                  
                                                  return ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                                                      child: Text(
                                                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?', // Changed user.name to user.fullName
                                                        style: TextStyle(
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(user.fullName), // Changed user.name to user.fullName
                                                    subtitle: Text(user.email),
                                                    trailing: Checkbox(
                                                      value: isSelected,
                                                      onChanged: (value) {
                                                        _toggleUserSelection(user);
                                                      },
                                                    ),
                                                    onTap: () {
                                                      _toggleUserSelection(user);
                                                    },
                                                  );
                                                },
                                              ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
