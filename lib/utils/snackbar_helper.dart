import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  // 1. SUCCESS (Warna Hijau)
  static void success(String message, {String title = 'Success'}) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: const Color(0xFF2E7D32), // Hijau Sukses (Green 800)
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 28,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 6),
      shouldIconPulse: false,
    );
  }

  // 2. WARNING (Warna Kuning)
  static void warning(String message, {String title = 'Warning'}) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF5D4037),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF5D4037),
          fontSize: 14,
        ), // Teks gelap agar kontras dengan kuning
      ),
      backgroundColor: const Color(
        0xFFFBC02D,
      ), // Kuning Peringatan (Yellow 700)
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Color(0xFF5D4037),
        size: 28,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 6),
      shouldIconPulse: false,
    );
  }

  // 3. DANGER / ERROR (Warna Merah)
  static void danger(String message, {String title = 'Danger'}) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: const Color(0xFFC62828), // Merah Danger (Red 800)
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.white,
        size: 28,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 6),
      shouldIconPulse: false,
    );
  }
}
