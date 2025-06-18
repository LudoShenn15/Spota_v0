import 'package:flutter/material.dart';
import 'package:shared_lib/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/sidebar.dart';
import '../components/modern_button.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  String? error;
  
  // Paramètres de l'application
  bool isDarkMode = true; // Par défaut en mode sombre
  bool notificationsEnabled = true;
  String selectedLanguage = 'Français';
  bool isMaintenanceMode = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      // Charger les paramètres depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Vérifier l'état des notifications via le NotificationService
      final notificationService = NotificationService();
      final notificationsStatus = await notificationService.isNotificationsEnabled();
      
      setState(() {
        isDarkMode = prefs.getBool('isDarkMode') ?? true;
        notificationsEnabled = notificationsStatus;
        selectedLanguage = prefs.getString('selectedLanguage') ?? 'Français';
        isMaintenanceMode = prefs.getBool('isMaintenanceMode') ?? false;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des paramètres: $e';
        isLoading = false;
      });
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      // Sauvegarder les paramètres dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);
      await prefs.setString('selectedLanguage', selectedLanguage);
      await prefs.setBool('isMaintenanceMode', isMaintenanceMode);
      
      // Mettre à jour l'état des notifications via le NotificationService
      final notificationService = NotificationService();
      await notificationService.setNotificationsEnabled(notificationsEnabled);
      
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres sauvegardés avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors de la sauvegarde des paramètres: $e';
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          const Sidebar(selectedIndex: 6),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Réessayer',
              icon: Icons.refresh,
              onPressed: _loadSettings,
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSettingsSection(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paramètres',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configurez les paramètres de l\'application',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179), // Équivalent à withOpacity(0.7)
              ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Apparence'),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode sombre'),
                  subtitle: const Text('Activer le thème sombre pour l\'application'),
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        _buildSectionTitle('Notifications'),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Recevoir des notifications de l\'application'),
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        _buildSectionTitle('Langue'),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Langue de l\'application',
                    border: InputBorder.none,
                  ),
                  value: selectedLanguage,
                  items: ['Français', 'English', 'Español']
                      .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        _buildSectionTitle('Administration'),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode maintenance'),
                  subtitle: const Text('Activer le mode maintenance pour l\'application'),
                  value: isMaintenanceMode,
                  onChanged: (value) {
                    setState(() {
                      isMaintenanceMode = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        Center(
          child: ModernButton(
            text: 'Sauvegarder les paramètres',
            icon: Icons.save,
            onPressed: _saveSettings,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}