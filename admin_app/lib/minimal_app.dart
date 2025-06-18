import 'package:flutter/material.dart';
import 'theme.dart';

void main() {
  runApp(const MinimalApp());
}

class MinimalApp extends StatelessWidget {
  const MinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spota Admin (Minimal)',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const MinimalHomePage(),
    );
  }
}

class MinimalHomePage extends StatefulWidget {
  const MinimalHomePage({super.key});

  @override
  State<MinimalHomePage> createState() => _MinimalHomePageState();
}

class _MinimalHomePageState extends State<MinimalHomePage> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const Placeholder(
      color: Colors.blue,
      child: Center(
        child: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const Placeholder(
      color: Colors.green,
      child: Center(
        child: Text(
          'Coaches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const Placeholder(
      color: Colors.orange,
      child: Center(
        child: Text(
          'Courses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const Placeholder(
      color: Colors.purple,
      child: Center(
        child: Text(
          'Bookings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const Placeholder(
      color: Colors.red,
      child: Center(
        child: Text(
          'Users',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const Placeholder(
      color: Colors.teal,
      child: Center(
        child: Text(
          'Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const Placeholder(
      color: Colors.amber,
      child: Center(
        child: Text(
          'Programs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const Placeholder(
      color: Colors.indigo,
      child: Center(
        child: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ];
  
  final List<String> _screenTitles = [
    'Dashboard',
    'Coaches',
    'Courses',
    'Bookings',
    'Users',
    'Schedule',
    'Programs',
    'Notifications',
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            extended: true,
            minExtendedWidth: 250,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard),
                label: Text(_screenTitles[0]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.sports),
                label: Text(_screenTitles[1]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.school),
                label: Text(_screenTitles[2]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.book_online),
                label: Text(_screenTitles[3]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.people),
                label: Text(_screenTitles[4]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.calendar_today),
                label: Text(_screenTitles[5]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.fitness_center),
                label: Text(_screenTitles[6]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.notifications),
                label: Text(_screenTitles[7]),
              ),
            ],
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // App bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _screenTitles[_selectedIndex],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.deepPurple,
                        child: Text('A'),
                      ),
                      const SizedBox(width: 8),
                      const Text('Admin'),
                    ],
                  ),
                ),
                // Screen content
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
