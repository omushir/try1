import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stock;
  final String farmerId;
  final List<String> images;
  final String category;
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
    required this.category,
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
      'category': category,
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
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static Future<String> create(Product product) async {
    print('Creating product with data: ${product.toMap()}');
    final docRef = await FirebaseFirestore.instance.collection('products').add(product.toMap());
    return docRef.id;
  }

  static Future<List<Product>> getAll() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
  }

  static Future<Product?> getById(String id) async {
    final doc = await FirebaseFirestore.instance.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc.data()!, doc.id);
  }

  Future<void> update() async {
    if (id == null) throw Exception('Cannot update product without id');
    await FirebaseFirestore.instance.collection('products').doc(id).update(toMap());
  }

  Future<void> delete() async {
    if (id == null) throw Exception('Cannot delete product without id');
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }
} 