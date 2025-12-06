// lib/screens/home/cashier_menu_controller.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';

class CashierMenuController extends ChangeNotifier {
  final BuildContext context;
  final List<Menu> menus;
  final List<Category> categories;
  final Future<void> Function() onRefresh;

  int? selectedCategoryId;

  CashierMenuController({
    required this.context,
    required this.menus,
    required this.categories,
    required this.onRefresh,
  });

  // Getter untuk menus yang sudah difilter
  List<Menu> get displayedMenus {
    return selectedCategoryId == null
        ? menus
        : menus.where((m) => m.categoryId == selectedCategoryId).toList();
  }

  // Method untuk mengubah kategori
  void selectCategory(int? categoryId) {
    selectedCategoryId = categoryId == -1 ? null : categoryId;
    notifyListeners();
  }

  // Normalize image URL
  String normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    String path = url;

    if (url.startsWith('http')) {
      return url;
    }

    if (!path.contains('storage')) {
      path = 'storage/$path';
    }

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    return '$BASE_URL/$path';
  }

  // Add item to cart
  void addToCart(Menu menu) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final itemCount = cart.getItemQuantity(menu.id);

    if (itemCount >= menu.stock) {
      _showSnack(
        "Maksimal order! Stok hanya ${menu.stock}.",
        color: Colors.red,
      );
      return;
    }

    if (menu.stock <= 0) {
      _showSnack("Stok habis!", color: Colors.red);
      return;
    }

    cart.addItem(menu);
  }

  // Decrease item from cart
  void decreaseFromCart(int menuId) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.decreaseItem(menuId);
  }

  // Remove item from cart
  void removeFromCart(int menuId) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.removeItem(menuId);
  }

  // Get item quantity from cart
  int getItemQuantity(int menuId) {
    return context.watch<CartProvider>().getItemQuantity(menuId);
  }

  // Show snackbar
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  // Get all categories including "All"
  List<Category> getAllCategories() {
    return [
      Category(id: -1, name: "All", menusCount: menus.length),
      ...categories,
    ];
  }

  // Get icon for category
  IconData getCategoryIcon(Category category) {
    String name = category.name.toLowerCase();

    if (name.contains("makan") || name.contains("main")) {
      return Icons.restaurant;
    } else if (name.contains("snack") || name.contains("camil")) {
      return Icons.fastfood;
    } else if (name.contains("minum") ||
        name.contains("drink") ||
        name.contains("kopi")) {
      return Icons.local_cafe;
    } else {
      return Icons.category;
    }
  }

  // Check if category is selected
  bool isCategorySelected(Category category) {
    if (category.id == -1) {
      return selectedCategoryId == null;
    }
    return category.id == selectedCategoryId;
  }

  // Uses ChangeNotifier.notifyListeners()
}
