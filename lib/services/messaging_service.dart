import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Request permissions (iOS + Android 13+)
  Future<void> requestPermission() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  /// Initialize listeners
  void initNotifications() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground notification received");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
    });

    // When app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Notification opened the app");
    });
  }
}
