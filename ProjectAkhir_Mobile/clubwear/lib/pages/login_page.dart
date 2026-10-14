import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  bool hidePassword = true;
  String? localError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final auth = context.read<AuthProvider>();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => localError = 'Masukkan email yang valid.');
      return;
    }
    if (password.length < 6) {
      setState(() => localError = 'Password minimal 6 karakter.');
      return;
    }
    setState(() => localError = null);

    if (isLogin) {
      await auth.signIn(email, password);
    } else {
      await auth.register(email, password);
    }
  }

  InputDecoration _field(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(icon, size: 20, color: AppColors.muted),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.ink, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final error = localError ?? auth.error;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.checkroom,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isLogin ? 'Selamat datang\nkembali.' : 'Buat akun\nbaru.',
                      key: ValueKey(isLogin),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin
                        ? 'Masuk untuk melanjutkan belanja di Clubwear.'
                        : 'Daftar dan temukan outfit favoritmu.',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _field('Email', Icons.mail_outline),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    onSubmitted: (_) => submit(),
                    decoration: _field(
                      'Password',
                      Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.muted,
                        ),
                        onPressed: () =>
                            setState(() => hidePassword = !hidePassword),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: error == null
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 16, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(error,
                                      style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.loading ? null : submit,
                      child: auth.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isLogin ? 'Masuk' : 'Daftar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().clearError();
                        setState(() {
                          isLogin = !isLogin;
                          localError = null;
                        });
                      },
                      child: Text(
                        isLogin
                            ? 'Belum punya akun? Daftar'
                            : 'Sudah punya akun? Masuk',
                        style: const TextStyle(color: AppColors.ink),
                      ),
                    ),
                  ),
                  if (!auth.useFirebase) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: AppColors.muted),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Mode demo: Firebase belum dikonfigurasi. Masuk dengan email apa saja (password min. 6 karakter).',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
