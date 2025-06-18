import 'package:flutter/material.dart';
import 'package:shared_lib/models/coach.dart';
import 'package:shared_lib/services/api_service.dart';
import '../components/modern_button.dart';
import '../components/data_table.dart';
import '../components/sidebar.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({super.key});

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  final ApiService _apiService = ApiService();
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
          const Sidebar(selectedIndex: 3),
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

    // Convertir les données des coachs en format compatible avec DataTableWidget
    final columns = ['Coach', 'Spécialité', 'Jours disponibles', 'Actions'];
    final rows = filteredCoaches.map((coach) {
      return [
        coach.speciality,
        coach.speciality,
        coach.availableDays.join(', '),
        'actions' // Cette colonne sera remplacée par des boutons d'action
      ];
    }).toList();

    return Expanded(
      child: DataTableWidget(
        columns: columns,
        rows: rows,
        onEdit: (index) {
          _showEditCoachDialog(context, filteredCoaches[index]);
        },
        onDelete: (index) {
          _showDeleteDialog(context, filteredCoaches[index]);
        },
      ),
    );
  }

  void _showAddCoachDialog(BuildContext context) {
    // Implémentation de l'ajout d'un coach
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un coach'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEditCoachDialog(BuildContext context, Coach coach) {
    // Implémentation de la modification d'un coach
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le coach'),
        content: Text('Modification du coach ${coach.speciality}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
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
