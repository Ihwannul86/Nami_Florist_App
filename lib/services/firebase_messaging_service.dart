import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Request permission (for iOS & Android 13+)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ User granted provisional permission');
      } else {
        print('❌ User declined or has not accepted permission');
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

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('╔════════════════════════════════════════════════════════════╗');
        print('║         📩 FOREGROUND MESSAGE RECEIVED                     ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║ Title: ${message.notification?.title ?? 'No title'}');
        print('║ Body: ${message.notification?.body ?? 'No body'}');
        print('║ Data: ${message.data}');
        print('╚════════════════════════════════════════════════════════════╝');
      });

      // Handle background messages (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('╔════════════════════════════════════════════════════════════╗');
        print('║      🔔 NOTIFICATION CLICKED (APP IN BACKGROUND)           ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║ Title: ${message.notification?.title ?? 'No title'}');
        print('║ Body: ${message.notification?.body ?? 'No body'}');
        print('║ Data: ${message.data}');
        print('╚════════════════════════════════════════════════════════════╝');
        
        // Handle routing here if needed
        // Example: Get.toNamed(message.data['route']);
      });

      // Check if app was opened from a terminated state by notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('╔════════════════════════════════════════════════════════════╗');
        print('║     🚀 APP OPENED FROM TERMINATED STATE BY NOTIFICATION    ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║ Title: ${initialMessage.notification?.title ?? 'No title'}');
        print('║ Body: ${initialMessage.notification?.body ?? 'No body'}');
        print('║ Data: ${initialMessage.data}');
        print('╚════════════════════════════════════════════════════════════╝');
        
        // Handle routing here if needed
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
