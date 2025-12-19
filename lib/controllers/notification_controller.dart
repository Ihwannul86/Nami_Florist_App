import 'package:get/get.dart';
import '../services/firebase_messaging_service.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  late FirebaseMessagingService _firebaseMessagingService;
  late NotificationService _notificationService;

  var fcmToken = RxString('');
  var notificationHistory = RxList<Map<String, dynamic>>([]);
  var isLoadingToken = RxBool(false);

  @override
  void onInit() async {
    super.onInit();
    _firebaseMessagingService = FirebaseMessagingService();
    _notificationService = NotificationService();

    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      isLoadingToken.value = true;

      await _notificationService.initializeLocalNotifications();
      print('[NotificationController] Local notifications initialized');

      await _firebaseMessagingService.initializeFirebaseMessaging();

      String? token = await _firebaseMessagingService.getFCMToken();
      if (token != null) {
        fcmToken.value = token;
        print('[NotificationController] FCM Token: $token');
      }

      _firebaseMessagingService.listenToTokenRefresh();

      isLoadingToken.value = false;
    } catch (e) {
      print('[NotificationController] Error initializing notifications: $e');
      isLoadingToken.value = false;
    }
  }

  Future<void> testCustomSoundNotification() async {
    try {
      await _notificationService.showNotification(
        id: 1,
        title: 'Test Custom Sound',
        body: 'Ini adalah notifikasi test dengan custom sound (notif1.mp3)',
        payload: 'test_notification',
        soundFileName: 'notif1.mp3',
      );
    } catch (e) {
      print('[NotificationController] Error testing notification: $e');
    }
  }

  Future<void> testProgressNotification() async {
    try {
      for (int i = 0; i <= 100; i += 10) {
        await _notificationService.showProgressNotification(
          id: 2,
          title: 'Download Progress',
          body: 'Downloading... $i%',
          progress: i,
          maxProgress: 100,
        );
        await Future.delayed(Duration(seconds: 1));
      }
    } catch (e) {
      print('[NotificationController] Error testing progress: $e');
    }
  }

  void addToHistory(String title, String body, {String? type}) {
    notificationHistory.add({
      'title': title,
      'body': body,
      'type': type ?? 'general',
      'timestamp': DateTime.now(),
    });
  }

  void clearHistory() {
    notificationHistory.clear();
  }

  String? getFCMToken() {
    return fcmToken.value.isNotEmpty ? fcmToken.value : null;
  }
}
