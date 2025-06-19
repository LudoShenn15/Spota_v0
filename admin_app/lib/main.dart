import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart'; // Added GetX import
import 'package:shared_lib/services/api_service.dart'; // Added ApiService import
import 'app.dart';
import 'package:shared_lib/config/supabase_config.dart';

// Gestionnaire d'erreurs global
void _handleError(Object error, StackTrace stack) {
  if (kDebugMode) {
    print('ERREUR GLOBALE CAPTURÉE: $error');
    print('STACK TRACE: $stack');
  }
}

// Fonction pour initialiser un service avec timeout
Future<T> _initializeWithTimeout<T>(Future<T> future, String serviceName, {int timeoutSeconds = 10}) async {
  try {
    return await future.timeout(Duration(seconds: timeoutSeconds), onTimeout: () {
      throw TimeoutException('Timeout lors de l\'initialisation de $serviceName après $timeoutSeconds secondes');
    });
  } catch (e) {
    if (kDebugMode) {
      print('ERREUR lors de l\'initialisation de $serviceName: $e');
    }
    if (kIsWeb) {
      // Sur le web, on peut continuer même si certains services échouent
      if (kDebugMode) {
        print('Exécution sur le web, on continue malgré l\'erreur dans $serviceName');
      }
      return null as T;
    } else {
      // Sur mobile, on relance l'erreur
      rethrow;
    }
  }
}

Future<void> initializeApp() async {
  try {
    if (kDebugMode) {
      print('Initialisation de l\'application...');
    }
    
    // Chargement des variables d'environnement
    if (kDebugMode) {
      print('Chargement des variables d\'environnement...');
    }
    
    try {
      await _initializeWithTimeout(dotenv.load(), 'dotenv');
      if (kDebugMode) {
        print('Variables d\'environnement chargées avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des variables d\'environnement: $e');
        print('Continuons sans les variables d\'environnement...');
      }
    }
    
    // Firebase temporairement désactivé pour le débogage Web
    if (kDebugMode) {
      print('Firebase temporairement désactivé pour le débogage Web');
    }
    
    // Simuler un délai pour éviter de bloquer le thread principal
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Services de notification et d'écoute d'événements temporairement désactivés pour le débogage Web
    if (kDebugMode) {
      print('Services de notification et d\'écoute d\'événements temporairement désactivés');
    }
    
    // Simuler un délai pour éviter de bloquer le thread principal
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Initialisation de Supabase
    if (kDebugMode) {
      print('Initialisation de Supabase...');
      print('URL Supabase: ${SupabaseConfig.url}');
      // Ne pas afficher la clé complète pour des raisons de sécurité
      print('Clé Supabase (premiers caractères): ${SupabaseConfig.anonKey.substring(0, 5)}...');
    }
    
    try {
      await _initializeWithTimeout(
        Supabase.initialize(
          url: SupabaseConfig.url,
          anonKey: SupabaseConfig.anonKey,
        ),
        'Supabase',
        timeoutSeconds: 15
      );
      if (kDebugMode) {
        print('Supabase initialisé avec succès');
      }

      // Initialize ApiService with GetX
      final supabaseClient = Supabase.instance.client;
      final apiService = ApiService(supabaseClient);
      Get.put<ApiService>(apiService, permanent: true);
      if (kDebugMode) {
        print('ApiService initialisé et enregistré avec GetX.');
      }

    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation de Supabase: $e');
        print('Continuons sans Supabase...');
      }
      // If Supabase fails, ApiService might not be initialized with a valid client.
      // Depending on app requirements, might want to handle this case (e.g. put a dummy/offline ApiService).
      // For now, if Supabase init fails, Get.put for ApiService might not be reached or might use a null/unusable client.
      // The current _initializeWithTimeout catches and can allow continuing without Supabase on web.
      // If Supabase is critical, the rethrow on mobile in _initializeWithTimeout would prevent reaching Get.put.
    }
    
    if (kDebugMode) {
      print('Initialisation de l\'application terminée');
    }
  } catch (e, stack) {
    if (kDebugMode) {
      print('ERREUR LORS DE L\'INITIALISATION: $e');
      print('STACK TRACE: $stack');
    }
    // Sur le web, on peut continuer même si l'initialisation échoue
    if (!kIsWeb) {
      rethrow;
    }
  }
}

void main() async {
  // Capture des erreurs non gérées
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      print('FLUTTER ERROR: ${details.exception}');
      print('STACK TRACE: ${details.stack}');
    }
    FlutterError.presentError(details);
  };
  
  // Capture des erreurs asynchrones non gérées
  PlatformDispatcher.instance.onError = (error, stack) {
    _handleError(error, stack);
    return true;
  };
  
  // Initialisation de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Définir un timeout global pour l'initialisation
    await initializeApp().timeout(Duration(seconds: 30), onTimeout: () {
      if (kDebugMode) {
        print('TIMEOUT GLOBAL: L\'initialisation a pris trop de temps');
      }
      // Ne pas lancer d'exception, juste continuer
    });
    
    // Lancer l'application même si l'initialisation a échoué ou a expiré
    runApp(const SpotaApp());
  } catch (e, stack) {
    if (kDebugMode) {
      print('ERREUR FATALE: $e');
      print('STACK TRACE: $stack');
    }
    // Afficher une application d'erreur au lieu de planter complètement
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
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
                  e.toString(),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    main(); // Tenter de redémarrer l'application
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}