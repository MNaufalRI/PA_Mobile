import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import 'auth_gate.dart';

/// Splash screen beranimasi. Ganti file assets/logo.png dengan logomu
/// (disarankan PNG transparan, warna putih, 512x512).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );
  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(_textFade);

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      Navigator.pushReplacement(context, fadeRoute(const AuthGate()));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => const Icon(
                        Icons.checkroom,
                        size: 96,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: const Column(
                    children: [
                      Text(
                        'CLUBWEAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Menswear, simplified.',
                        style: TextStyle(
                          color: Color(0xFF9A9A94),
                          fontSize: 13,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Progress bar tipis mengikuti animasi controller.
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 120,
                    height: 3,
                    child: LinearProgressIndicator(
                      value: _c.value,
                      backgroundColor: Colors.white12,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
