class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stock;
  final String farmerId;
  final List<String> images;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    required this.farmerId,
    required this.images,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stock': stock,
      'farmerId': farmerId,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      unit: map['unit'],
      stock: map['stock'],
      farmerId: map['farmerId'],
      images: List<String>.from(map['images']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} 