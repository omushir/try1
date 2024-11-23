import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/screens/product_details_screen.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;

    print('Current user email: $currentUserEmail');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final allProducts = snapshot.data?.docs ?? [];
            print('Total products found: ${allProducts.length}');
            for (var doc in allProducts) {
              final data = doc.data() as Map<String, dynamic>;
              print('Product: ${data['name']}, Email: ${data['userEmail']}');
            }
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('No products added yet'));
          }

          return GridView.builder(
            padding: EdgeInsets.all(padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenSize.width > 600 ? 3 : 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: padding,
              mainAxisSpacing: padding,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productWithId = {
                ...product,
                'id': products[index].id,
              };
              return _buildProductCard(context, productWithId, screenSize);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product, Size screenSize) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                productId: product['id'],
                product: product,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: product['imageUrl'] != null
                    ? Image.network(
                        product['imageUrl'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          size: screenSize.width * 0.1,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(product['name'] ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${product['price'] ?? 0} Rs'),
            ),
          ],
        ),
      ),
    );
  }
} 