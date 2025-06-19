import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/coaches_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/users_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/payments_screen.dart';
import 'package:flutter/material.dart'; // Needed for BuildContext
import 'package:get/get.dart';
import 'package:shared_lib/services/api_service.dart';
import 'package:shared_lib/models/user.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/coaches_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/users_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/login_screen.dart';

// Top-level redirect function
Future<String?> _redirectLogic(BuildContext context, GoRouterState state) async {
  // Get.isRegistered<ApiService>() check is important if ApiService might not be ready
  // during very early app phases or in test environments.
  if (!Get.isRegistered<ApiService>()) {
    // If ApiService is not ready, it might be too early to make decisions.
    // Or, if Supabase/ApiService initialization failed, this prevents further errors.
    // Depending on app logic, you might allow access to initial routes like splash,
    // or redirect to an error/setup page. For now, if it's not ready, don't redirect.
    return null;
  }
  final ApiService apiService = Get.find<ApiService>();

  User? currentUser;
  try {
    currentUser = await apiService.getCurrentUser();
  } catch (e) {
    // If error fetching user (e.g. network issue, Supabase down), treat as not logged in.
    debugPrint("Error fetching current user in redirect: $e");
    currentUser = null;
  }

  final bool loggedIn = currentUser != null;
  final bool isAdmin = loggedIn && currentUser!.isAdmin == true;

  final String currentLocation = state.matchedLocation;
  final bool isGoingToLogin = currentLocation == '/login';
  final bool isGoingToSplash = currentLocation == '/';

  // Public routes accessible by anyone
  final publicRoutes = ['/login', '/']; // Splash and Login are public

  final bool isPublicRoute = publicRoutes.contains(currentLocation);

  if (isGoingToSplash) {
    return null; // Always allow going to splash screen, it has its own logic
  }

  if (!loggedIn && !isPublicRoute) {
    debugPrint("Redirect: Not logged in, trying to access $currentLocation. Redirecting to /login.");
    return '/login'; // Not logged in, not going to a public page -> redirect to login
  }

  if (loggedIn && !isAdmin && !isPublicRoute) {
    // Logged in but not an admin, trying to access a protected admin route.
    // Sign them out and redirect to login.
    debugPrint("Redirect: Logged in but NOT ADMIN, trying to access $currentLocation. Signing out and redirecting to /login.");
    await apiService.signOut();
    return '/login';
  }

  if (loggedIn && isAdmin && isGoingToLogin) {
    debugPrint("Redirect: Logged in AS ADMIN, trying to access /login. Redirecting to /dashboard.");
    return '/dashboard'; // Logged in as admin and going to login -> redirect to dashboard
  }

  debugPrint("Redirect: No specific redirection condition met for $currentLocation. Current user: ${currentUser?.id}, isAdmin: $isAdmin");
  return null; // No redirect needed
}


class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: _redirectLogic, // Added redirect logic
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login', // Added login route
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/coaches',
        builder: (context, state) => const CoachesScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/programs',
        builder: (context, state) => const ProgramsScreen(),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const BookingsScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}