import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  Product product; // diperbarui bila stok/harga berubah di ProductProvider
  final String size;
  int quantity;
  CartItem({required this.product, required this.size, this.quantity = 1});

  String get key => '${product.id}|$size';
  int get subtotal => product.price * quantity;
}

/// State keranjang yang dipakai bersama oleh banyak halaman.
class CartProvider extends ChangeNotifier {
  CartProvider({required this.useFirebase});

  final bool useFirebase;
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.values.fold(0, (t, i) => t + i.quantity);
  int get grandTotal => _items.values.fold(0, (t, i) => t + i.subtotal);

  /// Total qty satu produk (semua ukuran) di keranjang.
  int quantityOf(String productId) => _items.values
      .where((i) => i.product.id == productId)
      .fold(0, (t, i) => t + i.quantity);

  bool canAdd(Product p) => p.stock > 0 && quantityOf(p.id) < p.stock;

  /// Sisa stok yang masih bisa dibeli = stok - yang sudah ada di keranjang.
  int availableOf(Product p) {
    final left = p.stock - quantityOf(p.id);
    return left < 0 ? 0 : left;
  }

  /// {productId: total qty} (semua ukuran digabung), dipakai untuk potong stok.
  Map<String, int> get quantitiesByProduct {
    final m = <String, int>{};
    for (final i in _items.values) {
      m[i.product.id] = (m[i.product.id] ?? 0) + i.quantity;
    }
    return m;
  }

  /// Samakan data produk di keranjang dengan data terbaru (tanpa notify,
  /// aman dipanggil dari build).
  void syncProducts(List<Product> latest) {
    final byId = {for (final p in latest) p.id: p};
    for (final item in _items.values) {
      final fresh = byId[item.product.id];
      if (fresh != null) item.product = fresh;
    }
  }

  /// Batas qty untuk item tertentu = stok - qty item lain pada produk sama.
  int maxFor(CartItem item) =>
      item.product.stock - (quantityOf(item.product.id) - item.quantity);

  void add(Product p, String size, {int qty = 1}) {
    if (!canAdd(p)) return;
    final key = '${p.id}|$size';
    final existing = _items[key];
    if (existing != null) {
      existing.quantity += qty;
    } else {
      _items[key] = CartItem(product: p, size: size, quantity: qty);
    }
    notifyListeners();
  }

  void setQuantity(String key, int qty) {
    final item = _items[key];
    if (item == null) return;
    final max = maxFor(item);
    item.quantity = qty.clamp(1, max < 1 ? 1 : max).toInt();
    notifyListeners();
  }

  void remove(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Simpan pesanan ke Firestore (jika aktif), lalu kosongkan keranjang.
  /// Mengembalikan total yang dibayar, atau null bila gagal menyimpan
  /// (keranjang TIDAK dikosongkan agar pesanan tidak hilang).
  Future<int?> checkout({String? uid, String? email}) async {
    if (_items.isEmpty) return null;
    final total = grandTotal;
    if (useFirebase) {
      try {
        await FirebaseFirestore.instance.collection('orders').add({
          'uid': uid,
          'email': email,
          'total': total,
          'createdAt': FieldValue.serverTimestamp(),
          'items': _items.values
              .map((i) => {
                    'productId': i.product.id,
                    'name': i.product.name,
                    'size': i.size,
                    'qty': i.quantity,
                    'price': i.product.price,
                  })
              .toList(),
        });
      } catch (e) {
        debugPrint('Gagal menyimpan pesanan: $e');
        return null;
      }
    }
    _items.clear();
    notifyListeners();
    return total;
  }
}
