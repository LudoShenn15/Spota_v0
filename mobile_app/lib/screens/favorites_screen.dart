import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/coach.dart';
import '../providers/api_providers.dart';
import '../theme.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
 
  List<Course> _favoriteCourses = [];
  List<Coach> _favoriteCoaches = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
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
      
      _userId = currentUser.id;
      
      // Charger les favoris en parallèle
      final results = await Future.wait([
        apiService.getUserFavoriteCourses(_userId!),
        apiService.getUserFavoriteCoaches(_userId!),
      ]);
      
      if (!mounted) return;
      
      setState(() {
        _favoriteCourses = results[0] as List<Course>;
        _favoriteCoaches = results[1] as List<Coach>;
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des favoris: $e');
      }
      
      if (!mounted) return;
      
      // Gestion des erreurs spécifiques
      String errorMessage = 'Erreur lors du chargement des favoris. Veuillez réessayer.';
      
      if (e.toString().contains('network')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre connexion internet.';
      } else if (e.toString().contains('not authenticated') || e.toString().contains('unauthorized')) {
        errorMessage = 'Votre session a expiré. Veuillez vous reconnecter.';
        if (mounted) {
          context.go('/login');
        }
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'RÉESSAYER',
              textColor: Colors.white,
              onPressed: _loadFavorites,
            ),
          ),
        );
      }
    }
  }

  Future<void> _removeFromFavorites(String id, bool isCourse) async {
    if (_userId == null) return;
    
    // Sauvegarder l'état actuel pour pouvoir restaurer en cas d'erreur
    final currentCourses = List<Course>.from(_favoriteCourses);
    final currentCoaches = List<Coach>.from(_favoriteCoaches);
    
    // Optimistic UI update - mettre à jour l'UI immédiatement
    setState(() {
      if (isCourse) {
        _favoriteCourses.removeWhere((course) => course.id == id);
      } else {
        _favoriteCoaches.removeWhere((coach) => coach.id == id);
      }
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Supprimer le favori de la base de données
      if (isCourse) {
        await apiService.removeFavoriteCourse(id);
      } else {
        await apiService.removeFavoriteCoach(id);
      }
      
      // Afficher un message de confirmation
      if (mounted) {
        final snackBar = SnackBar(
          content: Text(isCourse ? 'Cours retiré des favoris' : 'Coach retiré des favoris'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () async {
              // Réajouter le favori
              try {
                if (isCourse) {
                  await apiService.addFavoriteCourse(id);
                } else {
                  await apiService.addFavoriteCoach(id);
                }
                // Recharger les favoris
                await _loadFavorites();
              } catch (e) {
                if (kDebugMode) {
                  print('Erreur lors de l\'annulation: $e');
                }
              }
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      // En cas d'erreur, restaurer l'état précédent
      if (mounted) {
        setState(() {
          _favoriteCourses = currentCourses;
          _favoriteCoaches = currentCoaches;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression du favori'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      if (kDebugMode) {
        print('Erreur lors de la suppression du favori: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Favoris'),
            pinned: true,
            snap: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.fitness_center), text: 'Cours'),
                Tab(icon: Icon(Icons.people), text: 'Coachs'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCoursesList(),
            _buildCoachesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    if (_favoriteCourses.isEmpty) {
      // This is the empty state we built earlier for the 'Cours' tab.
      // We can centralize it or repeat it if it's simple enough.
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              'Aucun cours favori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87), // Added color with fallback
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des cours à vos favoris pour les retrouver ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SpotaTheme.secondaryTextColor), // This was likely correct
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/explore');
              },
              child: const Text('EXPLORER'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: SpotaTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteCourses.length,
        itemBuilder: (context, index) {
          final course = _favoriteCourses[index];
          return _buildCourseCard(course);
        },
      ),
    );
  }

  Widget _buildCoachesList() {
    if (_favoriteCoaches.isEmpty) {
        // This is the empty state we built earlier for the 'Coachs' tab.
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                Text(
                  'Aucun coach favori',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87), // Added color with fallback
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez des coachs à vos favoris pour les retrouver ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SpotaTheme.secondaryTextColor), // This was likely correct
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.go('/explore');
                  },
                  child: const Text('EXPLORER LES COACHS'),
                ),
              ],
            ),
          ),
        );
    }
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: SpotaTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteCoaches.length,
        itemBuilder: (context, index) {
          final coach = _favoriteCoaches[index];
          return _buildCoachCard(coach);
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Naviguer vers les détails du 'cours'
          context.push('/booking/${course.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du 'cours'
            SizedBox(
              height: 140,
              width: double.infinity,
              child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                  ? Image.network(
                      course.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                           color: Colors.grey.shade800,
                          child: const Center(
                            child: Icon(
                              Icons.fitness_center,
                               color: Colors.white54,
                               size: 40,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                       color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                           color: Colors.white54,
                           size: 40,
                        ),
                      ),
                    ),
            ),
            // Informations du 'cours'
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Titre
                      Expanded(
                        child: Text(
                          course.title, // Corrected string interpolation
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Bouton de suppression des favoris
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red, // Corrected Icon constructor
                        ),
                        onPressed: () => _removeFromFavorites(course.id, true), // Corrected interpolation/typo
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Coach
                  Row(
                    children: [
                      Icon( // Corrected Icon constructor
                        Icons.person,
                        size: 16, // Corrected Icon constructor
                        color: SpotaTheme.secondaryTextColor, // Corrected Icon constructor
                      ),
                      const SizedBox(width: 4),
                      Text(
                        // Assuming course.coachId and a helper to get name, or direct course.coachName
                        // For now, using course.coachId as placeholder if coachName is not direct.
                        // This part might need a new helper like getCoachNameById(course.coachId)
                        'Coach: ${course.coachId}', // Corrected string interpolation, placeholder for coach name
                        style: TextStyle( // Corrected TextStyle constructor
                          color: SpotaTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Évaluation
                  Row(
                    children: [
                      Icon( // Corrected Icon constructor
                        Icons.star,
                        size: 16, // Corrected Icon constructor
                        color: Colors.amber, // Corrected Icon constructor
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.rating ?? 0.0} (${course.reviewCount ?? 0} avis)', // Corrected string interpolation
                        style: TextStyle( // Corrected TextStyle constructor
                          color: SpotaTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Informations supplémentaires
                  Row(
                    children: [
                      _buildInfoChip(
                        '${course.duration ?? 0} min', // Corrected string interpolation
                        Icons.timer,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        course.level ?? 'Non spécifié', // Corrected null aware and string literal
                        Icons.fitness_center,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        course.category ?? 'Non spécifié', // Corrected null aware and string literal
                        Icons.category,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachCard(Coach coach) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Naviguer vers les détails du 'coach'
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo du coach
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade800,
                  image: coach.imageUrl != null && coach.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(coach.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: coach.imageUrl == null || coach.imageUrl!.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: Colors.white54,
                        size: 40,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Informations du coach
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nom
                        Expanded(
                          child: Text(
                            coach.name ?? 'Coach inconnu',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Bouton de suppression des favoris
                        IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeFromFavorites(coach.id, false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Spécialité
                    Text(
                      coach.speciality ?? 'Non spécifié',
                      style: TextStyle(
                        color: SpotaTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Évaluation
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${coach.rating ?? 0.0} (${coach.reviewCount ?? 0} avis)',
                          style: TextStyle(
                            color: SpotaTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.work,
                          size: 16,
                          color: SpotaTheme.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          coach.experience ?? 'Expérience non renseignée',
                          style: TextStyle(
                            color: SpotaTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bio
                    Text(
                      coach.bio ?? 'Aucune biographie disponible',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: SpotaTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: SpotaTheme.secondaryTextColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: SpotaTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
