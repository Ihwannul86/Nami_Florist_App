import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // ✅ Channel untuk CUSTOM SOUND (notif1.mp3)
  static const AndroidNotificationChannel customSoundChannel = AndroidNotificationChannel(
    'custom_sound_channel',
    'Custom Sound Notifications',
    description: 'Notifikasi dengan custom sound dari FCM',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notif1'), // Custom sound
    enableVibration: true,
  );

  // ✅ Channel untuk DEFAULT SOUND (system default)
  static const AndroidNotificationChannel defaultSoundChannel = AndroidNotificationChannel(
    'default_sound_channel',
    'Default Sound Notifications',
    description: 'Notifikasi dengan default sound untuk pembayaran',
    importance: Importance.high,
    playSound: true,
    // TIDAK ADA sound parameter = pakai default system sound
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
        AndroidInitializationSettings('@mipmap/ic_launcher');
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

    // ✅ Buat DUA channel: satu untuk custom sound, satu untuk default sound
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(customSoundChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultSoundChannel);
  }

  /// ✅ Fungsi untuk menampilkan notifikasi dengan pilihan custom sound atau default
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    String? soundFileName, // ✅ Jika null = default sound, jika ada = custom sound
  }) async {
    try {
      final AndroidNotificationDetails androidDetails;

      // ✅ Jika soundFileName dikasih (misal: 'notif1.mp3') = pakai CUSTOM SOUND CHANNEL
      if (soundFileName != null && soundFileName.isNotEmpty) {
        androidDetails = AndroidNotificationDetails(
          customSoundChannel.id, // ✅ Pakai custom sound channel
          customSoundChannel.name,
          channelDescription: customSoundChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(
            soundFileName.replaceAll('.mp3', ''), // Hilangkan extension
          ),
          enableVibration: true,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );
        print('[NotificationService] Using CUSTOM SOUND: $soundFileName');
      } else {
        // ✅ Jika soundFileName = null = pakai DEFAULT SOUND CHANNEL
        androidDetails = AndroidNotificationDetails(
          defaultSoundChannel.id, // ✅ Pakai default sound channel
          defaultSoundChannel.name,
          channelDescription: defaultSoundChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true, // Pakai default system sound
          enableVibration: true,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );
        print('[NotificationService] Using DEFAULT SYSTEM SOUND');
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

  /// Fungsi untuk menampilkan progress notification
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
        defaultSoundChannel.id, // ✅ Progress notification pakai default sound
        defaultSoundChannel.name,
        channelDescription: defaultSoundChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        onlyAlertOnce: true,
        icon: '@mipmap/ic_launcher',
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
