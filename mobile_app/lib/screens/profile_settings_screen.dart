import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs de formulaire
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  // Valeurs pour les sélecteurs
  String _selectedGender = 'Homme';
  String _selectedFitnessLevel = 'Intermédiaire';
  
  // Options pour les sélecteurs
  final List<String> _genderOptions = ['Homme', 'Femme', 'Autre', 'Préfère ne pas préciser'];
  final List<String> _fitnessLevelOptions = ['Débutant', 'Intermédiaire', 'Avancé', 'Expert'];
  
  // État de chargement
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Préférences de notification
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserProfile() async {
    // Simuler le chargement des données
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Utiliser ApiService de shared_lib pour charger les données réelles
    
    // Données fictives pour la démo
    setState(() {
      _nameController.text = 'Thomas Dubois';
      _emailController.text = 'thomas.dubois@example.com';
      _phoneController.text = '+33 6 12 34 56 78';
      _birthdateController.text = '15/04/1990';
      _heightController.text = '180';
      _weightController.text = '75';
      _selectedGender = 'Homme';
      _selectedFitnessLevel = 'Intermédiaire';
      _isLoading = false;
    });
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 ans par défaut
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SpotaTheme.primaryColor,
              onPrimary: Colors.black,
              surface: SpotaTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _birthdateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Simuler l'enregistrement des données
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Utiliser ApiService de shared_lib pour enregistrer les données
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du profil: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du profil'),
        backgroundColor: SpotaTheme.backgroundColor,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SpotaTheme.primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section photo de profil
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // Avatar
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade800,
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/default_avatar.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Bouton d'édition
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: SpotaTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _nameController.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _emailController.text,
                            style: const TextStyle(
                              color: SpotaTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Section Informations personnelles
                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 32),
                    
                    // Section Informations physiques
                    const Text(
                      'Informations physiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPhysicalInfoSection(),
                    const SizedBox(height: 32),
                    
                    // Section Préférences de notification
                    const Text(
                      'Préférences de notification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNotificationPreferencesSection(),
                    const SizedBox(height: 32),
                    
                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text('ENREGISTRER'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Bouton de déconnexion
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implémenter la déconnexion
                          context.go('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text(
                          'DÉCONNEXION',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildPersonalInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nom complet
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Veuillez entrer un email valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Téléphone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            
            // Date de naissance
            TextFormField(
              controller: _birthdateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: const InputDecoration(
                labelText: 'Date de naissance',
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: 16),
            
            // Genre
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Genre',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhysicalInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Taille
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Taille (cm)',
                prefixIcon: Icon(Icons.height),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final height = int.tryParse(value);
                  if (height == null || height < 100 || height > 250) {
                    return 'Veuillez entrer une taille valide (100-250 cm)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Poids
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Poids (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final weight = int.tryParse(value);
                  if (weight == null || weight < 30 || weight > 250) {
                    return 'Veuillez entrer un poids valide (30-250 kg)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Niveau de fitness
            DropdownButtonFormField<String>(
              value: _selectedFitnessLevel,
              decoration: const InputDecoration(
                labelText: 'Niveau de fitness',
                prefixIcon: Icon(Icons.fitness_center),
              ),
              items: _fitnessLevelOptions.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFitnessLevel = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationPreferencesSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notifications par email
            SwitchListTile(
              title: const Text('Notifications par email'),
              subtitle: const Text('Recevoir des notifications par email'),
              value: _emailNotifications,
              activeColor: SpotaTheme.primaryColor,
              onChanged: (bool value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            const Divider(),
            
            // Notifications push
            SwitchListTile(
              title: const Text('Notifications push'),
              subtitle: const Text('Recevoir des notifications push sur votre appareil'),
              value: _pushNotifications,
              activeColor: SpotaTheme.primaryColor,
              onChanged: (bool value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            const Divider(),
            
            // Notifications SMS
            SwitchListTile(
              title: const Text('Notifications SMS'),
              subtitle: const Text('Recevoir des notifications par SMS'),
              value: _smsNotifications,
              activeColor: SpotaTheme.primaryColor,
              onChanged: (bool value) {
                setState(() {
                  _smsNotifications = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
