// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../views/auth/login_page.dart';
import '../views/home/landing_page.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;

  User? get currentUser => _authService.currentUser;

  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;

      final res = await _authService.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil, silakan login.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAll(() => const LoginPage());
      } else {
        Get.snackbar(
          'Gagal',
          'Registrasi gagal, coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final res = await _authService.signIn(
        email: email,
        password: password,
      );

      if (res.user != null) {
        Get.offAll(() => LandingPage());
      } else {
        Get.snackbar(
          'Gagal',
          'Email atau password salah.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.offAll(() => const LoginPage());
  }
}
