// lib/screens/home/payment/payment_screen.dart

import 'package:flutter/material.dart';
import '../../../models/table_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../services/api_service.dart';
import '../../../utils/constants.dart';
import '/../services/receipt_service.dart';
import '../../../helpers/payment_helpers.dart';

class PaymentScreen extends StatefulWidget {
  final CartProvider cart;
  final List<RestoTable> tables;
  final ApiService apiService;
  final VoidCallback onOrderSuccess;

  const PaymentScreen({
    super.key,
    required this.cart,
    required this.tables,
    required this.apiService,
    required this.onOrderSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int? selectedTableId;
  String? selectedPaymentMethod;
  final receivedController = TextEditingController();
  final customerNameController = TextEditingController(text: 'Udean');
  bool isSubmitting = false;

  final ReceiptService _receiptService = ReceiptService();

  @override
  void dispose() {
    receivedController.dispose();
    customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Row(
            children: [
              // KOLOM KIRI - Order Details
              Expanded(
                flex: 2,
                child: Container(
                  color: kLightGreyColor.withOpacity(0.3),
                  padding: const EdgeInsets.only(top: 24.0, left: 72.0, right: 24.0, bottom: 24.0),
                  child: _buildOrderDetails(),
                ),
              ),
              // KOLOM KANAN - Payment Calculator
              Expanded(
                flex: 1,
                child: Container(
                  color: kBackgroundColor,
                  padding: const EdgeInsets.all(24),
                  child: _buildPaymentCalculator(),
                ),
              ),
            ],
          ),
          // Tombol Back
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

  Widget _buildOrderDetails() {
    return StatefulBuilder(
      builder: (context, setState) {
        final double received = double.tryParse(receivedController.text) ?? 0;
        final double change = (received > widget.cart.total) ? received - widget.cart.total : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(setState),
            const SizedBox(height: 24),
            Expanded(child: _buildOrderItems()),
            const SizedBox(height: 16),
            _buildSummarySection(widget.cart, change),
            const SizedBox(height: 16),
            _buildPaymentMethodSection(setState),
            const SizedBox(height: 16),
            _buildOrderButton(setState, change),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSection(StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedTableId == null
                  ? 'Pilih Meja'
                  : 'Meja ${widget.tables.firstWhere((t) => t.id == selectedTableId).number}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryColor),
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
                style: const TextStyle(fontSize: 16, color: kSecondaryColor),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: kPrimaryColor, size: 28),
          onPressed: () => _showTableSelectionDialog(context, setState),
        ),
      ],
    );
  }

  Widget _buildOrderItems() {
    return ListView.builder(
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
                decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.menu.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('x ${item.quantity}', style: TextStyle(fontSize: 14, color: kSecondaryColor.withOpacity(0.6))),
                  ],
                ),
              ),
              Text(
                'Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(CartProvider cart, double change) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFF4E0), borderRadius: BorderRadius.circular(12)),
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
              child: _buildSummaryRow('Kembalian', 'Rp ${change.toStringAsFixed(0)}', isChange: true),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(StateSetter setState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFF4E0), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Received', 'Rp ${double.tryParse(receivedController.text)?.toStringAsFixed(0) ?? "0"}'),
          const SizedBox(height: 24),
          const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPaymentMethodButton('Cash', Icons.money, 'cash', setState),
              const SizedBox(width: 12),
              _buildPaymentMethodButton('Debit Card', Icons.credit_card, 'debit', setState),
              const SizedBox(width: 12),
              _buildPaymentMethodButton('E-Wallet', Icons.account_balance_wallet, 'qris', setState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodButton(String label, IconData icon, String method, StateSetter setState) {
    return Expanded(
      child: PaymentHelpers.buildPaymentMethodButton(
        label: label,
        icon: icon,
        method: method,
        selectedMethod: selectedPaymentMethod,
        onSelect: (method) => setState(() => selectedPaymentMethod = method),
      ),
    );
  }

  Widget _buildOrderButton(StateSetter setState, double change) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (selectedTableId == null || selectedPaymentMethod == null || customerNameController.text.isEmpty || isSubmitting)
            ? null
            : () => _processOrder(setState, change),
        style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: isSubmitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: kBackgroundColor))
            : const Text('Order Completed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kBackgroundColor)),
      ),
    );
  }

  Widget _buildPaymentCalculator() {
    return StatefulBuilder(
      builder: (context, setState) {
        final double received = double.tryParse(receivedController.text) ?? 0;

        return Column(
          children: [
            const Text('Uang Pembayaran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kSecondaryColor)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: kLightGreyColor, borderRadius: BorderRadius.circular(16)),
              child: Text('Rp ${received.toStringAsFixed(0)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: kPrimaryColor)),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildCalculatorGrid(setState)),
            const SizedBox(height: 24),
            _buildActionButtons(setState),
          ],
        );
      },
    );
  }

  Widget _buildCalculatorGrid(StateSetter setState) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        for (var i = 1; i <= 9; i++)
          PaymentHelpers.buildCalculatorButton(i.toString(), receivedController, setState),
        PaymentHelpers.buildCalculatorButton('0', receivedController, setState),
        PaymentHelpers.buildCalculatorButton('X', receivedController, setState, isDelete: true),
      ],
    );
  }

  Widget _buildActionButtons(StateSetter setState) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => _receiptService.printReceipt(
              context: context,
              cart: widget.cart,
              customerName: customerNameController.text,
              tableId: selectedTableId,
              tableName: selectedTableId != null ? widget.tables.firstWhere((t) => t.id == selectedTableId).number : '',
              paymentMethod: selectedPaymentMethod,
              received: double.tryParse(receivedController.text) ?? 0,
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: kPrimaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buat Nota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => receivedController.text = widget.cart.total.toStringAsFixed(0)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kBackgroundColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isChange = false}) {
    final Color valueColor = isChange ? Colors.blueAccent : (isTotal ? kPrimaryColor : kSecondaryColor);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: kSecondaryColor.withOpacity(0.8))),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  void _showTableSelectionDialog(BuildContext context, StateSetter setState) {
    showDialog(
      context: context,
      builder: (dialogContext) => PaymentHelpers.buildTableSelectionDialog(
        context: dialogContext,
        tables: widget.tables,
        currentTableId: selectedTableId,
        onSelect: (tableId) => setState(() => selectedTableId = tableId),
      ),
    );
  }

  Future<void> _processOrder(StateSetter setState, double change) async {
    if (selectedPaymentMethod == 'debit' || selectedPaymentMethod == 'qris') {
      final bool? isConfirmed = await PaymentHelpers.showPaymentConfirmationDialog(context, selectedPaymentMethod!);
      if (isConfirmed != true) return;
    }

    setState(() => isSubmitting = true);

    try {
      final orderData = widget.cart.createOrderJson(
        tableId: selectedTableId!,
        paymentMethod: selectedPaymentMethod!,
        customerName: customerNameController.text,
      );

      final newOrder = await widget.apiService.createOrder(orderData);
      
      await widget.apiService.createTransaction({
        'order_id': newOrder.id,
        'payment_method': selectedPaymentMethod!,
        'amount_paid': double.tryParse(receivedController.text) ?? widget.cart.total,
      });

      await widget.apiService.updateTableStatus(selectedTableId!, 'occupied');

      widget.cart.clearCart();
      Navigator.of(context).pop();
      widget.onOrderSuccess();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
        setState(() => isSubmitting = false);
      }
    }
  }
}