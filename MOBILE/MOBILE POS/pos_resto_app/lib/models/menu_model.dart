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
  final String? imageUrl;
  final Category? category;
  final int categoryId; // <-- 1. TAMBAHKAN INI

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    this.category,
    required this.categoryId, // <-- 2. TAMBAHKAN INI
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        // id: json["id"],
        // name: json["name"],
        id: json["id"] ?? 0,
        name: json["name"] ?? 'Nama Menu Error',
        price: double.tryParse(json["price"]?.toString() ?? '0.0') ?? 0.0,
        stock: json["stock"] ?? 0,
        description: json["description"],
        imageUrl: json["image_url"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        categoryId: json["category_id"] ?? 0, // <-- 3. TAMBAHKAN INI
      );
}

class Category {
  final int id;
  final String name;
  // Kita tambahkan 'menus_count' sesuai API Laravel
  final int? menusCount; 

  Category({required this.id, required this.name, this.menusCount});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        // id: json["id"],
        // name: json["name"],
        id: json["id"] ?? 0,
        name: json["name"] ?? 'Nama Kategori Error',
        menusCount: json["menus_count"],
      );
}