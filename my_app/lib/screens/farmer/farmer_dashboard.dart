import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'my_products_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          DashboardCard(
            title: 'My Products',
            icon: Icons.inventory,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyProductsScreen()),
            ),
          ),
          DashboardCard(
            title: 'Add Product',
            icon: Icons.add_box,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            ),
          ),
          DashboardCard(
            title: 'Orders',
            icon: Icons.shopping_bag,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
          DashboardCard(
            title: 'Profile',
            icon: Icons.person,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FarmerProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
} 