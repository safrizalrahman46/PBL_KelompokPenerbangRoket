import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/menu_display_controller.dart';
import '../../models/menu_model.dart';
import '../../utils/constants.dart';

class MenuDisplayScreen extends StatefulWidget {
  const MenuDisplayScreen({super.key});

  @override
  State<MenuDisplayScreen> createState() => _MenuDisplayScreenState();
}

class _MenuDisplayScreenState extends State<MenuDisplayScreen> {
  late final MenuDisplayController _controller;
  VoidCallback? _listener;

  String _formatPrice(double price) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(price);
  }

  @override
  void initState() {
    super.initState();
    _controller = MenuDisplayController();
    _listener = () => setState(() {});
    _controller.addListener(_listener!);
    _controller.loadMenus();
    // start auto refresh every 10 seconds
    _controller.startAutoRefresh(seconds: 10);
  }

  @override
  void dispose() {
    if (_listener != null) _controller.removeListener(_listener!);
    // stop auto refresh before disposing
    _controller.stopAutoRefresh();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menus = _controller.filteredMenus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Pelanggan'),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, 
        ),
      ),

      backgroundColor: kBackgroundColor,
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.error != null
          ? Center(child: Text('Gagal memuat menu: ${_controller.error}'))
          : menus.isEmpty
          ? const Center(child: Text('Belum ada menu tersedia'))
          : RefreshIndicator(
              onRefresh: _controller.refresh,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.98,
                  ),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    return _buildMenuCard(menus[index]);
                  },
                ),
              ),
            ),
    );
  }

  // ============================================================
  // CARD YANG SAMA DENGAN CashierMenuScreen
  // ============================================================
  Widget _buildMenuCard(Menu menu) {
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
                                color: kPrimaryColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Harga (tanpa tombol add)
                    Text(
                      _formatPrice(menu.price),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? kPrimaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE SAMA SEPERTI CashierMenuScreen
  // ============================================================
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

          // Badge habis
          if (!isAvailable)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
}
