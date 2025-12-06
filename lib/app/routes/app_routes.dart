// lib/app/routes/app_routes.dart
import 'package:get/get.dart';
import '../../views/auth/login_page.dart';
import '../../views/home/landing_page.dart';
import '../../views/cart/cart_page.dart';
import '../../views/cart/checkout_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: home,
      page: () => LandingPage(),
    ),
    GetPage(
      name: cart,
      page: () => const CartPage(),
    ),
    GetPage(
      name: checkout,
      page: () => const CheckoutPage(),
    ),
  ];
}
