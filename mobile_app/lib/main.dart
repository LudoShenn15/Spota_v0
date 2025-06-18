import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'package:shared_lib/config/supabase_config.dart';

// Gestionnaire d'erreurs global
void _handleError(Object error, StackTrace stack) {
  if (kDebugMode) {
    print('ERREUR GLOBALE CAPTURÉE: $error');
    print('STACK TRACE: $stack');
  }
}

Future<void> initializeApp() async {
  try {
    if (kDebugMode) {
      print('Initialisation de l\'application mobile...');
    }
    
    // Chargement des variables d'environnement
    try {
      await dotenv.load();
      if (kDebugMode) {
        print('Variables d\'environnement chargées avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des variables d\'environnement: $e');
        print('Continuons sans les variables d\'environnement...');
      }
    }
    
    // Initialisation de Supabase
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        debug: kDebugMode,
      );
      if (kDebugMode) {
        print('Supabase initialisé avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation de Supabase: $e');
        throw Exception('Échec de l\'initialisation de Supabase');
      }
    }
    
    if (kDebugMode) {
      print('Initialisation de l\'application mobile terminée');
    }
  } catch (e, stack) {
    if (kDebugMode) {
      print('ERREUR LORS DE L\'INITIALISATION: $e');
      print('STACK TRACE: $stack');
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
    // Initialiser l'application
    await initializeApp();
    
    // Lancer l'application avec ProviderScope pour la gestion d'état
    runApp(const ProviderScope(child: SpotaApp()));
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
