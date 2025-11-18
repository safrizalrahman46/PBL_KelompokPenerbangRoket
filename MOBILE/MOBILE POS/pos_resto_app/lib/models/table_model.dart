// lib/models/resto_table_model.dart

class RestoTable {
  final int id;
  final String number;
  final String status;
  final int? capacity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RestoTable({
    required this.id,
    required this.number,
    required this.status,
    this.capacity,
    this.createdAt,
    this.updatedAt,
  });

  factory RestoTable.fromJson(Map<String, dynamic> json) {
    return RestoTable(
      id: json['id'],
      number: json['number'],
      status: json['status'],
      capacity: json['capacity'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': status,
      'capacity': capacity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}