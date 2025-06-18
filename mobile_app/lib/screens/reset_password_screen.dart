import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/api_providers.dart';
import '../theme.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Réinitialisation du mot de passe avec l'ApiService
      await apiService.resetPassword(_emailController.text.trim());
      
      if (kDebugMode) {
        print('Email de réinitialisation envoyé');
      }
      
      if (!mounted) return;
      
      setState(() {
        _resetSent = true;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la réinitialisation du mot de passe: $e');
      }
      
      if (!mounted) return;
      
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialiser le mot de passe'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _resetSent ? _buildSuccessContent() : _buildFormContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icône et titre
          const Icon(
            Icons.lock_reset,
            size: 60,
            color: SpotaTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Mot de passe oublié ?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Entrez votre adresse email pour recevoir un lien de réinitialisation',
            style: TextStyle(
              fontSize: 16,
              color: SpotaTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Champ email
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
          const SizedBox(height: 24),
          
          // Bouton de réinitialisation
          ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text('RÉINITIALISER LE MOT DE PASSE'),
          ),
          const SizedBox(height: 24),
          
          // Lien de retour à la connexion
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Vous vous souvenez de votre mot de passe ?',
                style: TextStyle(
                  color: SpotaTheme.secondaryTextColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icône de succès
        const Icon(
          Icons.check_circle,
          size: 80,
          color: SpotaTheme.primaryColor,
        ),
        const SizedBox(height: 24),
        const Text(
          'Email envoyé !',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Un email de réinitialisation a été envoyé à ${_emailController.text}',
          style: const TextStyle(
            fontSize: 16,
            color: SpotaTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.',
          style: TextStyle(
            fontSize: 16,
            color: SpotaTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Bouton de retour à la connexion
        OutlinedButton(
          onPressed: () {
            context.go('/login');
          },
          child: const Text('RETOUR À LA CONNEXION'),
        ),
      ],
    );
  }
}
