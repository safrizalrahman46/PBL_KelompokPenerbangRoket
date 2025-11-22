// lib/screens/home/cashier_table_screen.dart

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CashierTableScreen extends StatelessWidget {
  final List<RestoTable> tables;
  final Future<void> Function() onRefresh;
  final ApiService apiService;

  const CashierTableScreen({
    super.key,
    required this.tables,
    required this.onRefresh,
    required this.apiService,
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
            "Manajemen Meja",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final sortedTables = List<RestoTable>.from(tables)
                    ..sort((a, b) => a.number.compareTo(b.number));
                  final table = sortedTables[index];
                  return _buildTableCard(table, context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(RestoTable table, BuildContext context) {
    final bool isAvailable = table.status.toLowerCase() == 'available';
    final Color cardColor = isAvailable ? const Color.fromARGB(255, 230, 230, 230) : Colors.red.shade600;
    final Color textColor = isAvailable ? kSecondaryColor : Colors.white;
    final Color statusColor = isAvailable ? kSecondaryColor.withOpacity(0.8) : Colors.white.withOpacity(0.8);
    final String statusText = isAvailable ? 'Tersedia' : 'Terisi';

    return GestureDetector(
      onTap: () {
        _showUpdateStatusDialog(table, context);
      },
      child: Card(
        elevation: 4,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 14,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateStatusDialog(RestoTable table, BuildContext context) async {
  final bool isAvailable = table.status.toLowerCase() == 'available';
  final String newStatus = isAvailable ? 'occupied' : 'available';
  final String newStatusText = isAvailable ? 'Terisi' : 'Tersedia';

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: kBackgroundColor,
        child: SizedBox(
          width: 400, // lebar dialog
          height: 300, // tinggi dialog
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON BULAT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kSplashCircleColor,
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // TITLE
              const Text(
                'Konfirmasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),

              const SizedBox(height: 12),

              // MESSAGE
              Text(
                'Ubah status "Meja ${table.number}" menjadi "$newStatusText"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 28),

              // BUTTONS
              Row(
                children: [
                  // CANCEL BUTTON
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: kPrimaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // CONFIRM BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await apiService.updateTableStatus(table.id, newStatus);
                          await onRefresh();

                          Navigator.of(dialogContext).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Status Meja ${table.number} berhasil diubah!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal update: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ubah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
      );
    },
  );
}
}