import 'dart:convert';

List<Menu> menuFromJson(String str) =>
    List<Menu>.from(json.decode(str).map((x) => Menu.fromJson(x)));

List<Category> categoryFromJson(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

class Menu {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String? description;

  // 🔧 FIX: Tidak lagi final supaya aman saat manipulasi data
  String? imageUrl;

  final Category? category;
  final int categoryId;

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    this.category,
    required this.categoryId,
  });

// untuk tahu barang habis atau tidak berdasarkan stok.
  bool get isAvailable => stock > 0;

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        id: json["id"] ?? 0,
        name: json["name"] ?? 'Nama Menu Error',
        price: double.tryParse(json["price"]?.toString() ?? '0.0') ?? 0.0,
        stock: json["stock"] ?? 0,
        description: json["description"],
        imageUrl: json["image_url"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        categoryId: json["category_id"] ?? 0,
      );
}

class Category {
  final int id;
  final String name;
  final int? menusCount;

  Category({
    required this.id,
    required this.name,
    this.menusCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"] ?? 0,
        name: json["name"] ?? 'Nama Kategori Error',
        menusCount: json["menus_count"],
      );
}