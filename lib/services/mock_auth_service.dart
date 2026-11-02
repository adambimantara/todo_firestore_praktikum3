import 'dart:async';

class MockUser {
  final String uid;
  final String displayName;
  final String email;

  MockUser({
    required this.uid,
    required this.displayName,
    required this.email,
  });
}

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;

  final StreamController<MockUser?> _authStateController =
      StreamController<MockUser?>.broadcast();

  MockUser? _currentUser;

  MockAuthService._internal() {
    // Default logged in user for frontend testing
    _currentUser = MockUser(
      uid: 'user_dummy_123',
      displayName: 'Mahasiswa Praktikum',
      email: 'mahasiswa@example.com',
    );
  }

  MockUser? get currentUser => _currentUser;

  Stream<MockUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }

  Future<void> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network

    if (email.trim().isEmpty || password.isEmpty) {
      throw 'Email dan password tidak boleh kosong.';
    }

    // Set signed in user
    final name = email.split('@').first;
    _currentUser = MockUser(
      uid: 'user_${email.hashCode}',
      displayName: name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : 'Pengguna',
      email: email.trim(),
    );
    _authStateController.add(_currentUser);
  }

  Future<void> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network

    if (displayName.trim().isEmpty) {
      throw 'Nama pengguna tidak boleh kosong.';
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      throw 'Format email tidak valid.';
    }
    if (password.length < 6) {
      throw 'Password minimal 6 karakter.';
    }

    _currentUser = MockUser(
      uid: 'user_${email.hashCode}',
      displayName: displayName.trim(),
      email: email.trim(),
    );
    _authStateController.add(_currentUser);
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authStateController.add(null);
  }
}
