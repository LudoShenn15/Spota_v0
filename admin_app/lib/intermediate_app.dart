import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';

void main() {
  runApp(const IntermediateApp());
}

class IntermediateApp extends StatelessWidget {
  const IntermediateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spota Admin Intermediate',
      theme: AppTheme.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Configuration du routeur simplifiée
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreenSimple(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreenSimple(),
    ),
    GoRoute(
      path: '/coaches',
      builder: (context, state) => const PlaceholderScreen(title: 'Coaches'),
    ),
    GoRoute(
      path: '/courses',
      builder: (context, state) => const PlaceholderScreen(title: 'Courses'),
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const PlaceholderScreen(title: 'Bookings'),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const PlaceholderScreen(title: 'Users'),
    ),
    GoRoute(
      path: '/schedule',
      builder: (context, state) => const PlaceholderScreen(title: 'Schedule'),
    ),
    GoRoute(
      path: '/programs',
      builder: (context, state) => const PlaceholderScreen(title: 'Programs'),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const PlaceholderScreen(title: 'Notifications'),
    ),
  ],
);

// Écran de démarrage simplifié
class SplashScreenSimple extends StatefulWidget {
  const SplashScreenSimple({super.key});

  @override
  State<SplashScreenSimple> createState() => _SplashScreenSimpleState();
}

class _SplashScreenSimpleState extends State<SplashScreenSimple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Rediriger vers le tableau de bord après l'animation
    Future.delayed(const Duration(seconds: 3), () {
      context.go('/dashboard');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SPOTA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Écran de tableau de bord simplifié
class DashboardScreenSimple extends StatelessWidget {
  const DashboardScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            extended: true,
            minExtendedWidth: 250,
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              final destinations = [
                '/dashboard',
                '/coaches',
                '/courses',
                '/bookings',
                '/users',
                '/schedule',
                '/programs',
                '/notifications',
              ];
              if (index < destinations.length) {
                context.go(destinations[index]);
              }
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sports),
                label: Text('Coaches'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                label: Text('Courses'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_online),
                label: Text('Bookings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('Schedule'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fitness_center),
                label: Text('Programs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
            ],
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // App bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.deepPurple,
                        child: Text('A'),
                      ),
                      const SizedBox(width: 8),
                      const Text('Admin'),
                    ],
                  ),
                ),
                // Dashboard content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildStatCard(
                          context,
                          'Coaches',
                          '12',
                          Icons.sports,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          'Courses',
                          '24',
                          Icons.school,
                          Colors.green,
                        ),
                        _buildStatCard(
                          context,
                          'Bookings',
                          '156',
                          Icons.book_online,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          'Users',
                          '89',
                          Icons.people,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          context,
                          'Schedule',
                          '18',
                          Icons.calendar_today,
                          Colors.teal,
                        ),
                        _buildStatCard(
                          context,
                          'Programs',
                          '7',
                          Icons.fitness_center,
                          Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go('/${title.toLowerCase()}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Écran générique pour les autres sections
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            extended: true,
            minExtendedWidth: 250,
            selectedIndex: _getSelectedIndex(title),
            onDestinationSelected: (int index) {
              final destinations = [
                '/dashboard',
                '/coaches',
                '/courses',
                '/bookings',
                '/users',
                '/schedule',
                '/programs',
                '/notifications',
              ];
              if (index < destinations.length) {
                context.go(destinations[index]);
              }
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sports),
                label: Text('Coaches'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                label: Text('Courses'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_online),
                label: Text('Bookings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('Schedule'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fitness_center),
                label: Text('Programs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
            ],
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // App bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.deepPurple,
                        child: Text('A'),
                      ),
                      const SizedBox(width: 8),
                      const Text('Admin'),
                    ],
                  ),
                ),
                // Placeholder content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForTitle(title),
                          size: 100,
                          color: _getColorForTitle(title),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cette section est en cours de développement',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.go('/dashboard');
                          },
                          child: const Text('Retour au Dashboard'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String title) {
    switch (title.toLowerCase()) {
      case 'dashboard':
        return 0;
      case 'coaches':
        return 1;
      case 'courses':
        return 2;
      case 'bookings':
        return 3;
      case 'users':
        return 4;
      case 'schedule':
        return 5;
      case 'programs':
        return 6;
      case 'notifications':
        return 7;
      default:
        return 0;
    }
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard;
      case 'coaches':
        return Icons.sports;
      case 'courses':
        return Icons.school;
      case 'bookings':
        return Icons.book_online;
      case 'users':
        return Icons.people;
      case 'schedule':
        return Icons.calendar_today;
      case 'programs':
        return Icons.fitness_center;
      case 'notifications':
        return Icons.notifications;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'dashboard':
        return Colors.indigo;
      case 'coaches':
        return Colors.blue;
      case 'courses':
        return Colors.green;
      case 'bookings':
        return Colors.orange;
      case 'users':
        return Colors.purple;
      case 'schedule':
        return Colors.teal;
      case 'programs':
        return Colors.amber;
      case 'notifications':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
