import 'package:flutter/material.dart';
import 'package:shared_lib/models/schedule.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/coach.dart';
import 'package:shared_lib/services/api_service.dart';
import '../components/sidebar.dart';
import '../components/modern_button.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiService _apiService = ApiService();
  List<Schedule> schedules = [];
  List<Course> courses = [];
  List<Coach> coaches = [];
  bool isLoading = true;
  String? error;
  
  // Heures de début et de fin pour l'affichage du planning
  final int startHour = 6; // 6h du matin
  final int endHour = 21; // 21h du soir
  
  // Jours de la semaine
  final List<String> weekDays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

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

      final loadedSchedules = await _apiService.getAllSchedules();
      final loadedCourses = await _apiService.getAllCourses();
      final loadedCoaches = await _apiService.getAllCoaches();

      setState(() {
        schedules = loadedSchedules;
        courses = loadedCourses;
        coaches = loadedCoaches;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des données: $e';
        isLoading = false;
      });
    }
  }

  String getCourseName(String courseId) {
    final course = courses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => Course(
        id: 'unknown',
        title: 'Cours inconnu',
        coachId: 'unknown',
        capacity: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return course.title;
  }

  String getCoachName(String courseId) {
    final course = courses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => Course(
        id: 'unknown',
        title: 'Cours inconnu',
        coachId: 'unknown',
        capacity: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    final coach = coaches.firstWhere(
      (coach) => coach.id == course.coachId,
      orElse: () => Coach(
        id: 'unknown',
        userId: 'unknown',
        speciality: 'unknown',
        description: 'Coach inconnu',
        availableDays: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    return coach.id == 'unknown' ? 'Coach inconnu' : coach.speciality;
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
          const Sidebar(selectedIndex: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildScheduleGrid(context),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout d'un nouveau créneau
        },
        child: const Icon(Icons.add),
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
                'Planning hebdomadaire',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualisez et gérez tous les cours de la semaine',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(179), // Équivalent à withOpacity(0.7)
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
      ),
    );
  }

  Widget _buildScheduleGrid(BuildContext context) {
    final hoursCount = endHour - startHour + 1;
    
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
            children: [
              // En-tête avec les jours de la semaine
              Row(
                children: [
                  // Cellule vide pour l'en-tête des heures
                  SizedBox(
                    width: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Heures',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // En-têtes des jours
                  ...weekDays.map((day) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                ],
              ),
              const Divider(),
              // Grille des heures et cours
              Expanded(
                child: ListView.builder(
                  itemCount: hoursCount,
                  itemBuilder: (context, index) {
                    final hour = startHour + index;
                    return _buildTimeRow(context, hour);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, int hour) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cellule de l'heure
        SizedBox(
          width: 80,
          height: 80,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$hour:00',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Cellules des jours
        ...List.generate(weekDays.length, (dayIndex) {
          final day = weekDays[dayIndex];
          // Trouver les cours pour ce jour et cette heure
          final daySchedules = schedules.where((schedule) {
            final scheduleHour = int.tryParse(schedule.startTime.split(':')[0]) ?? 0;
            return schedule.day.toLowerCase() == day.toLowerCase() && scheduleHour == hour;
          }).toList();
          
          return Expanded(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor.withAlpha(26), // Équivalent à withOpacity(0.1)
                  width: 0.5,
                ),
              ),
              child: daySchedules.isEmpty
                  ? const SizedBox()
                  : ListView.builder(
                      itemCount: daySchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = daySchedules[index];
                        return _buildScheduleCard(context, schedule);
                      },
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context, Schedule schedule) {
    final courseName = getCourseName(schedule.courseId);
    final coachName = getCoachName(schedule.courseId);
    
    return Card(
      margin: const EdgeInsets.all(4),
      color: Theme.of(context).colorScheme.primary.withAlpha(26), // Équivalent à withOpacity(0.1)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withAlpha(77), // Équivalent à withOpacity(0.3)
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              courseName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              coachName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179), // Équivalent à withOpacity(0.7)
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${schedule.startTime} - ${schedule.endTime}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179), // Équivalent à withOpacity(0.7)
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
