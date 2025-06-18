import 'package:flutter/material.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/coach.dart';
import 'package:shared_lib/services/api_service.dart';
import '../components/sidebar.dart';
import '../components/modern_button.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final ApiService _apiService = ApiService();
  List<Course> courses = [];
  List<Coach> coaches = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  
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
      
      final loadedCourses = await _apiService.getAllCourses();
      final loadedCoaches = await _apiService.getAllCoaches();
      
      setState(() {
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
  
  String getCoachName(String coachId) {
    final coach = coaches.firstWhere(
      (coach) => coach.id == coachId,
      orElse: () => Coach(
        id: 'unknown',
        userId: 'unknown',
        speciality: 'Coach inconnu',
        description: '',
        availableDays: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    return coach.speciality;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          const Sidebar(selectedIndex: 2),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(context),
        child: const Icon(Icons.add),
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSearchBar(),
        Expanded(
          child: _buildCoursesList(),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Programmes de cours',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gérez les différents programmes proposés',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
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
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un programme...',
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
    );
  }
  
  Widget _buildCoursesList() {
    final filteredCourses = courses.where((course) {
      return course.title.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    
    if (filteredCourses.isEmpty) {
      return Center(
        child: Text(
          'Aucun programme trouvé',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredCourses.length,
        itemBuilder: (context, index) {
          return _buildCourseCard(filteredCourses[index]);
        },
      ),
    );
  }
  
  Widget _buildCourseCard(Course course) {
    final coachName = getCoachName(course.coachId);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(51),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showEditCourseDialog(context, course),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditCourseDialog(context, course);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, course);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                course.description ?? 'Aucune description',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Coach: $coachName',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                        ),
                  ),
                  Text(
                    'Capacité: ${course.capacity}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAddCourseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final capacityController = TextEditingController(text: '10');
    String? selectedCoachId = coaches.isNotEmpty ? coaches.first.id : null;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un programme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCoachId,
                decoration: const InputDecoration(
                  labelText: 'Coach',
                  border: OutlineInputBorder(),
                ),
                items: coaches.map((coach) {
                  return DropdownMenuItem(
                    value: coach.id,
                    child: Text(coach.speciality),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCoachId = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacité',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || selectedCoachId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                );
                return;
              }
              
              final newCourse = Course(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descriptionController.text.isEmpty ? null : descriptionController.text,
                coachId: selectedCoachId!,
                capacity: int.tryParse(capacityController.text) ?? 10,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              
              try {
                await _apiService.createCourse(newCourse);
                _loadData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
  
  void _showEditCourseDialog(BuildContext context, Course course) {
    final titleController = TextEditingController(text: course.title);
    final descriptionController = TextEditingController(text: course.description ?? '');
    final capacityController = TextEditingController(text: course.capacity.toString());
    String selectedCoachId = course.coachId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le programme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCoachId,
                decoration: const InputDecoration(
                  labelText: 'Coach',
                  border: OutlineInputBorder(),
                ),
                items: coaches.map((coach) {
                  return DropdownMenuItem(
                    value: coach.id,
                    child: Text(coach.speciality),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCoachId = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacité',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Créer un nouveau Course au lieu d'utiliser copyWith
              final updatedCourse = Course(
                id: course.id,
                title: titleController.text,
                description: descriptionController.text.isEmpty ? null : descriptionController.text,
                coachId: selectedCoachId,
                capacity: int.tryParse(capacityController.text) ?? course.capacity,
                createdAt: course.createdAt,
                updatedAt: DateTime.now(),
              );

              try {
                await _apiService.updateCourse(course.id, updatedCourse);
                _loadData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le programme "${course.title}" ?'),
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
                await _apiService.deleteCourse(course.id);
                _loadData();
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
