class MirrorItem {
  final String name;
  final int quantity;
  final double price;

  MirrorItem({required this.name, required this.quantity, required this.price});

  factory MirrorItem.fromJson(Map<String, dynamic> json) {
    return MirrorItem(
      name: json['name'] ?? 'Unknown',
      quantity: json['qty'] ?? 0, // Sesuaikan dengan key JSON backendmu
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}