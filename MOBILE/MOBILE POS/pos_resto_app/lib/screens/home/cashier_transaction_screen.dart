// lib/screens/home/cashier_transaction_screen.dart

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';

class CashierTransactionScreen extends StatelessWidget {
  final List<Order> orders;

  const CashierTransactionScreen({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detail Transaksi",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('Belum ada transaksi selesai.'))
                // --- PERUBAHAN DIMULAI DI SINI ---
                : GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Menampilkan 2 kolom
                      crossAxisSpacing: 20, // Spasi horizontal antar kartu
                      mainAxisSpacing: 20, // Spasi vertikal antar kartu
                      childAspectRatio:
                          1.2, // Rasio Lebar/Tinggi. Sesuaikan jika perlu
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(orders[index]);
                    },
                  ),
            // --- PERUBAHAN BERAKHIR DI SINI ---
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Order order) {
    // --- PERUBAHAN: Menghapus 'Align' ---
    return Card(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // --- PERUBAHAN: Menghapus 'margin' ---
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        // --- PERUBAHAN: Menghapus 'SizedBox(width: 450, ...)' ---
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      order.restoTable?.number ?? '??',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName ?? 'Nama Pelanggan',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const Divider(color: Colors.grey, height: 32),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text('Qty',
                      style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Text('Items',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7)))),
                  Text('Price',
                      style: TextStyle(color: Colors.white.withOpacity(0.7))),
                ],
              ),
            ),
            // Kita bungkus daftar item dengan Flexible agar tidak overflow
            // jika itemnya sangat banyak dalam mode Grid
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: order.orderItems
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Text('${item.quantity}'.padLeft(2, '0'),
                                    style: const TextStyle(color: Colors.white)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(item.menu.name,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                Text(
                                    'Rp ${item.priceAtTime.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SubTotal',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text(
                  'Rp ${order.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}