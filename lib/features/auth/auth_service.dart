import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_env.dart';

class AuthConfigException implements Exception {
  const AuthConfigException();

  @override
  String toString() {
    return 'Supabase is not configured. Start Flutter with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY dart defines.';
  }
}

class AuthService {
  AuthService();

  SupabaseClient get _client {
    if (!AppEnv.hasSupabaseConfig) {
      throw const AuthConfigException();
    }
    return Supabase.instance.client;
  }

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? phone,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
