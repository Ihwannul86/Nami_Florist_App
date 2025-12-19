import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notif1'),
    enableVibration: true,
  );

  NotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  factory NotificationService() {
    return _instance;
  }

  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/ic_launcher');
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    String? soundFileName,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails;

      if (soundFileName != null && soundFileName.isNotEmpty) {
        androidDetails = AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(
            soundFileName.replaceAll('.mp3', ''),
          ),
          enableVibration: true,
          ticker: 'ticker',
        );
      } else {
        androidDetails = AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          ticker: 'ticker',
        );
      }

      final DarwinNotificationDetails iOSDetails =
          const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('[NotificationService] Notifikasi ditampilkan: $title');
    } catch (e) {
      print('[NotificationService] Error menampilkan notifikasi: $e');
    }
  }

  Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        onlyAlertOnce: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      print('[NotificationService] Error menampilkan progress notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    print('[NotificationService] Notifikasi diklik: ${notificationResponse.payload}');
  }
}
