import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/providers/api_providers.dart'; // To override apiServiceProvider
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/widgets/stat_card.dart'; // To find StatCard widgets
import 'package:shared_lib/models/user.dart' as models_user;
import 'package:shared_lib/models/user_stats.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/booking.dart';
import 'package:shared_lib/services/api_service.dart';

// --- Fake ApiService for testing ---
class FakeApiService implements ApiService {
  models_user.User? mockCurrentUser;
  List<Booking>? mockUpcomingBookings;
  UserStats? mockUserStats;
  bool simulateLoadingDelay;

  FakeApiService({
    this.mockCurrentUser,
    this.mockUpcomingBookings,
    this.mockUserStats,
    this.simulateLoadingDelay = false,
  });

  @override
  Future<models_user.User?> getCurrentUser() async {
    if (simulateLoadingDelay) await Future.delayed(const Duration(milliseconds: 50));
    return mockCurrentUser;
  }

  @override
  Future<List<Booking>> getUpcomingUserBookings() async {
    if (simulateLoadingDelay) await Future.delayed(const Duration(milliseconds: 50));
    return mockUpcomingBookings ?? [];
  }

  @override
  Future<UserStats?> getUserStats() async {
    if (simulateLoadingDelay) await Future.delayed(const Duration(milliseconds: 50));
    return mockUserStats;
  }

  // Implement other ApiService methods as needed, returning default/empty values or throwing UnimplementedError
  // For this test, we only care about the ones used by HomeScreen's _loadData
  @override
  Future<List<Course>> getCoursesByIds(List<String> ids) async => [];

