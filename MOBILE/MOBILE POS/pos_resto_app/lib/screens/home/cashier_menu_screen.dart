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

          /// GRID MENU
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85, 
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

  // CATEGORY BAR
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

          IconData icon;
          switch (category.name.toLowerCase()) {
            case 'main course':
            case 'makanan':
              icon = Icons.restaurant;
              break;
            case 'snack':
              icon = Icons.fastfood;
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
                          "${category.id == -1 ? widget.menus.length : category.menusCount ?? 0} Items",
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? kBackgroundColor.withOpacity(0.8)
                                : kSecondaryColor.withOpacity(0.6),
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

  // ⭐️ FUNGSI NORMALIZE IMAGE URL YANG DIPERBAIKI (DENGAN OVERRIDE LOCALHOST)
  String normalizeImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    String path = imageUrl;
    
    // ⭐️ PERBAIKAN: Jika URL sudah full tapi masih menggunakan localhost dari API
    if (path.startsWith('http')) {
      if (path.contains('localhost') || path.contains('127.0.0.1')) {
          debugPrint('⚠️ Mengganti localhost/127.0.0.1 dengan BASE_URL Ngrok.');
          
          final uri = Uri.tryParse(path);
          if (uri != null && uri.path.isNotEmpty) {
             path = uri.path; // Ambil path-nya saja (e.g., /storage/menus/xxx.jpg)
          } else {
             // Fallback
             path = path.substring(path.indexOf('/storage/') + 1); 
          }
      } else {
          // Jika URL http/https yang valid (bukan localhost), langsung pakai
          return path; 
      }
    }
    
    // Lanjutkan normalisasi path relatif
    
    // Hapus '/' di awal jika ada
    if (path.startsWith('/')) {
        path = path.substring(1);
    }
    
    // Tambahkan 'storage/' jika belum ada
    if (!path.startsWith('storage/')) {
        path = 'storage/$path';
    }
    
    final String normalized = '$BASE_URL/$path';
    
    debugPrint('🖼️ Original path: $imageUrl');
    debugPrint('🔄 Normalized URL: $normalized');
    
    return normalized;
  }

  // MENU CARD
  Widget _buildMenuCard(Menu menu) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final int itemCountInCart = context.watch<CartProvider>().getItemQuantity(menu.id);

    // Gunakan fungsi yang sudah diperbaiki
    final String fullImageUrl = normalizeImageUrl(menu.imageUrl);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE SECTION
          _buildMenuImage(fullImageUrl),
          
          // CONTENT SECTION
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TITLE & DESCRIPTION
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
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // PRICE & QUANTITY CONTROLS
                  _buildPriceAndControls(menu, itemCountInCart, cart),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // WIDGET IMAGE YANG DIPISAH
  Widget _buildMenuImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: imageUrl.isEmpty
          ? Container(
              color: kLightGreyColor,
              child: const Icon(
                Icons.fastfood,
                color: kSecondaryColor,
                size: 40,
              ),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: kLightGreyColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                      color: kPrimaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Log error menggunakan debugPrint
                debugPrint('❌ Error loading image: $error');
                debugPrint('📁 Failed URL: $imageUrl');
                return Container(
                  color: kLightGreyColor,
                  child: const Icon(
                    Icons.broken_image,
                    color: kSecondaryColor,
                    size: 40,
                  ),
                );
              },
            ),
    );
  }

  // WIDGET PRICE & CONTROLS YANG DIPISAH
  Widget _buildPriceAndControls(Menu menu, int itemCountInCart, CartProvider cart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // PRICE
        Flexible(
          child: Text(
            "Rp ${menu.price.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // QUANTITY CONTROLS
        Container(
          decoration: BoxDecoration(
            color: itemCountInCart > 0 ? kPrimaryColor.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // DECREASE BUTTON
              if (itemCountInCart > 0)
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () => cart.decreaseItem(menu.id),
                ),

              // QUANTITY DISPLAY
              if (itemCountInCart > 0)
                Text(
                  itemCountInCart.toString(),
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                  ),
                ),

              // INCREASE BUTTON
              IconButton(
                icon: Icon(
                  itemCountInCart > 0 ? Icons.add : Icons.add_circle,
                  size: 18,
                  color: kPrimaryColor,
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => cart.addItem(menu),
              ),
            ],
          ),
        ),
      ],
    );
  }
}