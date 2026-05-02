import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ---------------- BACKGROUND HANDLER ----------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Optional: background logic
}

// ---------------- MAIN ----------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background notifications
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Local notifications setup
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: android);

  await FlutterLocalNotificationsPlugin().initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      final convoId = details.payload;
      if (convoId != null) {
        navigatorKey.currentState?.pushNamed(
          '/chat',
          arguments: {'convoId': convoId},
        );
      }
    },
  );

  runApp(const QuadConnectApp());
}

// ---------------- APP ----------------
class QuadConnectApp extends StatefulWidget {
  const QuadConnectApp({super.key});

  @override
  State<QuadConnectApp> createState() => _QuadConnectAppState();
}

class _QuadConnectAppState extends State<QuadConnectApp> {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // -------- FOREGROUND NOTIFICATIONS --------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        const androidDetails = AndroidNotificationDetails(
          'messages_channel',
          'Messages',
          importance: Importance.high,
          priority: Priority.high,
        );

        const details = NotificationDetails(android: androidDetails);

        _local.show(
          notification.hashCode,
          notification.title,
          notification.body,
          details,
          payload: message.data['convoId'], // click-to-open
        );
      }
    });

    // -------- APP OPENED FROM TERMINATED --------
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _openChatFromNotification(message);
      }
    });

    // -------- APP OPENED FROM BACKGROUND --------
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openChatFromNotification(message);
    });
  }

  void _openChatFromNotification(RemoteMessage message) {
    final convoId = message.data['convoId'];
    if (convoId != null) {
      navigatorKey.currentState?.pushNamed(
        '/chat',
        arguments: {'convoId': convoId},
      );
    }
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

        // -------- CHAT ROUTE FOR NOTIFICATION NAVIGATION --------
        '/chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          return ChatScreen(
            convoId: args['convoId'],
            uid: args['uid'], // optional if you pass it
            name: args['name'], // optional if you pass it
          );
        },
      },
    );
  }
}
