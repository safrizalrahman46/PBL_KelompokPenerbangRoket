// lib/screens/home/cashier_table_controller.dart

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CashierTableController extends ChangeNotifier {
  final BuildContext context;
  final List<RestoTable> tables;
  final Future<void> Function() onRefresh;
  final ApiService apiService;

  CashierTableController({
    required this.context,
    required this.tables,
    required this.onRefresh,
    required this.apiService,
  });

  // Get sorted tables
  List<RestoTable> getSortedTables() {
    return List<RestoTable>.from(tables)
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  // Get table status info
  Map<String, dynamic> getTableStatusInfo(RestoTable table) {
    final bool isAvailable = table.status.toLowerCase() == 'available';

    return {
      'isAvailable': isAvailable,
      'cardColor': isAvailable
          ? const Color.fromARGB(255, 230, 230, 230)
          : Colors.red.shade600,
      'textColor': isAvailable ? kSecondaryColor : Colors.white,
      'statusColor': isAvailable
          ? kSecondaryColor.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      'statusText': isAvailable ? 'Tersedia' : 'Terisi',
    };
  }

  // Get new status when toggling
  Map<String, dynamic> getNewStatusInfo(RestoTable table) {
    final bool isAvailable = table.status.toLowerCase() == 'available';
    final String newStatus = isAvailable ? 'occupied' : 'available';
    final String newStatusText = isAvailable ? 'Terisi' : 'Tersedia';

    return {'newStatus': newStatus, 'newStatusText': newStatusText};
  }

  // Update table status
  Future<void> updateTableStatus(RestoTable table, String newStatus) async {
    try {
      await apiService.updateTableStatus(table.id, newStatus);
      await onRefresh();

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status Meja ${table.number} berhasil diubah!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show update status dialog
  Future<void> showUpdateStatusDialog(RestoTable table) async {
    final statusInfo = getNewStatusInfo(table);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _UpdateStatusDialog(
          table: table,
          newStatusText: statusInfo['newStatusText']!,
          onConfirm: () async {
            await updateTableStatus(table, statusInfo['newStatus']!);
            if (context.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  // Uses ChangeNotifier.notifyListeners()
}

// Dialog widget dipisahkan sebagai stateless widget
class _UpdateStatusDialog extends StatelessWidget {
  final RestoTable table;
  final String newStatusText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _UpdateStatusDialog({
    required this.table,
    required this.newStatusText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: kBackgroundColor,
      child: SizedBox(
        width: 400,
        height: 300,
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
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),

              const SizedBox(height: 28),

              // BUTTONS
              Row(
                children: [
                  // CANCEL BUTTON
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
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
                      onPressed: onConfirm,
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
      ),
    );
  }
}
