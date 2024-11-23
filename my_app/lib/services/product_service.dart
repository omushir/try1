import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  // Create a singleton
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  // Get Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct({
    required String description,
    required String image,
    required String price,
    required String productname,
    required String stock,
    required String category,
  }) async {
    try {
      // Using _firestore instead of direct collection reference
      await _firestore.collection('products').add({
        'description': description,
        'image': image,
        'price': price,
        'productname': productname,
        'stock': stock,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
      rethrow; // Rethrow the error for proper error handling
    }
  }

  Stream<QuerySnapshot> getAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
} 