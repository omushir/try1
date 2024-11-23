import 'package:flutter/material.dart';
import 'user_login_screen.dart';
import 'farmer_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.05;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                const Spacer(),
                // Logo or App Icon
                Container(
                  width: screenSize.width * 0.4,
                  height: screenSize.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    size: screenSize.width * 0.25,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.04),
                // Welcome Text
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.06,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Bali Raja',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'Choose your login type',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                // Login Buttons
                _buildLoginButton(
                  context: context,
                  title: 'Customer Login',
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserLoginScreen(),
                      ),
                    );
                  },
                  screenSize: screenSize,
                  isCustomer: true,
                ),
                SizedBox(height: screenSize.height * 0.02),
                _buildLoginButton(
                  context: context,
                  title: 'Farmer Login',
                  icon: Icons.agriculture,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FarmerLoginScreen(),
                      ),
                    );
                  },
                  screenSize: screenSize,
                  isCustomer: false,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required Size screenSize,
    required bool isCustomer,
  }) {
    return Container(
      width: double.infinity,
      height: screenSize.height * 0.08,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: isCustomer
            ? LinearGradient(
                colors: [
                  Colors.green.shade500,
                  Colors.green.shade700,
                ],
              )
            : null,
        border: isCustomer
            ? null
            : Border.all(
                color: Colors.green.shade700,
                width: 2,
              ),
        boxShadow: isCustomer
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isCustomer ? Colors.white : Colors.green.shade700,
                ),
                SizedBox(width: screenSize.width * 0.03),
                Text(
                  title,
                  style: TextStyle(
                    color: isCustomer ? Colors.white : Colors.green.shade700,
                    fontSize: screenSize.width * 0.045,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 