import 'package:flutter/material.dart';
import 'package:shared_lib/models/subscription.dart';
import 'package:shared_lib/models/subscription_type.dart';
import 'package:shared_lib/models/user.dart';
import 'package:shared_lib/services/api_service.dart';
import '../components/sidebar.dart';
import '../components/badge.dart' as custom_badge;
import '../components/modern_button.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final ApiService _apiService = ApiService();
  List<Subscription> subscriptions = [];
  List<SubscriptionType> subscriptionTypes = [];
  List<AppUser> users = [];
  bool isLoading = true;
  String? error;
  String statusFilter = 'Tous';
  
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
  final dateFormat = DateFormat('dd/MM/yyyy');

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

      final loadedSubscriptions = await _apiService.getAllSubscriptions();
      final loadedSubscriptionTypes = await _apiService.getAllSubscriptionTypes();
      final loadedUsers = await _apiService.getAllUsers();

      setState(() {
        subscriptions = loadedSubscriptions;
        subscriptionTypes = loadedSubscriptionTypes;
        users = loadedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des données: $e';
        isLoading = false;
      });
    }
  }

  List<Subscription> get filteredSubscriptions {
    if (statusFilter == 'Tous') {
      return subscriptions;
    }
    return subscriptions.where((subscription) => subscription.status == statusFilter).toList();
  }

  String getUserName(String userId) {
    final user = users.firstWhere(
      (user) => user.id == userId,
      orElse: () => AppUser(
        id: userId,
        email: 'Unknown',
        name: 'Unknown User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return user.name;
  }

  SubscriptionType getSubscriptionType(String typeId) {
    return subscriptionTypes.firstWhere(
      (type) => type.id == typeId,
      orElse: () => SubscriptionType(
        id: typeId,
        name: 'Unknown',
        price: 0,
        description: 'Unknown',
        durationInDays: 0,
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  custom_badge.BadgeType getStatusBadgeType(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return custom_badge.BadgeType.success;
      case 'pending':
        return custom_badge.BadgeType.warning;
      case 'expired':
        return custom_badge.BadgeType.error;
      default:
        return custom_badge.BadgeType.info;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'pending':
        return 'En attente';
      case 'expired':
        return 'Expiré';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          const Sidebar(selectedIndex: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildStatistics(context),
                Expanded(
                  child: _buildSubscriptionsTable(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paiements et Abonnements',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gérez tous les abonnements et paiements',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: statusFilter,
                items: ['Tous', 'active', 'pending', 'expired'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'Tous' ? value : getStatusText(value)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    statusFilter = newValue!;
                  });
                },
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(width: 16),
              ModernButton(
                text: 'Actualiser',
                icon: Icons.refresh,
                onPressed: _loadData,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final totalRevenue = subscriptions
        .map((subscription) => getSubscriptionType(subscription.typeId).price)
        .fold(0.0, (prev, price) => prev + price);
    
    final activeSubscriptions = subscriptions.where((subscription) => subscription.status.toLowerCase() == 'active').length;
    final pendingSubscriptions = subscriptions.where((subscription) => subscription.status.toLowerCase() == 'pending').length;
    final expiredSubscriptions = subscriptions.where((subscription) => subscription.status.toLowerCase() == 'expired').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          _buildStatCard(
            context,
            'Revenu Total',
            currencyFormat.format(totalRevenue),
            Icons.euro,
            Colors.green,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            context,
            'Abonnements Actifs',
            activeSubscriptions.toString(),
            Icons.check_circle_outline,
            Colors.blue,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            context,
            'En Attente',
            pendingSubscriptions.toString(),
            Icons.pending_outlined,
            Colors.orange,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            context,
            'Expirés',
            expiredSubscriptions.toString(),
            Icons.cancel_outlined,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionsTable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Abonnements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredSubscriptions.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun abonnement trouvé',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredSubscriptions.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final subscription = filteredSubscriptions[index];
                          final subscriptionType = getSubscriptionType(subscription.typeId);
                          return ListTile(
                            title: Text(
                              getUserName(subscription.userId),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(subscriptionType.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currencyFormat.format(subscriptionType.price),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                custom_badge.Badge(
                                  text: getStatusText(subscription.status),
                                  type: getStatusBadgeType(subscription.status),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${dateFormat.format(subscription.startDate)} - ${dateFormat.format(subscription.endDate)}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () {
                                    // TODO: Implement edit subscription
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
