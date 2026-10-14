import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/cart_provider.dart';
import 'common.dart';

/// Kartu item keranjang dengan input jumlah (TextField + tombol +/-).
class CartItemCard extends StatefulWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.maxQuantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem item;
  final int maxQuantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late final TextEditingController quantityController;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: '${widget.item.quantity}');
    focusNode = FocusNode()..addListener(_onFocusChange);
  }

  // Saat kolom jumlah kehilangan fokus, isi yang kosong/tidak valid dikembalikan.
  void _onFocusChange() {
    if (!focusNode.hasFocus) _syncText(force: true);
  }

  // CartItem adalah objek yang sama yang dimutasi provider, jadi
  // `oldWidget.item.quantity` selalu sama dengan yang baru. Karena itu
  // bandingkan langsung ke isi TextField, bukan ke widget lama.
  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncText();
  }

  void _syncText({bool force = false}) {
    final q = widget.item.quantity;
    final text = quantityController.text;
    final typed = int.tryParse(text);
    // Jangan menimpa saat user sedang mengosongkan kolom untuk mengetik.
    if (!force && text.isEmpty) return;
    if (typed != q) {
      quantityController.text = '$q';
      quantityController.selection =
          TextSelection.collapsed(offset: quantityController.text.length);
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void _setQuantity(int q) {
    widget.onQuantityChanged(q);
    quantityController.text = '$q';
    quantityController.selection =
        TextSelection.collapsed(offset: quantityController.text.length);
  }

  void updateQuantity(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 1) return;
    final max = widget.maxQuantity < 1 ? 1 : widget.maxQuantity;
    final clamped = parsed.clamp(1, max).toInt();
    if (clamped != parsed) {
      quantityController.text = '$clamped';
      quantityController.selection =
          TextSelection.collapsed(offset: quantityController.text.length);
    }
    widget.onQuantityChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 88,
              height: 104,
              child: ProductImage(product: p, iconSize: 32),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onRemove,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  Text('Ukuran: ${item.size}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rupiah(item.subtotal),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      Row(
                        children: [
                          _QtyButton(
                            icon: Icons.remove,
                            onTap: item.quantity > 1
                                ? () => _setQuantity(item.quantity - 1)
                                : null,
                          ),
                          SizedBox(
                            width: 40,
                            height: 30,
                            child: TextField(
                              controller: quantityController,
                              focusNode: focusNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8),
                              ),
                              onChanged: updateQuantity,
                            ),
                          ),
                          _QtyButton(
                            icon: Icons.add,
                            onTap: item.quantity < widget.maxQuantity
                                ? () => _setQuantity(item.quantity + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? AppColors.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon,
            size: 16, color: enabled ? AppColors.ink : Colors.grey.shade400),
      ),
    );
  }
}
