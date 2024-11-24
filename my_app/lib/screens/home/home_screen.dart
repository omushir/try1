import 'package:flutter/material.dart';
import '../profile/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../product/product_details_screen.dart';
import '../cart/cart_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_selection_screen.dart';
import '../orders/my_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;

  const HomeScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bali Raja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(userEmail: widget.userEmail),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Categories
          Container(
            height: screenSize.height * 0.15,
            padding: EdgeInsets.symmetric(vertical: padding / 2),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: padding),
              children: [
                _buildCategoryItem(context, 'Vegetables', Icons.eco, screenSize),
                _buildCategoryItem(context, 'Fruits', Icons.apple, screenSize),
                _buildCategoryItem(context, 'Grains', Icons.grass, screenSize),
                _buildCategoryItem(context, 'Dairy', Icons.egg, screenSize),
                _buildCategoryItem(context, 'Others', Icons.more_horiz, screenSize),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.all(padding),
            child: TextField(
              controller: searchController,
              autofocus: isSearching,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                // Force rebuild to filter products
                setState(() {});
              },
            ),
          ),

          // Products grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data?.docs ?? [];
                
                // Filter products based on search
                final filteredProducts = products.where((doc) {
                  final product = doc.data() as Map<String, dynamic>;
                  final name = product['name'].toString().toLowerCase();
                  final searchTerm = searchController.text.toLowerCase();
                  return name.contains(searchTerm);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Refresh will happen automatically with StreamBuilder
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.all(padding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenSize.width > 600 ? 3 : 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: padding,
                      mainAxisSpacing: padding,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index].data() as Map<String, dynamic>;
                      final productWithId = {
                        ...product,
                        'id': filteredProducts[index].id,
                      };
                      return _buildProductCard(context, productWithId, screenSize);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.green,
        onTap: (index) {
          if (index == 2) { // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(userEmail: widget.userEmail),
              ),
            );
          }
          // TODO: Implement other navigation options
        },
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOrdersScreen(userEmail: widget.userEmail),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Wishlist'),
            onTap: () {
              // TODO: Navigate to wishlist
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Delivery Address'),
            onTap: () {
              // TODO: Navigate to addresses
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginSelectionScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, Size screenSize) {
    final iconSize = screenSize.width * 0.06;
    final containerSize = screenSize.width * 0.15;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(containerSize * 0.2),
            ),
            child: Icon(icon, size: iconSize, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
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
              builder: (context) => ProductDetailsScreen(product: product),
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
                child: Stack(
                  children: [
                    if (product['imageUrl'] != null)
                      Image.network(
                        product['imageUrl'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.image,
                          size: screenSize.width * 0.1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          // TODO: Add to wishlist
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['name'] ?? 'Unknown Product',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product['price'] ?? 0}/kg',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: screenSize.width * 0.04,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () async {
                            await addToCart(product);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userEmail)
        .collection('cart')
        .doc('cart_items');

    // Get current cart
    final cartDoc = await cartRef.get();
    final currentItems = (cartDoc.data()?['items'] as List<dynamic>?) ?? [];

    // Check if product already exists
    final existingItemIndex = currentItems.indexWhere(
      (item) => item['id'] == product['id'],
    );

    if (existingItemIndex != -1) {
      // Update quantity
      currentItems[existingItemIndex]['quantity'] =
          (currentItems[existingItemIndex]['quantity'] ?? 1) + 1;
    } else {
      // Add new item
      currentItems.add({
        ...product,
        'quantity': 1,
      });
    }

    // Update cart
    await cartRef.set({'items': currentItems});
  }
} 