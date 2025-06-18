import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_lib/config/supabase_config.dart';
import 'services/notification_service.dart';
import 'services/event_listener_service.dart';
import 'routes.dart';
import 'theme.dart';

// Application de débogage qui affiche les étapes d'initialisation
void main() {
  // Capture des erreurs non gérées
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      print('FLUTTER ERROR: ${details.exception}');
      print('STACK TRACE: ${details.stack}');
    }
    FlutterError.presentError(details);
  };
  
  // Initialisation de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lancer l'application de débogage
  runApp(const DebugApp());
}

class DebugApp extends StatefulWidget {
  const DebugApp({super.key});

  @override
  State<DebugApp> createState() => _DebugAppState();
}

class _DebugAppState extends State<DebugApp> {
  bool _isInitialized = false;
  String _currentStep = 'Démarrage...';
  String? _error;
  final List<String> _logs = [];
  bool _showLogs = false;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      _addLog('Initialisation de l\'application...');
      setState(() {
        _currentStep = 'Initialisation de l\'application...';
      });
      
      // Chargement des variables d'environnement
      _addLog('Chargement des variables d\'environnement...');
      setState(() {
        _currentStep = 'Chargement des variables d\'environnement...';
      });
      
      try {
        await dotenv.load();
        _addLog('Variables d\'environnement chargées avec succès');
      } catch (e) {
        _addLog('ERREUR lors du chargement des variables d\'environnement: $e');
        throw Exception('Erreur lors du chargement des variables d\'environnement: $e');
      }
      
      // Initialisation de Firebase
      _addLog('Initialisation de Firebase...');
      setState(() {
        _currentStep = 'Initialisation de Firebase...';
      });
      
      try {
        await Firebase.initializeApp();
        _addLog('Firebase initialisé avec succès');
      } catch (e) {
        _addLog('ERREUR lors de l\'initialisation de Firebase: $e');
        throw Exception('Erreur lors de l\'initialisation de Firebase: $e');
      }
      
      // Initialisation du service de notification
      _addLog('Initialisation du service de notification...');
      setState(() {
        _currentStep = 'Initialisation du service de notification...';
      });
      
      try {
        final notificationService = NotificationService();
        await notificationService.init();
        _addLog('Service de notification initialisé avec succès');
      } catch (e) {
        _addLog('ERREUR lors de l\'initialisation du service de notification: $e');
        throw Exception('Erreur lors de l\'initialisation du service de notification: $e');
      }
      
      // Initialisation du service d'écoute d'événements
      _addLog('Initialisation du service d\'écoute d\'événements...');
      setState(() {
        _currentStep = 'Initialisation du service d\'écoute d\'événements...';
      });
      
      try {
        final eventListenerService = EventListenerService();
        await eventListenerService.init();
        _addLog('Service d\'écoute d\'événements initialisé avec succès');
      } catch (e) {
        _addLog('ERREUR lors de l\'initialisation du service d\'écoute d\'événements: $e');
        throw Exception('Erreur lors de l\'initialisation du service d\'écoute d\'événements: $e');
      }
      
      // Initialisation de Supabase
      _addLog('Initialisation de Supabase...');
      setState(() {
        _currentStep = 'Initialisation de Supabase...';
      });
      
      _addLog('URL Supabase: ${SupabaseConfig.url}');
      // Ne pas afficher la clé complète pour des raisons de sécurité
      _addLog('Clé Supabase (premiers caractères): ${SupabaseConfig.anonKey.substring(0, 5)}...');
      
      try {
        await Supabase.initialize(
          url: SupabaseConfig.url,
          anonKey: SupabaseConfig.anonKey,
        );
        _addLog('Supabase initialisé avec succès');
      } catch (e) {
        _addLog('ERREUR lors de l\'initialisation de Supabase: $e');
        throw Exception('Erreur lors de l\'initialisation de Supabase: $e');
      }
      
      _addLog('Initialisation de l\'application terminée avec succès');
      setState(() {
        _currentStep = 'Initialisation terminée';
        _isInitialized = true;
      });
      
    } catch (e, stack) {
      _addLog('ERREUR FATALE: $e');
      _addLog('STACK TRACE: $stack');
      setState(() {
        _error = e.toString();
      });
    }
  }
  
  void _addLog(String log) {
    if (kDebugMode) {
      print(log);
    }
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $log');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spota Admin - Debug',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Spota Admin - Debug'),
          actions: [
            IconButton(
              icon: Icon(_showLogs ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _showLogs = !_showLogs;
                });
              },
              tooltip: _showLogs ? 'Masquer les logs' : 'Afficher les logs',
            ),
          ],
        ),
        body: _error != null
            ? _buildErrorScreen()
            : _isInitialized
                ? _buildSuccessScreen()
                : _buildLoadingScreen(),
      ),
    );
  }
  
  Widget _buildLoadingScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _currentStep,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (_showLogs) _buildLogs(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Erreur lors du démarrage de l\'application',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isInitialized = false;
                  _currentStep = 'Redémarrage...';
                  _logs.clear();
                });
                _initializeApp();
              },
              child: const Text('Réessayer'),
            ),
            if (_showLogs) _buildLogs(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Initialisation réussie !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MaterialApp.router(
                      title: 'Spota – Admin Dashboard',
                      theme: AppTheme.dark,
                      routerConfig: AppRoutes.router,
                      debugShowCheckedModeBanner: false,
                    ),
                  ),
                );
              },
              child: const Text('Lancer l\'application principale'),
            ),
            const SizedBox(height: 16),
            if (_showLogs) _buildLogs(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogs() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Logs:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              for (final log in _logs)
                Text(
                  log,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
