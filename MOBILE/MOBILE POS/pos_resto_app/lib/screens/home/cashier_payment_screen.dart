// lib/screens/home/cashier_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CashierPaymentScreen extends StatefulWidget {
  final CartProvider cart;
  final List<RestoTable> tables;
  final ApiService apiService;
  final VoidCallback onOrderSuccess;

  const CashierPaymentScreen({
    super.key,
    required this.cart,
    required this.tables,
    required this.apiService,
    required this.onOrderSuccess,
  });

  @override
  State<CashierPaymentScreen> createState() => _CashierPaymentScreenState();
}

class _CashierPaymentScreenState extends State<CashierPaymentScreen> {
  int? selectedTableId;
  String? selectedPaymentMethod;
  final TextEditingController receivedController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController(text: 'Udean');
  bool isSubmitting = false;

  @override
  void dispose() {
    receivedController.dispose();
    customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double received = double.tryParse(receivedController.text) ?? 0;
    double change = (received > widget.cart.total) ? received - widget.cart.total : 0;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: kLightGreyColor.withOpacity(0.3),
                  padding: const EdgeInsets.only(
                    top: 24.0,
                    left: 72.0,
                    right: 24.0,
                    bottom: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedTableId == null
                                    ? 'Pilih Meja'
                                    : 'Meja ${_getTableNumber(selectedTableId!)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 250,
                                child: TextField(
                                  controller: customerNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Pelanggan',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                                    border: UnderlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: kSecondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: kPrimaryColor, size: 28),
                            onPressed: () {
                              _showTableSelectionDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.cart.items.length,
                          itemBuilder: (context, index) {
                            final item = widget.cart.items[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: kPrimaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}'.padLeft(2, '0'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.menu.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'x ${item.quantity}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: kSecondaryColor.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummarySection(widget.cart, change),
                      const SizedBox(height: 16),
                      _buildPaymentMethodSection(),
                      const SizedBox(height: 16),
                      _buildOrderButton(change),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildCalculatorSection(received, change),
              ),
            ],
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: Container(
              decoration: BoxDecoration(
                color: kBackgroundColor.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: kSecondaryColor, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(CartProvider cart, double change) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', 'Rp ${cart.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax 10%', 'Rp ${(cart.subtotal * cart.taxPercent / 100).toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Tip', 'Rp 500'),
          const Divider(height: 24, thickness: 1),
          _buildSummaryRow('Total', 'Rp ${cart.total.toStringAsFixed(0)}', isTotal: true),
          if (change > 0 && selectedPaymentMethod == 'cash')
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _buildSummaryRow(
                'Kembalian',
                'Rp ${change.toStringAsFixed(0)}',
                isChange: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Received', 'Rp ${double.tryParse(receivedController.text) ?? 0}'),
          const SizedBox(height: 24),
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodButton(
                  'Cash',
                  Icons.money,
                  'cash',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentMethodButton(
                  'Debit Card',
                  Icons.credit_card,
                  'debit',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentMethodButton(
                  'E-Wallet',
                  Icons.account_balance_wallet,
                  'qris',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton(double change) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (selectedTableId == null ||
                    selectedPaymentMethod == null ||
                    customerNameController.text.isEmpty ||
                    isSubmitting)
            ? null
            : () async {
                if (selectedPaymentMethod == 'debit' || selectedPaymentMethod == 'qris') {
                  final bool? isConfirmed = await _showPaymentConfirmationDialog(
                    context,
                    selectedPaymentMethod!,
                  );

                  if (isConfirmed != true) {
                    return;
                  }
                }

                setState(() {
                  isSubmitting = true;
                });

                try {
                  final orderData = widget.cart.createOrderJson(
                    tableId: selectedTableId!,
                    paymentMethod: selectedPaymentMethod!,
                    customerName: customerNameController.text,
                  );

                  final Order newOrder = await widget.apiService.createOrder(orderData);

                  await widget.apiService.createTransaction({
                    'order_id': newOrder.id,
                    'payment_method': selectedPaymentMethod!,
                    'amount_paid': receivedController.text.isNotEmpty
                        ? double.parse(receivedController.text)
                        : widget.cart.total,
                  });

                  await widget.apiService.updateTableStatus(selectedTableId!, 'occupied');

                  widget.cart.clearCart();
                  Navigator.of(context).pop();
                  _showSuccessOrderDialog(context);
                  widget.onOrderSuccess();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal: ${e.toString().replaceFirst("Exception: ", "")}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    setState(() {
                      isSubmitting = false;
                    });
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kBackgroundColor,
                ),
              )
            : const Text(
                'Order Completed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kBackgroundColor,
                ),
              ),
      ),
    );
  }

  Widget _buildCalculatorSection(double received, double change) {
    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Uang Pembayaran',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kLightGreyColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Rp ${received.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildCalculatorButton('1'),
                _buildCalculatorButton('2'),
                _buildCalculatorButton('3'),
                _buildCalculatorButton('4'),
                _buildCalculatorButton('5'),
                _buildCalculatorButton('6'),
                _buildCalculatorButton('7'),
                _buildCalculatorButton('8'),
                _buildCalculatorButton('9'),
                _buildCalculatorButton('0'),
                _buildCalculatorButton('X', isDelete: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _printReceipt(context, received, change);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: kPrimaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Buat Nota',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      receivedController.text = widget.cart.total.toStringAsFixed(0);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kBackgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isChange = false}) {
    final Color valueColor = isChange ? Colors.blueAccent : (isTotal ? kPrimaryColor : kSecondaryColor);
    final Color labelColor = isChange ? Colors.blueAccent : kSecondaryColor.withOpacity(0.8);
    final double fontSize = (isTotal || isChange) ? 18 : 16;
    final FontWeight fontWeight = (isTotal || isChange) ? FontWeight.bold : FontWeight.normal;

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

  Widget _buildPaymentMethodButton(String label, IconData icon, String method) {
    final bool isSelected = selectedPaymentMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
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
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : kSecondaryColor,
            ),
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

  Widget _buildCalculatorButton(String value, {bool isDelete = false}) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isDelete) {
            if (receivedController.text.isNotEmpty) {
              receivedController.text = receivedController.text.substring(0, receivedController.text.length - 1);
            }
          } else {
            receivedController.text += value;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete ? kPrimaryColor : const Color(0xFFFFF4E0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

  String _getTableNumber(int tableId) {
    return widget.tables.firstWhere((t) => t.id == tableId).number;
  }

  void _showTableSelectionDialog(BuildContext context) {
    final availableTables = widget.tables
        .where((t) => t.status.toLowerCase() == 'available')
        .toList();

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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? kPrimaryColor : kSecondaryColor,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: kPrimaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedTableId = table.id;
                    });
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

  Future<bool?> _showPaymentConfirmationDialog(BuildContext context, String method) async {
    final bool isDebit = method == 'debit';
    final String title = isDebit ? 'Pembayaran Debit' : 'Pembayaran E-Wallet';
    final Widget imageWidget = isDebit
        ? const Icon(Icons.credit_card, size: 100, color: kPrimaryColor)
        : const Icon(Icons.qr_code_2, size: 100, color: kPrimaryColor);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
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
    );
  }

  void _showSuccessOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
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

  void _printReceipt(BuildContext context, double received, double change) {
    if (selectedTableId == null || selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih meja dan metode pembayaran dulu.')),
      );
      return;
    }

    final String tableName = _getTableNumber(selectedTableId!);

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
                Text('Meja: $tableName'),
                const Divider(),
                ...widget.cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.quantity}x ${item.menu.name}')),
                      Text('Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}'),
                    ],
                  ),
                )),
                const Divider(),
                _buildSummaryRow('Subtotal', 'Rp ${widget.cart.subtotal.toStringAsFixed(0)}'),
                _buildSummaryRow('Tax 10%', 'Rp ${(widget.cart.subtotal * widget.cart.taxPercent / 100).toStringAsFixed(0)}'),
                _buildSummaryRow('Tip', 'Rp 500'),
                const Divider(),
                _buildSummaryRow('Total', 'Rp ${widget.cart.total.toStringAsFixed(0)}', isTotal: true),
                const Divider(),
                _buildSummaryRow('Metode', selectedPaymentMethod!.toUpperCase()),
                _buildSummaryRow('Diterima', 'Rp ${received.toStringAsFixed(0)}'),
                if (change > 0 && selectedPaymentMethod == 'cash')
                  _buildSummaryRow('Kembali', 'Rp ${change.toStringAsFixed(0)}', isChange: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final Uint8List pdfData = await _generatePdfReceipt(
                    received,
                    change,
                    tableName,
                  );
                  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membuat PDF: $e')),
                    );
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

  Future<Uint8List> _generatePdfReceipt(
    double received,
    double change,
    String tableName,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 5 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('Eat.o Nota', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Nama: ${customerNameController.text}'),
              pw.Text('Meja: $tableName'),
              pw.Divider(height: 15),
              for (final item in widget.cart.items)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${item.quantity}x ${item.menu.name}'),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}'),
                        ]
                      )
                    ],
                  ),
                ),
              pw.Divider(height: 15),
              _buildPdfSummaryRow('Subtotal', 'Rp ${widget.cart.subtotal.toStringAsFixed(0)}'),
              _buildPdfSummaryRow('Tax 10%', 'Rp ${(widget.cart.subtotal * widget.cart.taxPercent / 100).toStringAsFixed(0)}'),
              _buildPdfSummaryRow('Tip', 'Rp 500'),
              pw.Divider(),
              _buildPdfSummaryRow('Total', 'Rp ${widget.cart.total.toStringAsFixed(0)}', isTotal: true),
              pw.Divider(),
              _buildPdfSummaryRow('Metode', selectedPaymentMethod!.toUpperCase()),
              _buildPdfSummaryRow('Diterima', 'Rp ${received.toStringAsFixed(0)}'),
              if (change > 0 && selectedPaymentMethod == 'cash')
                _buildPdfSummaryRow('Kembali', 'Rp ${change.toStringAsFixed(0)}', isChange: true),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Terima kasih!')),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfSummaryRow(String label, String value, {bool isTotal = false, bool isChange = false}) {
    final style = pw.TextStyle(
      fontWeight: (isTotal || isChange) ? pw.FontWeight.bold : pw.FontWeight.normal,
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
}