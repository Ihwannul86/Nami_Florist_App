// lib/app/routes/app_routes.dart
import 'package:get/get.dart';
import '../../views/auth/login_page.dart';
import '../../views/auth/register_page.dart';
import '../../views/home/landing_page.dart';
import '../../views/cart/cart_page.dart';
import '../../views/payment/checkout_page.dart';
import '../../views/payment/payment_success_page.dart';
import '../../views/notification_history_view.dart';

class AppRoutes {
  // Route names
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String paymentSuccess = '/payment-success';
  static const String notificationHistory = '/notification-history';

  // Route configurations
  static final routes = [
    GetPage(
      name: home,
      page: () => LandingPage(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: cart,
      page: () => const CartPage(),
    ),
    GetPage(
      name: checkout,
      page: () => CheckoutPage(), // ✅ FIX: Tanpa const, tanpa parameter
    ),
    GetPage(
      name: paymentSuccess,
      page: () => const PaymentSuccessPage(), // ✅ FIX: Tanpa parameter
    ),
    GetPage(
      name: notificationHistory,
      page: () => const NotificationHistoryView(),
    ),
  ];
}
