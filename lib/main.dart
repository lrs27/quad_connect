import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(QuadConnectApp());
}

class QuadConnectApp extends StatelessWidget {
  const QuadConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen());
  }
}
