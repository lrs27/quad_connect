import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const QuadConnectApp());
}

class QuadConnectApp extends StatefulWidget {
  const QuadConnectApp({super.key});

  @override
  State<QuadConnectApp> createState() => _QuadConnectAppState();
}

class _QuadConnectAppState extends State<QuadConnectApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((message) {
      final convoId = message.data['convoId'];
      if (convoId != null) {
        navigatorKey.currentState?.pushNamed(
          '/chat',
          arguments: {'convoId': convoId},
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final convoId = message.data['convoId'];
      if (convoId != null) {
        navigatorKey.currentState?.pushNamed(
          '/chat',
          arguments: {'convoId': convoId},
        );
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      final convoId = message?.data['convoId'];
      if (convoId != null) {
        navigatorKey.currentState?.pushNamed(
          '/chat',
          arguments: {'convoId': convoId},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),

        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          final convoId = (args is Map && args['convoId'] != null)
              ? args['convoId']
              : '';

          final uid = (args is Map && args['uid'] != null) ? args['uid'] : '';

          final name = (args is Map && args['name'] != null)
              ? args['name']
              : '';

          return ChatScreen(convoId: convoId, uid: uid, name: name);
        },
      },
    );
  }
}
