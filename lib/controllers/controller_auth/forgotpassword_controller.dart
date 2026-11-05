import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordController extends GetxController {
  final authService = AuthServices();

  final isLoading = false.obs;
  final isEmailSent = false.obs;
  final emailController = TextEditingController();

  Future<void> sendPasswordResetEmail() async {
    final email = emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter your email address.',
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter a valid email address.',
      );
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;

      debugPrint('Sending password recovery email to: $email');

      await authService.resetPasswordForEmail(email);

      isEmailSent.value = true;

      AppSnackbar.success(
        title: 'Reset Link Sent',
        message: 'Password reset link has been sent to $email.',
      );
    } on AuthException catch (e) {
      debugPrint('Supabase Reset Password Auth Exception: ${e.message}');

      AppSnackbar.error(
        title: 'Reset Failed',
        message: e.message,
      );
    } catch (e) {
      debugPrint('Reset Password Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while sending password reset email.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}