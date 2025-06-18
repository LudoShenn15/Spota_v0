import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes.dart';
import 'theme.dart';

class SpotaApp extends StatelessWidget {
  const SpotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurer l'application pour le mode portrait uniquement
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configurer la barre d'état pour qu'elle soit transparente
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: SpotaTheme.surfaceColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp.router(
      title: 'Spota',
      theme: SpotaTheme.lightTheme,
      darkTheme: SpotaTheme.darkTheme,
      themeMode: ThemeMode.dark, // Forcer le thème sombre par défaut
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
