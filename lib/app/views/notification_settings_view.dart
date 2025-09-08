import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Firebase Messaging Status
            Card(
              child: ListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Firebase Cloud Messaging handles push notifications automatically'),
                leading: const Icon(Icons.notifications),
                trailing: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // FCM Token
            Card(
              child: ListTile(
                title: const Text('FCM Token'),
                subtitle: notificationController.fcmToken.value.isNotEmpty
                    ? Text(
                        '${notificationController.fcmToken.value.substring(0, 20)}...',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      )
                    : const Text('Token not available'),
                leading: const Icon(Icons.vpn_key),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This app uses Firebase Cloud Messaging for push notifications. '
                      'Notifications are sent from the Firebase console and delivered directly to your device.\n\n'
                      'To manage notification permissions, go to your device settings.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
