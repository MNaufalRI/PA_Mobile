import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_header.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product, required this.heroTag});

  final Product product;
  final String heroTag;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late String selectedSize = widget.product.defaultSize;

  void _openCart() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          onShop: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ),
    );
  }

  void _addToCart(Product p) {
    final cart = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context);
    cart.add(p, selectedSize);
    // Tanpa SnackBarAction: snackbar ber-action di Flutter terbaru "persist"
    // (tidak auto-hilang). Tombol LIHAT dibuat manual agar pasti berfungsi.
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1800),
        padding: const EdgeInsets.fromLTRB(18, 4, 6, 4),
        content: Row(
          children: [
            Expanded(child: Text('Ukuran $selectedSize masuk keranjang')),
            TextButton(
              onPressed: () {
                messenger.removeCurrentSnackBar();
                _openCart();
              },
              child: const Text('LIHAT',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data produk TERBARU (stok bisa berubah setelah checkout/realtime).
    final p = context.select<ProductProvider, Product>(
        (s) => s.byId(widget.product.id) ?? widget.product);
    final topPad = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProductHeader(
              product: p,
              heroTag: widget.heroTag,
              height: 400,
              topPadding: topPad,
              onBack: () => Navigator.pop(context),
              onCart: _openCart,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: AppColors.bg,
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Text(p.category.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(p.name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 18, color: Color(0xFFE0A526)),
                const SizedBox(width: 4),
                Text(
                    '${p.rating.toStringAsFixed(1)}  •  ${p.sold} terjual',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(rupiah(p.price),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                if (p.discountPercent > 0) ...[
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(rupiah(p.originalPrice!),
                        style: const TextStyle(
                            color: AppColors.muted,
                            decoration:
                                TextDecoration.lineThrough)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('-${p.discountPercent}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            const Text('Pilih Ukuran',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: p.sizes.map((s) {
                final sel = s == selectedSize;
                return GestureDetector(
                  onTap: () => setState(() => selectedSize = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints:
                        const BoxConstraints(minWidth: 52),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.ink : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel
                              ? AppColors.ink
                              : AppColors.line),
                    ),
                    child: Text(s,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: sel
                                ? Colors.white
                                : AppColors.ink)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                final left = cart.availableOf(p);
                final inCart = cart.quantityOf(p.id);
                final label = p.stock <= 0
                    ? 'Stok habis'
                    : (left <= 0
                        ? 'Semua stok sudah ada di keranjangmu'
                        : 'Stok tersisa $left');
                return Text(
                  inCart > 0 && left > 0 ? '$label  •  $inCart di keranjang' : label,
                  style: TextStyle(
                      fontSize: 12,
                      color: left <= 10 ? AppColors.accent : AppColors.muted),
                );
              },
            ),
            const SizedBox(height: 22),
            const Text('Deskripsi',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(p.description,
                style: const TextStyle(
                    height: 1.55, color: Color(0xFF4A4A47))),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: const Column(
                children: [
                  _InfoRow(Icons.local_shipping_outlined,
                      'Gratis ongkir untuk pembelian min. Rp300.000'),
                  SizedBox(height: 10),
                  _InfoRow(Icons.autorenew,
                      'Tukar ukuran gratis dalam 7 hari'),
                ],
              ),
            ),
            const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom bar di slot Scaffold -> snackbar floating muncul DI ATASNYA,
      // tidak menutupi tombol.
      bottomNavigationBar: Container(
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
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Harga',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.muted)),
                    Text(rupiah(p.price),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      final canAdd = cart.canAdd(p);
                      return ElevatedButton.icon(
                        onPressed: canAdd ? () => _addToCart(p) : null,
                        icon: const Icon(Icons.shopping_bag_outlined,
                            size: 18),
                        label: Text(p.stock <= 0
                            ? 'Stok Habis'
                            : (canAdd
                                ? 'Tambah ke Keranjang'
                                : 'Maksimal di Keranjang')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.ink),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12.5, height: 1.3))),
      ],
    );
  }
}
