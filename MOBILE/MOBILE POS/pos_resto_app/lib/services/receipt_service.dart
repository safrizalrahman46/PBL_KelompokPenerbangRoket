// lib/screens/home/payment/receipt_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../providers/cart_provider.dart';
import '../../../utils/constants.dart';

class ReceiptService {
  Future<void> printReceipt({
    required BuildContext context,
    required CartProvider cart,
    required String customerName,
    required int? tableId,
    required String tableName,
    required String? paymentMethod,
    required double received,
  }) async {
    if (tableId == null || paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih meja dan metode pembayaran dulu.')),
      );
      return;
    }

    final double change = (received > cart.total) ? received - cart.total : 0;

    // Show preview dialog
    await showDialog(
      context: context,
      builder: (dialogContext) => _buildReceiptPreviewDialog(
        context: dialogContext,
        cart: cart,
        customerName: customerName,
        tableName: tableName,
        paymentMethod: paymentMethod,
        received: received,
        change: change,
      ),
    );
  }

  Widget _buildReceiptPreviewDialog({
    required BuildContext context,
    required CartProvider cart,
    required String customerName,
    required String tableName,
    required String paymentMethod,
    required double received,
    required double change,
  }) {
    return AlertDialog(
      title: const Text('Nota Pesanan'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nama: $customerName'),
            Text('Meja: $tableName'),
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
            _buildSummaryRow('Metode', paymentMethod.toUpperCase()),
            _buildSummaryRow('Diterima', 'Rp ${received.toStringAsFixed(0)}'),
            if (change > 0 && paymentMethod == 'cash')
              _buildSummaryRow(
                'Kembali',
                'Rp ${change.toStringAsFixed(0)}',
                isChange: true,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(' '),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final pdfData = await _generatePdfReceipt(
                cart,
                customerName,
                tableName,
                paymentMethod,
                received,
                change,
              );
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdfData,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota berhasil dicetak!')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal membuat PDF: $e')),
                );
              }
            }
          },
          child: const Text('Print PDF'),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: kSecondaryColor.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdfReceipt(
    CartProvider cart,
    String customerName,
    String tableName,
    String paymentMethod,
    double received,
    double change,
  ) async {
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
              // Header
              pw.Center(
                child: pw.Text(
                  'EAT.O RESTAURANT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'NOTA PEMBAYARAN',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Divider(height: 10, thickness: 1),

              // Customer Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Nama: $customerName',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Meja: $tableName',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Tanggal: ${_getFormattedDate()}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Waktu: ${_getFormattedTime()}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Divider(height: 10, thickness: 0.5),

              // Items Header
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Qty',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Harga',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Divider(height: 5, thickness: 0.3),

              // Items
              for (final item in cart.items)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          item.menu.name,
                          style: const pw.TextStyle(fontSize: 9),
                          maxLines: 2,
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          '${item.quantity}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),

              pw.Divider(height: 10, thickness: 0.5),

              // Summary
              _buildPdfSummaryRow(
                'Subtotal',
                'Rp ${cart.subtotal.toStringAsFixed(0)}',
              ),
              _buildPdfSummaryRow(
                'Pajak 10%',
                'Rp ${(cart.subtotal * cart.taxPercent / 100).toStringAsFixed(0)}',
              ),
              _buildPdfSummaryRow('Tip', 'Rp 500'),
              pw.Divider(height: 5, thickness: 0.5),
              _buildPdfSummaryRow(
                'TOTAL',
                'Rp ${cart.total.toStringAsFixed(0)}',
                isTotal: true,
              ),
              pw.Divider(height: 10, thickness: 0.5),

              // Payment Info
              _buildPdfSummaryRow('Metode Bayar', paymentMethod.toUpperCase()),
              _buildPdfSummaryRow(
                'Diterima',
                'Rp ${received.toStringAsFixed(0)}',
              ),
              if (change > 0 && paymentMethod == 'cash')
                _buildPdfSummaryRow(
                  'KEMBALI',
                  'Rp ${change.toStringAsFixed(0)}',
                  isChange: true,
                ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Terima kasih atas kunjungannya!',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Semoga makanan kami memuaskan :)',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
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
      fontSize: (isTotal || isChange) ? 10 : 9,
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }
}
