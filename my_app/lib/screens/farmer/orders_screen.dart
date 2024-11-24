import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc('omushir10@gmail.com')
            .collection('orders')
            .doc('QUJGd6hnO0YTxazG24V6')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 80,
                    color: Colors.green[200],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Order not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
          final orderDate = (orderData['orderDate'] as Timestamp).toDate();
          final formattedDate = DateFormat('MMM dd, yyyy • HH:mm').format(orderDate);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Order Date: $formattedDate'),
                      Text('Order ID: ${orderData['orderId'] ?? 'N/A'}'),
                      Text('Total: ₹${orderData['total']?.toString() ?? '0.00'}'),
                      const Divider(height: 24),
                      Text(
                        'Items',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...items.map((item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item['name'] ?? 'Unknown Item'),
                        subtitle: Text('Quantity: ${item['quantity']}'),
                        trailing: Text('₹${item['price']?.toString() ?? '0.00'}'),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 