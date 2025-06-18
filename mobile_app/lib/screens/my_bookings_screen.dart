import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_lib/models/booking.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/services/api_service.dart';
import '../providers/api_providers.dart';
import '../theme.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> with SingleTickerProviderStateMixin {

  bool _isLoading = true;
  late TabController _tabController;
  List<Booking> _upcomingBookings = [];
  List<Booking> _pastBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeDateFormatting('fr_FR', null).then((_) => _loadBookings());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      final apiService = ref.read(apiServiceProvider);
            
      // Récupérer les réservations à venir et passées
      final upcoming = await apiService.getUpcomingUserBookings();
      final past = await apiService.getPastUserBookings();
      
      if (kDebugMode) {
        print('Chargé ${upcoming.length} réservations à venir et ${past.length} réservations passées');
      }
      
      if (!mounted) return;
      
      setState(() {
        _upcomingBookings = upcoming;
        _pastBookings = past;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des réservations: $e');
      }
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des réservations: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Si l'erreur est liée à l'authentification, rediriger vers la page de connexion
      if (e.toString().contains('not authenticated') || e.toString().contains('unauthorized')) {
        context.go('/login');
      }
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    // Afficher une boîte de dialogue de confirmation
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('NON'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OUI'),
          ),
        ],
      ),
    );
    
    if (shouldCancel == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        final apiService = ref.read(apiServiceProvider);
        
        // Trouver la réservation à annuler
        final bookingIndex = _upcomingBookings.indexWhere((booking) => booking.id == bookingId);
        if (bookingIndex == -1) {
          throw Exception('Réservation non trouvée');
        }
        
        final booking = _upcomingBookings[bookingIndex];
        
        // Annuler la réservation via l'API
        await apiService.cancelBooking(bookingId);
        
        // Créer une nouvelle instance de Booking avec le statut mis à jour
        final updatedBooking = Booking(
          id: booking.id,
          userId: booking.userId,
          courseId: booking.courseId,
          bookingDate: booking.bookingDate,
          status: 'cancelled',  // Nouveau statut
          createdAt: booking.createdAt,
          updatedAt: DateTime.now(),
          timeSlotId: booking.timeSlotId,
          location: booking.location,
          rating: booking.rating,
          course: booking.course,
        );
        
        // Mettre à jour l'interface utilisateur de manière optimiste
        setState(() {
          // Déplacer la réservation annulée vers les réservations passées
          _pastBookings.insert(0, updatedBooking);
          _upcomingBookings.removeAt(bookingIndex);
          
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation annulée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de l\'annulation de la réservation: $e');
        }
        
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation de la réservation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rateBooking(String bookingId, int rating) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final apiService = ref.read(apiServiceProvider);
      
      // Trouver la réservation à évaluer
      final bookingIndex = _pastBookings.indexWhere((booking) => booking.id == bookingId);
      if (bookingIndex == -1) {
        throw Exception('Réservation non trouvée');
      }
      
      // Évaluer la réservation via l'API
      await apiService.rateBooking(bookingId, rating);
      
      final booking = _pastBookings[bookingIndex];
      
      // Créer une nouvelle instance de Booking avec la note mise à jour
      final updatedBooking = Booking(
        id: booking.id,
        userId: booking.userId,
        courseId: booking.courseId,
        bookingDate: booking.bookingDate,
        status: booking.status,
        createdAt: booking.createdAt,
        updatedAt: DateTime.now(),
        timeSlotId: booking.timeSlotId,
        location: booking.location,
        rating: rating,  // Nouvelle note
        course: booking.course,
      );
      
      // Mettre à jour l'interface utilisateur de manière optimiste
      setState(() {
        _pastBookings[bookingIndex] = updatedBooking;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merci pour votre évaluation !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'\u00e9valuation de la réservation: $e');
      }
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'\u00e9valuation de la réservation: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Mes Réservations'),
            floating: true,
            pinned: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'À venir'),
                Tab(text: 'Passées'),
              ],
              labelColor: SpotaTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: SpotaTheme.primaryColor,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadBookings,
                tooltip: 'Rafraîchir',
              ),
            ],
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _loadBookings,
          color: SpotaTheme.primaryColor,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: SpotaTheme.primaryColor,
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingBookingsTab(),
                    _buildPastBookingsTab(),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (mounted) {
            context.push('/booking');
          }
        },
        backgroundColor: SpotaTheme.primaryColor,
        tooltip: 'Nouvelle réservation',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpcomingBookingsTab() {
    if (_upcomingBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'Aucune réservation à venir',
        subtitle: 'Réservez un cours dès maintenant !',
        showBookButton: true,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingBookings.length,
      itemBuilder: (context, index) {
        final booking = _upcomingBookings[index];
        return _buildBookingCard(
          booking: booking,
          isUpcoming: true,
          onCancel: _cancelBooking,
          onRate: _rateBooking,
        );
      },
    );
  }

  Widget _buildPastBookingsTab() {
    // Placeholder implementation
    // TODO: Implement fetching and displaying past bookings similar to _upcomingBookings
    // For now, using _pastBookings list which should be populated in _loadBookings
    if (_pastBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'Aucune réservation passée',
        subtitle: 'Vos cours terminés apparaîtront ici.',
        showBookButton: false,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastBookings.length,
      itemBuilder: (context, index) {
        final booking = _pastBookings[index];
        // final course = _getCourseById(booking.courseId); // Assuming _getCourseById exists and works
        // For now, directly use booking.course if available and correctly typed
        final course = booking.course; 

        return _buildBookingCard(
          booking: booking,
          isUpcoming: false, 
          onCancel: (bookingId) {
            // Typically, past bookings can't be cancelled.
            if (kDebugMode) {
              print('Attempted to cancel past booking: $bookingId (Not a typical action)');
            }
          },
          onRate: _rateBooking, // Assuming _rateBooking can handle this
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmé';
      case 'cancelled':
        return 'Annulé';
      case 'completed':
        return 'Terminé';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return SpotaTheme.secondaryTextColor;
    }
  }

  // Widget pour afficher un message lorsqu'il n'y a pas de réservations
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showBookButton = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: SpotaTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: SpotaTheme.secondaryTextColor,
            ),
          ),
          if (showBookButton) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push('/booking');
              },
              child: const Text('RÉSERVER UN COURS'),
            ),
          ],
        ],
      ),
    );
  }

  // Widget pour afficher l'en-tête d'une carte de réservation avec image
  Widget _buildBookingCardHeader(Booking booking, Course? course) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: SpotaTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        image: course?.imageUrl != null && course!.imageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(course.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Overlay sombre pour améliorer la lisibilité
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
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
          // Informations du cours
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course?.title ?? 'Cours',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course?.coachName ?? 'Coach',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge de statut
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(booking.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher les informations de base d'une réservation
  Widget _buildBookingInfo(Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date et heure
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: SpotaTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat.yMMMMd('fr_FR').format(booking.bookingDate),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: SpotaTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(booking.timeSlotId ?? '10:00 - 11:00'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: SpotaTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(booking.location ?? 'Salle principale'),
          ],
        ),
      ],
    );
  }

  // Widget pour afficher une carte de réservation
  Widget _buildBookingCard({
    required Booking booking,
    required bool isUpcoming,
    required Function(String) onCancel,
    required Function(String, int) onRate,
  }) {
    final course = booking.course;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec image
          _buildBookingCardHeader(booking, course),
          
          // Détails de la réservation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations de base
                _buildBookingInfo(booking),
                
                const SizedBox(height: 16),
                
                // Actions spécifiques selon le type de réservation
                if (isUpcoming) 
                  // Boutons d'action pour les réservations à venir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            if (course != null) {
                              context.push('/course-details/${course.id}');
                            }
                          },
                          child: const Text('DÉTAILS'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: booking.status == 'confirmed'
                              ? () => onCancel(booking.id)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('ANNULER'),
                        ),
                      ),
                    ],
                  )
                else if (booking.status == 'completed')
                  // Section d'évaluation pour les réservations passées
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 3),
                      const SizedBox(height: 16),
                      booking.rating != null
                          ? Row(
                              children: [
                                const Text('Votre évaluation: '),
                                const SizedBox(width: 8),
                                ...List.generate(5, (i) {
                                  return Icon(
                                    i < (booking.rating ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: SpotaTheme.primaryColor,
                                    size: 24,
                                  );
                                }),
                              ],
                            )
                          : Row(
                              children: [
                                const Text('Noter ce cours: '),
                                const SizedBox(width: 8),
                                ...List.generate(5, (i) {
                                  return IconButton(
                                    onPressed: () => onRate(booking.id, i + 1),
                                    icon: const Icon(
                                      Icons.star_border,
                                      color: SpotaTheme.primaryColor,
                                      size: 24,
                                    ),
                                  );
                                }),
                              ],
                            ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            if (course != null) {
                              context.push('/course-details/${course.id}');
                            }
                          },
                          child: const Text('RÉSERVER À NOUVEAU'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
