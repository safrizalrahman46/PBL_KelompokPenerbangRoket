// lib/screens/home/payment/payment_helpers.dart

import 'package:flutter/material.dart';
import '../../models/table_model.dart';
import '../../utils/constants.dart';

class PaymentHelpers {
  static Widget buildCalculatorButton(
    String value,
    TextEditingController controller,
    StateSetter setState, {
    bool isDelete = false,
  }) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isDelete) {
            if (controller.text.isNotEmpty) {
              controller.text = controller.text.substring(0, controller.text.length - 1);
            }
          } else {
            controller.text += value;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete ? kPrimaryColor : const Color(0xFFFFF4E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDelete ? kBackgroundColor : kSecondaryColor,
        ),
      ),
    );
  }

  static Widget buildPaymentMethodButton({
    required String label,
    required IconData icon,
    required String method,
    required String? selectedMethod,
    required Function(String) onSelect,
  }) {
    final bool isSelected = selectedMethod == method;
    return InkWell(
      onTap: () => onSelect(method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimaryColor : kLightGreyColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? Colors.white : kSecondaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : kSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildTableSelectionDialog({
    required BuildContext context,
    required List<RestoTable> tables,
    required int? currentTableId,
    required Function(int) onSelect,
  }) {
    final availableTables = tables.where((t) => t.status.toLowerCase() == 'available').toList();

    return AlertDialog(
      title: const Text('Pilih Meja'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ListView.builder(
          itemCount: availableTables.length,
          itemBuilder: (context, index) {
            final table = availableTables[index];
            final isSelected = table.id == currentTableId;
            return ListTile(
              leading: Icon(Icons.table_restaurant, color: isSelected ? kPrimaryColor : kSecondaryColor),
              title: Text(
                'Meja ${table.number}',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? kPrimaryColor : kSecondaryColor,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: kPrimaryColor) : null,
              onTap: () {
                onSelect(table.id);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
      ],
    );
  }

  static Future<bool?> showPaymentConfirmationDialog(BuildContext context, String method) async {
    final bool isDebit = method == 'debit';
    final String title = isDebit ? 'Pembayaran Debit' : 'Pembayaran E-Wallet';
    final Widget imageWidget = isDebit
        ? const Icon(Icons.credit_card, size: 100, color: kPrimaryColor)
        : const Icon(Icons.qr_code_2, size: 100, color: kPrimaryColor);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            imageWidget,
            const SizedBox(height: 16),
            Text(
              isDebit
                  ? 'Silakan gesek kartu debit. Tekan "Selesai" jika berhasil.'
                  : 'Silakan pindai QRIS. Tekan "Selesai" jika berhasil.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Batalkan')),
          ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Selesai')),
        ],
      ),
    );
  }
}