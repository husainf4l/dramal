import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/theme_controller.dart';
import 'app/controllers/notification_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_themes.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize GetStorage
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(ThemeController());
    Get.put(AuthController());
    Get.put(NotificationController());
    return GetMaterialApp(
      title: 'Dramal',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: Get.find<ThemeController>().themeMode,

      // Route configuration
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
