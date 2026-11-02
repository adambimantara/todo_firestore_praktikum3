import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService._internal();

  // Stream of auth state changes (used by main.dart and routing)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current logged in user
  User? get currentUser => _auth.currentUser;

  // Sign In with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat masuk: $e';
    }
  }

  // Sign Up with email, password, and update displayName
  Future<UserCredential> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update user display name
      if (credential.user != null && displayName.trim().isNotEmpty) {
        await credential.user!.updateDisplayName(displayName.trim());
        await credential.user!.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat pendaftaran: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Gagal keluar dari akun: $e';
    }
  }

  // Helper to translate FirebaseAuthException codes into friendly Indonesian messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'configuration-not-found':
        return 'Firebase Authentication belum diaktifkan. Buka Firebase Console > Authentication > klik "Get Started" dan aktifkan "Email/Password".';
      case 'operation-not-allowed':
        return 'Metode Email/Password belum diaktifkan di Firebase Console (Authentication > Sign-in method).';
      case 'user-not-found':
        return 'Akun dengan email tersebut belum terdaftar.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau langsung masuk.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet atau permintaan diblokir. Periksa koneksi Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan tunggu beberapa saat.';
      case 'user-disabled':
        return 'Akun pengguna ini telah dinonaktifkan.';
      default:
        final msg = e.message != null && e.message!.isNotEmpty ? e.message! : 'Terjadi kesalahan autentikasi';
        return '$msg (${e.code})';
    }
  }
}
