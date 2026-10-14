/// Model produk. Disimpan di Firestore pada koleksi `products`.
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final int price;
  final int? originalPrice; // harga coret (jika diskon)
  final String imageUrl; // kosong = pakai placeholder bergradasi
  final int colorValue; // warna dasar placeholder
  final int stock;
  final List<String> sizes;
  final double rating;
  final int sold;
  final bool isNew;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.originalPrice,
    this.imageUrl = '',
    this.colorValue = 0xFF444444,
    this.stock = 0,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.rating = 4.5,
    this.sold = 0,
    this.isNew = false,
  });

  /// Ukuran bawaan bila user belum memilih (aman jika `sizes` kosong).
  String get defaultSize => sizes.isNotEmpty ? sizes.first : 'All Size';

  Product copyWith({int? stock, int? sold}) => Product(
        id: id,
        name: name,
        description: description,
        category: category,
        price: price,
        originalPrice: originalPrice,
        imageUrl: imageUrl,
        colorValue: colorValue,
        stock: stock ?? this.stock,
        sizes: sizes,
        rating: rating,
        sold: sold ?? this.sold,
        isNew: isNew,
      );

  int get discountPercent {
    final o = originalPrice;
    if (o == null || o <= price) return 0;
    return (((o - price) / o) * 100).round();
  }

  factory Product.fromMap(String id, Map<String, dynamic> m) {
    return Product(
      id: id,
      name: (m['name'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      category: (m['category'] ?? 'Lainnya') as String,
      price: (m['price'] as num?)?.toInt() ?? 0,
      originalPrice: (m['originalPrice'] as num?)?.toInt(),
      imageUrl: (m['imageUrl'] ?? '') as String,
      colorValue: (m['colorValue'] as num?)?.toInt() ?? 0xFF444444,
      stock: (m['stock'] as num?)?.toInt() ?? 0,
      sizes: (m['sizes'] as List?)?.map((e) => '$e').toList() ??
          const ['S', 'M', 'L', 'XL'],
      rating: (m['rating'] as num?)?.toDouble() ?? 4.5,
      sold: (m['sold'] as num?)?.toInt() ?? 0,
      isNew: (m['isNew'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'originalPrice': originalPrice,
        'imageUrl': imageUrl,
        'colorValue': colorValue,
        'stock': stock,
        'sizes': sizes,
        'rating': rating,
        'sold': sold,
        'isNew': isNew,
      };
}
