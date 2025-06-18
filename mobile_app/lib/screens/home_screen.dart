import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Utiliser Map<String, dynamic> si les modèles ne sont pas fiables
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/user.dart';
import 'package:shared_lib/models/booking.dart';
import 'package:shared_lib/models/user_stats.dart';

// import 'package:shared_lib/services/api_service.dart'; // Utilisation via provider
import '../providers/api_providers.dart';
import '../theme.dart';
import '../widgets/course_card.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = true;
  List<Course> _upcomingCourses = [];
  final List<Map<String, dynamic>> _stats = [];
  User? _currentUser;
  UserStats? _userStats;

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
        if (kDebugMode) {
          print('Utilisateur non connecté, redirection vers login');
        }
        if (mounted) {
          context.go('/login');
        }
        return;
      }
      
      // Récupérer les informations de l'utilisateur
      _currentUser = currentUser;
      
      // Charger les données en parallèle
      final results = await Future.wait([
        // Récupérer les prochains cours de l'utilisateur
        _safeApiCall(() => apiService.getUpcomingUserBookings()),
        // Récupérer les statistiques de l'utilisateur
        _safeApiCall(() => apiService.getUserStats()),
      ], eagerError: true);
      
      if (!mounted) return;
      
      final upcomingBookings = results[0] as List<Booking>? ?? [];
      final userStats = results[1] as UserStats?;
      
      // Si les statistiques sont nulles, créer un objet par défaut
      final DateTime now = DateTime.now();
      // Création d'un UserStats par défaut si nécessaire
      if (userStats == null) {
        setState(() {
          _userStats = UserStats(
            id: 'temp-${now.millisecondsSinceEpoch}',
            userId: _currentUser?.id ?? '',
            totalSessions: 0,
            totalMinutes: 0,
            caloriesBurned: 0,
            activityBreakdown: {},
            startDate: now.subtract(const Duration(days: 30)),
            endDate: now,
            createdAt: now,
            updatedAt: now,
          );
        });
      }
      
      // Récupérer les IDs des cours uniques
      final courseIds = upcomingBookings.map((b) => b.courseId).toSet().toList();
      
      // Récupérer les détails des cours
      List<Course> courses = [];
      if (courseIds.isNotEmpty) {
        final coursesData = await _safeApiCall(() => apiService.getCoursesByIds(courseIds));
        if (coursesData != null) {
          courses = coursesData;
        }
      }
      
      // Mettre à jour l'état avec les nouvelles données
      if (!mounted) return;
      
      setState(() {
        _upcomingCourses = courses.take(3).toList(); // Limiter à 3 cours pour l'affichage
        
        // Mettre à jour les statistiques avec les données réelles
        _stats.clear();
        _stats.addAll([
          {
            'title': 'Cours suivis',
            'value': '${userStats?.totalBookings ?? 0}',
            'icon': Icons.fitness_center,
            'showTrend': true,
            'trendValue': 0.0, // Valeur par défaut car improvementRate n'existe plus
            'isPositiveTrend': true,
          },
          {
            'title': 'Heures d\'entraînement',
            'value': userStats?.totalHours?.toStringAsFixed(1) ?? '0.0',
            'icon': Icons.timer,
            'showTrend': true,
            'trendValue': 0.0, // Valeur par défaut car consistency n'existe plus
            'isPositiveTrend': true,
          },
          {
            'title': 'Activité favorite',
            'value': userStats?.favoriteActivity ?? 'Aucune',
            'icon': Icons.favorite,
            'showTrend': false,
          },
        ]);
        
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des données: $e');
      }
      
      if (!mounted) return;
      
      // Afficher un message d'erreur plus détaillé
      String errorMessage = 'Erreur lors du chargement des données';
      if (e is Exception) {
        errorMessage = e.toString();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      
      // Rediriger vers l'écran de connexion en cas d'erreur d'authentification
      if (e.toString().contains('non authentifié') || e.toString().contains('non connecté')) {
        if (mounted) {
          context.go('/login');
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode utilitaire pour effectuer des appels API avec gestion d'erreur
  Future<dynamic> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur API: $e');
      }
      // Retourner null en cas d'erreur, sera géré par l'appelant
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: SpotaTheme.primaryColor,
              child: CustomScrollView(
                slivers: [
                  // En-tête avec le nom de l'utilisateur
                  SliverAppBar(
                    expandedHeight: 120.0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Bonjour, ${_currentUser?.fullName?.split(' ').first ?? 'utilisateur'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              SpotaTheme.primaryColor,
                              SpotaTheme.primaryColor.withValues(alpha: 204), // 0.8 * 255 = 204
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Contenu principal
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Statistiques
                          const Text(
                            'Vos statistiques',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _stats.length,
                              itemBuilder: (context, index) {
                                final stat = _stats[index];
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  child: StatCard(
                                    title: stat['title'],
                                    value: stat['value'],
                                    icon: stat['icon'],
                                    showTrend: stat['showTrend'],
                                    trendValue: stat['trendValue'],
                                    isPositiveTrend: stat['isPositiveTrend'],
                                    onTap: () {
                                      context.go('/stats');
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Section Prochains cours
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Vos prochains cours',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go('/my-bookings');
                                },
                                child: const Text('Voir tout'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Liste des prochains cours
                          _upcomingCourses.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 48,
                                          color: SpotaTheme.secondaryTextColor,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Aucun cours à venir',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: SpotaTheme.secondaryTextColor,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Réservez un cours pour commencer',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: SpotaTheme.secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _upcomingCourses.length,
                                  itemBuilder: (context, index) {
                                    final course = _upcomingCourses[index];
                                    return CourseCard.fromCourse(
                                      course: course,
                                      onTap: () {
                                        // Naviguer vers les détails du cours
                                        context.go('/course-details/${course.id}');
                                      },
                                    );
                                  },
                                ),
                          
                          const SizedBox(height: 24),
                          
                          // Bouton pour explorer plus de cours
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.go('/explore');
                              },
                              icon: const Icon(Icons.explore),
                              label: const Text('EXPLORER LES COURS'),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
