import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';

class CashierMenuScreen extends StatefulWidget {
  final List<Menu> menus;
  final List<Category> categories;
  final Future<void> Function() onRefresh;

  const CashierMenuScreen({
    super.key,
    required this.menus,
    required this.categories,
    required this.onRefresh,
  });

  @override
  State<CashierMenuScreen> createState() => _CashierMenuScreenState();
}

class _CashierMenuScreenState extends State<CashierMenuScreen> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final displayedMenus = _selectedCategoryId == null
        ? widget.menus
        : widget.menus
              .where((m) => m.categoryId == _selectedCategoryId)
              .toList();

    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryFilterBar(),
          const SizedBox(height: 24),
          const Text(
            "Semua Menu Kami",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: displayedMenus.isEmpty
                  ? const Center(
                      child: Text(
                        "Tidak ada menu",
                        style: TextStyle(color: kSecondaryColor),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: displayedMenus.length,
                      itemBuilder: (context, index) {
                        return _buildMenuCard(displayedMenus[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // CATEGORY FILTER BAR
  // ======================================================================
  Widget _buildCategoryFilterBar() {
    List<Category> allCategories = [
      Category(id: -1, name: "All", menusCount: widget.menus.length),
      ...widget.categories,
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final bool isSelected = category.id == (_selectedCategoryId ?? -1);

          // --- Icon Improvement ---
          IconData icon;
          String name = category.name.toLowerCase();

          if (name.contains("makan") || name.contains("main")) {
            icon = Icons.restaurant;
          } else if (name.contains("snack") || name.contains("camil")) {
            icon = Icons.fastfood;
          } else if (name.contains("minum") ||
              name.contains("drink") ||
              name.contains("kopi")) {
            icon = Icons.local_cafe;
          } else {
            icon = Icons.category;
          }

          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategoryId = category.id == -1 ? null : category.id;
            }),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : kLightGreyColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isSelected ? kBackgroundColor : kSecondaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? kBackgroundColor
                                  : kSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${category.id == -1 ? widget.menus.length : (category.menusCount ?? 0)} Items",
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? kBackgroundColor.withOpacity(0.8)
                                  : kSecondaryColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ======================================================================
  // NORMALIZE IMAGE URL
  // ======================================================================
  String normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    String path = url;

    // Full URL langsung dipakai
    if (url.startsWith('http')) {
      return url;
    }

    // Jika path tidak mengandung storage
    if (!path.contains('storage')) {
      path = 'storage/$path';
    }

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    return '$BASE_URL/$path';
  }

  // ======================================================================
  // MENU CARD
  // ======================================================================
  Widget _buildMenuCard(Menu menu) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final itemCount = context.watch<CartProvider>().getItemQuantity(menu.id);

    final fullImageUrl = normalizeImageUrl(menu.imageUrl);
    final isAvailable = menu.isAvailable;

    return Card(
      elevation: 2,
      color: isAvailable ? Colors.white : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMenuImage(fullImageUrl, isAvailable),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          menu.description ?? 'Tidak ada deskripsi',
                          style: TextStyle(
                            fontSize: 12,
                            color: kSecondaryColor.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isAvailable)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "Sisa Stok: ${menu.stock}",
                              style: TextStyle(
                                fontSize: 11,
                                color: kPrimaryColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    _buildPriceAndControls(menu, itemCount, cart, isAvailable),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================================
  // IMAGE WIDGET
  // ======================================================================
  Widget _buildMenuImage(String imageUrl, bool isAvailable) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.isEmpty
              ? Container(
                  color: kLightGreyColor,
                  child: const Icon(
                    Icons.fastfood,
                    size: 40,
                    color: kSecondaryColor,
                  ),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  color: isAvailable ? null : Colors.grey,
                  colorBlendMode: isAvailable ? null : BlendMode.saturation,
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        ),
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: kLightGreyColor,
                    child: const Icon(Icons.broken_image),
                  ),
                ),

          if (!isAvailable)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "HABIS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ======================================================================
  // PRICE + BUTTONS
  // ======================================================================
  Widget _buildPriceAndControls(
  Menu menu,
  int itemCount,
  CartProvider cart,
  bool isAvailable,
) {
  bool isMaxReached = itemCount >= menu.stock;
  bool outOfStock = menu.stock <= 0;

  // Fungsi untuk menampilkan snackbar dengan style yang konsisten
  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: color ?? Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1500), // Lebih pendek karena pesan lebih singkat
      ),
    );
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Text(
          "Rp ${menu.price.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isAvailable ? kPrimaryColor : Colors.grey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // --- Jika habis ---
      if (!isAvailable)
        const Text(
          "Stok Kosong",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        )
      else
        // --- Kontrol Add/Remove ---
        Container(
          decoration: BoxDecoration(
            color: itemCount > 0 ? kPrimaryColor.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              if (itemCount > 0)
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () => cart.decreaseItem(menu.id),
                ),

              if (itemCount > 0)
                Text(
                  itemCount.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              // --- ADD BUTTON ---
              IconButton(
                icon: Icon(
                  itemCount > 0 ? Icons.add : Icons.add_circle,
                  size: 18,
                  color: isMaxReached || outOfStock
                      ? Colors.grey
                      : kPrimaryColor,
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: isMaxReached || outOfStock
                    ? () {
                        _showSnack(
                          "Maksimal order! Stok hanya ${menu.stock}.",
                          color: Colors.red,
                        );
                      }
                    : () => cart.addItem(menu),
              ),
            ],
          ),
        ),
    ],
  );
}
}
