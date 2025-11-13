// lib/screens/home/cashier_table_screen.dart

import 'package:flutter/material.dart';
import '../../../models/table_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/constants.dart';

class CashierTableScreen extends StatefulWidget {
  final List<RestoTable> tables;
  final VoidCallback onRefresh;
  final ApiService apiService;

  const CashierTableScreen({
    super.key,
    required this.tables,
    required this.onRefresh,
    required this.apiService,
  });

  @override
  State<CashierTableScreen> createState() => _CashierTableScreenState();
}

class _CashierTableScreenState extends State<CashierTableScreen> {
  @override
  Widget build(BuildContext context) {
    final sortedTables = List.of(widget.tables)
      ..sort((a, b) => a.number.compareTo(b.number));

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
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                widget.onRefresh();
              },
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: sortedTables.length,
                itemBuilder: (context, index) {
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

    final Color cardColor =
        isAvailable ? Colors.grey.shade500 : Colors.red.shade600;
    final Color textColor = isAvailable ? kSecondaryColor : Colors.white;
    final Color statusColor =
        isAvailable ? kSecondaryColor.withOpacity(0.8) : Colors.white.withOpacity(0.8);

    final String statusText = isAvailable ? 'Tersedia' : 'Terisi';

    return GestureDetector(
      onTap: () => _showUpdateStatusDialog(table, context),
      child: Card(
        elevation: 4,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              const SizedBox(height: 4),
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

  Future<void> _showUpdateStatusDialog(
      RestoTable table, BuildContext context) async {
    final bool isAvailable = table.status.toLowerCase() == 'available';
    final String newStatus = isAvailable ? 'occupied' : 'available';
    final String newStatusText = isAvailable ? 'Terisi' : 'Tersedia';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Ubah Status'),
          content: Text(
              'Ubah status "Meja ${table.number}" menjadi "$newStatusText"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await widget.apiService
                      .updateTableStatus(table.id, newStatus);

                  widget.onRefresh();

                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Status Meja ${table.number} berhasil diubah!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal update: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Ubah'),
            ),
          ],
        );
      },
    );
  }
}
