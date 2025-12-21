// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart'; // ✅ IMPORT LANGSUNG

import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';
import 'services/storage/shared_prefs_service.dart';
import 'services/storage/hive_service.dart';
import 'controllers/notification_controller.dart';
import 'firebase_options.dart';
import 'views/auth/login_page.dart';
import 'views/home/landing_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load ENV
  await dotenv.load(fileName: ".env");

  // Init SharedPreferences
  await SharedPrefsService.init();

  // Init Hive
  await HiveService.init();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Validasi ENV supaya tidak null
  final supabaseUrl = dotenv.env["SUPABASE_URL"];
  final supabaseKey = dotenv.env["SUPABASE_ANON_KEY"];

  if (supabaseUrl == null || supabaseKey == null) {
    debugPrint("❌ ERROR: SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan di .env");
  }

  // Init Supabase dengan pengecekan aman
  try {
    await Supabase.initialize(
      url: supabaseUrl ?? "",
      anonKey: supabaseKey ?? "",
    );
    debugPrint("✅ Supabase initialized successfully");
  } catch (e) {
    debugPrint("❌ ERROR INIT SUPABASE: $e");
  }

  // Cek login state
  final bool loggedIn = SharedPrefsService.getLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
}


class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  /// ✅ Initialize semua permissions SETELAH app build
  Future<void> _initializePermissions() async {
    // Delay untuk memastikan GetMaterialApp sudah ready
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // ══════════════════════════════════════════════════════════
      // 1️⃣ REQUEST NOTIFICATION PERMISSION
      // ══════════════════════════════════════════════════════════
      print('🔔 Step 1: Requesting NOTIFICATION permission...');
      Get.put(NotificationController());
      print('✅ NotificationController initialized');
      
      // Tunggu sampai notification permission selesai
      await Future.delayed(const Duration(seconds: 2));
      
      // ══════════════════════════════════════════════════════════
      // 2️⃣ REQUEST LOCATION PERMISSION (FORCE)
      // ══════════════════════════════════════════════════════════
      print('📍 Step 2: Requesting LOCATION permission...');
      
      // Cek status permission saat ini
      LocationPermission currentPermission = await Geolocator.checkPermission();
      print('📊 Current location permission status: $currentPermission');
      
      // Selalu request permission (akan muncul dialog jika belum granted)
      if (currentPermission == LocationPermission.denied || 
          currentPermission == LocationPermission.deniedForever) {
        print('⚠️ Location permission not granted, requesting...');
        LocationPermission newPermission = await Geolocator.requestPermission();
        print('📊 New location permission status: $newPermission');
        
        if (newPermission == LocationPermission.denied) {
          print('❌ User DENIED location permission');
        } else if (newPermission == LocationPermission.deniedForever) {
          print('❌ User DENIED location permission FOREVER');
        } else {
          print('✅ Location permission GRANTED: $newPermission');
        }
      } else {
        print('✅ Location permission already granted: $currentPermission');
        // Jika sudah granted sebelumnya, tetap panggil sekali lagi untuk memastikan
        // (ini tidak akan muncul dialog lagi)
        await Geolocator.requestPermission();
      }
      
    } catch (e) {
      print('❌ Error initializing permissions: $e');
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
      home: widget.isLoggedIn ? LandingPage() : const LoginPage(),
    );
  }
}
