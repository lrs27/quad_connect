import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const QuadConnectApp());
}

class QuadConnectApp extends StatelessWidget {
  const QuadConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          // Still loading auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Not logged in → LoginScreen
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // Logged in → check if profile exists
          final user = snapshot.data!;
          return FutureBuilder(
            future: FirestoreService().getUser(user.uid),
            builder: (context, profileSnap) {
              if (!profileSnap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final profile = profileSnap.data;

              // No profile → go to setup
              if (profile == null) {
                return const ProfileSetupScreen();
              }

              // Profile exists → go to home
              return const HomeScreen();
            },
          );
        },
      ),
    );
  }
}
