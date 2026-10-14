import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/product_provider.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onOpenCart});
  final VoidCallback onOpenCart;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State lokal (setState): hanya dipakai di halaman ini.
  String searchQuery = '';
  String category = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        // Consumer: hanya bagian ini yang rebuild saat data produk berubah.
        child: Consumer<ProductProvider>(
          builder: (context, store, child) {
            final visible = store.products.where((p) {
              final okCat = category == 'Semua' || p.category == category;
              return okCat && p.name.toLowerCase().contains(searchQuery);
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selamat datang di',
                                    style: TextStyle(
                                        fontSize: 12, color: AppColors.muted)),
                                Text('CLUBWEAR',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 3)),
                              ],
                            ),
                            CartIconButton(onTap: widget.onOpenCart),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          onChanged: (value) => setState(
                              () => searchQuery = value.toLowerCase().trim()),
                          decoration: InputDecoration(
                            hintText: 'Cari kaos, hoodie, celana...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Icon(Icons.search,
                                  size: 24, color: Colors.grey.shade400),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  const BorderSide(color: AppColors.line),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: AppColors.ink, width: 1.2),
                            ),
                          ),
                        ),
                        if (searchQuery.isEmpty) ...[
                          const SizedBox(height: 18),
                          const _PromoBanner(),
                        ],
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: store.categories.length,
                      separatorBuilder: (context, i) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final c = store.categories[i];
                        final selected = c == category;
                        return GestureDetector(
                          onTap: () => setState(() => category = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.ink : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      selected ? AppColors.ink : AppColors.line),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.ink,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Hasil pencarian'
                              : (category == 'Semua'
                                  ? 'Rekomendasi untukmu'
                                  : category),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text('${visible.length} produk',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
                if (store.loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (visible.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'Produk tidak ditemukan',
                      subtitle: 'Coba kata kunci atau kategori yang lain.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 260,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ProductCard(
                            product: visible[i], heroPrefix: 'home'),
                        childCount: visible.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -56,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.7),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('KOLEKSI TERBARU',
                    style: TextStyle(
                        color: Color(0xFF9A9A94),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('Essentials untuk\nsetiap harimu.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 10),
                Text('Diskon hingga 30%',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
