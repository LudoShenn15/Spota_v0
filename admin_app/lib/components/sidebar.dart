import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;

  const Sidebar({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildNavigation(context),
          const Spacer(),
          _buildProfile(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.sports_gymnastics,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'SPOTA Admin',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    final navItems = [
      {
        'title': 'Tableau de bord',
        'icon': Icons.dashboard_outlined,
        'route': '/dashboard',
      },
      {
        'title': 'Coachs',
        'icon': Icons.groups_outlined,
        'route': '/coaches',
      },
      {
        'title': 'Cours',
        'icon': Icons.fitness_center_outlined,
        'route': '/courses',
      },
      {
        'title': 'Réservations',
        'icon': Icons.calendar_today_outlined,
        'route': '/bookings',
      },
      {
        'title': 'Planning',
        'icon': Icons.schedule_outlined,
        'route': '/schedule',
      },
      {
        'title': 'Paiements',
        'icon': Icons.payments_outlined,
        'route': '/payments',
      },
      {
        'title': 'Utilisateurs',
        'icon': Icons.person_outline,
        'route': '/users',
      },
      {
        'title': 'Programmes',
        'icon': Icons.fitness_center,
        'route': '/programs',
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_outlined,
        'route': '/notifications',
      },
      {
        'title': 'Paramètres',
        'icon': Icons.settings_outlined,
        'route': '/settings',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: navItems.length,
      itemBuilder: (context, index) {
        final item = navItems[index];
        final isSelected = index == selectedIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              onTap: () => context.go(item['route'] as String),
              selected: isSelected,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(
                item['icon'] as IconData,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.64),
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin SPOTA',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'admin@spota.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.64),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
            },
          ),
        ],
      ),
    );
  }
}