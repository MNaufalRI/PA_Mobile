import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/seed_products.dart';
import '../models/product.dart';

/// Sumber data produk. Firestore (realtime, snapshots) bila tersedia,
/// jika kosong/gagal otomatis memakai data lokal agar UI tidak kosong.
class ProductProvider extends ChangeNotifier {
  ProductProvider({required this.useFirebase});

  final bool useFirebase;
  List<Product> _products = [];
  bool _loading = true;
  bool _usingLocalData = true;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  /// Qty terjual selama sesi untuk data lokal (agar stok tetap berkurang
  /// walau data di-reload dari seed).
  final Map<String, int> _localSold = {};

  List<Product> get products => _products;
  bool get loading => _loading;
  bool get usingLocalData => _usingLocalData;

  List<String> get categories {
    final set = <String>{};
    for (final p in _products) {
      set.add(p.category);
    }
    return ['Semua', ...set];
  }

  Product? byId(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Dipanggil setelah user login (rules Firestore butuh auth).
  void start() {
    _sub?.cancel();
    _sub = null;
    if (!useFirebase) {
      _useSeed();
      return;
    }
    _loading = true;
    notifyListeners();
    _sub = FirebaseFirestore.instance
        .collection('products')
        .orderBy('name')
        .snapshots()
        .listen((snap) {
      if (snap.docs.isEmpty) {
        _useSeed();
        return;
      }
      _products = snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
      _usingLocalData = false;
      _loading = false;
      notifyListeners();
    }, onError: (Object e) {
      debugPrint('Firestore error: $e');
      _useSeed();
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  List<Product> _withLocalSales(List<Product> base) => base.map((p) {
        final q = _localSold[p.id];
        if (q == null) return p;
        final left = p.stock - q;
        return p.copyWith(stock: left < 0 ? 0 : left, sold: p.sold + q);
      }).toList();

  /// Dipanggil setelah checkout berhasil: kurangi stok (langsung di UI) dan,
  /// bila Firestore aktif, sinkronkan ke database.
  Future<void> applyPurchase(Map<String, int> qty) async {
    if (qty.isEmpty) return;
    _products = _products.map((p) {
      final q = qty[p.id];
      if (q == null) return p;
      final left = p.stock - q;
      return p.copyWith(stock: left < 0 ? 0 : left, sold: p.sold + q);
    }).toList();
    if (_usingLocalData) {
      qty.forEach((id, q) => _localSold[id] = (_localSold[id] ?? 0) + q);
    }
    notifyListeners();

    if (!useFirebase || _usingLocalData) return;
    try {
      final col = FirebaseFirestore.instance.collection('products');
      final batch = FirebaseFirestore.instance.batch();
      qty.forEach((id, q) {
        batch.update(col.doc(id), {
          'stock': FieldValue.increment(-q),
          'sold': FieldValue.increment(q),
        });
      });
      await batch.commit();
    } catch (e) {
      debugPrint('Gagal memperbarui stok di Firestore: $e');
    }
  }

  void _useSeed() {
    _products = _withLocalSales(seedProducts);
    _usingLocalData = true;
    _loading = false;
    notifyListeners();
  }

  /// Upload data awal ke Firestore (rules harus mengizinkan write sementara).
  Future<String> seedToFirestore() async {
    if (!useFirebase) return 'Firebase belum dikonfigurasi.';
    try {
      final col = FirebaseFirestore.instance.collection('products');
      final batch = FirebaseFirestore.instance.batch();
      for (final p in seedProducts) {
        batch.set(col.doc(p.id), p.toMap());
      }
      await batch.commit();
      return 'Berhasil mengunggah ${seedProducts.length} produk.';
    } on FirebaseException catch (e) {
      return 'Gagal (${e.code}). Izinkan write sementara di rules Firestore.';
    } catch (e) {
      return 'Gagal: $e';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
