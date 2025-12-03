// lib/screens/home/cashier_payment_controller.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CashierPaymentController extends ChangeNotifier {
  final BuildContext context;
  final CartProvider cart;
  final List<RestoTable> tables;
  final ApiService apiService;
  final VoidCallback onOrderSuccess;

  // State variables
  int? selectedTableId;
  String? selectedPaymentMethod;
  String serviceType = 'meja'; // 'meja' atau 'self_service'
  bool isSubmitting = false;

  // Controllers
  final TextEditingController receivedController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController(
    text: '',
  );

  // Payment method options
  final List<Map<String, dynamic>> paymentMethods = [
    {'label': 'Cash', 'icon': Icons.money, 'method': 'cash'},
    {'label': 'Debit Card', 'icon': Icons.credit_card, 'method': 'debit'},
    {
      'label': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'method': 'qris',
    },
  ];

  CashierPaymentController({
    required this.context,
    required this.cart,
    required this.tables,
    required this.apiService,
    required this.onOrderSuccess,
  });

  // Getter untuk received amount
  double get receivedAmount {
    return double.tryParse(receivedController.text) ?? 0;
  }

  // Getter untuk change amount
  double get changeAmount {
    return receivedAmount > cart.total ? receivedAmount - cart.total : 0;
  }

  // Method untuk mengubah service type
  void setServiceType(String type) {
    serviceType = type;
    if (type == 'self_service') {
      selectedTableId = null;
    }
    notifyListeners();
  }

  // Method untuk mengubah payment method
  void setPaymentMethod(String method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  // Method untuk mengubah selected table
  void setSelectedTable(int? tableId) {
    selectedTableId = tableId;
    notifyListeners();
  }

  // Get table number
  String getTableNumber(int tableId) {
    try {
      return tables.firstWhere((t) => t.id == tableId).number;
    } catch (e) {
      return '??';
    }
  }

  // Get available tables
  List<RestoTable> getAvailableTables() {
    return tables.where((t) => t.status.toLowerCase() == 'available').toList();
  }

  // Get service name for display
  String getServiceName() {
    if (serviceType == 'meja' && selectedTableId != null) {
      return 'Meja ${getTableNumber(selectedTableId!)}';
    } else if (serviceType == 'self_service') {
      return 'Ambil Sendiri';
    }
    return 'Belum Pilih Meja';
  }

  // Validasi form
  bool validateForm() {
    if (customerNameController.text.isEmpty) {
      showSnackBar('Nama pelanggan wajib diisi', color: Colors.red);
      return false;
    }

    if (serviceType == 'meja' && selectedTableId == null) {
      showSnackBar('Pilih meja untuk dine-in', color: Colors.red);
      return false;
    }

    if (selectedPaymentMethod == null) {
      showSnackBar('Pilih metode pembayaran', color: Colors.red);
      return false;
    }

    if (selectedPaymentMethod == 'cash' && receivedAmount < cart.total) {
      showSnackBar(
        'Uang tunai yang diterima kurang dari total',
        color: Colors.red,
      );
      return false;
    }

    return true;
  }

  // Proses order
  Future<void> processOrder() async {
    if (!validateForm()) return;

    if (selectedPaymentMethod == 'debit' || selectedPaymentMethod == 'qris') {
      final isConfirmed = await showPaymentConfirmationDialog(
        selectedPaymentMethod!,
      );
      if (!isConfirmed) return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      // Buat order
      final orderData = cart.createOrderJson(
        tableId: selectedTableId,
        paymentMethod: selectedPaymentMethod!,
        customerName: customerNameController.text,
        status:
            (selectedPaymentMethod == 'debit' ||
                selectedPaymentMethod == 'qris')
            ? 'pending'
            : 'paid',
      );

      final Order newOrder = await apiService.createOrder(orderData);

      // Buat transaksi
      await apiService.createTransaction({
        'order_id': newOrder.id,
        'payment_method': selectedPaymentMethod!,
        'amount_paid': receivedController.text.isNotEmpty
            ? double.parse(receivedController.text)
            : cart.total,
      });

      // Update status meja jika dine-in
      if (selectedTableId != null) {
        await apiService.updateTableStatus(selectedTableId!, 'occupied');
      }

      // Clear cart
      cart.clearCart();

      // Notify success
      onOrderSuccess();

      isSubmitting = false;
      notifyListeners();
    } catch (e) {
      isSubmitting = false;
      notifyListeners();

      showSnackBar(
        'Gagal: ${e.toString().replaceFirst("Exception: ", "")}',
        color: Colors.red,
      );
    }
  }

  // Calculator methods
  void calculatorInput(String value) {
    if (value == 'X') {
      if (receivedController.text.isNotEmpty) {
        receivedController.text = receivedController.text.substring(
          0,
          receivedController.text.length - 1,
        );
      }
    } else {
      receivedController.text += value;
    }
    notifyListeners();
  }

  void applyExactAmount() {
    receivedController.text = cart.total.toStringAsFixed(0);
    notifyListeners();
  }

  // Generate PDF receipt
  Future<Uint8List> generatePdfReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Eat.o Nota',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Tanggal: ${DateFormat('dd/MM/yy HH:mm').format(DateTime.now())}',
              ),
              pw.Text('Nama: ${customerNameController.text}'),
              pw.Text('Layanan: ${getServiceName()}'),
              pw.Divider(height: 15),
              for (final item in cart.items)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${item.quantity}x ${item.menu.name}'),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              pw.Divider(height: 15),
              _buildPdfSummaryRow(
                'Subtotal',
                'Rp ${cart.subtotal.toStringAsFixed(0)}',
              ),
              _buildPdfSummaryRow(
                'Tax 10%',
                'Rp ${(cart.subtotal * cart.taxPercent / 100).toStringAsFixed(0)}',
              ),
              _buildPdfSummaryRow('Tip', 'Rp 500'),
              pw.Divider(),
              _buildPdfSummaryRow(
                'Total',
                'Rp ${cart.total.toStringAsFixed(0)}',
                isTotal: true,
              ),
              pw.Divider(),
              _buildPdfSummaryRow(
                'Metode',
                selectedPaymentMethod!.toUpperCase(),
              ),
              _buildPdfSummaryRow(
                'Diterima',
                'Rp ${receivedAmount.toStringAsFixed(0)}',
              ),
              if (changeAmount > 0 && selectedPaymentMethod == 'cash')
                _buildPdfSummaryRow(
                  'Kembali',
                  'Rp ${changeAmount.toStringAsFixed(0)}',
                  isChange: true,
                ),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Terima kasih!')),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isChange = false,
  }) {
    final style = pw.TextStyle(
      fontWeight: (isTotal || isChange)
          ? pw.FontWeight.bold
          : pw.FontWeight.normal,
      fontSize: (isTotal || isChange) ? 12 : 10,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  // Show payment confirmation dialog
  Future<bool> showPaymentConfirmationDialog(String method) async {
    final isDebit = method == 'debit';
    final String title = isDebit ? 'Pembayaran Debit' : 'Pembayaran E-Wallet';

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isDebit
                      ? const Icon(
                          Icons.credit_card,
                          size: 100,
                          color: kPrimaryColor,
                        )
                      : const Icon(
                          Icons.qr_code_2,
                          size: 100,
                          color: kPrimaryColor,
                        ),
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
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batalkan'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Selesai'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Show success dialog
  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 500,
            height: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Pesanan Berhasil!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: kPrimaryColor,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Lanjutkan Transaksi',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show table selection dialog
  void showTableSelectionDialog() {
    final availableTables = getAvailableTables();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pilih Meja'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              itemCount: availableTables.length,
              itemBuilder: (context, index) {
                final table = availableTables[index];
                final isSelected = table.id == selectedTableId;
                return ListTile(
                  leading: Icon(
                    Icons.table_restaurant,
                    color: isSelected ? kPrimaryColor : kSecondaryColor,
                  ),
                  title: Text(
                    'Meja ${table.number}',
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? kPrimaryColor : kSecondaryColor,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: kPrimaryColor)
                      : null,
                  onTap: () {
                    setSelectedTable(table.id);
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Show receipt dialog
  void showReceiptDialog() async {
    if (!validateForm()) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nota Pesanan'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nama: ${customerNameController.text}'),
                Text('Layanan: ${getServiceName()}'),
                const Divider(),
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('${item.quantity}x ${item.menu.name}'),
                        ),
                        Text(
                          'Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                _buildSummaryRow(
                  'Subtotal',
                  'Rp ${cart.subtotal.toStringAsFixed(0)}',
                ),
                _buildSummaryRow(
                  'Tax 10%',
                  'Rp ${(cart.subtotal * cart.taxPercent / 100).toStringAsFixed(0)}',
                ),
                _buildSummaryRow('Tip', 'Rp 500'),
                const Divider(),
                _buildSummaryRow(
                  'Total',
                  'Rp ${cart.total.toStringAsFixed(0)}',
                  isTotal: true,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Metode',
                  selectedPaymentMethod!.toUpperCase(),
                ),
                _buildSummaryRow(
                  'Diterima',
                  'Rp ${receivedAmount.toStringAsFixed(0)}',
                ),
                if (changeAmount > 0 && selectedPaymentMethod == 'cash')
                  _buildSummaryRow(
                    'Kembali',
                    'Rp ${changeAmount.toStringAsFixed(0)}',
                    isChange: true,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(' '),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final pdfData = await generatePdfReceipt();
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfData,
                  );
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    showSnackBar('Gagal membuat PDF: $e');
                  }
                }
              },
              child: const Text('Print'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isChange = false,
  }) {
    final Color valueColor = isChange
        ? Colors.blueAccent
        : (isTotal ? kPrimaryColor : kSecondaryColor);
    final Color labelColor = isChange
        ? Colors.blueAccent
        : kSecondaryColor.withOpacity(0.8);
    final double fontSize = (isTotal || isChange) ? 18 : 16;
    final FontWeight fontWeight = (isTotal || isChange)
        ? FontWeight.bold
        : FontWeight.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color ?? kPrimaryColor),
    );
  }

  // Cleanup
  void dispose() {
    receivedController.dispose();
    customerNameController.dispose();
    super.dispose();
  }

  // Uses ChangeNotifier.notifyListeners()
}
