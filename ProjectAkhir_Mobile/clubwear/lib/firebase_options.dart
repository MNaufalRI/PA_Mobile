// FILE PLACEHOLDER.
// Jalankan perintah berikut agar file ini otomatis ditimpa konfigurasi asli:
//   flutterfire configure --project=<PROJECT_ID> --platforms=android,web
// Selama apiKey masih 'PLACEHOLDER', aplikasi berjalan di MODE DEMO
// (data lokal + login lokal) sehingga tetap bisa dicoba tanpa Firebase.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'PLACEHOLDER',
        appId: 'PLACEHOLDER',
        messagingSenderId: 'PLACEHOLDER',
        projectId: 'PLACEHOLDER',
      );
}
