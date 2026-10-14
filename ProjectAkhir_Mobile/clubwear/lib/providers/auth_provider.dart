import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:flutter/foundation.dart';

/// Mengelola login/registrasi. Firebase Auth jika sudah dikonfigurasi,
/// jika belum -> mode demo (login lokal) supaya app tetap bisa dicoba.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.useFirebase});

  final bool useFirebase;
  String? _demoEmail;
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;
  String? get email =>
      useFirebase ? FirebaseAuth.instance.currentUser?.email : _demoEmail;
  String? get uid =>
      useFirebase ? FirebaseAuth.instance.currentUser?.uid : _demoEmail;
  bool get isLoggedIn => email != null;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) {
    return _run(() async {
      if (useFirebase) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        _demoEmail = email;
      }
    });
  }

  Future<bool> register(String email, String password) {
    return _run(() async {
      if (useFirebase) {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } else {
        _demoEmail = email;
      }
    });
  }

  Future<void> signOut() async {
    if (useFirebase) {
      await FirebaseAuth.instance.signOut();
    } else {
      _demoEmail = null;
    }
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _message(e.code);
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
    }
    _loading = false;
    notifyListeners();
    return false;
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        return 'Autentikasi gagal ($code).';
    }
  }
}
