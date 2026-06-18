import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_env.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthConfigException implements Exception {
  const AuthConfigException();

  @override
  String toString() {
    return 'Mock Auth Configuration Exception';
  }
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String? upiId;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.upiId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      upiId: json['upi_id'] as String?,
    );
  }
}

class AuthService {
  AppUser? _currentUser;
  String? _jwtToken;
  String? _sessionCookie;

  AppUser? get currentUser => _currentUser;
  String? get jwtToken => _jwtToken;

  AuthService() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString('jwt_token');
    _sessionCookie = prefs.getString('session_cookie');
    final userStr = prefs.getString('current_user');
    if (userStr != null) {
      _currentUser = AppUser.fromJson(jsonDecode(userStr));
    }
  }

  Future<void> _saveSession(AppUser user, String jwtToken, String? sessionCookie) async {
    _currentUser = user;
    _jwtToken = jwtToken;
    _sessionCookie = sessionCookie;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', jwtToken);
    if (sessionCookie != null) {
      await prefs.setString('session_cookie', sessionCookie);
    }
    await prefs.setString('current_user', jsonEncode({
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'avatar': user.avatar,
      'upi_id': user.upiId,
    }));
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppEnv.neonAuthBaseUrl}/sign-in/email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final errData = jsonDecode(response.body);
      throw AuthException(errData['message'] ?? 'Invalid email or password.');
    }

    // Capture cookie
    final cookie = response.headers['set-cookie'];
    
    // Fetch JWT Token
    final tokenUrl = Uri.parse('${AppEnv.neonAuthBaseUrl}/token');
    final tokenResponse = await http.get(
      tokenUrl,
      headers: {
        if (cookie != null) 'cookie': cookie,
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw const AuthException('Failed to retrieve authentication token.');
    }

    final tokenData = jsonDecode(tokenResponse.body);
    final jwt = tokenData['token'] as String;

    // Fetch/create profile from backend using JWT
    final profileUrl = Uri.parse('${AppEnv.apiBaseUrl}/profile');
    final profileResponse = await http.get(
      profileUrl,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (profileResponse.statusCode != 200) {
      throw const AuthException('Failed to retrieve user profile.');
    }

    final profileData = jsonDecode(profileResponse.body);
    final user = AppUser.fromJson(profileData);

    await _saveSession(user, jwt, cookie);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final url = Uri.parse('${AppEnv.neonAuthBaseUrl}/sign-up/email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode != 200) {
      final errData = jsonDecode(response.body);
      throw AuthException(errData['message'] ?? 'Sign up failed.');
    }

    // Capture cookie
    final cookie = response.headers['set-cookie'];

    // Fetch JWT Token
    final tokenUrl = Uri.parse('${AppEnv.neonAuthBaseUrl}/token');
    final tokenResponse = await http.get(
      tokenUrl,
      headers: {
        if (cookie != null) 'cookie': cookie,
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw const AuthException('Failed to retrieve authentication token.');
    }

    final tokenData = jsonDecode(tokenResponse.body);
    final jwt = tokenData['token'] as String;

    // Complete/Create profile on backend using JWT
    final profileUrl = Uri.parse('${AppEnv.apiBaseUrl}/profile');
    final profileResponse = await http.post(
      profileUrl,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'avatar': '👨‍💻',
      }),
    );

    if (profileResponse.statusCode != 200) {
      throw const AuthException('Failed to initialize user profile.');
    }

    final profileData = jsonDecode(profileResponse.body);
    final user = AppUser.fromJson(profileData);

    await _saveSession(user, jwt, cookie);
  }

  Future<void> signInWithGoogle() async {
    final stateId = '${DateTime.now().millisecondsSinceEpoch}_${(100 + (DateTime.now().microsecondsSinceEpoch % 900))}';
    final startUrl = Uri.parse('${AppEnv.apiBaseUrl}/auth/google-start?stateId=$stateId');
    
    try {
      await launchUrl(
        startUrl,
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (e) {
      throw AuthException('Could not launch Google sign-in: ${e.toString()}');
    }
    
    // Poll the backend until the login is completed or times out (2 minutes)
    final pollUrl = Uri.parse('${AppEnv.apiBaseUrl}/auth/poll/$stateId');
    bool isAuthenticated = false;
    int attempts = 0;
    
    while (!isAuthenticated && attempts < 60) {
      await Future.delayed(const Duration(seconds: 2));
      attempts++;
      
      try {
        final pollResponse = await http.get(pollUrl);
        if (pollResponse.statusCode == 200) {
          final pollData = jsonDecode(pollResponse.body);
          if (pollData['status'] == 'success') {
            final jwt = pollData['jwt'] as String;
            final user = AppUser.fromJson(pollData['user']);
            
            await _saveSession(user, jwt, null);
            isAuthenticated = true;
            
            // Try to close the Custom Tab popup view
            await closeInAppWebView();
          }
        }
      } catch (e) {
        print('Polling error: $e');
      }
    }
    
    if (!isAuthenticated) {
      throw const AuthException('Sign-in timed out. Please try again.');
    }
  }

  Future<void> completeProfileSetup({
    required String name,
    required String upiId,
    required String avatar,
  }) async {
    if (_jwtToken == null) throw const AuthException('Not authenticated');

    final url = Uri.parse('${AppEnv.apiBaseUrl}/profile');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'upi_id': upiId,
        'avatar': avatar,
      }),
    );

    if (response.statusCode != 200) {
      throw const AuthException('Failed to update profile.');
    }

    final profileData = jsonDecode(response.body);
    final user = AppUser.fromJson(profileData);

    await _saveSession(user, _jwtToken!, _sessionCookie);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final url = Uri.parse('${AppEnv.neonAuthBaseUrl}/forget-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw const AuthException('Failed to send password reset email.');
    }
  }

  Future<void> signOut() async {
    final url = Uri.parse('${AppEnv.neonAuthBaseUrl}/sign-out');
    await http.post(
      url,
      headers: {
        if (_sessionCookie != null) 'cookie': _sessionCookie!,
      },
    );

    _currentUser = null;
    _jwtToken = null;
    _sessionCookie = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('session_cookie');
    await prefs.remove('current_user');
  }
}
