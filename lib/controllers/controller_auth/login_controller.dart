import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/user_model.dart';
import 'package:docelix_mobileapp/services/auth_services.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  final authService = AuthServices();
  final dioClient = DioClient();
  final sessionManager = SessionManager();
  final RxBool rememberMe = false.obs;

  final isLoading = false.obs;
  bool _isProcessingLogin = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRememberedLogin();

    // Listen for OAuth sign-in completion (Google Login / Registration)
    authService.authStateChanges.listen(
          (data) async {
        final event = data.event;
        final session = data.session;

        debugPrint('========================================');
        debugPrint('SUPABASE AUTH EVENT');
        debugPrint('Event: $event');
        debugPrint('Session exists: ${session != null}');

        if (session != null) {
          debugPrint('User ID: ${session.user.id}');
          debugPrint('User Email: ${session.user.email}');
        }

        debugPrint('========================================');

        if (event == AuthChangeEvent.signedIn &&
            session != null &&
            !_isProcessingLogin) {
          debugPrint('Google authentication successful.');
          debugPrint('Calling _handlePostLogin()...');

          await _handlePostLogin(session);
        }
      },
      onError: (error) {
        debugPrint('Supabase Auth Listener Error: $error');
      },
    );
  }

  Future<void> loadRememberedLogin() async {
    try {
      final data = await SessionManager.getRememberMe();
      final remember = data['remember'] as bool? ?? false;

      if (remember) {
        emailController.text = data['email']?.toString() ?? '';
        passwordController.text = data['password']?.toString() ?? '';
        rememberMe.value = true;
      }
    } catch (e) {
      debugPrint('Load remembered login error: $e');
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // ======================================================
  // GOOGLE LOGIN / REGISTRATION
  // ======================================================

  Future<void> loginWithGoogle() async {
    if (isLoading.value || _isProcessingLogin) return;

    try {
      isLoading.value = true;

      debugPrint('========================================');
      debugPrint('LOGIN WITH GOOGLE');
      debugPrint('========================================');

      final bool success = await authService.signInWithGoogle();

      if (!success) {
        AppSnackbar.error(
          title: 'Google Sign In Failed',
          message: 'Unable to sign in with Google. Please try again.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Google Login Error: $e');
      debugPrint('StackTrace: $stackTrace');

      AppSnackbar.error(
        title: 'Google Sign In Failed',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /*Future<void> loginWithGoogle() async {
    if (isLoading.value || _isProcessingLogin) return;

    try {
      isLoading.value = true;

      final bool success = await authService.signInWithGoogle();

      if (!success) {
        AppSnackbar.error(
          title: 'Google Sign In Failed',
          message: 'Unable to start Google authentication.',
        );
      }

      // IMPORTANT:
      // Do not call _handlePostLogin() here.
      //
      // Google authentication happens outside the app.
      // After Google authentication, Supabase redirects
      // back to the mobile app using the deep link.
      //
      // authStateChanges listener in onInit()
      // will receive AuthChangeEvent.signedIn and
      // call _handlePostLogin().
    } catch (e) {
      debugPrint('Google Login Error: $e');

      AppSnackbar.error(
        title: 'Google Sign In Failed',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }*/

  // ======================================================
  // EMAIL / PASSWORD LOGIN
  // ======================================================

  void login() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error(
        title: 'Validation',
        message: 'Please enter email and password.',
      );
      return;
    }

    if (isLoading.value || _isProcessingLogin) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await authService.signInWithEmailPassword(
        email,
        password,
      );

      final Session? session = response.session;

      if (session == null) {
        AppSnackbar.error(
          title: 'Login Failed',
          message: 'Unable to create a session.',
        );
        return;
      }

      await _handlePostLogin(session, email: email, password: password);
    } on AuthException catch (e) {
      debugPrint('Supabase Auth Error: ${e.message}');

      final isInvalidCredentials = e.code == 'invalid_credentials';

      AppSnackbar.error(
        title: 'Login Failed',
        message: isInvalidCredentials
            ? 'Invalid credentials. Please check your email and password.'
            : e.message,
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Failed',
        message: 'Something went wrong: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ======================================================
  // COMMON POST LOGIN HANDLER
  // ======================================================

  Future<void> _handlePostLogin(
    Session session, {
    String? email,
    String? password,
  }) async
  {
    if (_isProcessingLogin) return;
    _isProcessingLogin = true;
    isLoading.value = true;

    try {
      final String accessToken = session.accessToken;

      final meResponse = await dioClient.getMe('/me', accessToken);

      if (meResponse.statusCode == 200) {
        if (email != null && password != null) {
          await SessionManager.saveRememberMe(
            remember: rememberMe.value,
            email: email,
            password: password,
          );
        }

        UserModel user = UserModel.fromJson(meResponse.data);

        final createdDate = user.createdAt != null
            ? DateTime.parse(user.createdAt!).toString().split(' ').first
            : '';

        final company = user.companies?.isNotEmpty == true
            ? user.companies!.first
            : null;

        await SessionManager.saveEmail(user.email ?? session.user.email ?? '');
        await SessionManager.saveAccessToken(accessToken);
        await SessionManager.saveCompanyid(company?.id ?? 0);
        await SessionManager.saveCompanyname(company?.name ?? '');
        await SessionManager.saveCorrencycode(company?.currencyCode ?? '');
        await SessionManager.saveRole(company?.myRole ?? '');
        await SessionManager.saveAccCreatedDate(createdDate);

        AppSnackbar.success(
          title: 'Success',
          message: 'Congratulations, you have successfully logged in',
        );

        Get.offAllNamed(
          '/LandScreen',
          arguments: meResponse.data,
        );
      } else {
        AppSnackbar.error(
          title: 'Login Failed',
          message: 'Unable to load user information.',
        );
      }
    } catch (e) {
      debugPrint('Post Login Error: $e');

      AppSnackbar.error(
        title: 'Login Failed',
        message: 'Unable to load user information. Please try again.',
      );
    } finally {
      isLoading.value = false;
      _isProcessingLogin = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}