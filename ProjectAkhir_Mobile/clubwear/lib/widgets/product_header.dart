import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/product.dart';
import 'common.dart';

/// Header gambar detail produk.
///
/// Gambar tampil memenuhi kotak (cover). Ketuk gambar untuk membuka
/// tampilan layar penuh yang bisa di-scroll ke bawah (lihat seluruh foto).
class ProductHeader extends StatelessWidget {
  const ProductHeader({
    super.key,
    required this.product,
    required this.heroTag,
    required this.height,
    required this.topPadding,
    required this.onBack,
    required this.onCart,
  });

  final Product product;
  final String heroTag;
  final double height;
  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFF0EEEA)),
          Hero(tag: heroTag, child: _TapImage(product: product)),
          // Lengkungan sheet di bawah gambar.
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: 24,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(26)),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 14,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RoundIconButton(icon: Icons.arrow_back, onTap: onBack),
                Row(
                  children: [
                    WishlistButton(productId: product.id),
                    const SizedBox(width: 10),
                    CartIconButton(onTap: onCart),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gambar header: ketuk -> buka viewer layar penuh yang bisa di-scroll.
class _TapImage extends StatelessWidget {
  const _TapImage({required this.product});
  final Product product;

  void _open(BuildContext context) {
    if (product.imageUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ProductImageViewer(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProductImage(product: product, iconSize: 96),
          if (product.imageUrl.isNotEmpty)
            Positioned(
              right: 14,
              bottom: 38,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.open_in_full,
                    size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// Layar penuh: foto ditampilkan selebar layar, bisa di-scroll ke bawah
/// untuk melihat seluruh pakaian.
class ProductImageViewer extends StatelessWidget {
  const ProductImageViewer({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0EEEA),
        title: Text(product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Image.network(
          product.imageUrl,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          errorBuilder: (context, e, s) => SizedBox(
            height: 400,
            width: double.infinity,
            child: ProductImage(product: product, iconSize: 96),
          ),
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                ),
        ),
      ),
    );
  }
}
