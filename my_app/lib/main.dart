import 'package:flutter/material.dart';
import 'screens/auth/login_selection_screen.dart';

void main() {
  runApp(const BaliRajaApp());
}

class BaliRajaApp extends StatelessWidget {
  const BaliRajaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bali Raja',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginSelectionScreen(),
    );
  }
} 