import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase hanya diaktifkan jika sudah dikonfigurasi (flutterfire configure).
  // Jika belum, aplikasi berjalan di mode demo (data & login lokal).
  var firebaseReady = false;
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey != 'PLACEHOLDER') {
      await Firebase.initializeApp(options: options);
      firebaseReady = true;
    }
  } catch (e) {
    debugPrint('Firebase tidak aktif, memakai mode demo: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(useFirebase: firebaseReady)),
        ChangeNotifierProvider(
            create: (_) => ProductProvider(useFirebase: firebaseReady)),
        ChangeNotifierProvider(
            create: (_) => CartProvider(useFirebase: firebaseReady)),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clubwear',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashPage(),
    );
  }
}
