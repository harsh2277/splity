import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final String? phone;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.upiId,
    this.phone,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      upiId: json['upi_id'] as String?,
      phone: json['phone'] as String?,
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
      'phone': user.phone,
    }));
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppEnv.neonAuthBaseUrl}/sign-in/email');
    print('AuthService: Requesting POST $url');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Origin': 'http://localhost:4000',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('AuthService: Response Status: ${response.statusCode}');
    print('AuthService: Response Body: ${response.body}');

    if (response.statusCode != 200) {
      Map<String, dynamic>? errData;
      try {
        errData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}
      final msg = errData != null ? (errData['message'] ?? errData['error']) : null;
      throw AuthException(msg ?? 'Invalid email or password. Status: ${response.statusCode}');
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
    String? phone,
  }) async {
    final url = Uri.parse('${AppEnv.neonAuthBaseUrl}/sign-up/email');
    print('AuthService: Requesting POST $url');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Origin': 'http://localhost:4000',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    print('AuthService: Response Status: ${response.statusCode}');
    print('AuthService: Response Body: ${response.body}');

    if (response.statusCode != 200) {
      Map<String, dynamic>? errData;
      try {
        errData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}
      final msg = errData != null ? (errData['message'] ?? errData['error']) : null;
      throw AuthException(msg ?? 'Sign up failed. Status: ${response.statusCode}');
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
        'phone': phone,
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
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '864815036763-ab1ls1v4jru9du4pqgbj7h5sk4pvujl6.apps.googleusercontent.com',
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw const AuthException('Google sign-in cancelled.');
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Failed to retrieve Google identity token.');
      }

      final url = Uri.parse('${AppEnv.apiBaseUrl}/auth/google-native');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode != 200) {
        final errData = jsonDecode(response.body);
        throw AuthException(errData['error'] ?? 'Google native authentication failed.');
      }

      final resData = jsonDecode(response.body);
      final jwt = resData['jwt'] as String;
      final user = AppUser.fromJson(resData['user']);

      await _saveSession(user, jwt, null);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google sign-in failed: ${e.toString()}');
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
