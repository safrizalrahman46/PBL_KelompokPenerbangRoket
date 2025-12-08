import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../controllers/mirror_order_logic.dart';
import '../../utils/constants.dart';

class MirrorOrderScreen extends StatefulWidget {
  const MirrorOrderScreen({super.key});

  @override
  State<MirrorOrderScreen> createState() => _MirrorOrderScreenState();
}

class _MirrorOrderScreenState extends State<MirrorOrderScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MirrorOrderLogic>(context, listen: false).startPolling();
    });
  }

  @override
  void dispose() {
    final logic = Provider.of<MirrorOrderLogic>(context, listen: false);
    logic.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Consumer<MirrorOrderLogic>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Row(
            children: [

              // ================= KIRI : LIST ITEM =================
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    children: [

                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: kPrimaryColor,
                        child: const Row(
                          children: [
                            Expanded(flex: 5, child: Text('Keterangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('Jml', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('Harga', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),

                      // Item List
                      Expanded(
                        child: controller.items.isEmpty
                            ? Center(
                                child: controller.isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        "Menunggu Pesanan...",
                                        style: TextStyle(color: Colors.grey[400], fontSize: 18),
                                      ),
                              )
                            : ListView.separated(
                                itemCount: controller.items.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = controller.items[index];
                                  final isLastItem = index == controller.items.length - 1;

                                  return Container(
                                    color: isLastItem
                                        ? kPrimaryColor.withOpacity(0.1)
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "${item.quantity}",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            currencyFormat.format(item.price * item.quantity),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Subtotal
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[100],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Item: ${controller.items.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              "Subtotal: ${currencyFormat.format(controller.subtotal)}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= KANAN : DISPLAY UTAMA =================
              Expanded(
                flex: 6,
                child: Column(
                  children: [

                    // Logo
                    Expanded(
                      flex: 5,
                      child: Container(
                        width: double.infinity,
                        color: Colors.blueGrey[50],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/eato_logo.png', width: 90),
                            const SizedBox(height: 10),
                            Text(
                              "Eat.o Point of Sales",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: kPrimaryColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Total Besar
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Total Belanja", style: TextStyle(color: Colors.grey, fontSize: 20)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Rp ',
                                      style: TextStyle(color: Colors.orange, fontSize: 40, fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: NumberFormat('#,###', 'id_ID').format(controller.total),
                                      style: const TextStyle(color: Colors.orange, fontSize: 64, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ================= PEMBAYARAN =================
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Row(
                          children: [

                            // ✅ Nama Pelanggan & Metode Bayar
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Nama Pelanggan:", style: TextStyle(color: Colors.grey)),
                                  Text(
                                    controller.customerName.isNotEmpty
                                        ? controller.customerName
                                        : "Umum",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  const Text("Metode Bayar:", style: TextStyle(color: Colors.grey)),
                                  Text(
                                    controller.paymentMethod,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ✅ Nominal
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildMoneyRow("Diterima", controller.receivedAmount, currencyFormat),
                                  const SizedBox(height: 4),
                                  if (controller.changeAmount > 0)
                                    _buildMoneyRow(
                                      "Kembali",
                                      controller.changeAmount,
                                      currencyFormat,
                                      isHighlight: true,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Promo
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      width: double.infinity,
                      color: Colors.orangeAccent,
                      child: const Text(
                        "PROMO: Diskon 20% QRIS!",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoneyRow(String label, double amount, NumberFormat fmt, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: isHighlight ? 20 : 16, fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          fmt.format(amount),
          style: TextStyle(
            fontSize: isHighlight ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: isHighlight ? kPrimaryColor : Colors.black,
          ),
        ),
      ],
    );
  }
}
