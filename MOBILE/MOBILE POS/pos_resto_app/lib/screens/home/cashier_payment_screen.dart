// lib/screens/home/cashier_payment_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../controllers/cashier_payment_controller.dart';

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
  late CashierPaymentController _controller;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = CashierPaymentController(
      context: context,
      cart: widget.cart,
      tables: widget.tables,
      apiService: widget.apiService,
      onOrderSuccess: widget.onOrderSuccess,
    );
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }
    _controller.dispose();
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
              // --- PANEL KIRI ---
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Nama Pelanggan
                        const Text(
                          "Nama Pelanggan (Wajib)",
                          style: TextStyle(
                            fontSize: 16,
                            color: kSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _controller.customerNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Pelanggan',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              border: UnderlineInputBorder(),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: kSecondaryColor,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Tipe Layanan
                        const Text(
                          "Tipe Layanan",
                          style: TextStyle(
                            fontSize: 16,
                            color: kSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ToggleButtons(
                          borderColor: kPrimaryColor.withOpacity(0.5),
                          selectedBorderColor: kPrimaryColor,
                          selectedColor: Colors.white,
                          fillColor: kPrimaryColor,
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(8),
                          constraints: const BoxConstraints(
                            minHeight: 45.0,
                            minWidth: 150.0,
                          ),
                          isSelected: [
                            _controller.serviceType == 'meja',
                            _controller.serviceType == 'self_service',
                          ],
                          onPressed: (int index) {
                            _controller.setServiceType(
                              index == 0 ? 'meja' : 'self_service',
                            );
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.restaurant_menu, size: 18),
                                  SizedBox(width: 8),
                                  Text('Dine-In (Meja)'),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.shopping_bag, size: 18),
                                  SizedBox(width: 8),
                                  Text('Ambil Sendiri'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 3. Pilihan Meja (Kondisional)
                        if (_controller.serviceType == 'meja')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Meja Terpilih",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: kSecondaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _controller.selectedTableId == null
                                        ? 'Belum Pilih Meja'
                                        : 'Meja ${_controller.getTableNumber(_controller.selectedTableId!)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: kPrimaryColor,
                                  size: 28,
                                ),
                                onPressed: _controller.showTableSelectionDialog,
                              ),
                            ],
                          ),

                        if (_controller.serviceType == 'meja')
                          const SizedBox(height: 24),

                        // 4. Daftar Pesanan
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: kSecondaryColor.withOpacity(
                                              0.6,
                                            ),
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
                        const SizedBox(height: 16),
                        _buildSummarySection(),
                        const SizedBox(height: 16),
                        _buildPaymentMethodSection(),
                        const SizedBox(height: 16),
                        _buildOrderButton(),
                      ],
                    ),
                  ),
                ),
              ),
              // --- PANEL KANAN (Kalkulator) ---
              Expanded(flex: 1, child: _buildCalculatorSection()),
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: kSecondaryColor,
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Subtotal',
            'Rp ${widget.cart.subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Tax 10%',
            'Rp ${(widget.cart.subtotal * widget.cart.taxPercent / 100).toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Tip', 'Rp 500'),
          const Divider(height: 24, thickness: 1),
          _buildSummaryRow(
            'Total',
            'Rp ${widget.cart.total.toStringAsFixed(0)}',
            isTotal: true,
          ),
          if (_controller.changeAmount > 0 &&
              _controller.selectedPaymentMethod == 'cash')
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _buildSummaryRow(
                'Kembalian',
                'Rp ${_controller.changeAmount.toStringAsFixed(0)}',
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
          _buildSummaryRow(
            'Received',
            'Rp ${_controller.receivedAmount.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: _controller.paymentMethods.map((method) {
              final bool isSelected =
                  _controller.selectedPaymentMethod == method['method'];
              return Expanded(
                child: _buildPaymentMethodButton(method, isSelected),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _controller.isSubmitting
            ? null
            : () async {
                await _controller.processOrder();
                // Show splash burst animation
                showOrderSuccessSplash(context);

                // Close the payment screen
                Navigator.of(context).pop();

                // Show success dialog
                _controller.showSuccessDialog();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: _controller.isSubmitting
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

  Widget _buildCalculatorSection() {
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
              'Rp ${_controller.receivedAmount.toStringAsFixed(0)}',
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
                _buildCalculatorButton('000'),
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
                  onPressed: _controller.showReceiptDialog,
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
                  onPressed: _controller.applyExactAmount,
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

  Widget _buildPaymentMethodButton(
    Map<String, dynamic> method,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _controller.setPaymentMethod(method['method'] as String),
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
                method['icon'] as IconData,
                size: 32,
                color: isSelected ? Colors.white : kSecondaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                method['label'] as String,
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
      ),
    );
  }

  Widget _buildCalculatorButton(String value, {bool isDelete = false}) {
    return ElevatedButton(
      onPressed: () => _controller.calculatorInput(value),
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
}

// SPLASH BURST ANIMATION WIDGETS (UI only)
void showOrderSuccessSplash(BuildContext context) {
  final overlayState = Overlay.of(context);

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: Center(child: SplashBurst(size: 260, particles: 20)),
        ),
      );
    },
  );

  overlayState.insert(entry);

  Future.delayed(const Duration(milliseconds: 800), () {
    try {
      entry.remove();
    } catch (_) {}
  });
}

class SplashBurst extends StatefulWidget {
  final double size;
  final int particles;

  const SplashBurst({super.key, this.size = 180, this.particles = 18});

  @override
  _SplashBurstState createState() => _SplashBurstState();
}

class _SplashBurstState extends State<SplashBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();

    final random = Random();
    _particles = List.generate(widget.particles, (index) {
      return _Particle(
        angle: random.nextDouble() * 2 * pi,
        speed: random.nextDouble() * 40 + 40,
        radius: random.nextDouble() * 6 + 4,
        color: Colors.primaries[random.nextInt(Colors.primaries.length)]
            .withOpacity(0.95),
      );
    });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _BurstPainter(
          progress: _controller.value,
          particles: _particles,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double radius;
  final Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
  });
}

class _BurstPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _BurstPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity((1 - progress) * 0.4)
      ..style = PaintingStyle.fill;
    final glowRadius = (size.shortestSide / 6) * (1 + progress * 1.6);
    canvas.drawCircle(center, glowRadius, glowPaint);

    for (var p in particles) {
      final dx = cos(p.angle) * p.speed * progress;
      final dy = sin(p.angle) * p.speed * progress;

      final position = Offset(center.dx + dx, center.dy + dy);

      final paint = Paint()
        ..color = p.color.withOpacity((1 - progress).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, p.radius * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles.length != particles.length;
  }
}
