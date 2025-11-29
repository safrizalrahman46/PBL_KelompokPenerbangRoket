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
            child: RefreshIndicator(
              // Pastikan fungsi ini memanggil API fetchMenus()
              onRefresh: widget.onRefresh,
              child: displayedMenus.isEmpty 
                  ? const Center(child: Text("Tidak ada menu", style: TextStyle(color: kSecondaryColor)))
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75, // Aspect ratio agak dipanjangkan untuk muat text stok
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
            case 'makanan': icon = Icons.restaurant; break;
            case 'snack': icon = Icons.fastfood; break;
            case 'minuman': icon = Icons.local_cafe; break;
            default: icon = Icons.category;
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = category.id == -1 ? null : category.id),
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
                    Icon(icon, size: 32, color: isSelected ? kBackgroundColor : kSecondaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? kBackgroundColor : kSecondaryColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${category.id == -1 ? widget.menus.length : category.menusCount ?? 0} Items",
                            style: TextStyle(fontSize: 14, color: isSelected ? kBackgroundColor.withOpacity(0.8) : kSecondaryColor.withOpacity(0.6)),
                          ),
                        ],
                      ),
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

  String normalizeImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    String path = imageUrl;
    if (path.startsWith('http')) {
      if (path.contains('localhost') || path.contains('127.0.0.1')) {
          final uri = Uri.tryParse(path);
          path = (uri != null && uri.path.isNotEmpty) ? uri.path : path.substring(path.indexOf('/storage/') + 1);
      } else {
          return path; 
      }
    }
    if (path.startsWith('/')) path = path.substring(1);
    if (!path.startsWith('storage/')) path = 'storage/$path';
    return '$BASE_URL/$path';
  }

  Widget _buildMenuCard(Menu menu) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final int itemCountInCart = context.watch<CartProvider>().getItemQuantity(menu.id);
    final String fullImageUrl = normalizeImageUrl(menu.imageUrl);
    bool isAvailable = menu.isAvailable; 

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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          menu.description ?? 'Tidak ada deskripsi',
                          style: TextStyle(fontSize: 12, color: kSecondaryColor.withOpacity(0.6), height: 1.3),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                        
                        // 🔥 INDIKATOR STOK (Agar kamu tahu datanya sudah masuk atau belum)
                        if(isAvailable)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              "Sisa Stok: ${menu.stock}", 
                              style: TextStyle(fontSize: 11, color: kPrimaryColor.withOpacity(0.8), fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    _buildPriceAndControls(menu, itemCountInCart, cart, isAvailable),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuImage(String imageUrl, bool isAvailable) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.isEmpty
              ? Container(color: kLightGreyColor, child: const Icon(Icons.fastfood, color: kSecondaryColor, size: 40))
              : Image.network(
                  imageUrl, fit: BoxFit.cover,
                  color: isAvailable ? null : Colors.grey,
                  colorBlendMode: isAvailable ? null : BlendMode.saturation,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: kLightGreyColor, child: Center(child: CircularProgressIndicator(color: kPrimaryColor)));
                  },
                  errorBuilder: (context, error, stackTrace) => Container(color: kLightGreyColor, child: const Icon(Icons.broken_image, color: kSecondaryColor)),
                ),
          if (!isAvailable)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white, width: 2)),
                  child: const Text("HABIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceAndControls(Menu menu, int itemCountInCart, CartProvider cart, bool isAvailable) {
    // Logic validasi stok
    bool isMaxReached = itemCountInCart >= menu.stock;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Rp ${menu.price.toStringAsFixed(0)}",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isAvailable ? kPrimaryColor : Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isAvailable)
          const Text("Stok Kosong", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red))
        else
          Container(
            decoration: BoxDecoration(color: itemCountInCart > 0 ? kPrimaryColor.withOpacity(0.1) : null, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                if (itemCountInCart > 0)
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () => cart.decreaseItem(menu.id),
                  ),
                if (itemCountInCart > 0)
                  Text(itemCountInCart.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                
                IconButton(
                  icon: Icon(itemCountInCart > 0 ? Icons.add : Icons.add_circle, size: 18, color: isMaxReached ? Colors.grey : kPrimaryColor),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // Logic Klik
                    if (isMaxReached) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Maksimal order! Stok hanya ${menu.stock}."), backgroundColor: Colors.red, duration: const Duration(milliseconds: 1000)));
                    } else {
                      cart.addItem(menu);
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}