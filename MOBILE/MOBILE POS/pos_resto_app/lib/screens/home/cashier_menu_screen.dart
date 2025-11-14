// lib/screens/home/cashier_menu_screen.dart

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
        : widget.menus.where((menu) => menu.categoryId == _selectedCategoryId).toList();

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
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: displayedMenus.length,
              itemBuilder: (context, index) {
                return _buildMenuCard(displayedMenus[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

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
          final bool isSelected = (category.id == -1 && _selectedCategoryId == null) ||
                                  (category.id == _selectedCategoryId);

          IconData icon;
          switch (category.name.toLowerCase()) {
            case 'main course':
              icon = Icons.restaurant;
              break;
            case 'snack':
              icon = Icons.fastfood;
              break;
            case 'makanan':
              icon = Icons.restaurant;
              break;
            case 'minuman':
              icon = Icons.local_cafe;
              break;
            default:
              icon = Icons.category;
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryId = category.id == -1 ? null : category.id;
              });
            },
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? kBackgroundColor : kSecondaryColor,
                          ),
                        ),
                        Text(
                          "${category.menusCount ?? 0} Items",
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? kBackgroundColor.withOpacity(0.8) : kSecondaryColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(Menu menu) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final int itemCountInCart = context.watch<CartProvider>().getItemQuantity(menu.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (menu.imageUrl == null || menu.imageUrl!.isEmpty)
              ? Container(
                  height: 120,
                  width: double.infinity,
                  color: kLightGreyColor,
                  child: const Icon(Icons.image_not_supported, color: kSecondaryColor),
                )
              : Image.network(
                  menu.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: kLightGreyColor,
                    child: const Icon(Icons.image_not_supported, color: kSecondaryColor),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  menu.description ?? 'Tidak ada deskripsi',
                  style: TextStyle(fontSize: 12, color: kSecondaryColor.withOpacity(0.6)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${menu.price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: kPrimaryColor),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            cart.decreaseItem(menu.id);
                          },
                          iconSize: 22,
                        ),
                        Text(
                          itemCountInCart.toString(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: kPrimaryColor),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            cart.addItem(menu);
                          },
                          iconSize: 22,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}