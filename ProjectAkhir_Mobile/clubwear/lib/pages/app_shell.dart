import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'cart_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'wishlist_page.dart';

/// Kerangka utama: IndexedStack (state tiap tab terjaga, tidak rebuild ulang)
/// + bottom navigation custom.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  late final ProductProvider _products;

  @override
  void initState() {
    super.initState();
    _products = context.read<ProductProvider>();
    // Mulai memuat produk setelah frame pertama (hindari notify saat build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _products.start();
    });
  }

  @override
  void dispose() {
    _products.stop();
    super.dispose();
  }

  void go(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: index,
        children: [
          HomePage(onOpenCart: () => go(2)),
          const WishlistPage(),
          CartPage(onShop: () => go(0)),
          const ProfilePage(),
        ],
      ),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Beranda',
                    active: index == 0,
                    onTap: () => go(0)),
                _NavItem(
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    label: 'Favorit',
                    active: index == 1,
                    onTap: () => go(1)),
                _NavItem(
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag,
                    label: 'Keranjang',
                    active: index == 2,
                    badge: true,
                    onTap: () => go(2)),
                _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profil',
                    active: index == 3,
                    onTap: () => go(3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final bool badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ink : Colors.grey.shade400;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: active ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(active ? activeIcon : icon,
                        size: 24, color: color),
                  ),
                  if (badge)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Selector<CartProvider, int>(
                        selector: (_, c) => c.itemCount,
                        builder: (context, count, _) {
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('$count',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700)),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
