import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_lib/models/coach.dart';
import 'package:shared_lib/models/booking.dart';
import 'package:shared_lib/models/user.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/services/api_service.dart';
import '../components/stat_card.dart';
import '../components/modern_button.dart';
import '../components/badge.dart' as app_badge;
import '../components/progress_bar.dart';
import '../components/magic_tabs.dart';
import '../components/calendar_widget.dart';
import '../components/coach_card.dart';
import '../components/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Coach> coaches = [];
  List<Booking> bookings = [];
  List<AppUser> users = [];
  List<Course> courses = [];
  int selectedTabIndex = 0;
  bool isLoading = true;
  String? error;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final loadedCoaches = await _apiService.getAllCoaches();
      final loadedBookings = await _apiService.getAllBookings();
      final loadedUsers = await _apiService.getAllUsers();
      final loadedCourses = await _apiService.getAllCourses();
      
      setState(() {
        coaches = loadedCoaches;
        bookings = loadedBookings;
        users = loadedUsers;
        courses = loadedCourses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des données: $e';
        isLoading = false;
      });
    }
  }

  String getUserName(String userId) {
    final user = users.firstWhere(
      (user) => user.id == userId,
      orElse: () => AppUser(
        id: 'unknown',
        email: 'unknown@example.com',
        name: 'Utilisateur inconnu',
        phone: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return user.name;
  }

  String getCourseName(String courseId) {
    final course = courses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => Course(
        id: 'unknown',
        title: 'Cours inconnu',
        coachId: '',
        capacity: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return course.title;
  }

  // Fonction pour déterminer si un coach est actif (simulation)
  bool isCoachActive(Coach coach) {
    // Dans un cas réel, cette information pourrait être stockée dans la base de données
    // Pour l'instant, on considère qu'un coach est actif s'il a au moins un jour disponible
    return coach.availableDays.isNotEmpty;
  }

  // Fonction pour calculer les revenus d'un coach (simulation)
  double getCoachRevenue(Coach coach) {
    // Dans un cas réel, cette information serait calculée à partir des réservations
    // Pour l'instant, on génère une valeur aléatoire
    return 1000.0 + (coach.id.hashCode % 2000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          const Sidebar(selectedIndex: 0),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Réessayer',
              icon: Icons.refresh,
              onPressed: _loadData,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStats(),
          const SizedBox(height: 24),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tableau de bord',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenue dans votre espace administrateur',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                  ),
            ),
          ],
        ),
        ModernButton(
          text: 'Actualiser',
          icon: Icons.refresh,
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildStats() {
    final activeCoaches = coaches.where((coach) => isCoachActive(coach)).length;
    final totalBookings = bookings.length;
    final pendingBookings = bookings.where((booking) => booking.status == 'pending').length;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/coaches'),
            child: StatCard(
              title: 'Coachs actifs',
              value: '$activeCoaches',
              icon: Icons.person,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/bookings'),
            child: StatCard(
              title: 'Réservations totales',
              value: '$totalBookings',
              icon: Icons.calendar_today,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/bookings'),
            child: StatCard(
              title: 'Réservations en attente',
              value: '$pendingBookings',
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        MagicTabs(
          tabs: const ['Meilleurs coachs', 'Réservations récentes', 'Calendrier'],
          selectedIndex: selectedTabIndex,
          onTabSelected: (index) {
            setState(() {
              selectedTabIndex = index;
            });
          },
        ),
        const SizedBox(height: 24),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildTopCoaches();
      case 1:
        return _buildRecentBookings();
      case 2:
        return _buildCalendar();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTopCoaches() {
    // Filtrer les coachs actifs et les trier par revenus (simulés)
    final topCoaches = coaches
        .where((coach) => isCoachActive(coach))
        .toList()
        ..sort((a, b) => getCoachRevenue(b).compareTo(getCoachRevenue(a)));

    if (topCoaches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Aucun coach actif trouvé'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: topCoaches.length > 6 ? 6 : topCoaches.length,
      itemBuilder: (context, index) {
        final coach = topCoaches[index];
        return CoachCard(
          coach: coach,
          onEdit: () {
            // Navigation vers l'édition du coach
          },
          onDelete: () {
            // Afficher une boîte de dialogue de confirmation
          },
        );
      },
    );
  }

  Widget _buildRecentBookings() {
    // Trier les réservations par date
    final recentBookings = bookings.toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

    if (recentBookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Aucune réservation trouvée'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentBookings.length > 5 ? 5 : recentBookings.length,
      itemBuilder: (context, index) {
        final booking = recentBookings[index];
        final userName = getUserName(booking.userId);
        final courseName = getCourseName(booking.courseId);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(userName),
            subtitle: Text(courseName),
            trailing: app_badge.Badge(
              text: booking.status,
              type: _getStatusBadgeType(booking.status),
            ),
          ),
        );
      },
    );
  }

  app_badge.BadgeType _getStatusBadgeType(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return app_badge.BadgeType.success;
      case 'pending':
        return app_badge.BadgeType.warning;
      case 'cancelled':
        return app_badge.BadgeType.error;
      default:
        return app_badge.BadgeType.info;
    }
  }

  Widget _buildCalendar() {
    // Extraire les dates des réservations pour les mettre en évidence
    final highlightedDates = bookings.map((booking) => booking.bookingDate).toList();
    
    return Column(
      children: [
        CalendarWidget(
          selectedDate: selectedDate,
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
            });
          },
          highlightedDates: highlightedDates,
          highlightColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        _buildBookingsForSelectedDate(),
      ],
    );
  }

  Widget _buildBookingsForSelectedDate() {
    final bookingsForDate = bookings.where((booking) {
      return booking.bookingDate.year == selectedDate.year &&
          booking.bookingDate.month == selectedDate.month &&
          booking.bookingDate.day == selectedDate.day;
    }).toList();

    if (bookingsForDate.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Aucune réservation pour cette date'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Réservations du ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookingsForDate.length,
          itemBuilder: (context, index) {
            final booking = bookingsForDate[index];
            final userName = getUserName(booking.userId);
            final courseName = getCourseName(booking.courseId);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(userName),
                subtitle: Text(courseName),
                trailing: app_badge.Badge(
                  text: booking.status,
                  type: _getStatusBadgeType(booking.status),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
