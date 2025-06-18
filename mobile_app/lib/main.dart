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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
