 import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_lib/models/user.dart';
import 'package:shared_lib/models/subscription.dart';
import 'package:shared_lib/models/user_stats.dart';

import '../providers/api_providers.dart';
import '../theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  User? _user;
  Subscription? _subscription;
  UserStats? _userStats;

  Future<T?> _safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      final result = await apiCall();
      // Consider if a generic 'No data found' is better than 'Aucun cours trouvé'
      // For now, keeping it generic or removing the specific null check if the API call itself handles it.
      // if (result == null) throw Exception('Aucune donnée trouvée'); 
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

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
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
      
      // Charger les données en parallèle avec gestion des erreurs individuelles
      final results = await Future.wait([
        // Charger les données de l'utilisateur
        _safeApiCall(() => apiService.getUserProfile()),
        // Charger les données d'abonnement
        _safeApiCall(() => apiService.getUserSubscription()),
        // Charger les statistiques de l'utilisateur
        _safeApiCall(() => apiService.getUserStats()),
      ], eagerError: true);
      
      if (!mounted) return;
      
      // Mettre à jour l'état avec les données chargées
      setState(() {
        _user = results[0] as User?;
        _subscription = results[1] as Subscription?;
        _userStats = results[2] as UserStats?;
        _isLoading = false;
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement du profil utilisateur: $e');
      }
      
      if (!mounted) return;
      
      // Gestion des erreurs spécifiques
      String errorMessage = 'Erreur lors du chargement du profil. Veuillez réessayer.';
      
      if (e.toString().contains('non authentifié') || e.toString().contains('not authenticated')) {
        errorMessage = 'Votre session a expiré. Veuillez vous reconnecter.';
        if (mounted) {
          context.go('/login');
        }
        return;
      } else if (e.toString().contains('network')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre connexion internet.';
      }
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'RÉESSAYER',
            textColor: Colors.white,
            onPressed: _loadUserProfile,
          ),
        ),
      );
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: SpotaTheme.surfaceColor,
      child: Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor: SpotaTheme.primaryColor.withValues(alpha: 0.2),
          child: const Icon(
            Icons.person,
            size: 60,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        color: SpotaTheme.primaryColor,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: SpotaTheme.primaryColor,
                ),
              )
            : CustomScrollView(
                slivers: [
                  // App Bar avec photo de profil
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: SpotaTheme.backgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        _user?.fullName ?? 'Utilisateur',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          _user?.photoUrl != null && _user!.photoUrl!.isNotEmpty
                              ? Image.network(
                                  _user!.photoUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: SpotaTheme.primaryColor,
                                      ),
                                    );
                                  },
                                )
                              : _buildDefaultAvatar(),
                          Positioned(
                            top: 50,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () => context.go('/edit-profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                // Contenu principal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informations personnelles
                        _buildSectionTitle('Informations personnelles'),
                        _buildInfoCard([
                          _buildInfoRow(
                            icon: Icons.email,
                            title: 'Email',
                            value: _user?.email ?? 'Non renseigné',
                          ),
                          _buildInfoRow(
                            icon: Icons.phone_outlined,
                            title: 'Téléphone',
                            value: _user?.phone ?? 'N/A',
                          ),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            title: 'Membre depuis',
                            value: _user?.createdAt != null 
                                ? _formatDate(_user!.createdAt) 
                                : 'Non renseigné',
                          ),
                        ]),
                        
                        const SizedBox(height: 24),
                        
                        // Abonnement
                        _buildSubscriptionCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Statistiques
                        _buildSectionTitle('Statistiques'),
                        _buildStatsCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Actions
                        _buildSectionTitle('Actions'),
                        _buildActionsList(),
                        
                        const SizedBox(height: 32),
                        
                        // Bouton de déconnexion
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('DÉCONNEXION'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ), // Closes CustomScrollView or Center
          ), // Closes RefreshIndicator's child or body if _isLoading is true
        ), // Closes RefreshIndicator
    ); // Closes Scaffold
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: SpotaTheme.secondaryTextColor,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: SpotaTheme.secondaryTextColor,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final isActive = _subscription?.isActive ?? false;
    
    final type = _subscription?.planName ?? 'Aucun'; // Assuming planName is the correct field
    
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? SpotaTheme.primaryColor
                            : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    context.push('/subscription');
                  },
                  child: const Text('Gérer'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_userStats?.totalBookings}',
              style: Theme.of(context).textTheme.headlineMedium,
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/subscription');
                },
                child: const Text('VOIR LES OFFRES'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.calendar_today,
                  value: '${_userStats?.totalBookings ?? 0}', // Default to 0 or 'N/A' as appropriate
                  label: 'Réservations',
                ),
                _buildStatItem(
                  icon: Icons.timer,
                  value: '${_userStats?.totalHours ?? 0}', // Default to 0 or 'N/A' as appropriate
                  label: 'Heures',
                ),
                _buildStatItem(
                  icon: Icons.fitness_center,
                  value: _userStats?.favoriteActivity ?? 'N/A',
                  label: 'Favori',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.go('/stats');
                },
                child: const Text('VOIR TOUTES LES STATISTIQUES'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: SpotaTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: SpotaTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsList() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.calendar_today,
            title: 'Mes réservations',
            onTap: () {
              context.go('/my-bookings');
            },
          ),
          const Divider(height: 1),
          _buildActionItem(
            icon: Icons.favorite,
            title: 'Mes favoris',
            onTap: () {
              context.go('/favorites');
            },
          ),
          const Divider(height: 1),
          _buildActionItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              context.go('/notifications');
            },
          ),
          const Divider(height: 1),
          _buildActionItem(
            icon: Icons.lock,
            title: 'Changer le mot de passe',
            onTap: () {
              context.go('/change-password');
            },
          ),
          const Divider(height: 1),
          _buildActionItem(
            icon: Icons.help,
            title: 'Aide et support',
            onTap: () {
              context.go('/help');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: SpotaTheme.secondaryTextColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: SpotaTheme.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _logout() async {
    // Afficher une boîte de dialogue de confirmation
    // Afficher une boîte de dialogue de confirmation
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DÉCONNEXION'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.logout();

        if (!mounted) return;

        // Rediriger vers l'écran de connexion
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de la déconnexion: $e');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Une erreur est survenue lors de la déconnexion.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Réessayer',
              onPressed: _logout, // Permet de retenter la déconnexion
            ),
          ),
        );
      }
    }
  }
}
