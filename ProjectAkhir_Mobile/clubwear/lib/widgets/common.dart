import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

IconData categoryIcon(String c) {
  switch (c) {
    case 'Kaos':
      return Icons.checkroom;
    case 'Kemeja':
      return Icons.dry_cleaning;
    case 'Celana':
      return Icons.straighten;
    case 'Jaket':
      return Icons.layers;
    case 'Hoodie':
    case 'Sweater':
      return Icons.ac_unit;
    case 'Sepatu':
      return Icons.directions_walk;
    case 'Aksesoris':
      return Icons.watch;
    default:
      return Icons.local_mall;
  }
}

/// Gambar produk: network bila ada URL, jika tidak -> placeholder bergradasi.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.iconSize = 48,
  });

  final Product product;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final base = Color(product.colorValue);
    final placeholder = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, Color.lerp(base, Colors.black, 0.28)!],
        ),
      ),
      child: Center(
        child: Icon(
          categoryIcon(product.category),
          size: iconSize,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
    if (product.imageUrl.isEmpty) return placeholder;
    return Image.network(
      product.imageUrl,
      fit: fit,
      errorBuilder: (context, error, stack) => placeholder,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Ikon keranjang + badge jumlah. Selector -> hanya rebuild saat jumlah berubah.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RoundIconButton(icon: Icons.shopping_bag_outlined, onTap: onTap),
        Positioned(
          right: -2,
          top: -2,
          child: Selector<CartProvider, int>(
            selector: (_, cart) => cart.itemCount,
            builder: (context, count, _) {
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class WishlistButton extends StatelessWidget {
  const WishlistButton({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context) {
    return Selector<WishlistProvider, bool>(
      selector: (_, w) => w.has(productId),
      builder: (context, liked, _) {
        return Material(
          color: Colors.white.withValues(alpha: 0.92),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.read<WishlistProvider>().toggle(productId),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(liked),
                  size: 18,
                  color: liked ? AppColors.accent : AppColors.ink,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
              child: Icon(icon, size: 38, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.4)),
            if (buttonLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onPressed, child: Text(buttonLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
