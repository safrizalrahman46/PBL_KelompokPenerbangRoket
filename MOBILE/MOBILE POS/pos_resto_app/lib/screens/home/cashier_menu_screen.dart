// lib/screens/home/cashier_menu_screen.dart

import 'package:flutter/material.dart';
import '../../models/menu_model.dart';
import '../../utils/constants.dart';
import '../../controllers/cashier_menu_controller.dart';

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
  late CashierMenuController _controller;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = CashierMenuController(
      context: context,
      menus: widget.menus,
      categories: widget.categories,
      onRefresh: widget.onRefresh,
    );
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);
  }

  @override
  void didUpdateWidget(CashierMenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }

    _controller = CashierMenuController(
      context: context,
      menus: widget.menus,
      categories: widget.categories,
      onRefresh: widget.onRefresh,
    );

    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    // SORT: menu stok habis / tidak available pindah ke bawah
    
    final sortedMenus = List<Menu>.from(_controller.displayedMenus)
      ..sort((a, b) {
        final aOut = a.stock <= 0 || !a.isAvailable;
        final bOut = b.stock <= 0 || !b.isAvailable;

        if (aOut && !bOut) return 1; // a turun
        if (!aOut && bOut) return -1; // b turun
        return 0;
      });

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
              child: sortedMenus.isEmpty
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
                      itemCount: sortedMenus.length,
                      itemBuilder: (context, index) {
                        return _buildMenuCard(sortedMenus[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  
  // CATEGORY FILTER BAR
  
  Widget _buildCategoryFilterBar() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _controller.getAllCategories().length,
        itemBuilder: (context, index) {
          final category = _controller.getAllCategories()[index];
          final isSelected = _controller.isCategorySelected(category);
          final icon = _controller.getCategoryIcon(category);

          return GestureDetector(
            onTap: () => _controller.selectCategory(category.id),
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
                      color:
                          isSelected ? kBackgroundColor : kSecondaryColor,
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
                                  ? kBackgroundColor.withValues(alpha: 0.8)
                                  : kSecondaryColor.withValues(alpha: 0.6),
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

  
  // MENU CARD
  
  Widget _buildMenuCard(Menu menu) {
    final itemCount = _controller.getItemQuantity(menu.id);
    final fullImageUrl = _controller.normalizeImageUrl(menu.imageUrl);
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
                            color: kSecondaryColor.withValues(alpha: 0.6),
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
                                color:
                                    kPrimaryColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    _buildPriceAndControls(menu, itemCount, isAvailable),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  // IMAGE
  
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
                  colorBlendMode:
                      isAvailable ? null : BlendMode.saturation,
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(
                                  color: kPrimaryColor),
                            ),
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                    color: kLightGreyColor,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
          if (!isAvailable)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
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

  
  // PRICE + ADD BUTTONS
  
  Widget _buildPriceAndControls(
      Menu menu, int itemCount, bool isAvailable) {
    bool isMaxReached = itemCount >= menu.stock;
    bool outOfStock = menu.stock <= 0;

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
          Container(
            decoration: BoxDecoration(
              color: itemCount > 0
                  ? kPrimaryColor.withValues(alpha: 0.1)
                  : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                if (itemCount > 0)
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        _controller.decreaseFromCart(menu.id),
                  ),
                if (itemCount > 0)
                  Text(
                    itemCount.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    itemCount > 0
                        ? Icons.add
                        : Icons.add_circle,
                    size: 18,
                    color: isMaxReached || outOfStock
                        ? Colors.grey
                        : kPrimaryColor,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: isMaxReached || outOfStock
                      ? null
                      : () => _controller.addToCart(menu),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
