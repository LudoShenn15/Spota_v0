import 'package:flutter/material.dart';
import 'package:shared_lib/models/course.dart';
import '../theme.dart';

class CourseCard extends StatelessWidget {
  final String id;
  final String title;
  final String coachName;
  final String imageUrl;
  final int capacity;
  final int? enrolled;
  final DateTime? date;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.id,
    required this.title,
    required this.coachName,
    required this.imageUrl,
    required this.capacity,
    this.enrolled,
    this.date,
    this.onTap,
  });
  
  // Constructeur factory qui crée un CourseCard à partir d'un objet Course
  factory CourseCard.fromCourse({
    required Course course,
    required VoidCallback onTap,
  }) {
    return CourseCard(
      id: course.id,
      title: course.title,
      coachName: course.coachName ?? 'Coach non spécifié',
      imageUrl: course.imageUrl ?? '',
      capacity: course.capacity,
      enrolled: course.enrolled,
      date: course.startTime,
      onTap: onTap,
    );
  }
  
  // Construire l'image du cours avec gestion des erreurs et état de chargement
  Widget _buildCourseImage() {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade800,
        child: const Center(
          child: Icon(
            Icons.fitness_center,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }
    
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            color: SpotaTheme.primaryColor,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade800,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  'Image non disponible',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableSpots = capacity - (enrolled ?? 0);
    final isAvailable = availableSpots > 0;
    
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du cours
            Stack(
              children: [
                // Image avec effet d'assombrissement
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: _buildCourseImage(),
                ),
                // Overlay pour assombrir l'image
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Date du cours
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        if (date != null) ...[
                          Text(
                            '${date?.day ?? 1}/${date?.month ?? 1}/${date?.year ?? 1} - ${date?.hour ?? 0}:${(date?.minute ?? 0).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Indicateur de disponibilité
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? SpotaTheme.primaryColor
                          : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAvailable
                          ? '$availableSpots places'
                          : 'Complet',
                      style: TextStyle(
                        color: isAvailable ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Informations du cours
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: SpotaTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Coach: $coachName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: SpotaTheme.secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Barre de progression des places
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Places: $enrolled/$capacity',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SpotaTheme.secondaryTextColor,
                            ),
                          ),
                          Text(
                            isAvailable
                                ? 'Disponible'
                                : 'Complet',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? SpotaTheme.primaryColor
                                  : Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (enrolled ?? 0) / (capacity > 0 ? capacity : 1),
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isAvailable
                                ? SpotaTheme.primaryColor
                                : Colors.red.shade400,
                          ),
                          minHeight: 6,
                        ),
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
}
