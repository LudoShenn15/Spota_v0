import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_lib/services/api_service.dart';
import 'package:shared_lib/models/user.dart' as shared;
import 'package:supabase_flutter/supabase_flutter.dart';


// Provider pour le client Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider pour l'ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ApiService(supabaseClient);
});

// Provider pour l'état d'authentification
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

// Provider pour l'utilisateur actuel
final currentUserProvider = FutureProvider<shared.User?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getCurrentUser();
});
