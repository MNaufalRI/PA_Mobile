import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Favorit')),
      body: Consumer2<ProductProvider, WishlistProvider>(
        builder: (context, store, wish, child) {
          final liked =
              store.products.where((p) => wish.has(p.id)).toList();
          if (liked.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'Belum ada favorit',
              subtitle: 'Ketuk ikon hati pada produk untuk menyimpannya di sini.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            itemCount: liked.length,
            itemBuilder: (context, i) =>
                ProductCard(product: liked[i], heroPrefix: 'fav'),
          );
        },
      ),
    );
  }
}
