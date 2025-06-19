import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Added GetX import
import 'package:shared_lib/models/coach.dart';
import 'package:shared_lib/services/api_service.dart';
import '../components/modern_button.dart';
import '../components/modern_data_table.dart';
import '../components/badge.dart';
import '../components/progress_bar.dart';
import '../components/modern_form_field.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({super.key});

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  final ApiService _apiService = Get.find<ApiService>(); // Replaced with Get.find
  List<Coach> coaches = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final loadedCoaches = await _apiService.getAllCoaches();
      
      setState(() {
        coaches = loadedCoaches;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des coachs: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'SPOTA Admin',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Menu items
                // ... (sidebar menu items)
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCoachDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
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
              onPressed: _loadCoaches,
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
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildStats(context),
          const SizedBox(height: 24),
          _buildFilters(context),
          const SizedBox(height: 16),
          Expanded(
            child: _buildCoachesTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des coachs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gérez les coachs de votre plateforme',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                  ),
            ),
          ],
        ),
        ModernButton(
          text: 'Actualiser',
          icon: Icons.refresh,
          onPressed: _loadCoaches,
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    // Statistiques fictives pour la démonstration
    final totalCoaches = coaches.length;
    final activeCoaches = coaches.length; // Tous les coachs sont considérés actifs pour l'instant
    final averageRating = 4.5;

    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(51),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total des coachs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalCoaches',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(51),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coachs actifs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$activeCoaches',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(51),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note moyenne',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$averageRating',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un coach...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: selectedFilter,
          items: const [
            DropdownMenuItem(value: 'Tous', child: Text('Tous')),
            DropdownMenuItem(value: 'Actifs', child: Text('Actifs')),
            DropdownMenuItem(value: 'Inactifs', child: Text('Inactifs')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedFilter = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCoachesTable(BuildContext context) {
    final filteredCoaches = coaches.where((coach) {
      final matchesSearch = coach.speciality.toLowerCase().contains(searchQuery.toLowerCase());
      // Pour l'instant, tous les coachs sont considérés comme actifs
      final bool isActive = true;
      
      switch (selectedFilter) {
        case 'Actifs':
          return matchesSearch && isActive;
        case 'Inactifs':
          return matchesSearch && !isActive;
        default:
          return matchesSearch;
      }
    }).toList();

    return ModernDataTable<Coach>(
      columns: [
        DataColumn(label: Text('Coach', style: Theme.of(context).textTheme.titleMedium)),
        DataColumn(label: Text('Spécialités', style: Theme.of(context).textTheme.titleMedium)),
        DataColumn(label: Text('Contact', style: Theme.of(context).textTheme.titleMedium)),
        DataColumn(label: Text('Revenus', style: Theme.of(context).textTheme.titleMedium)),
        DataColumn(label: Text('Performance', style: Theme.of(context).textTheme.titleMedium)),
        DataColumn(label: Text('Statut', style: Theme.of(context).textTheme.titleMedium)),
        DataColumn(label: Text('Actions', style: Theme.of(context).textTheme.titleMedium)),
      ],
      rows: filteredCoaches.map((coach) {
        return DataRow(
          cells: [
            DataCell(_buildCoachCell(coach)),
            DataCell(_buildSpecialtiesCell(coach)),
            DataCell(_buildContactCell(coach)),
            DataCell(_buildRevenueCell(coach)),
            DataCell(_buildPerformanceCell(coach)),
            DataCell(_buildStatusCell(coach)),
            DataCell(_buildActionsCell(coach)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCoachCell(Coach coach) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(
            coach.speciality.isNotEmpty ? coach.speciality[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              coach.speciality,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'ID: ${coach.userId}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialtiesCell(Coach coach) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        Badge(
          label: coach.speciality,
          type: BadgeType.primary,
        ),
      ],
    );
  }

  Widget _buildContactCell(Coach coach) {
    // Normalement, on récupérerait ces informations via le userId
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Contact non disponible'),
        Text(
          'Voir profil utilisateur',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCell(Coach coach) {
    // Données fictives pour la démonstration
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '€1,250.00',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Ce mois-ci',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCell(Coach coach) {
    // Données fictives pour la démonstration
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const Text(
              '4.8',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: Colors.amber, size: 16),
          ],
        ),
        const SizedBox(height: 4),
        ProgressBar(
          value: 0.85,
          color: Colors.green,
          backgroundColor: Colors.grey[200]!,
        ),
      ],
    );
  }

  Widget _buildStatusCell(Coach coach) {
    // Pour l'instant, tous les coachs sont considérés comme actifs
    const bool isActive = true;
    
    return Badge(
      label: isActive ? 'Actif' : 'Inactif',
      type: isActive ? BadgeType.success : BadgeType.error,
    );
  }

  Widget _buildActionsCell(Coach coach) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditCoachDialog(context, coach),
          tooltip: 'Modifier',
        ),
        IconButton(
          icon: const Icon(Icons.block),
          onPressed: () => _showDeactivateDialog(context, coach),
          tooltip: 'Désactiver',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteDialog(context, coach),
          tooltip: 'Supprimer',
        ),
      ],
    );
  }

  void _showAddCoachDialog(BuildContext context) {
    // Implémentation de l'ajout d'un coach
    // ...
  }

  void _showEditCoachDialog(BuildContext context, Coach coach) {
    // Implémentation de la modification d'un coach
    // ...
  }

  void _showDeactivateDialog(BuildContext context, Coach coach) {
    // Pour l'instant, tous les coachs sont considérés comme actifs
    const bool isActive = true;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActive ? 'Désactiver le coach' : 'Activer le coach'),
        content: Text(
          isActive
              ? 'Êtes-vous sûr de vouloir désactiver ${coach.speciality} ?'
              : 'Êtes-vous sûr de vouloir activer ${coach.speciality} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ModernButton(
            text: isActive ? 'Désactiver' : 'Activer',
            icon: isActive ? Icons.block_outlined : Icons.check_circle_outlined,
            onPressed: () {
              // TODO: Implémenter la désactivation/activation
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Coach coach) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${coach.speciality} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await _apiService.deleteCoach(coach.id);
                _loadCoaches();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
