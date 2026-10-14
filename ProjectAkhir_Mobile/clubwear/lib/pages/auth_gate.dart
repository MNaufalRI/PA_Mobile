import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'app_shell.dart';
import 'login_page.dart';

/// Pemantau status login: sudah login -> AppShell, belum -> LoginPage.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    if (auth.useFirebase) {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.hasData ? const AppShell() : const LoginPage();
        },
      );
    }

    // Mode demo: dengarkan AuthProvider.
    return Consumer<AuthProvider>(
      builder: (context, a, _) => a.isLoggedIn ? const AppShell() : const LoginPage(),
    );
  }
}
