import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/product.dart';
import '../pages/product_detail_page.dart';
import '../providers/cart_provider.dart';
import 'common.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.heroPrefix});

  final Product product;
  final String heroPrefix; // beda per tab agar Hero tag tidak bentrok

  @override
  Widget build(BuildContext context) {
    final p = product;
    final soldOut = p.stock <= 0;
    final heroTag = '$heroPrefix-${p.id}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(product: p, heroTag: heroTag),
        ),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: heroTag, child: ProductImage(product: p)),
                  if (soldOut)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.7),
                        alignment: Alignment.center,
                        child: const Text(
                          'HABIS',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (p.discountPercent > 0)
                          _Badge('-${p.discountPercent}%', AppColors.accent),
                        if (p.isNew && p.discountPercent == 0)
                          const _Badge('BARU', AppColors.ink),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: WishlistButton(productId: p.id),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Selector<CartProvider, bool>(
                      selector: (_, cart) => cart.canAdd(p),
                      builder: (context, canAdd, _) {
                        return SizedBox(
                          width: 36,
                          height: 36,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                            ),
                            onPressed: canAdd
                                ? () {
                                    context
                                        .read<CartProvider>()
                                        .add(p, p.defaultSize);
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(SnackBar(
                                        duration:
                                            const Duration(milliseconds: 1400),
                                        content: Text(
                                            'Ditambahkan (ukuran ${p.defaultSize})'),
                                      ));
                                  }
                                : null,
                            child: const Icon(Icons.add, size: 20),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tinggi tetap 2 baris -> semua kartu punya blok teks setara,
                  // sehingga tinggi gambar pun sama di semua kartu.
                  SizedBox(
                    height: 34,
                    child: Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rupiah(p.price),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  // Slot harga coret selalu disediakan (kosong bila tanpa diskon).
                  SizedBox(
                    height: 16,
                    child: (p.originalPrice != null && p.discountPercent > 0)
                        ? Text(
                            rupiah(p.originalPrice!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFE0A526)),
                      const SizedBox(width: 2),
                      Text(
                        '${p.rating.toStringAsFixed(1)}  •  ${p.sold} terjual',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
