import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_lib/models/course.dart';

import '../providers/api_providers.dart';
import '../theme.dart';
import '../widgets/course_card.dart';


class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Course> _courses = [];
  List<Map<String, dynamic>> _coaches = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<T?> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
      return null;
    }
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
      
      // Annuler la recherche précédente si elle est en cours
      _debounce?.cancel();
      
      // Utiliser un délai pour éviter les appels API trop fréquents
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        try {
          List<Course> courses = [];
          List<Map<String, dynamic>> coaches = [];
          
          // Récupérer les cours disponibles
          if (_searchQuery.isEmpty) {
            // Si pas de recherche, charger tous les cours
            final results = await Future.wait([
              _safeApiCall(() => apiService.getAll('courses')),
              _safeApiCall(() => apiService.getAll('coaches')),
            ]);
            
            final coursesData = results[0] as List? ?? [];
            final coachesData = results[1] as List? ?? [];
            
            courses = coursesData.map((item) => Course.fromJson(item as Map<String, dynamic>)).toList();
            coaches = coachesData.map((item) => item as Map<String, dynamic>).toList();
          } else {
            // Effectuer une recherche
            final searchResults = await _safeApiCall<Map<String, dynamic>>(
              () => apiService.search(_searchQuery),
            ) ?? {};
            
            // Convertir les données brutes en objets typés
            if (searchResults.containsKey('courses')) {
              final coursesList = searchResults['courses'] as List? ?? [];
              courses = coursesList.map((item) => Course.fromJson(item as Map<String, dynamic>)).toList();
            }
            
            if (searchResults.containsKey('coaches')) {
              final coachesList = searchResults['coaches'] as List? ?? [];
              coaches = coachesList.map((item) => item as Map<String, dynamic>).toList();
            }
          }
          
          if (kDebugMode) {
            print('Chargé ${courses.length} cours et ${coaches.length} coaches');
          }
          
          if (!mounted) return;
          
          setState(() {
            _courses = courses;
            _coaches = coaches;
            _isLoading = false;
          });
        } catch (e) {
          if (kDebugMode) {
            print('Erreur lors de la recherche: $e');
          }
          
          if (!mounted) return;
          
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la recherche: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement initial: $e');
      }
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      // Ne pas afficher d'erreur pour les annulations de recherche
      if (e is! Exception || !e.toString().contains('cancelled')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des données: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SpotaTheme.primaryColor,
              ),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    backgroundColor: SpotaTheme.backgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Explorer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      titlePadding: const EdgeInsets.only(
                        left: 16,
                        bottom: 16,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // TODO: Afficher les filtres
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        children: [
                          // Barre de recherche
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Rechercher un cours ou un coach?',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: SpotaTheme.surfaceColor,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                              // Annuler le délai précédent et redémarrer le délai
                              _debounce?.cancel();
                              _debounce = Timer(const Duration(milliseconds: 500), _loadData);
                            },
                            onSubmitted: (_) {
                              _debounce?.cancel();
                              _loadData();
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Onglets
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'COURS'),
                              Tab(text: 'COACHS'),
                            ],
                            indicatorColor: SpotaTheme.primaryColor,
                            labelColor: SpotaTheme.primaryColor,
                            unselectedLabelColor: SpotaTheme.secondaryTextColor,
                            indicatorWeight: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Onglet Cours
                  _buildCoursesTab(),
                  
                  // Onglet Coachs
                  _buildCoachesTab(),
                ],
              ),
            ),
    );
  }

  List<Course> _getFilteredCoursesDupe() {
    if (_searchQuery.isEmpty) return _courses;
    
    final query = _searchQuery.toLowerCase();
    return _courses.where((course) {
      return (course.title.toLowerCase().contains(query) == true) ||
             (course.description?.toLowerCase().contains(query) == true) ||
             ((course['coach']?.fullName?.toLowerCase() ?? '').contains(query) == true);
    }).toList();
  }

  Widget _buildNoResults(String message) {
    return Center(child: Text(message, style: const TextStyle(color: Colors.grey)));
  }

  Widget _buildCoursesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SpotaTheme.primaryColor),
        ),
      );
    }
    
    final filteredCourses = _getFilteredCoursesDupe();
    
    if (filteredCourses.isEmpty) {
      return _buildNoResults(
        _searchQuery.isEmpty
            ? 'Aucun cours disponible pour le moment.'
            : 'Aucun cours ne correspond à votre recherche.',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        return CourseCard.fromCourse(
          course: course,
          onTap: () {
            if (course.id != null) {
              context.go('/course-details/${course.id}');
            }
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredCoachesDupe() {
    if (_searchQuery.isEmpty) return _coaches;
    
    final query = _searchQuery.toLowerCase();
    return _coaches.where((coach) {
      return (coach['fullName']??''.toLowerCase().contains(query) == true) ||
             (coach['specialty']??''.toLowerCase().contains(query) == true) ||
             (coach['bio'].toLowerCase().contains(query) == true);
    }).toList();
  }

  Widget _buildCoachesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SpotaTheme.primaryColor),
        ),
      );
    }
    
    final filteredCoaches = _getFilteredCoachesDupe();
    
    if (filteredCoaches.isEmpty) {
      return _buildNoResults(
        _searchQuery.isEmpty
            ? 'Aucun coach disponible pour le moment.'
            : 'Aucun coach ne correspond à votre recherche.',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: filteredCoaches.length,
      itemBuilder: (context, index) {
        final coach = filteredCoaches[index];
        // return _buildCoachCard(
        //   id: coach['id'] ?? '',
        //   name: coach['fullName'] ?? 'Inconnu',
        //   speciality: coach['specialty'] ?? 'Non spécifié',
        //   imageUrl: coach['profileImageUrl'] ?? '',
        //   description: coach['bio'] ?? '',
        //   availableDays: coach['availability'] ?? [],
        //   onTap: () {
        //     if (coach?.id != null) {
        //       context.go('/coach?-details/${coach?.id}');
        //     }
        //   },
        // );
        return ListTile(title: Text(coach['fullName'] ?? 'Unknown Coach')); // Placeholder
      },
    );
  }
}
