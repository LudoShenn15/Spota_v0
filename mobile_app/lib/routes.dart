import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/profile_settings_screen.dart';

// Widgets
import 'widgets/bottom_navbar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Routes d'authentification
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      
      // Routes principales avec navigation par onglets
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/explore',
            name: 'explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/booking',
            name: 'booking',
            builder: (context, state) => const BookingScreen(),
            routes: [
              GoRoute(
                path: ':courseId',
                name: 'bookingCourse',
                builder: (context, state) => BookingScreen(
                  courseId: state.pathParameters['courseId'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/stats',
            name: 'stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Routes secondaires (en dehors de la navigation par onglets)
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
        parentNavigatorKey: _rootNavigatorKey,
      ),
      GoRoute(
        path: '/my-bookings',
        name: 'myBookings',
        builder: (context, state) => const MyBookingsScreen(),
        parentNavigatorKey: _rootNavigatorKey,
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
        parentNavigatorKey: _rootNavigatorKey,
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
        parentNavigatorKey: _rootNavigatorKey,
      ),
      GoRoute(
        path: '/help-support',
        name: 'helpSupport',
        builder: (context, state) => const HelpSupportScreen(),
        parentNavigatorKey: _rootNavigatorKey,
      ),
      GoRoute(
        path: '/profile-settings',
        name: 'profileSettings',
        builder: (context, state) => const ProfileSettingsScreen(),
        parentNavigatorKey: _rootNavigatorKey,
      ),
    ],
    redirect: (context, state) {
      // TODO: Implémenter la redirection en fonction de l'état d'authentification
      // Exemple: Si l'utilisateur n'est pas connecté et essaie d'accéder à une page protégée, rediriger vers /login
      return null;
    },
  );
}

// Widget pour la navigation par onglets
class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  State<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;

  static const List<String> _paths = [
    '/home',
    '/explore',
    '/booking',
    '/stats',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    // Déterminer l'index actuel en fonction de l'emplacement actuel
    final location = GoRouterState.of(context).matchedLocation;
    _updateIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  void _updateIndex(String location) {
    final index = _paths.indexWhere((path) => location.startsWith(path));
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    // Ne naviguer que si l'index a changé
    if (index != _currentIndex) {
      context.go(_paths[index]);
    }
  }
}
