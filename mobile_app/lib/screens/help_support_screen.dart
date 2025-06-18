import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'Comment réserver un cours ?',
      'answer':
          'Pour réserver un cours, accédez à l\'onglet "Explorer" ou "Réserver", sélectionnez le cours qui vous intéresse, choisissez une date et un créneau horaire disponible, puis confirmez votre réservation.'
    },
    {
      'question': 'Comment annuler une réservation ?',
      'answer':
          'Pour annuler une réservation, accédez à l\'onglet "Profil", puis "Mes réservations". Sélectionnez la réservation que vous souhaitez annuler et appuyez sur le bouton "Annuler". Notez que l\'annulation peut être soumise à des conditions selon votre abonnement et le délai avant le cours.'
    },
    {
      'question': 'Comment fonctionne l\'abonnement ?',
      'answer':
          'Spota propose différentes formules d\'abonnement (Basic, Premium, Pro) avec des avantages variés. Vous pouvez consulter et gérer votre abonnement dans la section "Abonnement" accessible depuis votre profil. Les paiements sont automatiquement renouvelés chaque mois, sauf si vous désactivez le renouvellement automatique.'
    },
    {
      'question': 'Comment contacter un coach ?',
      'answer':
          'Vous pouvez contacter un coach en consultant sa page de profil accessible depuis les détails d\'un cours ou la section "Explorer". Utilisez le bouton "Contacter" pour envoyer un message directement au coach.'
    },
    {
      'question': 'Comment obtenir de l\'aide technique ?',
      'answer':
          'Pour toute assistance technique, utilisez le formulaire de contact ci-dessous ou envoyez un email à support@spota.com. Notre équipe vous répondra dans les 24 heures ouvrables.'
    },
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  final List<bool> _isExpanded = List.filled(5, false);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler l'envoi du formulaire
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Utiliser ApiService de shared_lib pour envoyer le formulaire
      
      if (!mounted) return;
      
      // Réinitialiser le formulaire
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre message a été envoyé avec succès. Nous vous répondrons dans les plus brefs délais.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi du formulaire: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir l\'URL: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Demande d\'assistance Spota',
      },
    );
    
    if (!await launchUrl(emailUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir le client email pour: $email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    
    if (!await launchUrl(phoneUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'appeler le numéro: $phone'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        backgroundColor: SpotaTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section FAQ
            const Text(
              'Questions fréquentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqSection(),
            const SizedBox(height: 32),
            
            // Section Contact
            const Text(
              'Nous contacter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactOptions(),
            const SizedBox(height: 32),
            
            // Section Formulaire
            const Text(
              'Formulaire de contact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactForm(),
            const SizedBox(height: 32),
            
            // Section Liens utiles
            const Text(
              'Liens utiles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUsefulLinks(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(_faqItems.length, (index) {
            return _buildFaqItem(
              _faqItems[index]['question'],
              _faqItems[index]['answer'],
              index,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, int index) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded[index] = !_isExpanded[index];
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded[index]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: SpotaTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded[index])
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 16,
            ),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: SpotaTheme.secondaryTextColor,
              ),
            ),
          ),
        if (index < _faqItems.length - 1)
          const Divider(
            color: SpotaTheme.surfaceColor,
            thickness: 1,
          ),
      ],
    );
  }

  Widget _buildContactOptions() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Email
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SpotaTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email,
                  color: SpotaTheme.primaryColor,
                ),
              ),
              title: const Text('Email'),
              subtitle: const Text('support@spota.com'),
              onTap: () => _launchEmail('support@spota.com'),
            ),
            const Divider(),
            // Téléphone
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SpotaTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  color: SpotaTheme.primaryColor,
                ),
              ),
              title: const Text('Téléphone'),
              subtitle: const Text('+33 1 23 45 67 89'),
              onTap: () => _launchPhone('+33123456789'),
            ),
            const Divider(),
            // Adresse
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SpotaTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: SpotaTheme.primaryColor,
                ),
              ),
              title: const Text('Adresse'),
              subtitle: const Text('123 Rue du Sport, 75001 Paris, France'),
              onTap: () => _launchURL('https://maps.google.com/?q=123+Rue+du+Sport+75001+Paris+France'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Entrez votre nom',
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
                  hintText: 'Entrez votre adresse email',
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
              
              // Sujet
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Sujet',
                  hintText: 'Entrez le sujet de votre message',
                  prefixIcon: Icon(Icons.subject),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un sujet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Entrez votre message',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.message),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre message';
                  }
                  if (value.length < 10) {
                    return 'Votre message doit contenir au moins 10 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Bouton d'envoi
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('ENVOYER'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsefulLinks() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLinkItem(
              'Conditions générales d\'utilisation',
              'Consultez nos conditions générales d\'utilisation',
              Icons.description,
              () => _launchURL('https://spota.com/terms'),
            ),
            const Divider(),
            _buildLinkItem(
              'Politique de confidentialité',
              'Consultez notre politique de confidentialité',
              Icons.privacy_tip,
              () => _launchURL('https://spota.com/privacy'),
            ),
            const Divider(),
            _buildLinkItem(
              'Guide d\'utilisation',
              'Consultez notre guide d\'utilisation complet',
              Icons.menu_book,
              () => _launchURL('https://spota.com/guide'),
            ),
            const Divider(),
            _buildLinkItem(
              'Blog',
              'Découvrez nos articles et actualités',
              Icons.article,
              () => _launchURL('https://spota.com/blog'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: SpotaTheme.primaryColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: SpotaTheme.primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: SpotaTheme.secondaryTextColor,
      ),
      onTap: onTap,
    );
  }
}