  // Add all other methods from ApiService interface with default implementations
  @override
  Future<models_user.User> signUp(String email, String password, models_user.User user) async => throw UnimplementedError();
  @override
  Future<models_user.User> signIn(String email, String password) async => throw UnimplementedError();
  @override
  Future<void> signOut() async => throw UnimplementedError();
  @override
  Future<void> resetPassword(String email) async => throw UnimplementedError();
  @override
  Future<bool> isAuthenticated() async => mockCurrentUser != null;
  @override
  Future<List<models_user.User>> getAllUsers() async => throw UnimplementedError();
  @override
  Future<models_user.User> getUserById(String id) async => throw UnimplementedError();
  @override
  Future<models_user.User> createUser(models_user.User user) async => throw UnimplementedError();
  @override
  Future<models_user.User> updateUser(String id, models_user.User user) async => throw UnimplementedError();
  @override
  Future<void> deleteUser(String id) async => throw UnimplementedError();
  @override
  Future<List<Course>> getAllCourses() async => [];
  @override
  Future<List<Course>> getAvailableCourses() async => [];
  @override
  Future<Course> getCourseById(String id) async => throw UnimplementedError();
  @override
  Future<Course> createCourse(Course course) async => throw UnimplementedError();
  @override
  Future<Course> updateCourse(String id, Course course) async => throw UnimplementedError();
  @override
  Future<void> deleteCourse(String id) async => throw UnimplementedError();
  @override
  Future<List<Booking>> getAllBookings() async => [];
  @override
  Future<Booking> getBookingById(String id) async => throw UnimplementedError();
  @override
  Future<Booking> createBooking(Booking booking) async => throw UnimplementedError();
  @override
  Future<Booking> updateBooking(String id, Booking booking) async => throw UnimplementedError();
  @override
  Future<void> deleteBooking(String id) async => throw UnimplementedError();
  @override
  Future<List<Notification>> getUserNotificationsForCurrentUser() async => [];
  @override
  Future<void> nAsReadForCurrentUser(String notificationId) async {}
  @override
  Future<void> markAllNotificationsAsReadForCurrentUser() async {}
  @override
  Future<void> deleteNotificationForCurrentUser(String notificationId) async {}
  @override
  Future<UserStats> getUserStatsById(String id) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> getById(String table, String id) async => throw UnimplementedError();
  @override
  Future<List<Map<String, dynamic>>> getAll(String table) async => [];
  @override
  Future<Map<String, dynamic>> create(String table, Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> update(String table, String id, Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<void> delete(String table, String id) async => throw UnimplementedError();
  @override
  Future<List<Schedule>> getAllSchedules() async => throw UnimplementedError();
  @override
  Future<Schedule> getScheduleById(String id) async => throw UnimplementedError();
  @override
  Future<Schedule> createSchedule(Schedule schedule) async => throw UnimplementedError();
  @override
  Future<Schedule> updateSchedule(String id, Schedule schedule) async => throw UnimplementedError();
  @override
  Future<void> deleteSchedule(String id) async => throw UnimplementedError();
  @override
  Future<List<Coach>> getAllCoaches() async => throw UnimplementedError();
  @override
  Future<Coach> getCoachById(String id) async => throw UnimplementedError();
  @override
  Future<Coach> createCoach(Coach coach) async => throw UnimplementedError();
  @override
  Future<Coach> updateCoach(String id, Coach coach) async => throw UnimplementedError();
  @override
  Future<void> deleteCoach(String id) async => throw UnimplementedError();
  @override
  Future<List<TimeSlot>> getAllTimeSlots() async => throw UnimplementedError();
  @override
  Future<TimeSlot> getTimeSlotById(String id) async => throw UnimplementedError();
  @override
  Future<TimeSlot> createTimeSlot(TimeSlot timeSlot) async => throw UnimplementedError();
  @override
  Future<TimeSlot> updateTimeSlot(String id, TimeSlot timeSlot) async => throw UnimplementedError();
  @override
  Future<void> deleteTimeSlot(String id) async => throw UnimplementedError();
  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date) async => throw UnimplementedError();
  @override
  Future<List<Subscription>> getAllSubscriptions() async => throw UnimplementedError();
  @override
  Future<Subscription> getSubscriptionById(String id) async => throw UnimplementedError();
  @override
  Future<Subscription> createSubscription(Subscription subscription) async => throw UnimplementedError();
  @override
  Future<Subscription> updateSubscription(String id, Subscription subscription) async => throw UnimplementedError();
  @override
  Future<void> deleteSubscription(String id) async => throw UnimplementedError();
  @override
  Future<List<SubscriptionType>> getAllSubscriptionTypes() async => throw UnimplementedError();
  @override
  Future<SubscriptionType> getSubscriptionTypeById(String id) async => throw UnimplementedError();
  @override
  Future<SubscriptionType> createSubscriptionType(SubscriptionType subscriptionType) async => throw UnimplementedError();
  @override
  Future<SubscriptionType> updateSubscriptionType(String id, SubscriptionType subscriptionType) async => throw UnimplementedError();
  @override
  Future<void> deleteSubscriptionType(String id) async => throw UnimplementedError();
  @override
  Future<List<Favorite>> getAllFavorites() async => throw UnimplementedError();
  @override
  Future<List<Favorite>> getUserFavorites(String userId) async => throw UnimplementedError();
  @override
  Future<List<Course>> getUserFavoriteCourses(String userId) async => throw UnimplementedError();
  @override
  Future<List<Coach>> getUserFavoriteCoaches(String userId) async => throw UnimplementedError();
  @override
  Future<void> addFavoriteCourse(String courseId) async => throw UnimplementedError();
  @override
  Future<void> addFavoriteCoach(String coachId) async => throw UnimplementedError();
  @override
  Future<void> removeFavoriteCourse(String courseId) async => throw UnimplementedError();
  @override
  Future<void> removeFavoriteCoach(String coachId) async => throw UnimplementedError();
  @override
  Future<void> addFavorite(String userId, String itemId, String itemType) async => throw UnimplementedError();
  @override
  Future<void> removeFavorite(String userId, String itemId, String itemType) async => throw UnimplementedError();
  @override
  Future<List<Notification>> getAllNotifications() async => throw UnimplementedError();
  @override
  Future<Notification> getNotificationById(String id) async => throw UnimplementedError();
  @override
  Future<List<Notification>> getUserNotifications(String userId) async => throw UnimplementedError();
  @override
  Future<Notification> createNotification(Notification notification) async => throw UnimplementedError();
  @override
  Future<void> markNotificationAsRead(String notificationId) async => throw UnimplementedError();
  @override
  Future<void> markAllNotificationsAsRead(String userId) async => throw UnimplementedError();
  @override
  Future<void> deleteNotification(String notificationId) async => throw UnimplementedError();
  @override
  Future<void> deleteAllUserNotifications(String userId) async => throw UnimplementedError();
  @override
  Future<List<UserStats>> getAllUserStats() async => throw UnimplementedError();
  @override
  Future<List<UserStats>> getUserStatsByUserId(String userId) async => throw UnimplementedError();
  @override
  Future<UserStats> getUserStatsByPeriod(String userId, DateTime startDate, DateTime endDate) async => throw UnimplementedError();
  @override
  Future<UserStats> createUserStats(UserStats userStats) async => throw UnimplementedError();
  @override
  Future<UserStats> updateUserStats(String id, UserStats userStats) async => throw UnimplementedError();
  @override
  Future<List<Rating>> getAllRatings() async => throw UnimplementedError();
  @override
  Future<Rating> getRatingById(String id) async => throw UnimplementedError();
  @override
  Future<List<Rating>> getUserRatings(String userId) async => throw UnimplementedError();
  @override
  Future<List<Rating>> getItemRatings(String itemId, String itemType) async => throw UnimplementedError();
  @override
  Future<double> getAverageRating(String itemId, String itemType) async => throw UnimplementedError();
  @override
  Future<Rating> createRating(Rating rating) async => throw UnimplementedError();
  @override
  Future<void> deleteRating(String id) async => throw UnimplementedError();
  @override
  Future<List<Course>> searchCourses({String? query, String? category, double? minPrice, double? maxPrice, String? difficulty, String? location}) async => throw UnimplementedError();
  @override
  Future<List<Coach>> searchCoaches({String? query, String? specialty, String? location, double? minRating}) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> submitContactForm({required String name, required String email, required String subject, required String message}) async => throw UnimplementedError();
  @override
  Future<Subscription?> getUserSubscription() async => throw UnimplementedError();
  @override
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async => throw UnimplementedError();
  @override
  Future<Subscription> updateSubscriptionPlan(String planId) async => throw UnimplementedError();
  @override
  Future<void> cancelSubscription() async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> getUserProfile() async => throw UnimplementedError();
  @override
  Future<UserStats?> getUserStats() async { // Changed return type to nullable UserStats?
    if (simulateLoadingDelay) await Future.delayed(const Duration(milliseconds: 50));
    return mockUserStats; // Directly return the potentially null mockUserStats
  }
  @override
  Future<void> logout() async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> search(String query) async => throw UnimplementedError();
  @override
  Future<List<Booking>> getUserBookings() async => mockUpcomingBookings ?? [];
  @override
  Future<List<Booking>> getPastUserBookings() async => [];
  @override
  Future<void> cancelBooking(String bookingId) async => throw UnimplementedError();
  @override
  Future<void> rateBooking(String bookingId, int rating) async => throw UnimplementedError();
}

// --- Test Data ---
final mockUser = models_user.User(
  id: 'user-123',
  email: 'test@example.com',
  fullName: 'Test User',
  role: models_user.UserRole.member,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final mockUserStatsData = UserStats(
  id: 'stats-123',
  userId: 'user-123',
  totalSessions: 10,
  totalMinutes: 600,
  caloriesBurned: 2500,
  activityBreakdown: {'Yoga': 5, 'Cardio': 5},
  startDate: DateTime.now().subtract(const Duration(days: 30)),
  endDate: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  totalBookings: 10,
  totalHours: 10.0,
  favoriteActivity: 'Yoga',
);

void main() {
  late FakeApiService fakeApiService;

  setUp(() {
    // Default setup for most tests
    fakeApiService = FakeApiService(
      mockCurrentUser: mockUser,
      mockUpcomingBookings: [], // Default to no upcoming courses
      mockUserStats: mockUserStatsData, // Default to having stats
    );
  });

  Widget createTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        apiServiceProvider.overrideWithValue(fakeApiService),
      ],
      child: MaterialApp(home: child), // MaterialApp is needed for Directionality, MediaQuery, etc.
    );
  }

  testWidgets('shows loading indicator initially', (WidgetTester tester) async {
    fakeApiService.simulateLoadingDelay = true; // Ensure there's a loading state
    // For this test, specifically make getUserStats take time or return incomplete future initially
    // However, the HomeScreen's _isLoading is set to true at start of _loadData and false at end.
    // Pumping just HomeScreen should show it.

    await tester.pumpWidget(createTestableWidget(const HomeScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for all timers and microtasks to complete
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });


  testWidgets('shows "unavailable" message when UserStats are null', (WidgetTester tester) async {
    // Arrange: Configure FakeApiService to return null for userStats
    fakeApiService.mockUserStats = null;
    fakeApiService.mockUpcomingBookings = []; // Provide empty bookings
    fakeApiService.mockCurrentUser = mockUser; // Ensure user is logged in

    await tester.pumpWidget(createTestableWidget(const HomeScreen()));

    // Act: Wait for loading to complete
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('User statistics are currently unavailable.'), findsOneWidget);
    expect(find.byType(StatCard), findsNothing); // No StatCards should be shown
  });

  testWidgets('shows StatCards when UserStats are available', (WidgetTester tester) async {
    // Arrange: Default setup in setUp() already provides mockUserStatsData
    // fakeApiService.mockUserStats is already mockUserStatsData
    fakeApiService.mockUpcomingBookings = [];
    fakeApiService.mockCurrentUser = mockUser;

    await tester.pumpWidget(createTestableWidget(const HomeScreen()));

    // Act: Wait for loading to complete
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('User statistics are currently unavailable.'), findsNothing);

    // Check for specific stats based on mockUserStatsData
    expect(find.byType(StatCard), findsWidgets); // Should find multiple StatCards
    expect(find.text('Cours suivis'), findsOneWidget);
    expect(find.text('${mockUserStatsData.totalBookings}'), findsOneWidget);
    expect(find.text('Heures d\'entraînement'), findsOneWidget);
    expect(find.text(mockUserStatsData.totalHours.toStringAsFixed(1)), findsOneWidget);
    expect(find.text('Activité favorite'), findsOneWidget);
    expect(find.text(mockUserStatsData.favoriteActivity), findsOneWidget);
  });
}
