import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'routes.dart';
import 'theme.dart';

class SpotaApp extends StatefulWidget {
  const SpotaApp({super.key});

  @override
  State<SpotaApp> createState() => _SpotaAppState();
}

class _SpotaAppState extends State<SpotaApp> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Simuler un délai pour permettre à l'interface de s'afficher
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur dans l\'initialisation de l\'application: $e');
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'Spota – Admin Dashboard',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: Colors.deepPurple,
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Spota Admin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Chargement en cours...'),
              ],
            ),
          ),
        ),
      );
    } else if (_error != null) {
      return MaterialApp(
        title: 'Spota – Admin Dashboard',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Erreur',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _initializeApp();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // L'application principale
      return MaterialApp.router(
        title: 'Spota – Admin Dashboard',
        theme: AppTheme.dark,
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      );
    }
  }
}