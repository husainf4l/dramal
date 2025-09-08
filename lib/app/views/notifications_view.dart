import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/notification-settings'),
          ),
        ],
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Firebase Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Firebase Notifications',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Push notifications are handled automatically by Firebase Cloud Messaging. '
                      'You will receive notifications directly on your device when sent from the Firebase console.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // FCM Token Card
            Card(
              child: ListTile(
                title: const Text('Device Token'),
                subtitle: notificationController.fcmToken.value.isNotEmpty
                    ? Text(
                        notificationController.fcmToken.value,
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
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notifications are sent from Firebase and appear as system notifications on your device.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                      ),
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
