// lib/screens/home/cashier_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/menu_model.dart';
import '../../models/order_model.dart'; // Impor ini diperlukan untuk RestoTable
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class CashierHomeScreen extends StatefulWidget {
  const CashierHomeScreen({super.key});

  @override
  State<CashierHomeScreen> createState() => _CashierHomeScreenState();
}

class _CashierHomeScreenState extends State<CashierHomeScreen> {
  late Future<void> _loadDataFuture;
  final ApiService _apiService = ApiService();

  List<Menu> _menus = [];
  List<Category> _categories = [];
  List<RestoTable> _tables = []; // BARU: Untuk menyimpan daftar meja
  int _selectedNavIndex = 0;
  int? _selectedCategoryId = null; // null untuk "All"

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  // Mengambil data menu, kategori, dan meja dari API
  Future<void> _loadData() async {
    try {
      // Ambil data secara paralel
      final results = await Future.wait([
        _apiService.fetchMenus(),
        _apiService.fetchCategories(),
        _apiService.fetchTables(), // BARU: Ambil data meja
      ]);

      setState(() {
        _menus = results[0] as List<Menu>;
        _categories = results[1] as List<Category>;
        _tables = results[2] as List<RestoTable>; // BARU: Simpan data meja
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
        );
      }
    }
  }

  // Fungsi untuk logout
  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Row(
            children: [
              _buildNavRail(),
              Expanded(
                flex: 3,
                child: _buildMainContent(),
              ),
              Expanded(
                flex: 2,
                child: _buildCartSidebar(),
              ),
            ],
          );
        },
      ),
    );
  }

  // WIDGET UNTUK KOLOM 1 (NAVIGASI)
  Widget _buildNavRail() {
    return Container(
      width: 110,
      color: kSplashBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          const Text(
            "Eat.o",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 40),
          _buildNavRailItem(Icons.restaurant_menu, "Menu", 0),
          _buildNavRailItem(Icons.receipt_long, "Transaksi", 1),
          _buildNavRailItem(Icons.list_alt, "Order", 2),
          _buildNavRailItem(Icons.table_restaurant, "Meja", 3),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: kSecondaryColor, size: 30),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildNavRailItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? kBackgroundColor : kSecondaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kBackgroundColor : kSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK KOLOM 2 (KONTEN UTAMA)
  Widget _buildMainContent() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildMenuPageContent();
      case 1:
        return const Center(
            child: Text("Halaman Transaksi", style: TextStyle(fontSize: 24)));
      case 2:
        return const Center(
            child: Text("Halaman Order", style: TextStyle(fontSize: 24)));
      case 3:
        return const Center(
            child: Text("Halaman Meja", style: TextStyle(fontSize: 24)));
      default:
        return _buildMenuPageContent();
    }
  }

  Widget _buildMenuPageContent() {
    // --- PERBAIKAN FILTER ---
    // Sesuaikan dengan model: menu.category?.id
    final displayedMenus = _selectedCategoryId == null
        ? _menus
        : _menus.where((menu) => menu.category?.id == _selectedCategoryId).toList();

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
    // --- PERBAIKAN COUNT ---
    // Tambahkan "All" secara manual ke daftar kategori
    List<Category> allCategories = [
      Category(id: -1, name: "All", menusCount: _menus.length), // Ganti ke menusCount
      ..._categories,
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
                          // --- PERBAIKAN COUNT ---
                          "${category.menusCount ?? 0} Items", // Gunakan menusCount
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
          // --- PERBAIKAN NULL CHECK ---
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
                // --- PERBAIKAN NULL CHECK ---
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
                      "Rp ${menu.price.toStringAsFixed(0)}", // Format harga
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

  // WIDGET UNTUK KOLOM 3 (KERANJANG)
  Widget _buildCartSidebar() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          color: kLightGreyColor.withOpacity(0.5),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pesanan Saat Ini",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: cart.items.isEmpty
                    ? const Center(
                        child: Text(
                          "Keranjang kosong",
                          style: TextStyle(fontSize: 16, color: kSecondaryColor),
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cart.items[index];
                          return _buildCartItem(cartItem, cart);
                        },
                      ),
              ),
              const SizedBox(height: 24),
              _buildCartSummary(cart),
              const SizedBox(height: 24),
              // --- PERBAIKAN TOMBOL ---
              _buildCartButtons(cart),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            // --- PERBAIKAN NULL CHECK ---
            child: (item.menu.imageUrl == null || item.menu.imageUrl!.isEmpty)
                ? Container(
                    width: 60,
                    height: 60,
                    color: kBackgroundColor,
                    child: const Icon(Icons.image_not_supported),
                  )
                : Image.network(
                    item.menu.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: kBackgroundColor,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${item.menu.price.toStringAsFixed(0)}", // Format harga
                  style: const TextStyle(fontSize: 14, color: kSecondaryColor),
                ),
              ],
            ),
          ),
          Text(
            "x${item.quantity}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () {
              cart.removeItem(item.menu.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Sub total", "Rp ${cart.subtotal.toStringAsFixed(0)}"),
          _buildSummaryRow("Diskon", "${cart.discountPercent}%"),
          _buildSummaryRow("Pajak", "${cart.taxPercent}%"),
          const Divider(thickness: 1, height: 24),
          _buildSummaryRow("Total", "Rp ${cart.total.toStringAsFixed(0)}",
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: kSecondaryColor.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? kPrimaryColor : kSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BARU (Implementasi TODO) ---
  Widget _buildCartButtons(CartProvider cart) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            // Panggil dialog saat ditekan
            onPressed: cart.items.isEmpty ? null : () => _showCreateOrderDialog(cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Lanjutkan Transaksi',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kBackgroundColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton(
            onPressed: () {
              cart.clearCart();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            child: const Text(
              'Batalkan Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // --- FUNGSI BARU (Implementasi TODO) ---
  Future<void> _showCreateOrderDialog(CartProvider cart) async {
    int? selectedTableId;
    bool isSubmitting = false;
    final formKey = GlobalKey<FormState>();

    // Cek jika tidak ada meja, beri tahu user
    if (_tables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal memuat daftar meja. Tidak bisa membuat pesanan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan dialog
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Selesaikan Pesanan'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown untuk pilih meja
                    DropdownButtonFormField<int>(
                      value: selectedTableId,
                      hint: const Text('Pilih Meja'),
                      items: _tables.map((RestoTable table) {
                        return DropdownMenuItem<int>(
                          value: table.id,
                          child: Text('Meja ${table.number}'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setDialogState(() {
                          selectedTableId = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Meja harus dipilih' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: (selectedTableId == null || isSubmitting)
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isSubmitting = true;
                            });

                            try {
                              // 1. Buat data order
                              final orderData = cart.createOrderJson(selectedTableId!);
                              
                              // 2. Kirim ke API
                              await _apiService.createOrder(orderData);
                              
                              // 3. Jika sukses
                              if (mounted) {
                                Navigator.of(dialogContext).pop(); // Tutup dialog
                                cart.clearCart(); // Kosongkan keranjang
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pesanan berhasil dibuat!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              // 4. Jika gagal
                              if (mounted) {
                                Navigator.of(dialogContext).pop(); // Tutup dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal: ${e.toString().replaceFirst("Exception: ", "")}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              setDialogState(() {
                                isSubmitting = false;
                              });
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kBackgroundColor,
                          ),
                        )
                      : const Text('Buat Pesanan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}