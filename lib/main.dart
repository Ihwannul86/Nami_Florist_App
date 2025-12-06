// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';
import 'services/storage/shared_prefs_service.dart';
import 'services/storage/hive_service.dart';
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

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nami Florist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialBinding: InitialBinding(),
      getPages: AppRoutes.routes,
      home: isLoggedIn ? LandingPage() : const LoginPage(),
    );
  }
}
