import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  // ============================================================
  // SUCCESS
  // ============================================================

  static void success({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      icon: const Icon(
        Icons.check_circle_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: false,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
      titleText: const Text(
        '',
        style: TextStyle(fontSize: 0),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  static void error({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: false,
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
      titleText: const Text(
        '',
        style: TextStyle(fontSize: 0),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  static void info({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
      icon: const Icon(
        Icons.info_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: false,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
      titleText: const Text(
        '',
        style: TextStyle(fontSize: 0),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }
}