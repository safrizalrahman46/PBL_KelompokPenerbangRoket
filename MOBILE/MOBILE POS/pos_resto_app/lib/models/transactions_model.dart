class Transaction {
  final int id;
  final int orderId;
  final String paymentMethod;
  final double amountPaid;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amountPaid,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      orderId: json['order_id'],
      paymentMethod: json['payment_method'],
      amountPaid: double.parse(json['amount_paid'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}