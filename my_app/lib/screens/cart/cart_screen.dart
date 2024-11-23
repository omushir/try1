import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatelessWidget {
  final String userEmail;

  const CartScreen({
    super.key,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    print('Building CartScreen for user: $userEmail'); // Debug print

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          // Add debug prints
          print('Connection state: ${snapshot.connectionState}');
          if (snapshot.hasError) print('Error: ${snapshot.error}');
          if (snapshot.hasData) print('Number of items: ${snapshot.data?.docs.length}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cartItems = snapshot.data?.docs ?? [];
          
          if (cartItems.isEmpty) {
            return const Center(
              child: Text('Your cart is empty', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final data = cartItems[index].data() as Map<String, dynamic>;
              final docId = cartItems[index].id;
              
              // Debug print for each item
              print('Rendering cart item: $data');

              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // Product Image
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: data['imageUrl'] != null
                              ? Image.network(
                                  data['imageUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, _) {
                                    print('Error loading image: $error');
                                    return const Icon(Icons.image);
                                  },
                                )
                              : const Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name']?.toString() ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${data['price']?.toString() ?? '0'}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Quantity Controls
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _updateQuantity(docId, data, false),
                                ),
                                Text(
                                  '${data['quantity'] ?? 1}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _updateQuantity(docId, data, true),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateQuantity(String docId, Map<String, dynamic> data, bool increase) async {
    try {
      final currentQuantity = data['quantity'] ?? 1;
      final newQuantity = increase ? currentQuantity + 1 : currentQuantity - 1;

      if (newQuantity <= 0) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .collection('cart')
            .doc(docId)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .collection('cart')
            .doc(docId)
            .update({'quantity': newQuantity});
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }
}

Future<void> addToCart(String userEmail, Map<String, dynamic> product) async {
  try {
    print('Adding to cart - Email: $userEmail'); // Debug print
    print('Product data being added: $product'); // Debug print
    
    if (userEmail.isEmpty) {
      throw 'User email is empty';
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('cart')
        .add({
          'name': product['name'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'quantity': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
    
    print('Successfully added to cart!');
  } catch (e) {
    print('Error adding to cart: $e');
    rethrow;
  }
} 