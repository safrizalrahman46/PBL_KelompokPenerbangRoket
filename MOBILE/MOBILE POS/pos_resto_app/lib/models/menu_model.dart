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

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    this.category,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        id: json["id"],
        name: json["name"],
        price: double.tryParse(json["price"]?.toString() ?? '0.0') ?? 0.0,
        stock: json["stock"] ?? 0,
        description: json["description"],
        imageUrl: json["image_url"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
      );
}

class Category {
  final int id;
  final String name;
  // Kita tambahkan 'menus_count' sesuai API Laravel
  final int? menusCount; 

  Category({required this.id, required this.name, this.menusCount});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        menusCount: json["menus_count"],
      );
}