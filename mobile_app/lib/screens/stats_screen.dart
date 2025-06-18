import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_lib/models/user_stats.dart';
import 'package:shared_lib/services/api_service.dart';
import '../theme.dart';
import '../widgets/stat_card.dart';
import '../providers/api_providers.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  UserStats? _userStats;
  bool _isLoading = true;
  String _selectedPeriod = 'month'; // 'week', 'month', 'year', 'all'
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // Méthode pour déterminer l'activité favorite à partir de activityBreakdown
  String _getFavoriteActivity() {
    if (_userStats == null || _userStats!.activityBreakdown.isEmpty) {
      return 'Aucune';
    }
    
    // Trouver l'activité avec le plus grand nombre de sessions
    String favoriteActivity = '';
    int maxCount = 0;
    
    _userStats!.activityBreakdown.forEach((activity, count) {
      if (count > maxCount) {
        maxCount = count;
        favoriteActivity = activity;
      }
    });
    
    return favoriteActivity.isNotEmpty ? favoriteActivity : 'Aucune';
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Charger les statistiques de l'utilisateur
      final stats = await apiService.getUserStats();
      
      if (!mounted) return;
      
      // Mettre à jour l'état avec les nouvelles statistiques
      setState(() {
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des statistiques: $e');
      }
      
      // Vérifier si l'erreur est due à une non-authentification
      if (e.toString().contains('non authentifié') || e.toString().contains('not authenticated')) {
        if (mounted) {
          // Rediriger vers l'écran de login
          context.go('/login');
        }
        return;
      }
      
      if (!mounted) return;
      
      // Afficher un message d'erreur générique
      setState(() {
        _errorMessage = 'Erreur lors du chargement des statistiques. Veuillez réessayer.';
        _isLoading = false;
      });
      
      // Afficher un SnackBar avec l'erreur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Erreur inconnue'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _loadStats,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: SpotaTheme.primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Mes Statistiques'),
              floating: true,
              actions: [
                // Sélecteur de période
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriod = newValue;
                        });
                        _loadStats();
                      }
                    },
                    items: <String>['week', 'month', 'year', 'all']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          {
                            'week': 'Cette semaine',
                            'month': 'Ce mois-ci',
                            'year': 'Cette année',
                            'all': 'Toutes périodes',
                          }[value] ?? value,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: SpotaTheme.primaryColor,
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadStats,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpotaTheme.primaryColor,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('RÉESSAYER'),
                      ),
                    ],
                  ),
                ),
              )
              : SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Cartes de statistiques
                      _buildStatCards(),
                      const SizedBox(height: 24),
                      // Graphique d'évolution
                      _buildProgressChart(),
                      const SizedBox(height: 24),
                      // Détails des activités
                      _buildActivityDetails(),
                      const SizedBox(height: 24),
                    ]),
                  ),
                )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        StatCard(
          title: 'Cours suivis',
          value: '${_userStats?.totalSessions ?? 0}',
          icon: Icons.fitness_center,
          showTrend: true,
          trendValue: 0.0, // Valeur par défaut car coursesAttendedTrend n'existe plus
          isPositiveTrend: true,
        ),
        StatCard(
          title: 'Heures d\'entraînement',
          value: '${((_userStats?.totalMinutes ?? 0) / 60.0).toStringAsFixed(1)}',
          icon: Icons.timer,
          showTrend: true,
          trendValue: 0.0, // Valeur par défaut car trainingHoursTrend n'existe plus
          isPositiveTrend: true,
        ),
        StatCard(
          title: 'Calories brûlées',
          value: '${_userStats?.caloriesBurned ?? 0}',
          icon: Icons.local_fire_department,
          showTrend: true,
          trendValue: 0.0, // Valeur par défaut car caloriesBurnedTrend n'existe plus
          isPositiveTrend: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Activité favorite',
                value: _getFavoriteActivity(),
                icon: Icons.favorite,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Sessions',
                value: '${_userStats?.totalSessions ?? 0}',
                icon: Icons.auto_graph,
                showTrend: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Série actuelle',
                value: '${_userStats?['streak']} jours',
                icon: Icons.flash_on,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Meilleure série',
                value: '${_userStats?['longestStreak']} jours',
                icon: Icons.emoji_events,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityBreakdown() {
    final activities = List<Map<String, dynamic>>.from(_userStats?['activityBreakdown']);
    
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Graphique en barres
            SizedBox(
              height: 200,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: activities.map((activity) {
                      final percentage = activity['percentage'] as int;
                      final barHeight = constraints.maxHeight * (percentage / 100);
                      
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 30,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: SpotaTheme.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity['name'],
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyActivity() {
    final weeklyActivity = List<Map<String, dynamic>>.from(_userStats?['weeklyActivity']);
    
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyActivity.map((day) {
              final count = day['count'] as int;
              final isToday = weeklyActivity.indexOf(day) == 1; // Simuler que nous sommes mardi
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: count * 30.0,
                    decoration: BoxDecoration(
                      color: isToday
                          ? SpotaTheme.primaryColor
                          : SpotaTheme.primaryColor.withAlpha(128),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day['day'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyProgress() {
    final monthlyProgress = List<Map<String, dynamic>>.from(_userStats?['monthlyProgress']);
    
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...monthlyProgress.map((month) {
                    final hours = month['hours'] as int;
                    final isCurrentMonth = monthlyProgress.indexOf(month) == 4; // Simuler que nous sommes en mai
                    
                    return Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$hours h',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 30,
                            height: hours * 10.0,
                            decoration: BoxDecoration(
                              color: isCurrentMonth
                                  ? SpotaTheme.primaryColor
                                  : SpotaTheme.primaryColor.withAlpha(128),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            month['month'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges() {
    // Liste fictive de badges
    final badges = [
      {
        'name': 'Premier pas',
        'description': 'Première séance effectuée',
        'icon': Icons.emoji_events,
        'unlocked': true,
      },
      {
        'name': 'Régulier',
        'description': '5 séances en un mois',
        'icon': Icons.calendar_today,
        'unlocked': true,
      },
      {
        'name': 'Marathonien',
        'description': '10 heures d\'entraînement',
        'icon': Icons.timer,
        'unlocked': true,
      },
      {
        'name': 'Explorateur',
        'description': 'Essayer 3 activités différentes',
        'icon': Icons.explore,
        'unlocked': true,
      },
      {
        'name': 'Série de feu',
        'description': '7 jours consécutifs d\'activité',
        'icon': Icons.local_fire_department,
        'unlocked': false,
        'progress': 3,
        'total': 7,
      },
      {
        'name': 'Expert',
        'description': '20 séances de la même activité',
        'icon': Icons.fitness_center,
        'unlocked': false,
        'progress': 15,
        'total': 20,
      },
    ];
    
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: badges.map((badge) {
                final unlocked = badge['unlocked'] as bool;
                
                return SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? SpotaTheme.primaryColor
                                  : SpotaTheme.surfaceColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              badge['icon'] as IconData,
                              color: unlocked ? Colors.black : SpotaTheme.secondaryTextColor,
                              size: 30,
                            ),
                          ),
                          if (!unlocked && badge.containsKey('progress'))
                            CircularProgressIndicator(
                              value: (badge['progress'] as int) / (badge['total'] as int),
                              strokeWidth: 3,
                              backgroundColor: Colors.transparent,
                              color: SpotaTheme.primaryColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: unlocked ? Colors.white : SpotaTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!unlocked && badge.containsKey('progress'))
                        Text(
                          '${badge['progress']}/${badge['total']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: SpotaTheme.secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
