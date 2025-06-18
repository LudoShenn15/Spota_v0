import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/course_details_screen.dart';

void main() {
import 'package:go_router/go_router.dart';
import 'package:mobile_app/routes.dart'; // Assuming AppRouter and _rootNavigatorKey are accessible or need mocking

void main() {
  // Test navigator key
  final GlobalKey<NavigatorState> testNavigatorKey = GlobalKey<NavigatorState>();

  // Simplified router for testing CourseDetailsScreen navigation.
  // This avoids issues with Supabase dependency in the main AppRouter.router's redirect logic for this widget test.
  final testRouter = GoRouter(
    initialLocation: '/',
    navigatorKey: testNavigatorKey, // Use a specific key for testing if needed for deep links
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('Mock Home Screen')),
      ),
      GoRoute(
        path: '/course-details/:courseId',
        name: 'courseDetails', // Ensure this matches the name used in AppRouter if any navigation relies on it
        builder: (context, state) => CourseDetailsScreen(
          courseId: state.pathParameters['courseId']!,
        ),
      ),
    ],
  );

  group('CourseDetailsScreen Direct Widget Test', () {
    testWidgets('renders correctly with course ID', (WidgetTester tester) async {
      const String mockCourseId = 'test-course-123';

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const MaterialApp(
          home: CourseDetailsScreen(courseId: mockCourseId),
        ),
      );

      // Verify AppBar title.
      expect(find.text('Course Details'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify course ID is displayed.
      expect(find.text('Course ID: $mockCourseId'), findsOneWidget);
      expect(find.byType(Center), findsOneWidget); // Check if the text is within a Center widget
    });
  });

  group('CourseDetailsScreen Navigation Test', () {
    testWidgets('navigates to CourseDetailsScreen and displays correct course ID', (WidgetTester tester) async {
      const String navigateCourseId = 'nav-course-456';

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );

      // Ensure the initial screen is the mock home screen
      expect(find.text('Mock Home Screen'), findsOneWidget);

      // Navigate to the course details screen
      // Use a context that has access to the GoRouter instance
      final BuildContext context = tester.element(find.text('Mock Home Screen'));
      GoRouter.of(context).go('/course-details/$navigateCourseId');

      // Wait for navigation to complete and screen to build
      await tester.pumpAndSettle();

      // Verify CourseDetailsScreen is displayed
      expect(find.text('Course Details'), findsOneWidget); // AppBar title
      expect(find.text('Course ID: $navigateCourseId'), findsOneWidget);
    });
  });
}
