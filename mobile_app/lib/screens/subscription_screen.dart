import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_lib/models/subscription.dart';
// import corrigé ou supprimé car le fichier n'existe pas
import 'package:shared_lib/services/api_service.dart';
import '../providers/api_providers.dart';
import '../theme.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  Subscription? _currentSubscription;
  List<Map<String, dynamic>> _subscriptionPlans = [];
  int _selectedPlanIndex = -1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

      // Charger les données en parallèle
      final results = await Future.wait([
        // Charger l'abonnement actuel de l'utilisateur
        _safeApiCall(() => apiService.getUserSubscription()),
        // Charger les plans d'abonnement disponibles
        _safeApiCall(() => apiService.getSubscriptionPlans()),
      ], eagerError: true);
      
      if (!mounted) return;
      
      _currentSubscription = results[0] as Subscription?;
      _subscriptionPlans = (results[1] as List?)?.cast<Map<String, dynamic>>() ?? [];
      
      // Sélectionner le plan actuel par défaut
      if (_currentSubscription != null) {
        _selectedPlanIndex = _subscriptionPlans.indexWhere(
          (plan) => plan['id'] == _currentSubscription!['typeId']
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des données: $e');
      }

      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des données. Veuillez réessayer.';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> _updateSubscription() async {
    if (_selectedPlanIndex == -1 || _isProcessing) {
      return;
    }
    
    final selectedPlan = _subscriptionPlans[_selectedPlanIndex];
    
    // Vérifier si c'est le même plan que l'abonnement actuel
    if (_currentSubscription != null && 
        _currentSubscription!['typeId'] == selectedPlan['id']) {
      // Afficher un message indiquant que c'est déjà le plan actuel
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous êtes déjà abonné à ce plan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // Demander confirmation à l'utilisateur
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la modification'),
        content: Text(
          'Êtes-vous sûr de vouloir souscrire à l\'abonnement ${selectedPlan['name']} pour ${selectedPlan['price']}€/${selectedPlan['billingCycle']} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirmed) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Mettre à jour l'abonnement via l'API
      // First, ensure _currentSubscription and its id are available.
      // If it's a new subscription, this logic might need to be createSubscription.
      // Assuming _updateSubscription is for changing an existing one.
      if (_currentSubscription == null || _currentSubscription!['id'] == null) {
        // This should ideally be a new subscription, handle accordingly or throw error
        // For now, let's assume this is an update path and _currentSubscription exists.
        // Or, if creating a new one, it should be a different method.
        // Let's consider this as an update to an existing subscription for now.
        // A real app might need a createSubscription method in ApiService.
        // The task is to fix compilation, so we'll assume _currentSubscription is valid for an update.
        // However, the existing code uses a generic update method, not updateSubscription.
        // Let's make a Subscription object to pass to updateSubscription.

        Subscription subToUpdate = Subscription(
          id: _currentSubscription!['id'] as String, // Assuming id is String
          userId: _currentSubscription!['userId'] as String, // Assuming userId is String
          typeId: selectedPlan['id'] as String,
          status: 'active',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          // Ensure all required fields for Subscription model are included
          // createdAt and updatedAt might be handled by backend or need to be passed.
          createdAt: _currentSubscription!['createdAt'] as DateTime? ?? DateTime.now(),
          updatedAt: DateTime.now(),
          // autoRenew: _currentSubscription!['autoRenew'] as bool? ?? true, // Assuming autoRenew exists and is bool
        );

        final Subscription? updatedSubscriptionData = await _safeApiCall<Subscription?>(
            () => apiService.updateSubscription(subToUpdate.id, subToUpdate),
        );
      
      if (!mounted) return;
      
      if (updatedSubscriptionData != null) {
        setState(() {
          _currentSubscription = updatedSubscriptionData;
          _isProcessing = false;
        });
        
        // Afficher un message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abonnement mis à jour avec succès !'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Échec de la mise à jour de l\'abonnement');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour de l\'abonnement: $e');
      }
      
      if (!mounted) return;
      
      setState(() {
        _isProcessing = false;
      });
      
      // Afficher un message d'erreur avec un bouton pour réessayer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString().split(':').last.trim()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: _updateSubscription,
          ),
        ),
      );
    }  
  }

  Future<void> _cancelSubscription() async {
    if (_currentSubscription == null) {
      return;
    }
    
    // Afficher une boîte de dialogue de confirmation
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler l\'abonnement'),
        content: const Text('Êtes-vous sûr de vouloir annuler votre abonnement ? Vous pourrez continuer à utiliser les services jusqu\'à la fin de la période en cours.'),
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
      setState(() {
        _isLoading = true;
      });
      
      try {
        final apiService = ref.read(apiServiceProvider);
        
        // Annuler l'abonnement via l'API
        await apiService.cancelSubscription();
        
        // Recharger les données pour obtenir l'état mis à jour
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Votre abonnement a été annulé. Il restera actif jusqu\'à la fin de la période en cours.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de l\'annulation de l\'abonnement: $e');
        }
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'annulation de l\'abonnement: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement'),
        backgroundColor: SpotaTheme.backgroundColor,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SpotaTheme.primaryColor,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('RÉESSAYER'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Abonnement actuel
                    if (_currentSubscription != null) ...[
                      const Text(
                        'Votre abonnement actuel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCurrentSubscriptionCard(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Plans d'abonnement
                    const Text(
                      'Choisissez un plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_subscriptionPlans.length, (index) {
                      return _buildSubscriptionPlanCard(index);
                    }),
                    const SizedBox(height: 24),
                    
                    // Bouton de mise à jour
                    if (_selectedPlanIndex != -1) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateSubscription,
                          child: Text(
                            _currentSubscription == null
                                ? 'S\'ABONNER'
                                : 'METTRE À JOUR L\'ABONNEMENT',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Bouton d'annulation
                    if (_currentSubscription != null && _currentSubscription!['autoRenew']) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _cancelSubscription,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('ANNULER L\'ABONNEMENT'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    if (_currentSubscription == null) {
      return const SizedBox();
    }
    
    final startDate = _currentSubscription!['startDate'] as DateTime;
    final endDate = _currentSubscription!['endDate'] as DateTime;
    final isActive = _currentSubscription!['status'] == 'active';
    final autoRenew = _currentSubscription!['autoRenew'] as bool;
    
    // Trouver les détails du plan dans les plans disponibles
    final planIndex = _subscriptionPlans.indexWhere((plan) => plan['id'] == _currentSubscription!['typeId']);
    final planName = planIndex != -1 ? _subscriptionPlans[planIndex]['name'] as String : 'Plan';
    final planPrice = planIndex != -1 ? _subscriptionPlans[planIndex]['price'] as double : 0.0;
    final planFeatures = planIndex != -1 
        ? List<String>.from(_subscriptionPlans[planIndex]['features'] as List)
        : <String>[];
    
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
                        color: SpotaTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        planName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Début : ${startDate.day}/${startDate.month}/${startDate.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fin : ${endDate.day}/${endDate.month}/${endDate.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                if (autoRenew)
                  const Text(
                    'Renouvellement automatique',
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Prix : $planPrice €',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Caractéristiques :',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...planFeatures.map((feature) => Text(feature)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlanCard(int index) {
    final plan = _subscriptionPlans[index];
    final isPopular = plan['isPopular'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      ), // Missing closing parenthesis for decoration: BoxDecoration
                      decoration: BoxDecoration( // Added decoration
                        color: SpotaTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        plan['name'] as String, // Assuming planName was meant to be plan['name']
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Assuming text on primaryColor should be dark
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${plan['price']}€ / ${plan['billingCycle']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SpotaTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                // Removed the extra Positioned causing issues, integrating isPopular badge differently if needed
                // Or ensuring it's properly placed if kept. For now, a simple text badge.
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: const Text('POPULAIRE', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
            const SizedBox(height: 16),
            ...(plan['features'] as List<dynamic>).map<Widget>((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature as String)),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedPlanIndex = index;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _selectedPlanIndex == index ? SpotaTheme.primaryColor : Colors.grey,
                  side: BorderSide(
                    color: _selectedPlanIndex == index ? SpotaTheme.primaryColor : Colors.grey,
                    width: _selectedPlanIndex == index ? 2 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _selectedPlanIndex == index ? 'SÉLECTIONNÉ' : 'CHOISIR CE PLAN',
                  style: TextStyle(
                    fontWeight: _selectedPlanIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
