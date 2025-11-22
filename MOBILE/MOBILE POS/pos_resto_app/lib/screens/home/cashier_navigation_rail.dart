import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CashierNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final VoidCallback onLogout;

  const CashierNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
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
          // Logout Icon sudah menggunakan kPrimaryColor
          IconButton(
            icon: const Icon(Icons.logout, color: kPrimaryColor, size: 30),
            onPressed: onLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildNavRailItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    // Logika warna:
    // Jika terpilih (isSelected=true) -> Putih (kBackgroundColor)
    // Jika TIDAK terpilih (isSelected=false) -> Oranye (kPrimaryColor)
    final Color itemColor = isSelected ? kBackgroundColor : kPrimaryColor;
    
    return GestureDetector(
      onTap: () => onIndexChanged(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.transparent, // Latar belakang tetap seperti ini
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: itemColor, // Menggunakan warna baru (Oranye jika unselected)
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: itemColor, // Menggunakan warna baru (Oranye jika unselected)
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}