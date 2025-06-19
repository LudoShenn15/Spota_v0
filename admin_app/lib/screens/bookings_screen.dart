import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Added GetX import
import 'package:shared_lib/models/booking.dart';
import 'package:shared_lib/models/user.dart'; // User model
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/services/api_service.dart';
import '../components/sidebar.dart';
import '../components/modern_button.dart';
import '../components/badge.dart' as app_badge;

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Booking> bookings = [];
  List<User> users = []; // Changed AppUser to User
  List<Course> courses = [];
  bool isLoading = true;
  String? error;
  String statusFilter = 'Tous';
  
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

      final loadedBookings = await _apiService.getAllBookings();
      final loadedUsers = await _apiService.getAllUsers();
      final loadedCourses = await _apiService.getAllCourses();

      setState(() {
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

  List<Booking> get filteredBookings {
    if (statusFilter == 'Tous') {
      return bookings;
    }
    return bookings.where((booking) => booking.status == statusFilter).toList();
  }

  String getUserName(String userId) {
    final user = users.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(
        id: 'unknown',
        email: 'unknown@example.com',
        fullName: 'Utilisateur inconnu',
        isAdmin: false, // Corrected: Use isAdmin instead of role
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return user.fullName; // Changed user.name to user.fullName
  }

  String getCourseName(String courseId) {
    final course = courses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => Course(
        id: 'unknown',
        title: 'Cours inconnu',
        coachId: 'unknown', // Kept as unknown
        capacity: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // duration: 60, // duration is not required by Course constructor
        // category: '', // category is not required by Course constructor
        // difficulty: '', // difficulty is not required
        // imageUrl: '', // imageUrl is not required
        // isActive: false, // isActive is not required
      ),
    );
    return course.title;
  }

  app_badge.BadgeType getStatusBadgeType(String status) {
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
  
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmé';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          const Sidebar(selectedIndex: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildBookingsTable(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Réservations',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gérez les réservations des utilisateurs',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                    ),
              ),
            ],
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: statusFilter,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      statusFilter = value;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'Tous',
                    child: Text('Tous les statuts'),
                  ),
                  DropdownMenuItem(
                    value: 'confirmed',
                    child: Text('Confirmé'),
                  ),
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Annulé'),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              ModernButton(
                text: 'Actualiser',
                icon: Icons.refresh,
                onPressed: _loadData,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Liste des réservations (${filteredBookings.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredBookings.isEmpty
                    ? Center(
                        child: Text(
                          'Aucune réservation trouvée',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Utilisateur')),
                              DataColumn(label: Text('Cours')),
                              DataColumn(label: Text('Statut')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: filteredBookings.map((booking) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(booking.id.substring(0, 8))),
                                  DataCell(Text(getUserName(booking.userId))),
                                  DataCell(Text(getCourseName(booking.courseId))),
                                  DataCell(
                                    app_badge.Badge(
                                      text: getStatusText(booking.status),
                                      type: getStatusBadgeType(booking.status),
                                    ),
                                  ),
                                  DataCell(Text(
                                    booking.bookingDate.toString().substring(0, 10),
                                  )),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () {
                                            // TODO: Implémenter la modification
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          onPressed: () {
                                            // TODO: Implémenter la suppression
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
