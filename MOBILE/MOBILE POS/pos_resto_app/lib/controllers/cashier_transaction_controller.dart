// lib/screens/home/cashier_transaction_controller.dart

import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class CashierTransactionController extends ChangeNotifier {
  final BuildContext context;
  final List<Order> orders;
  final VoidCallback onRefresh;

  String selectedFilter = 'Hari Ini';
  String searchQuery = '';

  final List<String> filterOptions = [
    'Hari Ini',
    'Kemarin',
    '7 Hari Terakhir',
    'Bulan Ini',
    'Semua',
  ];

  CashierTransactionController({
    required this.context,
    required this.orders,
    required this.onRefresh,
  });

  // Getter untuk orders yang sudah di-filter dan di-sort
  List<Order> get filteredOrders {
    List<Order> filteredList = orders.where((order) {
      // Filter A: Waktu
      bool passDate = checkDateFilter(order.createdAt);

      // Filter B: Search
      bool passSearch = true;
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final name = order.customerName?.toLowerCase() ?? '';
        final id = order.id.toString();
        final table = order.restoTable?.number.toLowerCase() ?? '';
        passSearch =
            name.contains(query) || id.contains(query) || table.contains(query);
      }

      return passDate && passSearch;
    }).toList();

    // Sorting (Terbaru di atas)
    return filteredList.reversed.toList();
  }

  // Logika filter tanggal
  bool checkDateFilter(DateTime orderDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(
      orderDate.year,
      orderDate.month,
      orderDate.day,
    );

    switch (selectedFilter) {
      case 'Hari Ini':
        return dateToCheck.isAtSameMomentAs(today);
      case 'Kemarin':
        final yesterday = today.subtract(const Duration(days: 1));
        return dateToCheck.isAtSameMomentAs(yesterday);
      case '7 Hari Terakhir':
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        return dateToCheck.isAfter(sevenDaysAgo) &&
            (dateToCheck.isBefore(today) ||
                dateToCheck.isAtSameMomentAs(today));
      case 'Bulan Ini':
        return orderDate.year == now.year && orderDate.month == now.month;
      case 'Semua':
      default:
        return true;
    }
  }

  // Method untuk mengubah filter
  void setSelectedFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  // Method untuk mengubah search query
  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  // Get empty state message
  String getEmptyStateMessage() {
    if (searchQuery.isNotEmpty) {
      return 'Tidak ditemukan transaksi: "$searchQuery"';
    } else {
      return 'Tidak ada transaksi periode: "$selectedFilter"';
    }
  }

  // Get filter info text
  String getFilterInfoText() {
    return "Menampilkan ${filteredOrders.length} transaksi ($selectedFilter)";
  }

  // Uses ChangeNotifier.notifyListeners()
}
