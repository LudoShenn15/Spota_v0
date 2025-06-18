import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_lib/services/api_service.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/schedule.dart';
import 'package:shared_lib/models/booking.dart';
import '../components/sidebar.dart';
import '../components/modern_button.dart';

class ProgramEvent {
  final String title;
  final String time;
  final int capacity;
  final String courseId;

  ProgramEvent({
    required this.title,
    required this.time,
    required this.capacity,
    required this.courseId,
  });
}

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final ApiService _apiService = ApiService();
  
  // Calendrier
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  // Données
  // Ces champs sont utilisés dans _loadData mais pas directement référencés ailleurs
  // Nous les gardons pour une future implémentation
  // ignore: unused_field
  List<Course> _courses = [];
  // ignore: unused_field
  List<Schedule> _schedules = [];
  // ignore: unused_field
  List<Booking> _bookings = [];
  Map<DateTime, List<ProgramEvent>> _events = {};
  
  // Statistiques
  Map<String, int> _weeklyStats = {};
  Map<String, int> _monthlyStats = {};
  Map<String, int> _yearlyStats = {};
  
  bool isLoading = true;
  String? error;

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
      
      // Charger les données depuis Supabase
      final loadedCourses = await _apiService.getAllCourses();
      final loadedSchedules = await _apiService.getAllSchedules();
      final loadedBookings = await _apiService.getAllBookings();
      
      // Organiser les événements par jour
      final events = <DateTime, List<ProgramEvent>>{};
      
      for (final schedule in loadedSchedules) {
        // Trouver le cours associé
        final course = loadedCourses.firstWhere(
          (c) => c.id == schedule.courseId,
          orElse: () => Course(
            id: 'unknown',
            title: 'Cours inconnu',
            capacity: 0,
            coachId: 'unknown',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        // Convertir le jour de la semaine en date
        final now = DateTime.now();
        final dayIndex = _getDayIndex(schedule.day);
        final daysToAdd = (dayIndex - now.weekday + 7) % 7;
        final eventDate = DateTime(now.year, now.month, now.day + daysToAdd);
        
        // Créer l'événement
        final event = ProgramEvent(
          title: course.title,
          time: '${schedule.startTime} - ${schedule.endTime}',
          capacity: course.capacity,
          courseId: course.id,
        );
        
        // Ajouter à la liste des événements
        if (events[eventDate] == null) {
          events[eventDate] = [];
        }
        events[eventDate]!.add(event);
      }
      
      // Calculer les statistiques
      final weeklyStats = <String, int>{};
      final monthlyStats = <String, int>{};
      final yearlyStats = <String, int>{};
      
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      final yearStart = DateTime(now.year, 1, 1);
      
      for (final booking in loadedBookings) {
        // Trouver le cours associé
        final course = loadedCourses.firstWhere(
          (c) => c.id == booking.courseId,
          orElse: () => Course(
            id: 'unknown',
            title: 'Cours inconnu',
            capacity: 0,
            coachId: 'unknown',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        final courseTitle = course.title;
        
        // Statistiques hebdomadaires
        if (booking.bookingDate.isAfter(weekStart)) {
          weeklyStats[courseTitle] = (weeklyStats[courseTitle] ?? 0) + 1;
        }
        
        // Statistiques mensuelles
        if (booking.bookingDate.isAfter(monthStart)) {
          monthlyStats[courseTitle] = (monthlyStats[courseTitle] ?? 0) + 1;
        }
        
        // Statistiques annuelles
        if (booking.bookingDate.isAfter(yearStart)) {
          yearlyStats[courseTitle] = (yearlyStats[courseTitle] ?? 0) + 1;
        }
      }
      
      setState(() {
        _courses = loadedCourses;
        _schedules = loadedSchedules;
        _bookings = loadedBookings;
        _events = events;
        _weeklyStats = weeklyStats;
        _monthlyStats = monthlyStats;
        _yearlyStats = yearlyStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des données: $e';
        isLoading = false;
      });
    }
  }
  
  int _getDayIndex(String day) {
    switch (day.toLowerCase()) {
      case 'lundi': return 1;
      case 'mardi': return 2;
      case 'mercredi': return 3;
      case 'jeudi': return 4;
      case 'vendredi': return 5;
      case 'samedi': return 6;
      case 'dimanche': return 7;
      default: return 1;
    }
  }

  List<ProgramEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          const Sidebar(selectedIndex: 5),
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
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendrier et événements
                Expanded(
                  flex: 3,
                  child: _buildCalendarSection(),
                ),
                // Statistiques
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(left: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildStatsSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Programmes',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gérez les programmes et consultez les statistiques',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(77), // Équivalent à withOpacity(0.3)
              ),
        ),
      ],
    );
  }
  
  Widget _buildCalendarSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cours programmés',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _getEventsForDay(_selectedDay).isEmpty
                  ? Center(
                      child: Text(
                        'Aucun cours programmé pour cette journée',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(77), // Équivalent à withOpacity(0.3)
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _getEventsForDay(_selectedDay).length,
                      itemBuilder: (context, index) {
                        final event = _getEventsForDay(_selectedDay)[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26), // Équivalent à withOpacity(0.1)
                              child: Icon(
                                Icons.fitness_center,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(event.title),
                            subtitle: Text('${event.time} • ${event.capacity} places'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Implémenter l'édition du programme
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques des réservations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cette semaine',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildStatsList(_weeklyStats),
        const SizedBox(height: 16),
        Text(
          'Ce mois-ci',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildStatsList(_monthlyStats),
        const SizedBox(height: 16),
        Text(
          'Cette année',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildStatsList(_yearlyStats),
        const SizedBox(height: 24),
        Center(
          child: ModernButton(
            text: 'Exporter les statistiques',
            icon: Icons.download,
            onPressed: () {
              // TODO: Implémenter l'exportation des statistiques
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsList(Map<String, int> stats) {
    if (stats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(77), // Équivalent à withOpacity(0.3)
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    return Column(
      children: stats.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(child: Text(entry.key)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(26), // Équivalent à withOpacity(0.1)
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${entry.value}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}