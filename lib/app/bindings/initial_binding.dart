// lib/app/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/weather_controller.dart';
import '../../controllers/plant_controller.dart';
import '../../controllers/landing_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put all controllers here
    Get.put(CartController(), permanent: true);
    Get.put(PaymentController(), permanent: true);
    Get.put(WeatherController(), permanent: true);
    Get.put(PlantController(), permanent: true);
    Get.put(LandingController(), permanent: true);
  }
}
