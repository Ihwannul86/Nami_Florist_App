// lib/services/firebase_messaging_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'notification_service.dart';
import '../app/routes/app_routes.dart';
import '../controllers/cart_controller.dart'; // ✅ IMPORT CART CONTROLLER

// ✅ POIN 1: Top-level background handler (WAJIB untuk terminated state)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('╔════════════════════════════════════════════════════════════╗');
    print('║     📨 BACKGROUND/TERMINATED MESSAGE HANDLER               ║');
    print('╠════════════════════════════════════════════════════════════╣');
    print('║ Title: ${message.notification?.title ?? 'No title'}');
    print('║ Body: ${message.notification?.body ?? 'No body'}');
    print('║ Data: ${message.data}');
    print('╚════════════════════════════════════════════════════════════╝');
  }
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Request permission
      if (kDebugMode) {
        print('🔔 Requesting notification permission...');
      }
      
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('📊 Permission status: ${settings.authorizationStatus}');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('✅ User granted notification permission');
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print('⚠️ User granted provisional permission');
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        if (kDebugMode) {
          print('❌ User DENIED notification permission');
        }
        return;
      }

      // Get FCM Token
      String? token = await _firebaseMessaging.getToken();
      if (token != null && kDebugMode) {
        print('╔════════════════════════════════════════════════════════════╗');
        print('║                    🔑 FCM TOKEN                            ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║ $token');
        print('╚════════════════════════════════════════════════════════════╝');
      }

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('🔄 FCM Token refreshed: $newToken');
        }
      });

      // ✅ Register background handler (untuk background & terminated)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // ✅ EKSPERIMEN 1: Handle FOREGROUND messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('╔════════════════════════════════════════════════════════════╗');
          print('║         📩 FOREGROUND MESSAGE RECEIVED                     ║');
          print('╠════════════════════════════════════════════════════════════╣');
          print('║ Title: ${message.notification?.title ?? 'No title'}');
          print('║ Body: ${message.notification?.body ?? 'No body'}');
          print('║ Data: ${message.data}');
          print('╚════════════════════════════════════════════════════════════╝');
        }
        
        if (message.notification != null) {
          _notificationService.showNotification(
            id: message.notification.hashCode,
            title: message.notification!.title ?? 'Notifikasi',
            body: message.notification!.body ?? '',
            payload: message.data.toString(),
            soundFileName: 'notif1.mp3',
          );
        }
      });

      // ✅ EKSPERIMEN 2: Handle notification clicked (APP IN BACKGROUND)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('╔════════════════════════════════════════════════════════════╗');
          print('║   🔔 NOTIFICATION CLICKED (APP IN BACKGROUND) - EXP 2     ║');
          print('╠════════════════════════════════════════════════════════════╣');
          print('║ Title: ${message.notification?.title ?? 'No title'}');
          print('║ Body: ${message.notification?.body ?? 'No body'}');
          print('║ Data: ${message.data}');
          print('╚════════════════════════════════════════════════════════════╝');
        }
        
        _handleNotificationNavigation(message);
      });

      // ✅ EKSPERIMEN 3: Check if app opened from TERMINATED state
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print('╔════════════════════════════════════════════════════════════╗');
          print('║  🚀 APP OPENED FROM TERMINATED STATE BY NOTIFICATION - EXP 3 ║');
          print('╠════════════════════════════════════════════════════════════╣');
          print('║ Title: ${initialMessage.notification?.title ?? 'No title'}');
          print('║ Body: ${initialMessage.notification?.body ?? 'No body'}');
          print('║ Data: ${initialMessage.data}');
          print('╚════════════════════════════════════════════════════════════╝');
        }
        
        // ✅ Delay untuk memastikan InitialBinding selesai inject controllers
        Future.delayed(const Duration(seconds: 2), () {
          if (kDebugMode) {
            print('⏰ Delay completed, attempting navigation...');
          }
          _handleNotificationNavigation(initialMessage);
        });
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Firebase Messaging: $e');
      }
    }
  }

  /// ✅ Handle navigation based on notification data (EKSPERIMEN 2 & 3)
  void _handleNotificationNavigation(RemoteMessage message) {
    try {
      String? title = message.notification?.title?.toLowerCase();
      String? body = message.notification?.body?.toLowerCase();
      Map<String, dynamic> data = message.data;

      if (kDebugMode) {
        print('🧭 Starting navigation handler...');
        print('   Title: $title');
        print('   Body: $body');
        print('   Data: $data');
      }

      // ══════════════════════════════════════════════════════════
      // CARA 1: Routing berdasarkan KATA KUNCI di title/body
      // ══════════════════════════════════════════════════════════
      
      if (title != null || body != null) {
        String fullText = '${title ?? ''} ${body ?? ''}'.toLowerCase();
        
        // Cek kata kunci "keranjang" atau "cart"
        if (fullText.contains('keranjang') || fullText.contains('cart')) {
          if (kDebugMode) {
            print('🛒 Keyword "keranjang" detected! Navigating to Cart...');
          }
          
          // ✅ Navigasi langsung tanpa cek isRegistered (karena permanent: true di InitialBinding)
          try {
            Get.toNamed(AppRoutes.cart);
            
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.snackbar(
                'Navigasi Otomatis',
                'Membuka halaman Keranjang Belanja',
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 2),
              );
            });
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error navigating to cart: $e');
              print('   Fallback to home');
            }
            Get.offAllNamed(AppRoutes.home);
          }
          return;
        }
        
        // Cek kata kunci "checkout" atau "pembayaran"
        if (fullText.contains('checkout') || fullText.contains('pembayaran')) {
          if (kDebugMode) {
            print('💳 Keyword "checkout" detected! Navigating to Checkout...');
          }
          try {
            Get.toNamed(AppRoutes.checkout);
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error navigating to checkout: $e');
            }
            Get.offAllNamed(AppRoutes.home);
          }
          return;
        }
        
        // Cek kata kunci "home" atau "beranda"
        if (fullText.contains('home') || fullText.contains('beranda')) {
          if (kDebugMode) {
            print('🏠 Keyword "home" detected! Navigating to Home...');
          }
          Get.offAllNamed(AppRoutes.home);
          return;
        }
      }

      // ══════════════════════════════════════════════════════════
      // CARA 2: Routing berdasarkan DATA PAYLOAD (lebih reliable)
      // ══════════════════════════════════════════════════════════
      
      if (data.containsKey('route')) {
        String route = data['route'];
        if (kDebugMode) {
          print('🧭 Route from data payload: $route');
        }
        
        try {
          switch (route) {
            case 'cart':
            case '/cart':
              if (kDebugMode) {
                print('🛒 Navigating to Cart from data...');
              }
              Get.toNamed(AppRoutes.cart);
              break;
            case 'checkout':
            case '/checkout':
              if (kDebugMode) {
                print('💳 Navigating to Checkout from data...');
              }
              Get.toNamed(AppRoutes.checkout);
              break;
            case 'home':
            case '/home':
              if (kDebugMode) {
                print('🏠 Navigating to Home from data...');
              }
              Get.offAllNamed(AppRoutes.home);
              break;
            default:
              if (kDebugMode) {
                print('⚠️ Unknown route: $route');
              }
              Get.offAllNamed(AppRoutes.home);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error navigating from data: $e');
          }
          Get.offAllNamed(AppRoutes.home);
        }
        return;
      }

      // ══════════════════════════════════════════════════════════
      // FALLBACK: Jika tidak ada keyword/data, buka Home
      // ══════════════════════════════════════════════════════════
      
      if (kDebugMode) {
        print('ℹ️ No specific routing found, opening Home...');
      }
      Get.offAllNamed(AppRoutes.home);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling navigation: $e');
        print('   Error details: ${e.toString()}');
      }
      Get.offAllNamed(AppRoutes.home);
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      if (kDebugMode) {
        print('✅ FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting FCM token: $e');
      }
    }
  }
}
