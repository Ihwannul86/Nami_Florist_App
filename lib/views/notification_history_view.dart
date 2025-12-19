import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationHistoryView extends StatelessWidget {
  const NotificationHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        backgroundColor: Colors.red[400],
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.grey[50],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your FCM Token',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return controller.isLoadingToken.value
                        ? const CircularProgressIndicator()
                        : SelectableText(
                            controller.fcmToken.value.isNotEmpty
                                ? controller.fcmToken.value
                                : 'Token not available',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.black87,
                            ),
                          );
                  }),
                  const SizedBox(height: 8),
                  Obx(() {
                    return controller.fcmToken.value.isNotEmpty
                        ? ElevatedButton.icon(
                            onPressed: () {
                              Get.snackbar(
                                'Copied',
                                'FCM Token copied to clipboard!',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy Token'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[400],
                            ),
                          )
                        : const SizedBox();
                  }),
                ],
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.testCustomSoundNotification(),
                  icon: const Icon(Icons.notification_add),
                  label: const Text('Test Custom Sound'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.testProgressNotification(),
                  icon: const Icon(Icons.download),
                  label: const Text('Test Progress'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.clearHistory(),
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.notificationHistory.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications received yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.notificationHistory.length,
                itemBuilder: (context, index) {
                  final notification = controller.notificationHistory[index];
                  return _NotificationCard(notification: notification);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final DateTime timestamp =
        notification['timestamp'] as DateTime? ?? DateTime.now();
    final String type = notification['type'] as String? ?? 'general';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: _getIconByType(type),
        title: Text(
          notification['title'] ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['body'] ?? 'No Body',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: _getChipByType(type),
      ),
    );
  }

  Widget _getIconByType(String type) {
    switch (type) {
      case 'promo':
        return Icon(Icons.local_offer, color: Colors.orange[400]);
      case 'order':
        return Icon(Icons.shopping_cart, color: Colors.blue[400]);
      case 'notification':
        return Icon(Icons.notifications_active, color: Colors.red[400]);
      default:
        return Icon(Icons.notifications, color: Colors.grey[400]);
    }
  }

  Widget _getChipByType(String type) {
    Color? bgColor;
    Color? textColor;

    switch (type) {
      case 'promo':
        bgColor = Colors.orange[100];
        textColor = Colors.orange[900];
        break;
      case 'order':
        bgColor = Colors.blue[100];
        textColor = Colors.blue[900];
        break;
      case 'notification':
        bgColor = Colors.red[100];
        textColor = Colors.red[900];
        break;
      default:
        bgColor = Colors.grey[200];
        textColor = Colors.grey[800];
    }

    return Chip(
      label: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      backgroundColor: bgColor,
    );
  }
}
