import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Observables
  final RxString fcmToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 NotificationController initialized');
    _initializePushNotifications();
  }

  // Initialize push notifications
  Future<void> _initializePushNotifications() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      fcmToken.value = token;
      print('FCM Token received: $token');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      // Handle foreground notification
      _handleForegroundMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background: ${message.notification?.title}');
      // Handle when user taps on notification
      _handleMessageOpened(message);
    });

    // Handle when app is opened from terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print(
          'App opened from terminated state: ${initialMessage.notification?.title}');
      _handleMessageOpened(initialMessage);
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification or handle in-app
    Get.snackbar(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      duration: const Duration(seconds: 5),
    );
  }

  // Handle when user opens notification
  void _handleMessageOpened(RemoteMessage message) {
    // Navigate to appropriate screen based on message data
    if (message.data['screen'] != null) {
      // Navigate to specific screen
      Get.toNamed(message.data['screen']);
    }
  }

  // Update FCM token when user signs in
  Future<void> updateFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      fcmToken.value = token;
      print('FCM Token updated: $token');

      // Here you could send the token to your backend if needed
      // For now, we'll just store it locally
    }
  }
}
