// lib/app/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/weather_controller.dart'; // ✅ Import dulu
import '../../controllers/plant_controller.dart';
import '../../controllers/landing_controller.dart';
import '../../services/firebase_messaging_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ URUTAN PENTING: Inject WeatherController DULU sebelum PlantController
    Get.put(WeatherController(), permanent: true);
    
    // ✅ Lalu inject controller lainnya
    Get.put(CartController(), permanent: true);
    Get.put(PaymentController(), permanent: true);
    Get.put(PlantController(), permanent: true); // ✅ Sekarang sudah ada WeatherController
    Get.put(LandingController(), permanent: true);
    
    // ✅ Initialize Firebase Messaging
    final messagingService = FirebaseMessagingService();
    messagingService.initialize();
    
   //debugPrint('✅ All controllers initialized in InitialBinding');
  }
}
