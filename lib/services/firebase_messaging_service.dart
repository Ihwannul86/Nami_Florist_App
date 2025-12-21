import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

// ✅ POIN 1: Top-level background handler
// Annotation @pragma diperlukan agar function tidak di-tree-shake saat build release
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Fungsi ini dipanggil ketika aplikasi dalam kondisi background atau terminated
  print('╔════════════════════════════════════════════════════════════╗');
  print('║     📨 BACKGROUND/TERMINATED MESSAGE HANDLER               ║');
  print('╠════════════════════════════════════════════════════════════╣');
  print('║ Title: ${message.notification?.title ?? 'No title'}');
  print('║ Body: ${message.notification?.body ?? 'No body'}');
  print('║ Data: ${message.data}');
  print('╚════════════════════════════════════════════════════════════╝');
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService(); // ✅ POIN 2: Instance NotificationService

  /// Initialize Firebase Messaging with explicit permission request
  Future<void> initialize() async {
    try {
      // ✅ Request permission dengan lebih eksplisit
      print('🔔 Requesting notification permission...');
      
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,           // Tampilkan alert/banner
        announcement: false,   // Announcement (iOS)
        badge: true,           // Badge di app icon
        carPlay: false,        // CarPlay (iOS)
        criticalAlert: false,  // Critical alert (iOS)
        provisional: false,    // Provisional permission (iOS)
        sound: true,           // Suara notifikasi
      );

      print('📊 Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ User granted provisional permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ User DENIED notification permission');
        print('⚠️ Minta user untuk enable notifikasi di Settings HP');
        return; // Stop jika permission ditolak
      } else {
        print('❌ User has not accepted permission');
        return;
      }

      // Get FCM Token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('╔════════════════════════════════════════════════════════════╗');
        print('║                    🔑 FCM TOKEN                            ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║ $token');
        print('╚════════════════════════════════════════════════════════════╝');
      } else {
        print('❌ Failed to get FCM token');
      }

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
      });

      // ✅ POIN 1: Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // ✅ POIN 2: Handle foreground messages dengan CUSTOM SOUND
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('╔════════════════════════════════════════════════════════════╗');
        print('║         📩 FOREGROUND MESSAGE RECEIVED                     ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║ Title: ${message.notification?.title ?? 'No title'}');
        print('║ Body: ${message.notification?.body ?? 'No body'}');
        print('║ Data: ${message.data}');
        print('╚════════════════════════════════════════════════════════════╝');
        
        // ✅ TAMPILKAN NOTIFIKASI DENGAN CUSTOM SOUND notif1.mp3
        if (message.notification != null) {
          _notificationService.showNotification(
            id: message.notification.hashCode,
            title: message.notification!.title ?? 'Notifikasi',
            body: message.notification!.body ?? '',
            payload: message.data.toString(),
            soundFileName: 'notif1.mp3', // ✅ CUSTOM SOUND untuk FCM
          );
          print('✅ Foreground notification displayed with CUSTOM SOUND (notif1.mp3)');
        }
      });

      // Handle notification clicked (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('╔════════════════════════════════════════════════════════════╗');
        print('║      🔔 NOTIFICATION CLICKED (APP IN BACKGROUND)           ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║ Title: ${message.notification?.title ?? 'No title'}');
        print('║ Body: ${message.notification?.body ?? 'No body'}');
        print('║ Data: ${message.data}');
        print('╚════════════════════════════════════════════════════════════╝');
        
        // TODO: Handle routing here if needed (akan dikerjakan di poin 5)
        // Example: Get.toNamed(message.data['route']);
      });

      // Check if app was opened from terminated state by notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('╔════════════════════════════════════════════════════════════╗');
        print('║     🚀 APP OPENED FROM TERMINATED STATE BY NOTIFICATION    ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║ Title: ${initialMessage.notification?.title ?? 'No title'}');
        print('║ Body: ${initialMessage.notification?.body ?? 'No body'}');
        print('║ Data: ${initialMessage.data}');
        print('╚════════════════════════════════════════════════════════════╝');
        
        // TODO: Handle routing here if needed (akan dikerjakan di poin 5)
      }

    } catch (e) {
      print('❌ Error initializing Firebase Messaging: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }
}
