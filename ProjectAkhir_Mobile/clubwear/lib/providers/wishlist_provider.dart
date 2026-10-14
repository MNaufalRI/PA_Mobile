import 'package:flutter/foundation.dart';

/// Daftar produk favorit.
class WishlistProvider extends ChangeNotifier {
  final Set<String> _ids = {};

  Set<String> get ids => _ids;
  int get count => _ids.length;
  bool has(String id) => _ids.contains(id);

  void toggle(String id) {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
  }

  void clear() {
    _ids.clear();
    notifyListeners();
  }
}
