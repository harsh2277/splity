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

class MockUser {
  final String id;
  final String email;
  final String? phone;

  const MockUser({
    required this.id,
    required this.email,
    this.phone,
  });
}

class AuthService {
  AuthService();

  MockUser? _currentUser;

  MockUser? get currentUser => _currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (email == 'error@example.com') {
      throw const AuthException('Invalid email or password.');
    }

    _currentUser = MockUser(
      id: 'mock-user-id-123',
      email: email,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? phone,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (email == 'exists@example.com') {
      throw const AuthException('An account with this email already exists.');
    }

    _currentUser = MockUser(
      id: 'mock-user-id-123',
      email: email,
      phone: phone,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}
