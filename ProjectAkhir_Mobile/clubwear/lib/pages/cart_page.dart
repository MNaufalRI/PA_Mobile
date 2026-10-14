import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/common.dart';
import 'checkout_success_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.onShop});

  /// Dipanggil saat keranjang kosong dan user menekan "Mulai Belanja".
  final VoidCallback onShop;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _busy = false; // cegah checkout ganda saat menunggu Firestore

  Future<void> _checkout() async {
    if (_busy) return;
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final store = context.read<ProductProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _busy = true);
    final purchased = cart.quantitiesByProduct;
    final total = await cart.checkout(uid: auth.uid, email: auth.email);
    if (mounted) setState(() => _busy = false);

    if (total == null) {
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Pesanan gagal disimpan. Coba lagi.')));
      return;
    }
    unawaited(store.applyPurchase(purchased)); // stok berkurang
    navigator.push(
      MaterialPageRoute(
        builder: (context) => CheckoutSuccessPage(total: total),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Keranjang')),
      body: Consumer2<CartProvider, ProductProvider>(
        builder: (context, cart, store, child) {
          // Pastikan stok/harga di keranjang selalu data terbaru.
          cart.syncProducts(store.products);
          if (cart.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Keranjangmu masih kosong',
              subtitle: 'Yuk, temukan outfit favoritmu di Clubwear.',
              buttonLabel: 'Mulai Belanja',
              onPressed: widget.onShop,
            );
          }
          final items = cart.items;
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: items.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return CartItemCard(
                      key: ValueKey(item.key),
                      item: item,
                      maxQuantity: cart.maxFor(item),
                      onQuantityChanged: (q) =>
                          context.read<CartProvider>().setQuantity(item.key, q),
                      onRemove: () =>
                          context.read<CartProvider>().remove(item.key),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total (${cart.itemCount} barang)',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                          Text(rupiah(cart.grandTotal),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              cart.grandTotal > 0 && !_busy ? _checkout : null,
                          icon: _busy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.lock_outline, size: 18),
                          label: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
