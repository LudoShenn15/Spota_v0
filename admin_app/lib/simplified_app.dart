import 'package:flutter/material.dart';
import 'package:shared_lib/services/api_service.dart';
import 'package:shared_lib/models/coach.dart';
import 'package:shared_lib/models/course.dart';
import 'package:shared_lib/models/booking.dart';

void main() {
  runApp(const SimplifiedApp());
}

class SimplifiedApp extends StatelessWidget {
  const SimplifiedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spota Admin Simplified',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SimplifiedHomePage(),
    );
  }
}

class SimplifiedHomePage extends StatefulWidget {
  const SimplifiedHomePage({super.key});

  @override
  State<SimplifiedHomePage> createState() => _SimplifiedHomePageState();
}

class _SimplifiedHomePageState extends State<SimplifiedHomePage> {
  final ApiService _apiService = ApiService();
  List<Coach> coaches = [];
  List<Course> courses = [];
  List<Booking> bookings = [];
  bool isLoading = true;
  String? error;

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

      final loadedCoaches = await _apiService.getAllCoaches();
      final loadedCourses = await _apiService.getAllCourses();
      final loadedBookings = await _apiService.getAllBookings();

      setState(() {
        coaches = loadedCoaches;
        courses = loadedCourses;
        bookings = loadedBookings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des données: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spota Admin Simplified'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erreur: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Données chargées avec succès!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDataSection('Coachs (${coaches.length})', coaches.map((coach) => 
                    'ID: ${coach.id}, Spécialité: ${coach.speciality}'
                  ).toList()),
                  const SizedBox(height: 20),
                  _buildDataSection('Cours (${courses.length})', courses.map((course) => 
                    'ID: ${course.id}, Titre: ${course.title}'
                  ).toList()),
                  const SizedBox(height: 20),
                  _buildDataSection('Réservations (${bookings.length})', bookings.map((booking) => 
                    'ID: ${booking.id}, Date: ${booking.bookingDate}'
                  ).toList()),
                ],
              ),
            ),
    );
  }

  Widget _buildDataSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length > 5 ? 5 : items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]),
              );
            },
          ),
        ),
        if (items.length > 5)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Voir plus...'),
            ),
          ),
      ],
    );
  }
}
