import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/time_slot.dart';
import 'package:shared_lib/models/booking.dart';
import '../providers/api_providers.dart';
import '../theme.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String? courseId;
  
  const BookingScreen({
    super.key,
    this.courseId,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  Future<T?> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      final result = await apiCall();
      if (result == null) throw Exception('Aucun cours trouvé');
      return result;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
      return null;
    }
  }
  bool _isLoading = true;
  Course? _selectedCourse;
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  List<Course> _availableCourses = [];
  List<TimeSlot> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Vérifier si l'utilisateur est connecté
      final currentUser = await apiService.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          context.go('/login');
        }
        return;
      }
      
      // Charger les données en parallèle
      final results = await Future.wait([
        // Charger les cours disponibles
        _safeApiCall(() => apiService.getAvailableCourses()),
        // Charger les créneaux horaires disponibles pour la date sélectionnée
        _safeApiCall(() => apiService.getAvailableTimeSlots(_selectedDate)),
      ], eagerError: true);
      
      if (!mounted) return;
      
      final courses = results[0] as List<Course>? ?? [];
      final timeSlots = results[1] as List<TimeSlot>? ?? [];
      
      setState(() {
        _availableCourses = courses;
        _availableTimeSlots = timeSlots;
        
        // Si un courseId a été passé, sélectionner ce cours
        // Initialize _selectedCourse to null before attempting to set it
        _selectedCourse = null; 

        if (widget.courseId != null) {
          try {
            // Attempt to find the course by ID
            _selectedCourse = _availableCourses.firstWhere(
              (course) => course.id == widget.courseId,
              // If not found, firstWhere would throw. We'll catch it below.
            );
          } catch (e) {
            // If the course with widget.courseId is not found, _selectedCourse remains null.
            // Optionally, log this event or handle it if specific behavior is needed.
            if (kDebugMode) {
              print('Course with ID ${widget.courseId} not found in available courses.');
            }
          }
        }
        
        // If no course was selected based on courseId (either courseId was null or not found),
        // and there are available courses, select the first one.
        if (_selectedCourse == null && _availableCourses.isNotEmpty) {
          _selectedCourse = _availableCourses.first;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des données: $e');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des données. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(DateTime date) async {
    if (_selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day) {
      return; // Même date, pas besoin de recharger
    }
    
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null;
      _isLoading = true;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final timeSlots = await apiService.getAvailableTimeSlots(date);
      
      if (!mounted) return;
      
      setState(() {
        _availableTimeSlots = timeSlots;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des créneaux: $e');
      }
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du chargement des créneaux horaires. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    try {
      // Charger les créneaux horaires disponibles pour la nouvelle date
      final timeSlots = await ref.read(apiServiceProvider).getAvailableTimeSlots(date);
      
      if (mounted) {
        setState(() {
          _availableTimeSlots = timeSlots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des créneaux horaires: $e');
      }
      
      if (mounted) {
        setState(() {
          _availableTimeSlots = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des créneaux horaires. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectTimeSlot(TimeSlot timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
    });
  }

  void _selectCourse(Course course) {
    setState(() {
      _selectedCourse = course;
    });
  }

  Future<void> _confirmBooking() async {
    if (_selectedCourse == null || _selectedTimeSlot == null) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un cours et un créneau horaire'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (!mounted) return;
    
    // Vérifier si le créneau est toujours disponible
    final now = DateTime.now();
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      final apiService = ref.read(apiServiceProvider);
      final currentUser = await apiService.getCurrentUser();
      
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      // Créer la réservation
      final booking = Booking(
        id: '', // L'ID sera généré par le serveur
        userId: currentUser.id,
        courseId: _selectedCourse!.id,
        timeSlotId: _selectedTimeSlot!.id,
        status: 'confirmed',
        bookingDate: _selectedDate,
        createdAt: now,
        updatedAt: now,
        course: _selectedCourse, // Inclure les détails du cours
      );
      
      // Créer la réservation via l'API
      await apiService.createBooking(booking);
      
      if (!mounted) return;
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation effectuée avec succès !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Attendre un court instant avant la redirection
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      // Rediriger vers l'écran des réservations
      context.go('/my-bookings');
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la réservation: $e');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la réservation. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un cours'),
        backgroundColor: SpotaTheme.backgroundColor,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SpotaTheme.primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélection du cours
                    if (widget.courseId == null) ...[
                      const Text(
                        'Sélectionnez un cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _availableCourses.isEmpty
                          ? const Center(
                              child: Text('Aucun cours disponible'),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _availableCourses.length,
                              itemBuilder: (context, index) {
                                final course = _availableCourses[index];
                                final isSelected = _selectedCourse != null && 
                                                  _selectedCourse!.id == course.id;
                                
                                return GestureDetector(
                                  onTap: () => _selectCourse(course),
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? SpotaTheme.primaryColor.withValues(alpha: 0.2)
                                          : SpotaTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? SpotaTheme.primaryColor
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Image du cours
                                        Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: SpotaTheme.surfaceColor,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                            image: course.imageUrl != null && 
                                                  course.imageUrl!.isNotEmpty
                                                ? DecorationImage(
                                                    image: NetworkImage(course.imageUrl!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: course.imageUrl == null || 
                                                course.imageUrl!.isEmpty
                                              ? Center(
                                                  child: Icon(
                                                    _getCourseIcon(course.title),
                                                    size: 40,
                                                    color: SpotaTheme.secondaryTextColor,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        // Informations du cours
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                course.coachName ?? 'Coach non spécifié',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: SpotaTheme.secondaryTextColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${course.price?.toStringAsFixed(2) ?? '0.00'} €',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: SpotaTheme.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Détails du cours sélectionné
                    if (_selectedCourse != null) ...[
                      const Text(
                        'Détails du cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedCourse!['title'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: SpotaTheme.secondaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedCourse!['coachName'],
                                    style: const TextStyle(
                                      color: SpotaTheme.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedCourse!['description'],
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildInfoItem(
                                    icon: Icons.timer,
                                    label: '${_selectedCourse!['duration']} min',
                                  ),
                                  const SizedBox(width: 16),
                                  _buildInfoItem(
                                    icon: Icons.location_on,
                                    label: _selectedCourse!['location'],
                                  ),
                                  const SizedBox(width: 16),
                                  _buildInfoItem(
                                    icon: Icons.people,
                                    label: '${_selectedCourse!['enrolled']}/${_selectedCourse!['capacity']}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Équipement nécessaire:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List<String>.from(_selectedCourse!['equipment']).map((item) {
                                  return Chip(
                                    label: Text(item),
                                    backgroundColor: SpotaTheme.surfaceColor,
                                    padding: EdgeInsets.zero,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Sélection de la date
                    const Text(
                      'Sélectionnez une date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7, // Afficher les 7 prochains jours
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(Duration(days: index));
                          final isSelected = _selectedDate.year == date.year &&
                                            _selectedDate.month == date.month &&
                                            _selectedDate.day == date.day;
                          
                          return GestureDetector(
                            onTap: () => _selectDate(date),
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? SpotaTheme.primaryColor
                                    : SpotaTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('E', 'fr_FR').format(date).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.black : null,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.black : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM', 'fr_FR').format(date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? Colors.black : SpotaTheme.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sélection du créneau horaire
                    const Text(
                      'Sélectionnez un horaire',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _availableTimeSlots.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text('Aucun créneau disponible pour cette date'),
                          ),
                        )
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _availableTimeSlots.map((timeSlot) {
                            final isSelected = _selectedTimeSlot != null && _selectedTimeSlot!.id == timeSlot.id;
                            final isAvailable = timeSlot.isAvailable;
                            
                            return GestureDetector(
                              onTap: isAvailable ? () => _selectTimeSlot(timeSlot) : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? SpotaTheme.primaryColor
                                      : isAvailable
                                          ? SpotaTheme.surfaceColor
                                          : Colors.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${timeSlot.startTime} - ${timeSlot.endTime}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.black
                                        : isAvailable
                                            ? null
                                            : SpotaTheme.secondaryTextColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    const SizedBox(height: 32),
                    
                    // Bouton de réservation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedCourse != null && _selectedTimeSlot != null
                            ? _confirmBooking
                            : null,
                        child: const Text('RÉSERVER'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: SpotaTheme.secondaryTextColor,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  IconData _getCourseIcon(String courseTitle) {
    final title = courseTitle.toLowerCase();
    
    if (title.contains('yoga') || title.contains('meditation')) {
      return Icons.self_improvement;
    } else if (title.contains('boxe') || title.contains('combat') || title.contains('karate') || title.contains('judo')) {
      return Icons.sports_martial_arts;
    } else if (title.contains('velo') || title.contains('vélo') || title.contains('cycling')) {
      return Icons.directions_bike;
    } else if (title.contains('natation') || title.contains('aqua')) {
      return Icons.pool;
    } else if (title.contains('course') || title.contains('running') || title.contains('jogging')) {
      return Icons.directions_run;
    } else if (title.contains('football') || title.contains('soccer')) {
      return Icons.sports_soccer;
    } else if (title.contains('basketball')) {
      return Icons.sports_basketball;
    } else if (title.contains('tennis')) {
      return Icons.sports_tennis;
    } else if (title.contains('golf')) {
      return Icons.sports_golf;
    } else if (title.contains('volleyball')) {
      return Icons.sports_volleyball;
    } else {
      return Icons.fitness_center; // Icône par défaut
    }
  }
}
