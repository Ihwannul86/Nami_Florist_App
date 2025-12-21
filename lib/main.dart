// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';

import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';
import 'services/storage/shared_prefs_service.dart';
import 'services/storage/hive_service.dart';
import 'controllers/notification_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load ENV
  await dotenv.load(fileName: ".env");

  // Init SharedPreferences
  await SharedPrefsService.init();

  // Init Hive
  await HiveService.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Validasi ENV
  final supabaseUrl = dotenv.env["SUPABASE_URL"];
  final supabaseKey = dotenv.env["SUPABASE_ANON_KEY"];

  if (supabaseUrl == null || supabaseKey == null) {
    debugPrint("❌ ERROR: SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan di .env");
  }

  // Init Supabase
  try {
    await Supabase.initialize(
      url: supabaseUrl ?? "",
      anonKey: supabaseKey ?? "",
    );
    debugPrint("✅ Supabase initialized successfully");
  } catch (e) {
    debugPrint("❌ ERROR INIT SUPABASE: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Initialize NotificationController
      Get.put(NotificationController());
      debugPrint('✅ NotificationController initialized');
      
      // Request location permission
      await Future.delayed(const Duration(seconds: 1));
      
      try {
        LocationPermission currentPermission = await Geolocator.checkPermission();
        debugPrint('📊 Current location permission status: $currentPermission');
        
        if (currentPermission == LocationPermission.denied || 
            currentPermission == LocationPermission.deniedForever) {
          debugPrint('⚠️ Location permission not granted, requesting...');
          LocationPermission newPermission = await Geolocator.requestPermission();
          debugPrint('📊 New location permission status: $newPermission');
          
          if (newPermission == LocationPermission.denied) {
            debugPrint('❌ User DENIED location permission');
          } else if (newPermission == LocationPermission.deniedForever) {
            debugPrint('❌ User DENIED location permission FOREVER');
          } else {
            debugPrint('✅ Location permission GRANTED: $newPermission');
          }
        } else {
          debugPrint('✅ Location permission already granted: $currentPermission');
          await Geolocator.requestPermission();
        }
      } catch (e) {
        debugPrint('❌ Error requesting location permission: $e');
      }
      
    } catch (e) {
      debugPrint('❌ Error initializing permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nami Florist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialBinding: InitialBinding(),
      getPages: AppRoutes.routes,
      initialRoute: AppRoutes.home, // ✅ GUNAKAN ROUTE, BUKAN home:
    );
  }
}
