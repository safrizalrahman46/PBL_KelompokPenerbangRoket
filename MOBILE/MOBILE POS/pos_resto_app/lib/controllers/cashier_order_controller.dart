// lib/screens/home/cashier_order_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CashierOrderController extends ChangeNotifier {
  final BuildContext context;
  final List<Order> orders;
  final Future<void> Function() onRefresh;
  final ApiService apiService;

  final FlutterTts _flutterTts = FlutterTts();

  String selectedStatusFilter = 'Semua';
  String selectedTimeFilter = 'Hari Ini';

  final List<String> statusOptions = [
    'Semua',
    'Pending',
    'Disiapkan',
    'Siap',
    'Selesai',
  ];

  final List<String> timeOptions = [
    'Hari Ini',
    'Kemarin',
    '7 Hari Terakhir',
    'Bulan Ini',
    'Semua',
  ];

  CashierOrderController({
    required this.context,
    required this.orders,
    required this.onRefresh,
    required this.apiService,
  });

  // Getter untuk orders yang sudah di-sort dan di-filter
  List<Order> get filteredOrders {
    // 1. Sorting (terbaru di atas)
    List<Order> sortedOrders = List.from(orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 2. Filter waktu
    List<Order> timeFilteredOrders = sortedOrders.where((order) {
      return checkTimeFilter(order.createdAt);
    }).toList();

    // 3. Filter status
    return filterByStatus(timeFilteredOrders);
  }

  // Method untuk mengubah filter status
  void selectStatusFilter(String filter) {
    selectedStatusFilter = filter;
    notifyListeners();
  }

  // Method untuk mengubah filter waktu
  void selectTimeFilter(String filter) {
    selectedTimeFilter = filter;
    notifyListeners();
  }

  // Logika cek waktu
  bool checkTimeFilter(DateTime orderDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(
      orderDate.year,
      orderDate.month,
      orderDate.day,
    );

    switch (selectedTimeFilter) {
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

  // Logika filter status
  List<Order> filterByStatus(List<Order> orders) {
    switch (selectedStatusFilter) {
      case 'Pending':
        return orders.where((order) {
          final status = order.status.toLowerCase();
          return status == 'pending' || status == 'paid';
        }).toList();

      case 'Disiapkan':
        return orders.where((order) {
          final status = order.status.toLowerCase();
          return status == 'preparing' || status == 'cooking';
        }).toList();

      case 'Siap':
        return orders.where((order) {
          final status = order.status.toLowerCase();
          return status == 'ready' || status == 'ready to serve';
        }).toList();

      case 'Selesai':
        return orders.where((order) {
          final status = order.status.toLowerCase();
          return status == 'completed' ||
              status == 'done' ||
              status == 'finished';
        }).toList();

      default:
        return orders;
    }
  }

  // Get text untuk empty state
  String getEmptyStateText() {
    switch (selectedStatusFilter) {
      case 'Pending':
        return 'Tidak ada order pending';
      case 'Disiapkan':
        return 'Tidak ada order yang sedang disiapkan';
      case 'Siap':
        return 'Tidak ada order yang siap disajikan';
      case 'Selesai':
        return 'Tidak ada order yang selesai';
      default:
        return 'Belum ada order aktif';
    }
  }

  // Update order status
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await apiService.updateOrderStatus(orderId, newStatus);

      if (isMounted()) {
        showSnack(
          'Pesanan #$orderId diperbarui ke $newStatus',
          color: Colors.green,
        );
      }

      await onRefresh();
    } catch (e) {
      if (isMounted()) {
        showSnack('Gagal update status: $e', color: Colors.red);
      }
    }
  }

  // Text to Speech
  Future<void> speak(String text) async {
    try {
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    } catch (e) {
      if (isMounted()) {
        showSnack('Gagal memutar audio: $e', color: Colors.red);
      }
    }
  }

  // Get status info
  Map<String, dynamic> getStatusInfo(String status) {
    status = status.toLowerCase();

    if (status == 'pending' || status == 'paid') {
      return {
        'text': 'Pending',
        'icon': Icons.hourglass_empty,
        'color': Colors.orange.shade300,
      };
    }
    if (status == 'preparing' || status == 'cooking') {
      return {
        'text': 'Disiapkan',
        'icon': Icons.kitchen,
        'color': Colors.blue.shade300,
      };
    }
    if (status == 'ready' || status == 'ready to serve') {
      return {
        'text': 'Siap',
        'icon': Icons.check_circle,
        'color': Colors.green.shade300,
      };
    }
    if (status == 'completed' || status == 'done' || status == 'finished') {
      return {
        'text': 'Selesai',
        'icon': Icons.done_all,
        'color': Colors.grey.shade300,
      };
    }

    return {
      'text': status.toUpperCase(),
      'icon': Icons.help_outline,
      'color': Colors.grey.shade300,
    };
  }

  // Show snackbar
  void showSnack(String message, {Color? color}) {
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
        backgroundColor: color ?? kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Periksa apakah widget sudah terpasang
  bool isMounted() {
    return context.mounted;
  }

}
