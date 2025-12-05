// lib/screens/home/cashier_table_screen.dart

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../controllers/cashier_table_controller.dart';

class CashierTableScreen extends StatefulWidget {
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
  State<CashierTableScreen> createState() => _CashierTableScreenState();
}

class _CashierTableScreenState extends State<CashierTableScreen> {
  late CashierTableController _controller;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = CashierTableController(
      context: context,
      tables: widget.tables,
      onRefresh: widget.onRefresh,
      apiService: widget.apiService,
    );
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);
  }

  @override
  void didUpdateWidget(CashierTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }

    // Update controller jika data berubah
    _controller = CashierTableController(
      context: context,
      tables: widget.tables,
      onRefresh: widget.onRefresh,
      apiService: widget.apiService,
    );

    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }
    super.dispose();
  }

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
              onRefresh: widget.onRefresh,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: _controller.getSortedTables().length,
                itemBuilder: (context, index) {
                  final table = _controller.getSortedTables()[index];
                  return _buildTableCard(table);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(RestoTable table) {
    final statusInfo = _controller.getTableStatusInfo(table);

    return GestureDetector(
      onTap: () {
        _controller.showUpdateStatusDialog(table);
      },
      child: Card(
        elevation: 4,
        color: statusInfo['cardColor'] as Color,
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
                  color: statusInfo['textColor'] as Color,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                statusInfo['statusText'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: statusInfo['statusColor'] as Color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
