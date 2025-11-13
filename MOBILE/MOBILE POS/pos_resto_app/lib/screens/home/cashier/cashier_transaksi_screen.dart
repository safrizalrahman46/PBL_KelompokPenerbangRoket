// lib/screens/home/cashier_transaction_screen.dart

import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../utils/constants.dart';

class CashierTransactionScreen extends StatelessWidget {
  final List<Order> orders;
  final VoidCallback onRefresh;

  const CashierTransactionScreen({
    super.key,
    required this.orders,
    required this.onRefresh,
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
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(orders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Order order) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 450,
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
                      Text('Qty', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      const SizedBox(width: 16),
                      Expanded(child: Text('Items', style: TextStyle(color: Colors.white.withOpacity(0.7)))),
                      Text('Price', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                ),
                ...order.orderItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Text('${item.quantity}'.padLeft(2, '0'),
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(item.menu.name,
                                style: const TextStyle(color: Colors.white)),
                          ),
                          Text('Rp ${item.priceAtTime.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    )),
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
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}