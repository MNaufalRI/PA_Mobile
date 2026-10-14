# Clubwear — Toko Pakaian Pria (Flutter)

Minimalist e-commerce menswear. State management: **Provider**. Database/Auth: **Firebase** (opsional, ada mode demo).

## Menjalankan
```
flutter pub get
flutter run
```
Tanpa konfigurasi Firebase, app jalan di **mode demo** (data lokal + login lokal, email apa saja & password min. 6 karakter).

## Mengaktifkan Firebase
1. Buat project di Firebase Console, aktifkan **Authentication → Email/Password** dan **Firestore** (production mode).
2. `flutterfire configure --project=<PROJECT_ID> --platforms=android,web` (menimpa `lib/firebase_options.dart`).
3. Rules Firestore:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if false;   // ubah ke true SEMENTARA saat upload data awal
    }
    match /orders/{orderId} {
      allow create: if request.auth != null && request.resource.data.uid == request.auth.uid;
      allow read: if request.auth != null && resource.data.uid == request.auth.uid;
    }
  }
}
```
4. Login, buka tab Profil → **Upload data awal ke Firestore** (24 produk). Setelah itu kembalikan `write` ke `false`.

Field dokumen `products`: name, description, category, price, originalPrice, imageUrl, colorValue, stock, sizes[], rating, sold, isNew.

## Struktur
```
lib/
  main.dart                 MultiProvider + init Firebase
  core/                     theme, util (rupiah, transisi)
  models/product.dart
  data/seed_products.dart   data lokal / bahan seeding
  providers/                auth, product (Firestore snapshots), cart, wishlist
  pages/                    splash, auth_gate, login, app_shell, home, detail, cart, checkout_success, wishlist, profile
  widgets/                  product_card, cart_item_card, common
```
