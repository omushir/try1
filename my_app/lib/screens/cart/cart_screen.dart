import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartScreen extends StatefulWidget {
  final String userEmail;

  const CartScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _logger = Logger();
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Get current cart items
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .collection('cart')
          .doc('cart_items');
      
      final cartSnapshot = await cartRef.get();
      final cartData = cartSnapshot.data() as Map<String, dynamic>;
      final cartItems = List<dynamic>.from(cartData['items'] ?? []);

      // Create order in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .collection('orders')
          .add({
        'items': cartItems,
        'orderDate': FieldValue.serverTimestamp(),
        'paymentId': response.paymentId,
        'status': 'completed',
        'total': cartItems.fold(0.0, (sum, item) => 
          sum + (double.parse(item['price'].toString()) * (item['quantity'] ?? 1))),
      });

      // Clear the cart
      await cartRef.update({'items': []});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      _logger.e('Error creating order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating order. Please contact support.')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _logger.e('Payment Error: ${response.code} - ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  void _openCheckout(double amount) {
    var options = {
      'key': 'rzp_test_uY5O09cEm1oquM',
      'amount': (amount * 100).toInt(),
      'name': 'Foodiee',
      'description': 'Pay and have fun',
      'prefill': {
        'email': widget.userEmail,
        'contact': '',
        'name': '',
      },
      'currency': 'INR',
      'theme': {
        'color': '#FF5733'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _logger.e('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userEmail)
                  .collection('cart')
                  .doc('cart_items')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Your cart is empty'));
                }

                final cartData = snapshot.data!.data() as Map<String, dynamic>;
                final cartItems = (cartData['items'] as List<dynamic>?) ?? [];

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final itemData = cartItems[index] as Map<String, dynamic>;
                          final quantity = itemData['quantity'] ?? 1;
                          final price = double.tryParse(itemData['price'] ?? '0') ?? 0;
                          final subtotal = price * quantity;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      itemData['image'] ?? '',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          itemData['name'] ?? 'Unknown Product',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Price: \$${price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove),
                                                  onPressed: () {
                                                    _updateQuantity(itemData['id'], quantity - 1);
                                                  },
                                                ),
                                                Text('$quantity'),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    _updateQuantity(itemData['id'], quantity + 1);
                                                  },
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Delete Button
                                        TextButton.icon(
                                          onPressed: () {
                                            _removeFromCart(itemData['id'], widget.userEmail);
                                          },
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          label: const Text(
                                            'Remove',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildCheckoutBar(context, cartItems),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFromCart(String itemId, String? userEmail) async {
    if (userEmail == null) return;
    
    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('cart')
          .doc('cart_items');

      final snapshot = await cartRef.get();
      final cartData = snapshot.data() as Map<String, dynamic>;
      final items = List<dynamic>.from(cartData['items'] ?? []);

      items.removeWhere((item) => item['id'] == itemId);
      await cartRef.update({'items': items});
    } catch (e) {
      _logger.e('Error removing item from cart: $e');
    }
  }

  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 1) return; // Prevent negative quantities
    
    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .collection('cart')
          .doc('cart_items');

      final snapshot = await cartRef.get();
      final cartData = snapshot.data() as Map<String, dynamic>;
      final items = List<dynamic>.from(cartData['items'] ?? []);

      final itemIndex = items.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        items[itemIndex]['quantity'] = newQuantity;
        await cartRef.update({'items': items});
      }
    } catch (e) {
      _logger.e('Error updating quantity: $e');
    }
  }

  Widget _buildCheckoutBar(BuildContext context, List<dynamic> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      final price = double.tryParse(item['price'] ?? '0') ?? 0;
      final quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: cartItems.isEmpty ? null : () {
              print('Button pressed, total: $total'); // Debug print
              _openCheckout(total);
            },
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }
}
