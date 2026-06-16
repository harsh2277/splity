import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import 'package:dio/dio.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, Map<String, dynamic>? user, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api = ApiService();

  AuthNotifier() : super(const AuthState());

  Future<void> checkSession() async {
    final token = await _api.getToken();
    if (token == null) {
      state = state.copyWith(isAuthenticated: false);
      return;
    }
    try {
      final res = await _api.dio.get('/auth/me');
      state = state.copyWith(isAuthenticated: true, user: res.data['user']);
    } catch (_) {
      await _api.clearToken();
      state = state.copyWith(isAuthenticated: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.dio.post('/auth/login', data: {'email': email, 'password': password});
      await _api.saveToken(res.data['token']);
      state = state.copyWith(isAuthenticated: true, isLoading: false, user: res.data['user']);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Login failed';
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, {String? phone, String? upiId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (upiId != null) 'upi_id': upiId,
      });
      await _api.saveToken(res.data['token']);
      state = state.copyWith(isAuthenticated: true, isLoading: false, user: res.data['user']);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Registration failed';
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
